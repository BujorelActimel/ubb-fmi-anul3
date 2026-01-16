%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

extern int yylex();
extern int yylineno;
extern char *yytext;
extern FILE *yyin;
extern int error_count;

void yyerror(const char *s);

ASTNode *root = NULL;
%}

%union {
    int int_val;
    char *str_val;
    struct ASTNode *node;
    int op_val;
}

%token PACKAGE IMPORT FUNC VAR RETURN
%token INT

%token FMT_SCANF FMT_PRINTF

%token PLUS MINUS STAR SLASH PERCENT
%token AMPERSAND ASSIGN

%token LPAREN RPAREN LBRACE RBRACE COMMA SEMICOLON DOT

%token <str_val> IDENTIFIER STRING_LITERAL
%token <int_val> INTEGER_CONST

%type <node> program package_decl import_decl
%type <node> declaration_list declaration var_decl
%type <node> func_decl func_body local_decl_list
%type <node> statement_list statement
%type <node> assignment_stmt return_stmt
%type <node> scanf_stmt printf_stmt block_stmt
%type <node> expression additive multiplicative unary primary
%type <node> arg_list var_list
%type <str_val> format_string

%%

program: package_decl import_decl declaration_list func_decl
       {
           $$ = create_program_node($1->data.identifier.name, $3, $4);
           root = $$;
       }
       | package_decl declaration_list func_decl
       {
           $$ = create_program_node($1->data.identifier.name, $2, $3);
           root = $$;
       }
       ;

package_decl: PACKAGE IDENTIFIER
            {
                $$ = create_identifier_node($2);
            }
            ;

import_decl: IMPORT STRING_LITERAL
           {
               $$ = create_string_const_node($2);
           }
           ;


declaration_list:
                {
                    $$ = NULL;
                }
                | declaration_list declaration
                {
                    $$ = append_node($1, $2);
                }
                ;

declaration: var_decl
           {
               $$ = $1;
           }
           ;

var_decl: VAR IDENTIFIER INT
        {
            $$ = create_var_decl_node($2, TYPE_INT, NULL);
        }
        ;

func_decl: FUNC IDENTIFIER LPAREN RPAREN LBRACE func_body RBRACE
         {
             $$ = create_func_decl_node($2, TYPE_VOID, NULL, $6);
         }
         ;

func_body: local_decl_list statement_list
         {
             $$ = create_block_stmt_node(append_node($1, $2));
         }
         ;

local_decl_list:
               {
                   $$ = NULL;
               }
               | local_decl_list var_decl
               {
                   $$ = append_node($1, $2);
               }
               ;


statement_list:
              {
                  $$ = NULL;
              }
              | statement_list statement
              {
                  $$ = append_node($1, $2);
              }
              ;

statement: assignment_stmt
         {
             $$ = $1;
         }
         | return_stmt
         {
             $$ = $1;
         }
         | scanf_stmt
         {
             $$ = $1;
         }
         | printf_stmt
         {
             $$ = $1;
         }
         | block_stmt
         {
             $$ = $1;
         }
         ;

assignment_stmt: IDENTIFIER ASSIGN expression
               {
                   $$ = create_assign_stmt_node($1, $3);
               }
               ;


return_stmt: RETURN expression
           {
               $$ = create_return_stmt_node($2);
           }
           ;

scanf_stmt: FMT_SCANF LPAREN format_string COMMA var_list RPAREN
          {
              $$ = create_scanf_stmt_node($3, $5);
          }
          ;

printf_stmt: FMT_PRINTF LPAREN format_string RPAREN
           {
               $$ = create_printf_stmt_node($3, NULL);
           }
           | FMT_PRINTF LPAREN format_string COMMA arg_list RPAREN
           {
               $$ = create_printf_stmt_node($3, $5);
           }
           ;

block_stmt: LBRACE statement_list RBRACE
          {
              $$ = create_block_stmt_node($2);
          }
          ;

format_string: STRING_LITERAL
             {
                 $$ = $1;
             }
             ;

var_list: AMPERSAND IDENTIFIER
        {
            $$ = create_unary_expr_node(OP_ADDR, create_identifier_node($2));
        }
        | var_list COMMA AMPERSAND IDENTIFIER
        {
            $$ = append_node($1, create_unary_expr_node(OP_ADDR, create_identifier_node($4)));
        }
        ;

arg_list: expression
        {
            $$ = $1;
        }
        | arg_list COMMA expression
        {
            $$ = append_node($1, $3);
        }
        ;

expression: additive
          {
              $$ = $1;
          }
          ;

additive: multiplicative
        {
            $$ = $1;
        }
        | additive PLUS multiplicative
        {
            $$ = create_binary_expr_node(OP_ADD, $1, $3);
        }
        | additive MINUS multiplicative
        {
            $$ = create_binary_expr_node(OP_SUB, $1, $3);
        }
        ;

multiplicative: unary
              {
                  $$ = $1;
              }
              | multiplicative STAR unary
              {
                  $$ = create_binary_expr_node(OP_MUL, $1, $3);
              }
              | multiplicative SLASH unary
              {
                  $$ = create_binary_expr_node(OP_DIV, $1, $3);
              }
              | multiplicative PERCENT unary
              {
                  $$ = create_binary_expr_node(OP_MOD, $1, $3);
              }
              ;

unary: primary
     {
         $$ = $1;
     }
     | MINUS unary
     {
         $$ = create_unary_expr_node(OP_NEG, $2);
     }
     | AMPERSAND unary
     {
         $$ = create_unary_expr_node(OP_ADDR, $2);
     }
     ;

primary: IDENTIFIER
       {
           $$ = create_identifier_node($1);
       }
       | INTEGER_CONST
       {
           $$ = create_int_const_node($1);
       }
       | LPAREN expression RPAREN
       {
           $$ = $2;
       }
       ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error at line %d: %s (near '%s')\n", yylineno, s, yytext);
    error_count++;
}
