package main

import (
	"fmt"
	"io/ioutil"
	"net"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
	"time"
)

type TestCall struct {
	ExpectedUrl    string
	ExpectedQuery  string
	ExpectedMethod string
	Response       string
}

var (
	responses []TestCall
	pageCount = 0
)

func TestRegistersTheServer(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if pageCount < len(responses) {
			testCall := responses[pageCount]
			if r.URL.Path != testCall.ExpectedUrl {
				t.Errorf("Expected different url: Expected %s, but got %s", testCall.ExpectedUrl, r.URL.Path)
			}
			if r.URL.RawQuery != testCall.ExpectedQuery {
				t.Errorf("Expected different query: Expected %s, but got %s", testCall.ExpectedQuery, r.URL.RawQuery)
			}
			if r.Method != testCall.ExpectedMethod {
				t.Errorf("Expected different method: Expected %s, but got %s", testCall.ExpectedMethod, r.Method)
			}
			w.Write([]byte(testCall.Response))
			pageCount++
		} else {
			w.WriteHeader(-1)
		}
	}))
	defer ts.Close()

	backupHost := registrationHost
	registrationHost = ts.URL

	responses = []TestCall{
		{
			ExpectedUrl:    "/",
			ExpectedMethod: "GET",
			Response:       fmt.Sprintf(getPage("testdata/welcome.html"), ts.URL),
		}, {
			ExpectedUrl:    "/",
			ExpectedMethod: "GET",
			Response:       getPage("testdata/authorize.html"),
		}, {
			ExpectedUrl:    "/authorize",
			ExpectedMethod: "GET",
			ExpectedQuery:  "password=PASSWORD&username=USERNAME",
			Response:       fmt.Sprintf(getPage("testdata/registrationData.html"), "SERVER_NAME"),
		}, {
			ExpectedUrl:    "/server-registration",
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
}

func TestUsesJetBrainsHostForRegistration(t *testing.T) {
	if registrationHost != "https://account.jetbrains.com" {
		t.Error("Expected registration to happen against https://account.jetbrains.com")
	}
}

func TestRetriesRegistration(t *testing.T) {
	var response string

	address := "127.0.0.1:8000"

	ts := &httptest.Server{
		Config: &http.Server{Handler: http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.Write([]byte(response))
		})},
	}

	url := "http://" + address

	response = fmt.Sprintf(getPage("testdata/welcome.html"), url)

	go func() {
		time.Sleep(2 * time.Second)
		l, err := net.Listen("tcp", address)
		if err != nil {
			panic("httptest: failed to listen")
		}
		ts.Listener = l
		ts.Start()
	}()

	openServerSite(url)
	ts.Close()
}

func TestStopsTryingAfterANumberOfTries(t *testing.T) {
	if maxTries != 60 {
		t.Error("Number of tries not as expected")
	}
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

func getPage(name string) string {
	page, _ := ioutil.ReadFile(name)
	return string(page)
}
