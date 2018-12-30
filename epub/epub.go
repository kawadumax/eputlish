package epub

import (
	"fmt"
	"os"
	"os/user"
	"strconv"
	"time"
)

func Hello() {
	fmt.Println("hello from epub")
}

func Eputlish() {
	initApp()
	fmt.Println("IMG_QUALITY(1~100) : ")
	fmt.Println("TITLE : ")
	var auther, _ = user.Current()
	var date = time.Now().Unix()
	var bookId string = "urn:uuid:" + strconv.FormatInt(date, 10) + "." + auther.Username + ".eputlish"
	var cnt = 0
}

func initApp() {
	// preserve original images
	if err := os.Mkdir("org", 0777); err != nil {
		fmt.Println(err)
	}
	if err := os.MkdirAll("epub/META-INF", 0777); err != nil {
		fmt.Println(err)
	}
	if err := os.MkdirAll("epub/OEBPS/image", 0777); err != nil {
		fmt.Println(err)
	}
}
