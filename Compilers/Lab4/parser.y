%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yylineno;
extern char *yytext;
extern FILE *yyin;
extern int error_count;

void yyerror(const char *s);
%}

%token PACKAGE IMPORT CONST TYPE STRUCT FUNC VAR RETURN IF ELSE FOR
%token INT FLOAT32 FLOAT64 STRING_TYPE BOOL
%token FMT_SCANF FMT_PRINTF
%token IDENTIFIER INTEGER_CONST FLOAT_CONST STRING_LITERAL
%token LPAREN RPAREN LBRACE RBRACE COMMA SEMICOLON DOT COLON

%left OR
%left AND
%left EQ NE
%left LT LE GT GE
%left PLUS MINUS
%left STAR SLASH PERCENT
%right UNARY
%token AMPERSAND EXCLAMATION
%token ASSIGN PLUS_ASSIGN MINUS_ASSIGN STAR_ASSIGN SLASH_ASSIGN PERCENT_ASSIGN SHORT_ASSIGN
%token INC DEC

%nonassoc IF_NO_ELSE
%nonassoc ELSE

%%

program: PACKAGE IDENTIFIER package_imports declarations_opt function_declarations
       ;

package_imports: IMPORT STRING_LITERAL
               | IMPORT LPAREN string_list RPAREN
               ;

string_list: /* empty */
           | string_list STRING_LITERAL
           ;

declarations_opt: /* empty */
                | declarations
                ;

declarations: declaration
            | declarations declaration
            ;

declaration: const_declaration
           | type_declaration
           ;

const_declaration: CONST IDENTIFIER type_specifier ASSIGN expression
                 ;

type_declaration: TYPE IDENTIFIER struct_type
                ;

struct_type: STRUCT LBRACE field_declarations RBRACE
           ;

field_declarations: /* empty */
                  | field_declarations field_declaration
                  ;

field_declaration: IDENTIFIER type_specifier
                 ;

function_declarations: /* empty */
                     | function_declarations function_declaration
                     ;

function_declaration: FUNC receiver_opt IDENTIFIER signature function_body
                    ;

receiver_opt: /* empty */
            | LPAREN IDENTIFIER pointer_opt IDENTIFIER RPAREN
            ;

pointer_opt: /* empty */
           | STAR
           ;

signature: parameters return_type_opt
         ;

parameters: LPAREN parameter_list_opt RPAREN
          ;

parameter_list_opt: /* empty */
                  | parameter_list
                  ;

parameter_list: parameter_decl
              | parameter_list COMMA parameter_decl
              ;

parameter_decl: identifier_list type_specifier
              ;

identifier_list: IDENTIFIER
               | identifier_list COMMA IDENTIFIER
               ;

return_type_opt: /* empty */
               | type_specifier
               ;

function_body: LBRACE statement_list RBRACE
             ;

type_specifier: basic_type
              | STAR IDENTIFIER
              | IDENTIFIER
              ;

basic_type: INT
          | FLOAT32
          | FLOAT64
          | STRING_TYPE
          | BOOL
          ;

statement_list: /* empty */
              | statement_list statement
              ;

statement: declaration_statement
         | short_var_declaration
         | assignment_statement
         | expression_statement
         | return_statement
         | if_statement
         | for_statement
         | compound_statement
         | input_statement
         | output_statement
         | inc_dec_statement
         ;

inc_dec_statement: IDENTIFIER INC
                 | IDENTIFIER DEC
                 ;

declaration_statement: VAR identifier_list type_specifier
                     | VAR identifier_list type_specifier ASSIGN expression
                     ;

short_var_declaration: IDENTIFIER SHORT_ASSIGN expression
                     ;

assignment_statement: left_value assignment_operator expression
                    ;

left_value: IDENTIFIER
          | postfix_expression DOT IDENTIFIER
          ;

assignment_operator: ASSIGN
                   | PLUS_ASSIGN
                   | MINUS_ASSIGN
                   | STAR_ASSIGN
                   | SLASH_ASSIGN
                   | PERCENT_ASSIGN
                   ;

expression_statement: expression
                    ;

return_statement: RETURN
                | RETURN expression
                ;

if_statement: IF expression compound_statement %prec IF_NO_ELSE
            | IF expression compound_statement ELSE compound_statement
            ;

for_statement: FOR compound_statement
             | FOR expression compound_statement
             | FOR for_clause compound_statement
             ;

for_clause: simple_statement_opt SEMICOLON expression_opt SEMICOLON simple_statement_opt
          ;

simple_statement_opt: /* empty */
                    | simple_statement
                    ;

simple_statement: assignment_statement
                | short_var_declaration
                | inc_dec_statement
                ;

expression_opt: /* empty */
              | expression
              ;

compound_statement: LBRACE statement_list RBRACE
                  ;

input_statement: FMT_SCANF LPAREN STRING_LITERAL COMMA AMPERSAND IDENTIFIER RPAREN
               ;

output_statement: FMT_PRINTF LPAREN STRING_LITERAL RPAREN
                | FMT_PRINTF LPAREN STRING_LITERAL COMMA expression RPAREN
                | FMT_PRINTF LPAREN STRING_LITERAL COMMA expression COMMA expression RPAREN
                | FMT_PRINTF LPAREN STRING_LITERAL COMMA expression COMMA expression COMMA expression RPAREN
                | FMT_PRINTF LPAREN STRING_LITERAL COMMA expression COMMA expression COMMA expression COMMA expression RPAREN
                | FMT_PRINTF LPAREN STRING_LITERAL COMMA expression COMMA expression COMMA expression COMMA expression COMMA expression RPAREN
                ;

expression: expression PLUS expression
          | expression MINUS expression
          | expression STAR expression
          | expression SLASH expression
          | expression PERCENT expression
          | expression AND expression
          | expression OR expression
          | expression EQ expression
          | expression NE expression
          | expression LT expression
          | expression LE expression
          | expression GT expression
          | expression GE expression
          | PLUS expression %prec UNARY
          | MINUS expression %prec UNARY
          | EXCLAMATION expression %prec UNARY
          | AMPERSAND expression %prec UNARY
          | STAR expression %prec UNARY
          | postfix_expression
          ;

postfix_expression: primary_base
                  | postfix_expression DOT IDENTIFIER
                  | postfix_expression LPAREN argument_list_opt RPAREN
                  ;

primary_base: IDENTIFIER
            | INTEGER_CONST
            | FLOAT_CONST
            | STRING_LITERAL
            | LPAREN expression RPAREN
            | composite_literal
            | basic_type LPAREN expression RPAREN
            ;

composite_literal: AMPERSAND IDENTIFIER LBRACE field_initializer_list_opt RBRACE
                 ;

field_initializer_list_opt: /* empty */
                          | field_initializer_list
                          ;

field_initializer_list: field_initializer
                      | field_initializer_list COMMA field_initializer
                      ;

field_initializer: IDENTIFIER COLON expression
                 | expression
                 ;

argument_list_opt: /* empty */
                 | argument_list
                 ;

argument_list: argument
             | argument_list COMMA argument
             ;

argument: expression
        ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax error at line %d, near token '%s'\n", yylineno, yytext);
}

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

    yyin = input;

    printf("Parsing %s\n", argv[1]);

    int parse_result = yyparse();

    fclose(input);

    if (parse_result == 0 && error_count == 0) {
        printf("Syntax is correct\n");
        return 0;
    } else {
        return 1;
    }
}
