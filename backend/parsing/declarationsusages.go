package parsing

import (
	"fmt"
	"go/token"
)

type DeclarationsMap map[string]token.Position
type UsagesMap map[string][]token.Position


func (m *DeclarationsMap) Insert(name string, pos token.Position) {
	(*m)[name] = pos
}

func (m *DeclarationsMap) Print() {
	fmt.Println("Declarations")
	for k, v := range *m {
		fmt.Println(k, v)
	}
}

func NewDeclarationMap() *DeclarationsMap {
	return new(DeclarationsMap)
}

func (m *UsagesMap) Add(name string, pos token.Position) {
	lm := *m

	if _, ok := lm[name]; !ok {
		lm[name] = make([]token.Position, 0)
	}

	lm[name] = append(lm[name], pos)
}

func (m *UsagesMap) Print() {
	fmt.Println("Usages")
	for k, usages := range *m {
		fmt.Print(k + ": ")
		for _, usage := range usages {
			fmt.Print(usage)
			fmt.Print(" ")
		}

		fmt.Println()
	}
}
