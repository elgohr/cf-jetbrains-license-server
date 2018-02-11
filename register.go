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
	customer, serverUid := parseRegistrationData(bow, serverName)
	register(bow, customer, serverUrl, serverUid)
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
	if strings.Compare(bow.Title(), "JetBrains Account") != 0 {
		panic("Could not log in")
	}
}

func parseRegistrationData(
	bow *browser.Browser,
	serverName string) (string, string) {
	var customer string
	var serverUid string

	bow.Find("input[name=customer]").Each(func(_ int, f *goquery.Selection) {
		customer, _ = f.Attr("value")
	})
	bow.Find("label").Each(func(_ int, l *goquery.Selection) {
		if strings.Contains(l.Text(), serverName) {
			l.Find("input").Each(func(_ int, f *goquery.Selection) {
				value, _ := f.Attr("value")
				serverUid = value
			})
		}
	})
	if customer == "" || serverUid == "" {
		panic("Could not get registration data")
	}
	return customer, serverUid
}

func register(
	bow *browser.Browser,
	customer string,
	url string,
	serverUid string) {
	fmt.Printf("Registering - url(%s),serverUid(%s),customer(%s)", url, serverUid, customer)
	err := bow.Open(fmt.Sprintf("https://account.jetbrains.com/server-registration?customer=%s&url=%s&server_uid=%s", customer, url, serverUid))
	if err != nil {
		panic(err)
	}
}
