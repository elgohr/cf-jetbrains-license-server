package main

import (
	"fmt"
	"github.com/PuerkitoBio/goquery"
	"github.com/headzoo/surf/browser"
	"gopkg.in/headzoo/surf.v1"
	"os"
	"strings"
)

func main() {
	serverUrl := os.Args[1]
	username := os.Args[2]
	password := os.Args[3]
	serverName := os.Args[4]
	bow := surf.NewBrowser()

	login(bow, serverUrl, username, password)
	customer, url, serverUid := parseRegistrationData(bow, serverName)
	register(bow, customer, url, serverUid)
}

func login(
	bow *browser.Browser,
	serverUrl string,
	username string,
	password string) {

	err := bow.Open(serverUrl)
	if err != nil {
		panic(err)
	}
	bow.Click(".btn")
	login, err := bow.Form("form[action='/authorize']")
	if err != nil {
		panic(err)
	}
	login.Input("username", username)
	login.Input("password", password)
	err = login.Submit()
	if err != nil {
		panic(err)
	}
}

func parseRegistrationData(
	bow *browser.Browser,
	serverName string) (string, string, string) {
	var customer string
	var url string
	var serverUid string

	bow.Find("input").Each(func(_ int, f *goquery.Selection) {
		name, _ := f.Attr("name")
		value, _ := f.Attr("value")

		if strings.Compare(name, "customer") == 0 {
			customer = value
		}
		if strings.Compare(name, "url") == 0 {
			url = value
		}
	})
	bow.Find("label").Each(func(_ int, l *goquery.Selection) {
		if strings.Contains(l.Text(), serverName) {
			l.Find("input").Each(func(_ int, f *goquery.Selection) {
				value, _ := f.Attr("value")
				serverUid = value
			})
		}
	})
	if customer == "" || url == "" || serverUid == "" {
		panic("Could not get registration data")
	}
	return customer, url, serverUid
}

func register(
	bow *browser.Browser,
	customer string,
	url string,
	serverUid string) {

	err := bow.Open(fmt.Sprintf("https://account.jetbrains.com/server-registration?customer=%s&url=%s&server_uid=%s", customer, url, serverUid))
	if err != nil {
		panic(err)
	}
}
