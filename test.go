package main

import (
	"fmt"
	"net/http"
	"time"
)

const token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE0OTkxNjk1NjgsInN1YiI6IjFjN2IxNTk2LTkxYzEtNDU0ZS05M2IwLTA0ZThmYTU4MWQ5YiJ9.doSgiauZ5jfpG9x3UwmhHHbmhaXRCC-vAPUOXWu58Zw"

func main() {
	for i := 0; i < 5; i++ {
		go bla()
	}
	time.Sleep(5 * time.Second)
}

func bla() {
	c := &http.Client{}
	req, _ := http.NewRequest("GET", "http://127.0.0.1:9999/secure/", nil)
	req.Header.Add("Authorization", "Bearer "+token)
	res, err := c.Do(req)
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(res.StatusCode)
}
