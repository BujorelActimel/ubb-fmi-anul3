%top{
#define _GNU_SOURCE
}

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

int column = 1;
int error_count = 0;

extern YYSTYPE yylval;
%}

%option yylineno
%option noyywrap
%option noinput
%option nounput

DIGIT       [0-9]
LETTER      [a-zA-Z]
IDENTIFIER  {LETTER}({LETTER}|{DIGIT}|_)*
INTEGER     ([1-9]{DIGIT}*)|0
STRING      \"([^\"\n\\]|\\[ntr\\\"])*\"

%%

"package"       { column += yyleng; return PACKAGE; }
"import"        { column += yyleng; return IMPORT; }
"func"          { column += yyleng; return FUNC; }
"var"           { column += yyleng; return VAR; }
"return"        { column += yyleng; return RETURN; }

"int"           { column += yyleng; return INT; }

"fmt.Scanf"     { column += yyleng; return FMT_SCANF; }
"fmt.Printf"    { column += yyleng; return FMT_PRINTF; }

"+"             { column += yyleng; return PLUS; }
"-"             { column += yyleng; return MINUS; }
"*"             { column += yyleng; return STAR; }
"/"             { column += yyleng; return SLASH; }
"%"             { column += yyleng; return PERCENT; }
"&"             { column += yyleng; return AMPERSAND; }
"="             { column += yyleng; return ASSIGN; }

"("             { column += yyleng; return LPAREN; }
")"             { column += yyleng; return RPAREN; }
"{"             { column += yyleng; return LBRACE; }
"}"             { column += yyleng; return RBRACE; }
","             { column += yyleng; return COMMA; }
";"             { column += yyleng; return SEMICOLON; }
"."             { column += yyleng; return DOT; }

{IDENTIFIER}    {
                    column += yyleng;
                    yylval.str_val = strdup(yytext);
                    return IDENTIFIER;
                }

{INTEGER}       {
                    column += yyleng;
                    yylval.int_val = atoi(yytext);
                    return INTEGER_CONST;
                }

{STRING}        {
                    column += yyleng;
                    yylval.str_val = strdup(yytext);
                    return STRING_LITERAL;
                }

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
