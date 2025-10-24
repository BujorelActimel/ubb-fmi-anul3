package lexer

import "fmt"

type TokenType int

const (
	EOF TokenType = iota
	ILLEGAL

	IDENTIFIER
	INT
	FLOAT
	STRING

	PACKAGE
	IMPORT
	CONST
	TYPE
	STRUCT
	FUNC
	VAR
	RETURN
	IF
	ELSE
	FOR

	PLUS        // +
	MINUS       // -
	ASTERISK    // *
	SLASH       // /
	PERCENT     // %
	AMPERSAND   // &
	EXCLAMATION // !

	ASSIGN       // =
	PLUS_ASSIGN  // +=
	MINUS_ASSIGN // -=
	MULT_ASSIGN  // *=
	DIV_ASSIGN   // /=
	MOD_ASSIGN   // %=
	SHORT_ASSIGN // :=

	EQ  // ==
	NEQ // !=
	LT  // <
	LTE // <=
	GT  // >
	GTE // >=

	AND // &&
	OR  // ||

	LPAREN    // (
	RPAREN    // )
	LBRACE    // {
	RBRACE    // }
	COMMA     // ,
	SEMICOLON // ;
	DOT       // .
	COLON     // :
)

var tokenNames = map[TokenType]string{
	EOF:     "EOF",
	ILLEGAL: "ILLEGAL",

	IDENTIFIER: "IDENTIFIER",
	INT:        "INT",
	FLOAT:      "FLOAT",
	STRING:     "STRING",

	PACKAGE: "PACKAGE",
	IMPORT:  "IMPORT",
	CONST:   "CONST",
	TYPE:    "TYPE",
	STRUCT:  "STRUCT",
	FUNC:    "FUNC",
	VAR:     "VAR",
	RETURN:  "RETURN",
	IF:      "IF",
	ELSE:    "ELSE",
	FOR:     "FOR",

	PLUS:        "PLUS",
	MINUS:       "MINUS",
	ASTERISK:    "ASTERISK",
	SLASH:       "SLASH",
	PERCENT:     "PERCENT",
	AMPERSAND:   "AMPERSAND",
	EXCLAMATION: "EXCLAMATION",

	ASSIGN:       "ASSIGN",
	PLUS_ASSIGN:  "PLUS_ASSIGN",
	MINUS_ASSIGN: "MINUS_ASSIGN",
	MULT_ASSIGN:  "MULT_ASSIGN",
	DIV_ASSIGN:   "DIV_ASSIGN",
	MOD_ASSIGN:   "MOD_ASSIGN",
	SHORT_ASSIGN: "SHORT_ASSIGN",

	EQ:  "EQ",
	NEQ: "NEQ",
	LT:  "LT",
	LTE: "LTE",
	GT:  "GT",
	GTE: "GTE",

	AND: "AND",
	OR:  "OR",

	LPAREN:    "LPAREN",
	RPAREN:    "RPAREN",
	LBRACE:    "LBRACE",
	RBRACE:    "RBRACE",
	COMMA:     "COMMA",
	SEMICOLON: "SEMICOLON",
	DOT:       "DOT",
	COLON:     "COLON",
}

var keywords = map[string]TokenType{
	"package": PACKAGE,
	"import":  IMPORT,
	"const":   CONST,
	"type":    TYPE,
	"struct":  STRUCT,
	"func":    FUNC,
	"var":     VAR,
	"return":  RETURN,
	"if":      IF,
	"else":    ELSE,
	"for":     FOR,
	"int":     IDENTIFIER,
	"float32": IDENTIFIER,
	"float64": IDENTIFIER,
	"string":  IDENTIFIER,
	"bool":    IDENTIFIER,
}

type Token struct {
	Type    TokenType
	Literal string
	Line    int
	Column  int
}

func (t Token) String() string {
	typeName := tokenNames[t.Type]
	if typeName == "" {
		typeName = fmt.Sprintf("UNKNOWN(%d)", t.Type)
	}
	return fmt.Sprintf("Token{Type: %s, Literal: %q, Line: %d, Column: %d}",
		typeName, t.Literal, t.Line, t.Column)
}

func LookupIdentifier(ident string) TokenType {
	if tok, ok := keywords[ident]; ok {
		return tok
	}
	return IDENTIFIER
}

func GetTokenName(t TokenType) string {
	return tokenNames[t]
}
