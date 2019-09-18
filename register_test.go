package main

import (
	"fmt"
	"github.com/stretchr/testify/assert"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
	"time"
)

type TestCall struct {
	ExpectedQuery      string
	ExpectedFormValues map[string]string
	ExpectedMethod     string
	Response           string
	Called             bool
}

var (
	responses map[string]*TestCall
)

func TestRegistersTheServer(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		testCall := responses[r.URL.Path]
		r.ParseForm()
		if len(testCall.ExpectedFormValues) > 0 {
			for key, expectedValue := range testCall.ExpectedFormValues {
				realValue := r.FormValue(key)
				assert.Equal(t, expectedValue, realValue, r.URL.Path)
			}
		}
		assert.Equal(t, testCall.ExpectedQuery, r.URL.RawQuery)
		assert.Equal(t, testCall.ExpectedMethod, r.Method)
		testCall.Called = true
		w.Write([]byte(testCall.Response))
	}))
	defer ts.Close()

	backupHost := registrationHost
	registrationHost = ts.URL

	responses = map[string]*TestCall{
		"/": {
			ExpectedMethod: "GET",
			Response:       fmt.Sprintf(getPage("testdata/welcome.html"), ts.URL+"/auth"),
		},
		"/auth": {
			ExpectedMethod: "GET",
			Response:       getPage("testdata/authorize.html"),
		},
		"/authorize": {
			ExpectedMethod: "POST",
			ExpectedFormValues: map[string]string{
				"username": "USERNAME",
				"password": "PASSWORD",
			},
			ExpectedQuery: "_st=IyXkXxKLnkZX6uS3uFQ_7VaRhpLmRSOJtQng5pCLFfEm4xjJR3hvpEb8pu6slFb2",
			Response:      fmt.Sprintf(getPage("testdata/registrationData.html"), "SERVER_NAME"),
		},
		"/server-registration": {
			ExpectedMethod: "GET",
			ExpectedQuery:  fmt.Sprintf("customer=XYZcustomer&url=%s&server_uid=XYZserver", ts.URL),
		},
	}

	os.Args = []string{
		"",
		ts.URL,
		"USERNAME",
		"PASSWORD",
		"SERVER_NAME",
	}
	main()

	registrationHost = backupHost
	for path, expectation := range responses {
		assert.True(t, expectation.Called, "Didn't call "+path)
	}
}

func TestUsesJetBrainsHostForRegistration(t *testing.T) {
	assert.Equal(t, "https://account.jetbrains.com", registrationHost)
}

func TestStopsTryingAfterANumberOfTries(t *testing.T) {
	assert.Equal(t, maxTries, 60)

	reduceTriesForTest()
	defer func() { maxTries = 60 }()

	url := "http://127.0.0.1:8001"

	err := openServerSite(url)
	if err == nil {
		t.Error("Didn't exit as expected")
	}
}

func reduceTriesForTest() {
	maxTries = 2
}

func TestRetriesRegistration(t *testing.T) {
	var response string

	ts := &httptest.Server{
		Config: &http.Server{Handler: http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.Write([]byte(response))
		})},
	}
	defer ts.Close()

	address := "127.0.0.1:8085"
	url := "http://" + address
	response = fmt.Sprintf(getPage("testdata/welcome.html"), url)

	go func() {
		time.Sleep(2 * time.Second)
		l, err := net.Listen("tcp", address)
		if err != nil {
			log.Fatal("httptest: failed to listen")
		}
		ts.Listener = l
		ts.Start()
	}()

	assert.Eventually(t, func() bool {
		return openServerSite(url) == nil
	}, 10*time.Second, 1*time.Second)

}

func getPage(name string) string {
	page, _ := ioutil.ReadFile(name)
	return string(page)
}
