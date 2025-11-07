package lexer

import (
	"unicode"

	"github.com/bujor/compilers/shared/automaton"
)

type Lexer struct {
	input        string
	position     int
	readPosition int
	ch           byte
	line         int
	column       int

	identifierFA *automaton.FiniteAutomaton
	integerFA    *automaton.FiniteAutomaton
	floatFA      *automaton.FiniteAutomaton
}

func New(input string) *Lexer {
	l := &Lexer{
		input:  input,
		line:   1,
		column: 0,
	}
	l.readChar()
	return l
}

func NewWithAutomata(input string, identifierFA, integerFA, floatFA *automaton.FiniteAutomaton) *Lexer {
	l := &Lexer{
		input:        input,
		line:         1,
		column:       0,
		identifierFA: identifierFA,
		integerFA:    integerFA,
		floatFA:      floatFA,
	}
	l.readChar()
	return l
}

func (l *Lexer) readChar() {
	if l.readPosition >= len(l.input) {
		l.ch = 0
	} else {
		l.ch = l.input[l.readPosition]
	}
	l.position = l.readPosition
	l.readPosition++
	l.column++
}

func (l *Lexer) peekChar() byte {
	if l.readPosition >= len(l.input) {
		return 0
	}
	return l.input[l.readPosition]
}

