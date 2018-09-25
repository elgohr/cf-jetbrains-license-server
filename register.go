package main

import (
	"fmt"
	"github.com/PuerkitoBio/goquery"
	"github.com/headzoo/surf"
	"log"
	"os"
	"strings"
	"time"
)

var (
	browse           = surf.NewBrowser()
	maxTries         = 60
	tries            = 0
	registrationHost = "https://account.jetbrains.com"
)

func main() {
	serverUrl := os.Args[1]
	username := os.Args[2]
	password := os.Args[3]
	serverName := os.Args[4]

	err := openServerSite(serverUrl)
	if err != nil {
		panic(err)
	}
	login(username, password)
	customer, serverUid := parseRegistrationData(serverName)
	register(customer, serverUrl, serverUid)
}

func openServerSite(serverUrl string) error {
	var retryOrFail = func(
		serverUrl string,
		err error,
	) error {
		if tries <= maxTries {
			time.Sleep(2 * time.Second)
			tries++
			return openServerSite(serverUrl)
		} else {
			return err
		}
	}

	err := browse.Open(serverUrl)
	if err != nil {
		return retryOrFail(serverUrl, err)
	}
	err = browse.Click(".btn")
	if err != nil {
		return retryOrFail(serverUrl, err)
	}
	return nil
}

func login(
	username string,
	password string,
) {
	login, err := browse.Form("form[action='/authorize']")
	if err != nil {
		panic(err)
	}
	login.Input("username", username)
	login.Input("password", password)
	err = login.Submit()
	if err != nil {
		panic(err)
	}
	if strings.Compare(browse.Title(), "JetBrains Account") != 0 {
		panic("Could not log in")
	}
}

func parseRegistrationData(
	serverName string,
) (
	string,
	string,
) {
	var (
		customer  string
		serverUid string
	)

	browse.Find("input[name=customer]").Each(func(_ int, f *goquery.Selection) {
		customer, _ = f.Attr("value")
	})
	browse.Find("label").Each(func(_ int, l *goquery.Selection) {
		if strings.Contains(l.Text(), serverName) {
			l.Find("input").Each(func(_ int, f *goquery.Selection) {
				serverUid, _ = f.Attr("value")
			})
		}
	})
	if customer == "" || serverUid == "" {
		panic("Could not get registration data")
	}
	return customer, serverUid
}

func register(
	customer string,
	url string,
	serverUid string,
) {
	log.Printf("Registering - url(%s),serverUid(%s),customer(%s)", url, serverUid, customer)
	registrationUrl := fmt.Sprintf("%s/server-registration?customer=%s&url=%s&server_uid=%s", registrationHost, customer, url, serverUid)
	err := browse.Open(registrationUrl)
	if err != nil {
		panic(err)
	}
}
