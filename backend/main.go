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

	res := make(map[string]interface{})
	res["data"] = linesList

	jsonData, err := json.Marshal(res)
	checkErr(err)

	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

	_, _ = w.Write(jsonData)
}