func (l *Lexer) NextToken() Token {
	var tok Token

	l.skipWhitespace()

	tok.Line = l.line
	tok.Column = l.column

	switch l.ch {
	case '=':
		if l.peekChar() == '=' {
			ch := l.ch
			l.readChar()
			tok = Token{Type: EQ, Literal: string(ch) + string(l.ch), Line: tok.Line, Column: tok.Column}
		} else {
			tok = Token{Type: ASSIGN, Literal: string(l.ch), Line: tok.Line, Column: tok.Column}
		}
	case '+':
		if l.peekChar() == '=' {
			ch := l.ch
			l.readChar()
			tok = Token{Type: PLUS_ASSIGN, Literal: string(ch) + string(l.ch), Line: tok.Line, Column: tok.Column}
		} else if l.peekChar() == '+' {
			ch := l.ch
			l.readChar()
			tok = Token{Type: PLUS_ASSIGN, Literal: string(ch) + string(l.ch), Line: tok.Line, Column: tok.Column}
		} else {
			tok = Token{Type: PLUS, Literal: string(l.ch), Line: tok.Line, Column: tok.Column}
		}
	case '-':
		if l.peekChar() == '=' {
			ch := l.ch
			l.readChar()
			tok = Token{Type: MINUS_ASSIGN, Literal: string(ch) + string(l.ch), Line: tok.Line, Column: tok.Column}
		} else {
			tok = Token{Type: MINUS, Literal: string(l.ch), Line: tok.Line, Column: tok.Column}
		}
	case '*':
		if l.peekChar() == '=' {
			ch := l.ch
			l.readChar()
			tok = Token{Type: MULT_ASSIGN, Literal: string(ch) + string(l.ch), Line: tok.Line, Column: tok.Column}
		} else {
			tok = Token{Type: ASTERISK, Literal: string(l.ch), Line: tok.Line, Column: tok.Column}
		}
	case '/':
		if l.peekChar() == '=' {
			ch := l.ch
			l.readChar()
			tok = Token{Type: DIV_ASSIGN, Literal: string(ch) + string(l.ch), Line: tok.Line, Column: tok.Column}
		} else if l.peekChar() == '/' {
			l.skipLineComment()
			return l.NextToken()
		} else if l.peekChar() == '*' {
			l.skipBlockComment()
			return l.NextToken()
		} else {
			tok = Token{Type: SLASH, Literal: string(l.ch), Line: tok.Line, Column: tok.Column}
		}
	case '%':
		if l.peekChar() == '=' {
			ch := l.ch
			l.readChar()
			tok = Token{Type: MOD_ASSIGN, Literal: string(ch) + string(l.ch), Line: tok.Line, Column: tok.Column}
		} else {
			tok = Token{Type: PERCENT, Literal: string(l.ch), Line: tok.Line, Column: tok.Column}
		}
	case '!':
		if l.peekChar() == '=' {
			ch := l.ch
			l.readChar()
			tok = Token{Type: NEQ, Literal: string(ch) + string(l.ch), Line: tok.Line, Column: tok.Column}
		} else {
			tok = Token{Type: EXCLAMATION, Literal: string(l.ch), Line: tok.Line, Column: tok.Column}
		}
	case '<':
		if l.peekChar() == '=' {
			ch := l.ch
			l.readChar()
			tok = Token{Type: LTE, Literal: string(ch) + string(l.ch), Line: tok.Line, Column: tok.Column}
		} else {
			tok = Token{Type: LT, Literal: string(l.ch), Line: tok.Line, Column: tok.Column}
		}
	case '>':
		if l.peekChar() == '=' {
			ch := l.ch
			l.readChar()
			tok = Token{Type: GTE, Literal: string(ch) + string(l.ch), Line: tok.Line, Column: tok.Column}
		} else {
			tok = Token{Type: GT, Literal: string(l.ch), Line: tok.Line, Column: tok.Column}
		}
	case '&':
		if l.peekChar() == '&' {
			ch := l.ch
			l.readChar()
			tok = Token{Type: AND, Literal: string(ch) + string(l.ch), Line: tok.Line, Column: tok.Column}
		} else {
			tok = Token{Type: AMPERSAND, Literal: string(l.ch), Line: tok.Line, Column: tok.Column}
		}
	case '|':
		if l.peekChar() == '|' {
			ch := l.ch
			l.readChar()
			tok = Token{Type: OR, Literal: string(ch) + string(l.ch), Line: tok.Line, Column: tok.Column}
		} else {
			tok = Token{Type: ILLEGAL, Literal: string(l.ch), Line: tok.Line, Column: tok.Column}
		}
	case ':':
		if l.peekChar() == '=' {
			ch := l.ch
			l.readChar()
			tok = Token{Type: SHORT_ASSIGN, Literal: string(ch) + string(l.ch), Line: tok.Line, Column: tok.Column}
		} else {
			tok = Token{Type: COLON, Literal: string(l.ch), Line: tok.Line, Column: tok.Column}
		}
	case '(':
		tok = Token{Type: LPAREN, Literal: string(l.ch), Line: tok.Line, Column: tok.Column}
	case ')':
		tok = Token{Type: RPAREN, Literal: string(l.ch), Line: tok.Line, Column: tok.Column}
	case '{':
		tok = Token{Type: LBRACE, Literal: string(l.ch), Line: tok.Line, Column: tok.Column}
	case '}':
		tok = Token{Type: RBRACE, Literal: string(l.ch), Line: tok.Line, Column: tok.Column}
	case ',':
		tok = Token{Type: COMMA, Literal: string(l.ch), Line: tok.Line, Column: tok.Column}
	case ';':
		tok = Token{Type: SEMICOLON, Literal: string(l.ch), Line: tok.Line, Column: tok.Column}
	case '.':
		if l.floatFA != nil {
			remainingInput := l.input[l.position:]
			prefix, result := l.floatFA.LongestPrefix(remainingInput)
			if prefix != "" && result.Accepted {
				tok.Type = FLOAT
				tok.Literal = prefix
				for range prefix {
					l.readChar()
				}
				return tok
			}
		} else if isDigit(l.peekChar()) {
			tok.Type = FLOAT
			tok.Literal = l.readFloatStartingWithDot()
			return tok
		}
		tok = Token{Type: DOT, Literal: string(l.ch), Line: tok.Line, Column: tok.Column}
	case '"':
		tok.Type = STRING
		tok.Literal = l.readString()
		return tok
	case 0:
		tok = Token{Type: EOF, Literal: "", Line: tok.Line, Column: tok.Column}
	default:
		if isLetter(l.ch) || l.ch == '_' {
			if l.identifierFA != nil {
				remainingInput := l.input[l.position:]
				prefix, result := l.identifierFA.LongestPrefix(remainingInput)
				if prefix != "" && result.Accepted {
					tok.Literal = prefix
					tok.Type = LookupIdentifier(tok.Literal)
					for range prefix {
						l.readChar()
					}
					return tok
				}
			} else {
				tok.Literal = l.readIdentifier()
				tok.Type = LookupIdentifier(tok.Literal)
				return tok
			}
		} else if isDigit(l.ch) {
			if l.floatFA != nil && l.integerFA != nil {
				remainingInput := l.input[l.position:]

				floatPrefix, floatResult := l.floatFA.LongestPrefix(remainingInput)
				intPrefix, intResult := l.integerFA.LongestPrefix(remainingInput)

				testLiteral := l.peekNumberLike()

				if len(testLiteral) > len(floatPrefix) && len(testLiteral) > len(intPrefix) {
					tok.Type = ILLEGAL
					tok.Literal = testLiteral
					for range testLiteral {
						l.readChar()
					}
					return tok
				}

				if len(floatPrefix) > len(intPrefix) && floatResult.Accepted {
					tok.Type = FLOAT
					tok.Literal = floatPrefix
					for range floatPrefix {
						l.readChar()
					}
					return tok
				} else if intResult.Accepted {
					tok.Type = INT
					tok.Literal = intPrefix
					for range intPrefix {
						l.readChar()
					}

					if l.ch == '.' {
						testInput := intPrefix + string(l.input[l.position:])
						testFloatPrefix, testFloatResult := l.floatFA.LongestPrefix(testInput)

						nextChar := l.peekChar()
						if !testFloatResult.Accepted || len(testFloatPrefix) <= len(intPrefix) {
							if isDigit(nextChar) || nextChar == '_' || nextChar == 'e' || nextChar == 'E' {
								invalidLiteral := intPrefix + "."
								l.readChar() // consume '.'
								for isDigit(l.ch) || l.ch == '_' || l.ch == 'e' || l.ch == 'E' || l.ch == '+' || l.ch == '-' {
									invalidLiteral += string(l.ch)
									l.readChar()
								}
								return Token{Type: ILLEGAL, Literal: invalidLiteral, Line: tok.Line, Column: tok.Column}
							}
						}
					}

					return tok
				}
			} else {
				return l.readNumber(tok)
			}
		}
		tok = Token{Type: ILLEGAL, Literal: string(l.ch), Line: tok.Line, Column: tok.Column}
	}

	l.readChar()
	return tok
}

