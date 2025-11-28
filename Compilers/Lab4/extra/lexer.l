%{
#include <stdio.h>
#include <string.h>
#include "parser.tab.h"
#define BASE_WORD "limbaj"

int column = 1;
int error_count = 0;
int word_count = 0;
int limbaj_count = 0;

int is_declinare(const char *word, const char *base_word) {
    size_t base_len = strlen(base_word);
    return strncmp(word, base_word, base_len) == 0;
}
%}

%option yylineno
%option noyywrap
%option noinput
%option nounput

LETTER      [a-z]
WORD        {LETTER}+

%%

{WORD}      {
                word_count++;
                if (is_declinare(yytext, BASE_WORD)) {
                    limbaj_count++;
                }
                return WORD;
            }

\n          { column = 1; }
[ \t\r]+    { column += yyleng; }

.           {
                fprintf(stderr, "Eroare lexicala la linia %d, coloana %d: caracter ilegal '%c'\n",
                        yylineno, column, yytext[0]);
                column += yyleng;
                error_count++;
            }

%%
