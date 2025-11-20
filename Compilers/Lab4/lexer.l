%{
#include <stdio.h>
#include <string.h>
#include "parser.tab.h"

int column = 1;
int error_count = 0;
%}

%option yylineno
%option noyywrap
%option noinput
%option nounput

DIGIT       [0-9]
LETTER      [a-zA-Z]
IDENTIFIER  {LETTER}({LETTER}|{DIGIT}|_)*
INTEGER     ([1-9]{DIGIT}*)|0
FLOAT       ({DIGIT}*\.{DIGIT}+)|({DIGIT}+\.)
STRING      \"([^\"\n\\]|\\[ntr\\\"])*\"

%%

"package"       { column += yyleng; return PACKAGE; }
"import"        { column += yyleng; return IMPORT; }
"const"         { column += yyleng; return CONST; }
"type"          { column += yyleng; return TYPE; }
"struct"        { column += yyleng; return STRUCT; }
"func"          { column += yyleng; return FUNC; }
"var"           { column += yyleng; return VAR; }
"return"        { column += yyleng; return RETURN; }
"if"            { column += yyleng; return IF; }
"else"          { column += yyleng; return ELSE; }
"for"           { column += yyleng; return FOR; }
"int"           { column += yyleng; return INT; }
"float32"       { column += yyleng; return FLOAT32; }
"float64"       { column += yyleng; return FLOAT64; }
"string"        { column += yyleng; return STRING_TYPE; }
"bool"          { column += yyleng; return BOOL; }

"fmt.Scanf"     { column += yyleng; return FMT_SCANF; }
"fmt.Printf"    { column += yyleng; return FMT_PRINTF; }

"&&"            { column += yyleng; return AND; }
"||"            { column += yyleng; return OR; }
"=="            { column += yyleng; return EQ; }
"!="            { column += yyleng; return NE; }
"<="            { column += yyleng; return LE; }
">="            { column += yyleng; return GE; }
"+="            { column += yyleng; return PLUS_ASSIGN; }
"-="            { column += yyleng; return MINUS_ASSIGN; }
"*="            { column += yyleng; return STAR_ASSIGN; }
"/="            { column += yyleng; return SLASH_ASSIGN; }
"%="            { column += yyleng; return PERCENT_ASSIGN; }
":="            { column += yyleng; return SHORT_ASSIGN; }
"++"            { column += yyleng; return INC; }
"--"            { column += yyleng; return DEC; }

"+"             { column += yyleng; return PLUS; }
"-"             { column += yyleng; return MINUS; }
"*"             { column += yyleng; return STAR; }
"/"             { column += yyleng; return SLASH; }
"%"             { column += yyleng; return PERCENT; }
"&"             { column += yyleng; return AMPERSAND; }
"!"             { column += yyleng; return EXCLAMATION; }
"<"             { column += yyleng; return LT; }
">"             { column += yyleng; return GT; }
"="             { column += yyleng; return ASSIGN; }

"("             { column += yyleng; return LPAREN; }
")"             { column += yyleng; return RPAREN; }
"{"             { column += yyleng; return LBRACE; }
"}"             { column += yyleng; return RBRACE; }
","             { column += yyleng; return COMMA; }
";"             { column += yyleng; return SEMICOLON; }
"."             { column += yyleng; return DOT; }
":"             { column += yyleng; return COLON; }

{IDENTIFIER}    { column += yyleng; return IDENTIFIER; }
{INTEGER}       { column += yyleng; return INTEGER_CONST; }
{FLOAT}         { column += yyleng; return FLOAT_CONST; }
{STRING}        { column += yyleng; return STRING_LITERAL; }

"//".*\n        { column = 1; }
"/*"([^*]|\*+[^*/])*\*+"/"  {
                    for (int i = 0; i < yyleng; i++) {
                        if (yytext[i] == '\n') {
                            column = 1;
                        } else {
                            column++;
                        }
                    }
                }

\n              { column = 1; }
[ \t\r]+        { column += yyleng; }

.               {
                    fprintf(stderr, "Lexical error at line %d, column %d: illegal character '%s'\n",
                            yylineno, column, yytext);
                    column += yyleng;
                    error_count++;
                }

%%
