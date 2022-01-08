package main

import (
	"github.com/headzoo/surf"
	"io/ioutil"
	"log"
	"os"
)

var (
	browse           = surf.NewBrowser()
	versionFile      = "currentVersion.txt"
	registrationHost = "https://www.jetbrains.com/help/license_server/release_notes.html"
)

func main() {
	if err := browse.Open(registrationHost); err != nil {
		log.Fatalln(err)
	}
	currentVersion, err := ioutil.ReadFile("currentVersion.txt")
	if err != nil {
		log.Fatalln(err)
	}
	latestBuildVersion, err := browse.Find("h3").Eq(1).Html()
	if err != nil {
		log.Fatalln(err)
	}
	if string(currentVersion) != latestBuildVersion {
		if err := ioutil.WriteFile(versionFile, []byte(latestBuildVersion), os.ModePerm); err != nil {
			log.Fatalln(err)
		}
		println("::set-output name=changed::true")
		println("::set-output name=version::" + latestBuildVersion)
	} else {
		println("::set-output name=changed::false")
	}
}
