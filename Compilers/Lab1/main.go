package main

import (
	"Lab1/lexer"
	"fmt"
	"os"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: lexer <source-file>")
		os.Exit(1)
	}

	filename := os.Args[1]
	content, err := os.ReadFile(filename)
	if err != nil {
		fmt.Printf("Error reading file: %v\n", err)
		os.Exit(1)
	}

	l := lexer.New(string(content))

	fmt.Printf("Tokenizing file: %s:\n\n", filename)

	for {
		tok := l.NextToken()
		fmt.Println(tok)

		if tok.Type == lexer.EOF {
			break
		}
	}
}
