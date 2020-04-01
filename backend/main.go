package main

import (
	"encoding/json"
	"fmt"
	"github.com/alecthomas/chroma"
	"github.com/alecthomas/chroma/lexers"
	"io/ioutil"
	"net/http"
	"os"
	"os/exec"
	"path"
	"path/filepath"
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

func getTokens(source string) ([]chroma.Token, error) {
	lexer := lexers.Get("go")

	iterator, err := lexer.Tokenise(nil, source)
	if err != nil {
		return nil, err
	}

	tokens := replaceTabsForSpaces(iterator.Tokens())
	fmt.Println(tokens)

	return tokens, nil
}

func replaceTabsForSpaces(tokens []chroma.Token) []chroma.Token {
	res := make([]chroma.Token, 0)

	for _, t := range tokens {
		if t.Value == "\t" {
			t.Value = "    "
		}

		res = append(res, t)
	}

	return res
}

const repo = "https://gitlab.com/afruizc/wogiki"

type FileData struct {
	FilePath string         `json:"path"`
	Content  []chroma.Token `json:"content"`
}


type FileMap map[string][]byte

func readFile(path string) ([]byte, error) {
	return ioutil.ReadFile(path)
}

func isGolangFile(info os.FileInfo) bool {
	return !info.IsDir() && strings.HasSuffix(info.Name(), ".go")
}

func (fm *FileMap) walk(path string, info os.FileInfo, err error) error {
	if err != nil {
		return err
	}

	if ! isGolangFile(info) {
		return nil
	}

	fmt.Println("adding name", path)

	contents, err := readFile(path)
	if err != nil {
		return err
	}

	(*fm)[strings.TrimPrefix(path, os.TempDir())] = contents
	return nil
}

func getLocalFileName(localDir, repo string) string {
	_, repoName := path.Split(repo)

	return path.Join(localDir, repoName)
}

func pathExists(path string) bool {
	if _, err := os.Stat(path); os.IsNotExist(err) {
		return false
	}
	return true
}

func downloadFromGit(repo string) {
	if err := os.Chdir(os.TempDir()); err != nil {
		panic(err)
	}

	cmd := exec.Command("git", "clone", repo)
	if err := cmd.Run(); err != nil {
		panic(err)
	}
}

func getFiles(repoDir string) FileMap {
	localFileName := getLocalFileName(os.TempDir(), repoDir)

	if ! pathExists(localFileName) {
		downloadFromGit(repo)
	}

	fm := make(FileMap)
	fmt.Println("starting to walk", localFileName)

	if err := filepath.Walk(localFileName, fm.walk); err != nil {
		panic(err)
	}

	return fm
}

func HelloServer(w http.ResponseWriter, r *http.Request) {
	dataMap := getFiles(repo)

	res := make(map[string]interface{})
	allFiles := make([]FileData, 0)

	for k, v := range dataMap {
		tokens, err := getTokens(string(v))
		checkErr(err)

		fileData := FileData{FilePath: k, Content: tokens}
		allFiles = append(allFiles, fileData)
	}

	res["data"] = allFiles

	jsonData, err := json.Marshal(res)
	checkErr(err)

	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers",
		"Content-Type")

	_, _ = w.Write(jsonData)
	fmt.Println(string(jsonData))
}