func (l *Lexer) skipWhitespace() {
	for l.ch == ' ' || l.ch == '\t' || l.ch == '\n' || l.ch == '\r' {
		if l.ch == '\n' {
			l.line++
			l.column = 0
		}
		l.readChar()
	}
}

func (l *Lexer) skipLineComment() {
	l.readChar()
	l.readChar()
	for l.ch != '\n' && l.ch != 0 {
		l.readChar()
	}
}

func (l *Lexer) skipBlockComment() {
	l.readChar()
	l.readChar()
	for {
		if l.ch == 0 {
			return
		}
		if l.ch == '*' && l.peekChar() == '/' {
			l.readChar()
			l.readChar()
			return
		}
		if l.ch == '\n' {
			l.line++
			l.column = 0
		}
		l.readChar()
	}
}

func (l *Lexer) readIdentifier() string {
	position := l.position
	for isLetter(l.ch) || isDigit(l.ch) || l.ch == '_' {
		l.readChar()
	}
	return l.input[position:l.position]
}

func (l *Lexer) readNumber(tok Token) Token {
	position := l.position
	isFloat := false

	for isDigit(l.ch) {
		l.readChar()
	}

	if l.ch == '.' && isDigit(l.peekChar()) {
		isFloat = true
		l.readChar()
		for isDigit(l.ch) {
			l.readChar()
		}
	} else if l.ch == '.' && l.peekChar() == '.' {
		tok.Type = INT
		tok.Literal = l.input[position:l.position]
		return tok
	} else if l.ch == '.' {
		isFloat = true
		l.readChar()
	}

	tok.Literal = l.input[position:l.position]
	if isFloat {
		tok.Type = FLOAT
	} else {
		tok.Type = INT
	}
	return tok
}

func (l *Lexer) readFloatStartingWithDot() string {
	position := l.position
	l.readChar()
	for isDigit(l.ch) {
		l.readChar()
	}
	return l.input[position:l.position]
}

func (l *Lexer) readString() string {
	position := l.position + 1
	l.readChar()

	result := ""
	for l.ch != '"' && l.ch != 0 && l.ch != '\n' {
		if l.ch == '\\' {
			l.readChar()
			switch l.ch {
			case 'n':
				result += "\n"
			case 't':
				result += "\t"
			case 'r':
				result += "\r"
			case '\\':
				result += "\\"
			case '"':
				result += "\""
			default:
				result += string('\\') + string(l.ch)
			}
			l.readChar()
		} else {
			result += string(l.ch)
			l.readChar()
		}
	}

	if l.ch != '"' {
		return l.input[position:l.position]
	}

	l.readChar()
	return result
}

func isLetter(ch byte) bool {
	return unicode.IsLetter(rune(ch))
}

func isDigit(ch byte) bool {
	return '0' <= ch && ch <= '9'
}

func (l *Lexer) peekNumberLike() string {
	pos := l.position

	for pos < len(l.input) && (isDigit(l.input[pos]) || l.input[pos] == '_') {
		pos++
	}

	if pos < len(l.input) && l.input[pos] == '.' {
		pos++
		for pos < len(l.input) && (isDigit(l.input[pos]) || l.input[pos] == '_') {
			pos++
		}
	}

	if pos < len(l.input) && (l.input[pos] == 'e' || l.input[pos] == 'E') {
		pos++
		if pos < len(l.input) && (l.input[pos] == '+' || l.input[pos] == '-') {
			pos++
		}
		for pos < len(l.input) && (isDigit(l.input[pos]) || l.input[pos] == '_') {
			pos++
		}
	}

	return l.input[l.position:pos]
}
