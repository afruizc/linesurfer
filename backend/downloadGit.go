package main

import (
	"github.com/alecthomas/chroma"
	"io/ioutil"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"strings"
)

type FileData struct {
	FilePath string         `json:"path"`
	Content  []chroma.Token `json:"content"`
}

type FileMap map[string][]byte

func isGolangFile(info os.FileInfo) bool {
	return !info.IsDir() && strings.HasSuffix(info.Name(), ".go")
}

func isElmFile(info os.FileInfo) bool {
	return !info.IsDir() && strings.HasSuffix(info.Name(), ".elm")
}

func (fm *FileMap) walk(path string, info os.FileInfo, err error) error {
	if err != nil {
		return err
	}

	if ! isGolangFile(info) {
		return nil
	}

	contents, err := ioutil.ReadFile(path)
	if err != nil {
		return err
	}

	(*fm)[strings.TrimPrefix(path, os.TempDir())] = contents
	return nil
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

func GetFiles(repo string) FileMap {
	localFileName := getLocalFileName(os.TempDir(), repo)

	if ! pathExists(localFileName) {
		downloadFromGit(repo)
	}

	fm := make(FileMap)

	if err := filepath.Walk(localFileName, fm.walk); err != nil {
		panic(err)
	}

	return fm
}
