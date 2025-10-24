package analyzer

import (
	"Lab1/lexer"
	"fmt"
)

type Analyzer struct {
	tokens      []lexer.Token
	symbolTable *SymbolTable
	fip         *FIP
	errors      []string
}

func NewAnalyzer(tokens []lexer.Token) *Analyzer {
	return &Analyzer{
		tokens:      tokens,
		symbolTable: NewSymbolTable(),
		fip:         NewFIP(),
		errors:      make([]string, 0),
	}
}

func (a *Analyzer) Analyze() {
	a.checkBracketMatching()

	for i := 0; i < len(a.tokens); i++ {
		tok := a.tokens[i]

		if tok.Type == lexer.ILLEGAL {
			a.errors = append(a.errors,
				fmt.Sprintf("Line %d, Column %d: Illegal character: %s",
					tok.Line, tok.Column, tok.Literal))
		}

		a.checkSyntaxErrors(i)

		var entry FIPEntry
		entry.TokenType = tok.Type

		switch tok.Type {
		case lexer.IDENTIFIER, lexer.INT, lexer.FLOAT, lexer.STRING:
			a.symbolTable.Add(tok.Literal)
			entry.Symbol = tok.Literal
		default:
			entry.Symbol = ""
		}

		a.fip.AddEntry(entry)
	}
}

func (a *Analyzer) checkSyntaxErrors(i int) {
	if i >= len(a.tokens) {
		return
	}

	tok := a.tokens[i]

	if (tok.Type == lexer.INT || tok.Type == lexer.FLOAT) && i+2 < len(a.tokens) {
		next := a.tokens[i+1]
		afterNext := a.tokens[i+2]

		if next.Type == lexer.DOT && (afterNext.Type == lexer.INT || afterNext.Type == lexer.FLOAT) {
			a.errors = append(a.errors,
				fmt.Sprintf("Line %d, Column %d: Invalid number literal: malformed numeric sequence '%s.%s'",
					tok.Line, tok.Column, tok.Literal, afterNext.Literal))
		}
	}

	if a.isOperator(tok.Type) && i+1 < len(a.tokens) {
		next := a.tokens[i+1]
		if tok.Type == lexer.PLUS && next.Type == lexer.PLUS {
			a.errors = append(a.errors,
				fmt.Sprintf("Line %d, Column %d: Invalid operator sequence: '++'",
					tok.Line, tok.Column))
		}
		if tok.Type == lexer.MINUS && next.Type == lexer.MINUS {
			a.errors = append(a.errors,
				fmt.Sprintf("Line %d, Column %d: Invalid operator sequence: '--'",
					tok.Line, tok.Column))
		}
	}

	if tok.Type == lexer.ASSIGN && i > 0 {
		prev := a.tokens[i-1]
		if prev.Type != lexer.IDENTIFIER && prev.Type != lexer.RBRACE {
			a.errors = append(a.errors,
				fmt.Sprintf("Line %d, Column %d: Invalid assignment: left side must be an identifier",
					tok.Line, tok.Column))
		}
	}

	if tok.Type == lexer.DOT && i+1 < len(a.tokens) {
		next := a.tokens[i+1]
		if next.Type == lexer.DOT {
			a.errors = append(a.errors,
				fmt.Sprintf("Line %d, Column %d: Invalid syntax: consecutive dots '..'",
					tok.Line, tok.Column))
		}
	}
}

func (a *Analyzer) isOperator(t lexer.TokenType) bool {
	return t == lexer.PLUS || t == lexer.MINUS || t == lexer.ASTERISK ||
		t == lexer.SLASH || t == lexer.PERCENT || t == lexer.ASSIGN ||
		t == lexer.EQ || t == lexer.NEQ || t == lexer.LT ||
		t == lexer.LTE || t == lexer.GT || t == lexer.GTE ||
		t == lexer.AND || t == lexer.OR
}

func (a *Analyzer) checkBracketMatching() {
	type bracket struct {
		tokenType lexer.TokenType
		line      int
		column    int
	}

	stack := make([]bracket, 0)

	for _, tok := range a.tokens {
		switch tok.Type {
		case lexer.LPAREN, lexer.LBRACE:
			stack = append(stack, bracket{tok.Type, tok.Line, tok.Column})

		case lexer.RPAREN:
			if len(stack) == 0 {
				a.errors = append(a.errors,
					fmt.Sprintf("Line %d, Column %d: Unmatched closing parenthesis ')'",
						tok.Line, tok.Column))
			} else {
				last := stack[len(stack)-1]
				if last.tokenType != lexer.LPAREN {
					a.errors = append(a.errors,
						fmt.Sprintf("Line %d, Column %d: Mismatched brackets: expected '}' but found ')'",
							tok.Line, tok.Column))
				}
				stack = stack[:len(stack)-1]
			}

		case lexer.RBRACE:
			if len(stack) == 0 {
				a.errors = append(a.errors,
					fmt.Sprintf("Line %d, Column %d: Unmatched closing brace '}'",
						tok.Line, tok.Column))
			} else {
				last := stack[len(stack)-1]
				if last.tokenType != lexer.LBRACE {
					a.errors = append(a.errors,
						fmt.Sprintf("Line %d, Column %d: Mismatched brackets: expected ')' but found '}'",
							tok.Line, tok.Column))
				}
				stack = stack[:len(stack)-1]
			}
		}
	}

	for _, b := range stack {
		bracketName := "("
		if b.tokenType == lexer.LBRACE {
			bracketName = "{"
		}
		a.errors = append(a.errors,
			fmt.Sprintf("Line %d, Column %d: Unclosed bracket '%s'",
				b.line, b.column, bracketName))
	}
}

func (a *Analyzer) GetSymbolTable() *SymbolTable {
	return a.symbolTable
}

func (a *Analyzer) GetFIP() *FIP {
	return a.fip
}

func (a *Analyzer) GetErrors() []string {
	return a.errors
}

func (a *Analyzer) HasErrors() bool {
	return len(a.errors) > 0
}
