#ifndef CODEGEN_X86_H
#define CODEGEN_X86_H

#include <stdio.h>
#include "ast.h"

typedef struct {
    FILE *output;
    int label_counter;
    int temp_counter;
    int var_count;
    int stack_offset;
} CodeGenContext;

void generate_x86_code(ASTNode *root, FILE *output);

void gen_program(CodeGenContext *ctx, ASTNode *node);
void gen_function(CodeGenContext *ctx, ASTNode *node);
void gen_statement(CodeGenContext *ctx, ASTNode *node);
void gen_expression(CodeGenContext *ctx, ASTNode *node);

int get_var_offset(const char *var_name);
void register_variable(const char *var_name, int offset);
int new_label(CodeGenContext *ctx);

#endif /* CODEGEN_X86_H */
