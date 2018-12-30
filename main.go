package main

import (
	"fmt"
	"os"

	"./epub"

	"github.com/urfave/cli"
)

func main() {
	app := cli.NewApp()

	app.Name = "eputlish"
	app.Usage = "This app conbine sequenced images to epub."
	app.Version = "0.0.1"

	app.Action = func(context *cli.Context) error {
		if context.Bool("cat") {
			fmt.Println(context.Args().Get(0) + "だにゃん♡")
		} else {
			epub.Eputlish()
		}
		return nil
	}

	app.Flags = []cli.Flag{
		cli.BoolFlag{
			Name:  "cat, c",
			Usage: "Echo with cat",
		},
	}

	app.Run(os.Args)
}
