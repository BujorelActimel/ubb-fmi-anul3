%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symboltable.h"

#define PACKAGE 1
#define IMPORT 2
#define CONST 3
#define TYPE 4
#define STRUCT 5
#define FUNC 6
#define VAR 7
#define RETURN 8
#define IF 9
#define ELSE 10
#define FOR 11
#define INT 12
#define FLOAT32 13
#define FLOAT64 14
#define STRING_TYPE 15
#define BOOL 16
#define FMT_SCANF 17
#define FMT_PRINTF 18

#define PLUS 19
#define MINUS 20
#define STAR 21
#define SLASH 22
#define PERCENT 23
#define AMPERSAND 24
#define EXCLAMATION 25
#define AND 26
#define OR 27
#define EQ 28
#define NE 29
#define LT 30
#define LE 31
#define GT 32
#define GE 33
#define ASSIGN 34
#define PLUS_ASSIGN 35
#define MINUS_ASSIGN 36
#define STAR_ASSIGN 37
#define SLASH_ASSIGN 38
#define PERCENT_ASSIGN 39
#define SHORT_ASSIGN 40

#define LPAREN 41
#define RPAREN 42
#define LBRACE 43
#define RBRACE 44
#define COMMA 45
#define SEMICOLON 46
#define DOT 47
#define COLON 48

#define IDENTIFIER 49
#define INTEGER 50
#define FLOAT 51
#define STRING_LITERAL 52

// ACTIVITATE
#define REPETA 53
#define PANACAND 54
#define SFREPETA 55

SymbolTable *symbol_table;
FILE *fip_file;
int column = 1;

void add_to_fip(int token_code, int st_pos) {
    fprintf(fip_file, "%d,%d\n", token_code, st_pos);
}

void print_token(int token_code, const char *lexeme) {
    printf("%d:%d TOKEN_%d \"%s\"\n", yylineno, column, token_code, lexeme);
}

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

"package"       { print_token(PACKAGE, yytext); add_to_fip(PACKAGE, -1); column += yyleng; return PACKAGE; }
"import"        { print_token(IMPORT, yytext); add_to_fip(IMPORT, -1); column += yyleng; return IMPORT; }
"const"         { print_token(CONST, yytext); add_to_fip(CONST, -1); column += yyleng; return CONST; }
"type"          { print_token(TYPE, yytext); add_to_fip(TYPE, -1); column += yyleng; return TYPE; }
"struct"        { print_token(STRUCT, yytext); add_to_fip(STRUCT, -1); column += yyleng; return STRUCT; }
"func"          { print_token(FUNC, yytext); add_to_fip(FUNC, -1); column += yyleng; return FUNC; }
"var"           { print_token(VAR, yytext); add_to_fip(VAR, -1); column += yyleng; return VAR; }
"return"        { print_token(RETURN, yytext); add_to_fip(RETURN, -1); column += yyleng; return RETURN; }
"if"            { print_token(IF, yytext); add_to_fip(IF, -1); column += yyleng; return IF; }
"else"          { print_token(ELSE, yytext); add_to_fip(ELSE, -1); column += yyleng; return ELSE; }
"for"           { print_token(FOR, yytext); add_to_fip(FOR, -1); column += yyleng; return FOR; }

"repeta"        { print_token(REPETA, yytext); add_to_fip(REPETA, -1); column += yyleng; return REPETA; }
"panacand"      { print_token(PANACAND, yytext); add_to_fip(PANACAND, -1); column += yyleng; return PANACAND; }
"sfrepeta"      { print_token(SFREPETA, yytext); add_to_fip(SFREPETA, -1); column += yyleng; return SFREPETA; }

"int"           { print_token(INT, yytext); add_to_fip(INT, -1); column += yyleng; return INT; }
"float32"       { print_token(FLOAT32, yytext); add_to_fip(FLOAT32, -1); column += yyleng; return FLOAT32; }
"float64"       { print_token(FLOAT64, yytext); add_to_fip(FLOAT64, -1); column += yyleng; return FLOAT64; }
"string"        { print_token(STRING_TYPE, yytext); add_to_fip(STRING_TYPE, -1); column += yyleng; return STRING_TYPE; }
"bool"          { print_token(BOOL, yytext); add_to_fip(BOOL, -1); column += yyleng; return BOOL; }

"fmt.Scanf"     { print_token(FMT_SCANF, yytext); add_to_fip(FMT_SCANF, -1); column += yyleng; return FMT_SCANF; }
"fmt.Printf"    { print_token(FMT_PRINTF, yytext); add_to_fip(FMT_PRINTF, -1); column += yyleng; return FMT_PRINTF; }

