package main

import (
	"encoding/json"
	"fmt"
	"github.com/alecthomas/chroma"
	"github.com/alecthomas/chroma/lexers"
	"io/ioutil"
	"net/http"
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

func getTokens(source string) ([]chroma.Token, error) {
	lexer := lexers.Get("go")

	iterator, err := lexer.Tokenise(nil, source)
	if err != nil {
		return nil, err
	}

	tokens := iterator.Tokens()
	fmt.Println(tokens)

	return tokens, nil
}

func HelloServer(w http.ResponseWriter, r *http.Request) {
	data, err := ioutil.ReadFile("main.go")
	checkErr(err)

	lines, err := getTokens(string(data))
	if err != nil {
		panic(err)
	}

	res := make(map[string]interface{})
	res["data"] = lines

	jsonData, err := json.Marshal(res)
	checkErr(err)

	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

	_, _ = w.Write(jsonData)
}
