package main

import (
	"Lab1/analyzer"
	"Lab1/lexer"
	"fmt"
	"os"
	"path/filepath"

	"github.com/bujor/compilers/shared/automaton"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: analyzer <source-file>")
		os.Exit(1)
	}

	filename := os.Args[1]
	content, err := os.ReadFile(filename)
	if err != nil {
		fmt.Printf("Error reading file: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Analyzing file: %s\n\n", filename)

	identifierFA, err := automaton.ParseFromFile("../shared/automaton/definitions/identifier.json")
	if err != nil {
		fmt.Printf("Error loading identifier automaton: %v\n", err)
		os.Exit(1)
	}

	integerFA, err := automaton.ParseFromFile("../shared/automaton/definitions/integer.json")
	if err != nil {
		fmt.Printf("Error loading integer automaton: %v\n", err)
		os.Exit(1)
	}

	floatFA, err := automaton.ParseFromFile("../shared/automaton/definitions/float.json")
	if err != nil {
		fmt.Printf("Error loading float automaton: %v\n", err)
		os.Exit(1)
	}

	l := lexer.NewWithAutomata(string(content), identifierFA, integerFA, floatFA)
	tokens := make([]lexer.Token, 0)

	for {
		tok := l.NextToken()
		tokens = append(tokens, tok)
		if tok.Type == lexer.EOF {
			break
		}
	}

	a := analyzer.NewAnalyzer(tokens)
	a.Analyze()

	if a.HasErrors() {
		fmt.Println("Lexical errors found:")
		for _, errMsg := range a.GetErrors() {
			fmt.Println("  " + errMsg)
		}
		os.Exit(1)
	}

	dir := filepath.Dir(filename)
	posMap := a.GetSymbolTable().GetPositionMap()

	fipPath := filepath.Join(dir, "fip.csv")
	if err := a.GetFIP().SaveToFile(fipPath, posMap); err != nil {
		fmt.Printf("Error writing FIP file: %v\n", err)
		os.Exit(1)
	}
	fmt.Printf("FIP saved to: %s\n", fipPath)

	tsPath := filepath.Join(dir, "ts.csv")
	if err := a.GetSymbolTable().SaveToFile(tsPath); err != nil {
		fmt.Printf("Error writing TS file: %v\n", err)
		os.Exit(1)
	}
	fmt.Printf("TS saved to: %s\n", tsPath)
}