"&&"            { print_token(AND, yytext); add_to_fip(AND, -1); column += yyleng; return AND; }
"||"            { print_token(OR, yytext); add_to_fip(OR, -1); column += yyleng; return OR; }
"=="            { print_token(EQ, yytext); add_to_fip(EQ, -1); column += yyleng; return EQ; }
"!="            { print_token(NE, yytext); add_to_fip(NE, -1); column += yyleng; return NE; }
"<="            { print_token(LE, yytext); add_to_fip(LE, -1); column += yyleng; return LE; }
">="            { print_token(GE, yytext); add_to_fip(GE, -1); column += yyleng; return GE; }
"+="            { print_token(PLUS_ASSIGN, yytext); add_to_fip(PLUS_ASSIGN, -1); column += yyleng; return PLUS_ASSIGN; }
"-="            { print_token(MINUS_ASSIGN, yytext); add_to_fip(MINUS_ASSIGN, -1); column += yyleng; return MINUS_ASSIGN; }
"*="            { print_token(STAR_ASSIGN, yytext); add_to_fip(STAR_ASSIGN, -1); column += yyleng; return STAR_ASSIGN; }
"/="            { print_token(SLASH_ASSIGN, yytext); add_to_fip(SLASH_ASSIGN, -1); column += yyleng; return SLASH_ASSIGN; }
"%="            { print_token(PERCENT_ASSIGN, yytext); add_to_fip(PERCENT_ASSIGN, -1); column += yyleng; return PERCENT_ASSIGN; }
":="            { print_token(SHORT_ASSIGN, yytext); add_to_fip(SHORT_ASSIGN, -1); column += yyleng; return SHORT_ASSIGN; }

"+"             { print_token(PLUS, yytext); add_to_fip(PLUS, -1); column += yyleng; return PLUS; }
"-"             { print_token(MINUS, yytext); add_to_fip(MINUS, -1); column += yyleng; return MINUS; }
"*"             { print_token(STAR, yytext); add_to_fip(STAR, -1); column += yyleng; return STAR; }
"/"             { print_token(SLASH, yytext); add_to_fip(SLASH, -1); column += yyleng; return SLASH; }
"%"             { print_token(PERCENT, yytext); add_to_fip(PERCENT, -1); column += yyleng; return PERCENT; }
"&"             { print_token(AMPERSAND, yytext); add_to_fip(AMPERSAND, -1); column += yyleng; return AMPERSAND; }
"!"             { print_token(EXCLAMATION, yytext); add_to_fip(EXCLAMATION, -1); column += yyleng; return EXCLAMATION; }
"<"             { print_token(LT, yytext); add_to_fip(LT, -1); column += yyleng; return LT; }
">"             { print_token(GT, yytext); add_to_fip(GT, -1); column += yyleng; return GT; }
"="             { print_token(ASSIGN, yytext); add_to_fip(ASSIGN, -1); column += yyleng; return ASSIGN; }

"("             { print_token(LPAREN, yytext); add_to_fip(LPAREN, -1); column += yyleng; return LPAREN; }
")"             { print_token(RPAREN, yytext); add_to_fip(RPAREN, -1); column += yyleng; return RPAREN; }
"{"             { print_token(LBRACE, yytext); add_to_fip(LBRACE, -1); column += yyleng; return LBRACE; }
"}"             { print_token(RBRACE, yytext); add_to_fip(RBRACE, -1); column += yyleng; return RBRACE; }
","             { print_token(COMMA, yytext); add_to_fip(COMMA, -1); column += yyleng; return COMMA; }
";"             { print_token(SEMICOLON, yytext); add_to_fip(SEMICOLON, -1); column += yyleng; return SEMICOLON; }
"."             { print_token(DOT, yytext); add_to_fip(DOT, -1); column += yyleng; return DOT; }
":"             { print_token(COLON, yytext); add_to_fip(COLON, -1); column += yyleng; return COLON; }

{IDENTIFIER}    {
                    int pos = st_insert(symbol_table, yytext);
                    print_token(IDENTIFIER, yytext);
                    add_to_fip(IDENTIFIER, pos);
                    column += yyleng;
                    return IDENTIFIER;
                }

{INTEGER}       {
                    int pos = st_insert(symbol_table, yytext);
                    print_token(INTEGER, yytext);
                    add_to_fip(INTEGER, pos);
                    column += yyleng;
                    return INTEGER;
                }

{FLOAT}         {
                    int pos = st_insert(symbol_table, yytext);
                    print_token(FLOAT, yytext);
                    add_to_fip(FLOAT, pos);
                    column += yyleng;
                    return FLOAT;
                }

{STRING}        {
                    int pos = st_insert(symbol_table, yytext);
                    print_token(STRING_LITERAL, yytext);
                    add_to_fip(STRING_LITERAL, pos);
                    column += yyleng;
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
                    fprintf(stderr, "Error at line %d, column %d: illegal character '%s'\n",
                            yylineno, column, yytext);
                    column += yyleng;
                }

%%

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    FILE *input = fopen(argv[1], "r");
    if (!input) {
        fprintf(stderr, "Error: Cannot open file %s\n", argv[1]);
        return 1;
    }

    symbol_table = st_create();

    fip_file = fopen("output/fip.csv", "w");
    if (!fip_file) {
        fprintf(stderr, "Error: Cannot create output/fip.csv\n");
        fclose(input);
        return 1;
    }
    fprintf(fip_file, "TokenCode,SymbolTablePos\n");

    yyin = input;

    printf("=== LEXICAL ANALYSIS ===\n");
    while (yylex());

    fclose(input);
    fclose(fip_file);

    st_save_to_csv(symbol_table, "output/ts.csv");

    st_destroy(symbol_table);

    printf("\n=== ANALYSIS COMPLETE ===\n");
    printf("Symbol table saved to: output/ts.csv\n");
    printf("FIP saved to: output/fip.csv\n");

    return 0;
}
