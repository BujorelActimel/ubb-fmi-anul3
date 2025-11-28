%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yylineno;
extern char *yytext;
extern FILE *yyin;
extern int error_count;
extern int word_count;
extern int limbaj_count;

void yyerror(const char *s);
%}

%token WORD

%%

program: WORD
    | program WORD
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Eroare de sintaxa la linia %d, token apropiat '%s'\n", yylineno, yytext);
}

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <fisier_intrare>\n", argv[0]);
        return 1;
    }

    FILE *input = fopen(argv[1], "r");
    if (!input) {
        fprintf(stderr, "Error: Nu pot deschide fisierul %s\n", argv[1]);
        return 1;
    }

    yyin = input;

    printf("Procesez fisierul %s\n", argv[1]);

    int parse_result = yyparse();

    fclose(input);

    printf("Numar total de cuvinte: %d\n", word_count);
    printf("Aparitii ale declinarii 'limbaj': %d\n", limbaj_count);

    if (parse_result == 0 && error_count == 0) {
        return 0;
    } else {
        return 1;
    }
}
