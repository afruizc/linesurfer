package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
)

func main() {
	fmt.Println("Connect here")
	http.HandleFunc("/", HelloServer)
	_ = http.ListenAndServe(":8080", nil)
}

func checkErr(err error) {
	if err != nil {
		panic(err)
	}
}

func splitLines(data []byte) []string {
	dataStr := string(data)

	return strings.Split(dataStr, "\n")
}

func HelloServer(w http.ResponseWriter, r *http.Request) {
	data, err := ioutil.ReadFile("main.go")
	checkErr(err)

	linesList := splitLines(data)

	jsonData, err := json.Marshal(linesList)
	checkErr(err)

	_, _ = w.Write(jsonData)
}
