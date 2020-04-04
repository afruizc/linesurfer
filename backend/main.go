package main

import (
	"encoding/json"
	"fmt"
	"github.com/alecthomas/chroma"
	"github.com/alecthomas/chroma/lexers"
	"net/http"
	"os"
	"strings"
)

func main1() {
	fmt.Println("Connect here, tmp:", os.TempDir())
	http.HandleFunc("/", HelloServer)
	if err := http.ListenAndServe(":8080", nil); err != nil {
		panic(err)
	}
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

	tokens := replaceTabsForSpaces(iterator.Tokens())

	return tokens, nil
}

func trimRightAndReturnCount(s string, sep string) (string, int) {
	count := 0
	for strings.HasSuffix(s, sep) {
		count += 1
		idx := strings.LastIndex(s, sep)
		s = s[:idx]
	}

	return s, count
}

func addToken(tokenList []chroma.Token, cur chroma.Token) []chroma.Token {
	cur.Value = strings.Replace(cur.Value, "\t", "    ", -1)

	if cur.Type != chroma.CommentSingle {
		tokenList = append(tokenList, cur)
		return tokenList
	}

	var count int
	cur.Value, count = trimRightAndReturnCount(cur.Value, "\n")
	tokenList = append(tokenList, cur)

	for count > 0 {

		tokenList = append(tokenList, chroma.Token{
			Type:  chroma.Text,
			Value: "\n"})

		count -= 1
	}

	return tokenList
}

func replaceTabsForSpaces(tokens []chroma.Token) []chroma.Token {
	res := make([]chroma.Token, 0)

	for _, t := range tokens {
		res = addToken(res, t)
	}

	return res
}

func HelloServer(w http.ResponseWriter, r *http.Request) {
	const repo = "https://github.com/afruizc/linesurfer"
	dataMap := GetFiles(repo)

	res := make(map[string]interface{})
	allFiles := make([]FileData, 0)

	for k, v := range dataMap {
		tokens, err := getTokens(string(v))
		checkErr(err)

		fileData := FileData{FilePath: k, Content: tokens}
		allFiles = append(allFiles, fileData)
	}

	res["declarations"] = allFiles

	jsonData, err := json.Marshal(res)
	checkErr(err)

	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers",
		"Content-Type")

	_, _ = w.Write(jsonData)
}
