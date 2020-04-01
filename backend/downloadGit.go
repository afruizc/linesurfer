package main

import (
	"fmt"
)


func printFiles(fileMap FileMap) {
	for k, v := range fileMap {
		fmt.Println(k)
		fmt.Println(string(v[:10]))
	}
}
