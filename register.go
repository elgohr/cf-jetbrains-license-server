package main

import (
	"context"
	"fmt"
	"github.com/chromedp/chromedp"
	"log"
	"os"
	"strconv"
	"strings"
	"time"
)

func main() {
	serverUrl := os.Args[1]
	username := os.Args[2]
	password := os.Args[3]
	serverName := os.Args[4]

	ctx := getChromeDPContext()

	// create a timeout
	ctx, cancel := context.WithTimeout(ctx, 15*time.Second)
	defer cancel()

	login(ctx, serverUrl, username, password, serverName)

	selectCorrectServerAndConfirm(ctx, serverName)

	waitForServerPageToRender(ctx)

	log.Printf("Successfully registered to %s", serverName)
}

func getChromeDPContext() context.Context {
	headless := true
	if len(os.Args) > 5 {
		headlessArg, err := strconv.ParseBool(os.Args[5])
		if err != nil {
			log.Fatal(err)
		}
		headless = headlessArg
		println("Running in headless: ", headless)
	}
	opts := append(chromedp.DefaultExecAllocatorOptions[:],
		func(a *chromedp.ExecAllocator) {
			chromedp.Flag("headless", headless)(a)
		},
	)

	allocCtx, _ := chromedp.NewExecAllocator(context.Background(), opts...)

	ctx, _ := chromedp.NewContext(allocCtx)
	return ctx
}

func login(ctx context.Context, serverUrl string, username string, password string, serverName string) {
	err := chromedp.Run(ctx,
		chromedp.Navigate(serverUrl),
		chromedp.Click(`.btn`, chromedp.NodeVisible, chromedp.ByQuery),
		chromedp.Click(`button:nth-child(6)`, chromedp.NodeVisible, chromedp.ByQueryAll),
		chromedp.SendKeys(`#email`, username, chromedp.NodeVisible),
		chromedp.Click(`button:nth-child(2)`, chromedp.NodeVisible, chromedp.ByQueryAll),
		chromedp.SendKeys(`#password`, password, chromedp.NodeVisible),
		chromedp.Click(`button:nth-child(2)`, chromedp.NodeVisible, chromedp.ByQueryAll),
		chromedp.WaitVisible(`.btn`, chromedp.ByQuery),
		chromedp.Evaluate(
			fmt.Sprintf(`
				document.querySelectorAll('label:has(>input[type="radio"])').forEach(function (label) {
					if(label.innerText.includes("%s")) {label.click()};
				})`,
				serverName),
			nil),
	)

	if err != nil {
		log.Fatalf("Error logging in and selecting server: %s", err)
	}
}

func selectCorrectServerAndConfirm(ctx context.Context, serverName string) {
	var value string
	err := chromedp.Run(ctx,
		chromedp.TextContent(`label:has(>input[type="radio"]:checked)`, &value, chromedp.NodeVisible, chromedp.ByQuery),
	)

	if err != nil {
		log.Fatalf("Error validating correct server is selected: %s", err)
	}

	if !strings.Contains(value, serverName) {
		log.Fatalf("Server was not selected correctly was: %s, should be: %s", value, serverName)
	}

	err = chromedp.Run(ctx,
		chromedp.Click(`.btn`, chromedp.NodeVisible, chromedp.ByQuery),
	)

	if err != nil {
		log.Fatalf("Error clicking confirm button: %s", err)
	}
}

func waitForServerPageToRender(ctx context.Context) {
	var res string

	for {
		err := chromedp.Run(ctx,
			chromedp.TextContent(`h1`, &res, chromedp.NodeVisible, chromedp.ByQuery),
		)
		if err != nil {
			log.Fatalf("Error while waiting for Server page to show: %s", err)
		}
		if res == "Added Licenses" {
			break
		}
		time.Sleep(1 * time.Second) // wait before retrying
	}
}
