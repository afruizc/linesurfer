package main

import (
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
	"linesurfer-backend/parsing"
)

func main() {

	//	src := `package foo
	//
	//import (
	//	"fmt"
	//	"time"
	//)
	//
	//type Visitor struct {
	//	declarations map[string]string
	//}
	//
	//func bar() {
	//	fmt.Println("abc")
	//}`

	walker := newVisitor()
	// Parse src but stop after processing the imports.
	f, err := parser.ParseFile(walker.fset,
		"./small.go", nil, parser.AllErrors)
	if err != nil {
		fmt.Println(err)
		return
	}

	ast.Walk(walker, f)

	walker.printData()
}

func newVisitor() *Visitor {
	fset := token.NewFileSet() // positions are relative to fset

	declarations := make(map[string]token.Position)
	usages := make(map[string][]token.Position)

	return &Visitor{
		declarations: declarations,
		usages:       usages,
		fset:         fset,
	}
}

type Visitor struct {
	declarations parsing.DeclarationsMap
	usages       parsing.UsagesMap
	fset         *token.FileSet
}

func (v Visitor) Visit(n ast.Node) ast.Visitor {
	if n == nil {
		return nil
	}

	switch d := n.(type) {
	case *ast.AssignStmt:
		if d.Tok != token.DEFINE {
			return v
		}

		v.processAssign(d)
	case *ast.GenDecl:
		if d.Tok != token.VAR &&
			d.Tok != token.TYPE {
			return v
		}

		v.processGenDecl(d)
	case *ast.FuncDecl:
		ast.Print(v.fset, d)
		v.declarations.Insert(d.Name.Name,
			v.fset.Position(d.Name.NamePos))

	case *ast.CallExpr:
		if ident, ok := d.Fun.(*ast.Ident); ok {
			v.usages.Add(ident.Name, v.fset.Position(ident.NamePos))
		}

	default:
		//ast.Print(v.fset, d)
	}

	return v
}

func (v *Visitor) processGenDecl(d *ast.GenDecl) {
	for _, spec := range d.Specs {
		switch vv := spec.(type) {
		case *ast.ValueSpec:
			for _, name := range vv.Names {
				if name.Name == "_" {
					continue
				}

				v.declarations.Insert(
					name.Name,
					v.fset.Position(vv.Pos()))
			}
		case *ast.TypeSpec:
			v.declarations.Insert(
				vv.Name.Name,
				v.fset.Position(vv.Pos()))
		}
	}
}

func (v *Visitor) processAssign(d *ast.AssignStmt) {
	for _, name := range d.Lhs {
		if ident, ok := name.(*ast.Ident); ok {
			v.declarations.Insert(
				ident.Name,
				v.fset.Position(ident.NamePos))
		}
	}
}

func (v *Visitor) printData() {
	v.declarations.Print()
	v.usages.Print()
}
