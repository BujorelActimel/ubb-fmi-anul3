#define _GNU_SOURCE
#include "codegen_x86.h"
#include <string.h>
#include <stdlib.h>

typedef struct VarEntry {
    char *name;
    int offset;
    struct VarEntry *next;
} VarEntry;

static VarEntry *var_table = NULL;

void register_variable(const char *var_name, int offset) {
    VarEntry *entry = malloc(sizeof(VarEntry));
    entry->name = strdup(var_name);
    entry->offset = offset;
    entry->next = var_table;
    var_table = entry;
}

int get_var_offset(const char *var_name) {
    for (VarEntry *e = var_table; e != NULL; e = e->next) {
        if (strcmp(e->name, var_name) == 0) {
            return e->offset;
        }
    }
    return -1;
}

int new_label(CodeGenContext *ctx) {
    return ctx->label_counter++;
}

void gen_prologue(CodeGenContext *ctx) {
    fprintf(ctx->output, ".section .rodata\n");
    fprintf(ctx->output, "fmt_in: .string \"%%d\"\n");
    fprintf(ctx->output, "fmt_out: .string \"%%d\\n\"\n");
    fprintf(ctx->output, "\n");
    fprintf(ctx->output, ".text\n");
    fprintf(ctx->output, ".globl main\n");
    fprintf(ctx->output, "\n");
}

void gen_func_prologue(CodeGenContext *ctx, int local_vars) {
    fprintf(ctx->output, "    pushq %%rbp\n");
    fprintf(ctx->output, "    movq %%rsp, %%rbp\n");
    if (local_vars > 0) {
        /* Align stack to 16 bytes */
        int stack_size = local_vars * 8;
        /* Round up to multiple of 16 */
        stack_size = (stack_size + 15) & ~15;
        fprintf(ctx->output, "    subq $%d, %%rsp\n", stack_size);
    }
}

void gen_func_epilogue(CodeGenContext *ctx) {
    fprintf(ctx->output, "    movq %%rbp, %%rsp\n");
    fprintf(ctx->output, "    popq %%rbp\n");
    fprintf(ctx->output, "    xorq %%rax, %%rax\n");
    fprintf(ctx->output, "    ret\n");
}

void gen_scanf(CodeGenContext *ctx, ASTNode *var_node) {
    if (var_node->type == AST_UNARY_EXPR && var_node->data.unary.op == OP_ADDR) {
        ASTNode *var = var_node->data.unary.operand;
        if (var->type == AST_IDENTIFIER) {
            int offset = get_var_offset(var->data.identifier.name);
            fprintf(ctx->output, "    leaq %d(%%rbp), %%rsi\n", offset);
            fprintf(ctx->output, "    leaq fmt_in(%%rip), %%rdi\n");
            fprintf(ctx->output, "    xorq %%rax, %%rax\n");
            fprintf(ctx->output, "    call scanf@PLT\n");
        }
    }
}

void gen_printf(CodeGenContext *ctx, ASTNode *arg) {
    /* Evaluate expression into rax */
    gen_expression(ctx, arg);

    /* Call printf */
    fprintf(ctx->output, "    movq %%rax, %%rsi\n");
    fprintf(ctx->output, "    leaq fmt_out(%%rip), %%rdi\n");
    fprintf(ctx->output, "    xorq %%rax, %%rax\n");
    fprintf(ctx->output, "    call printf@PLT\n");
}

/* Generate expression evaluation (result in rax) */
void gen_expression(CodeGenContext *ctx, ASTNode *node) {
    if (!node) return;

    switch (node->type) {
        case AST_INTEGER_CONST:
            fprintf(ctx->output, "    movq $%d, %%rax\n", node->data.int_const.value);
            break;

        case AST_IDENTIFIER: {
            int offset = get_var_offset(node->data.identifier.name);
            fprintf(ctx->output, "    movq %d(%%rbp), %%rax\n", offset);
            break;
        }

        case AST_BINARY_EXPR: {
            /* Evaluate left side */
            gen_expression(ctx, node->data.binary.left);
            fprintf(ctx->output, "    pushq %%rax\n");

            /* Evaluate right side */
            gen_expression(ctx, node->data.binary.right);
            fprintf(ctx->output, "    movq %%rax, %%rbx\n");
            fprintf(ctx->output, "    popq %%rax\n");

            /* Perform operation */
            switch (node->data.binary.op) {
                case OP_ADD:
                    fprintf(ctx->output, "    addq %%rbx, %%rax\n");
                    break;
                case OP_SUB:
                    fprintf(ctx->output, "    subq %%rbx, %%rax\n");
                    break;
                case OP_MUL:
                    fprintf(ctx->output, "    imulq %%rbx, %%rax\n");
                    break;
                case OP_DIV:
                    fprintf(ctx->output, "    cqo\n");
                    fprintf(ctx->output, "    idivq %%rbx\n");
                    break;
                case OP_MOD:
                    fprintf(ctx->output, "    cqo\n");
                    fprintf(ctx->output, "    idivq %%rbx\n");
                    fprintf(ctx->output, "    movq %%rdx, %%rax\n");
                    break;
                default:
                    fprintf(stderr, "Unknown binary operator\n");
                    break;
            }
            break;
        }

        case AST_UNARY_EXPR:
            gen_expression(ctx, node->data.unary.operand);
            if (node->data.unary.op == OP_NEG) {
                fprintf(ctx->output, "    negq %%rax\n");
            } else if (node->data.unary.op == OP_NOT) {
                fprintf(ctx->output, "    testq %%rax, %%rax\n");
                fprintf(ctx->output, "    setz %%al\n");
                fprintf(ctx->output, "    movzbq %%al, %%rax\n");
            }
            break;

        default:
            break;
    }
}

/* Generate statement */
void gen_statement(CodeGenContext *ctx, ASTNode *node) {
    if (!node) return;

    switch (node->type) {
        case AST_ASSIGN_STMT: {
            gen_expression(ctx, node->data.assign.value);
            int offset = get_var_offset(node->data.assign.var_name);
            fprintf(ctx->output, "    movq %%rax, %d(%%rbp)\n", offset);
            break;
        }

        case AST_SCANF_STMT: {
            ASTNode *var = node->data.scanf_stmt.var_list;
            while (var) {
                gen_scanf(ctx, var);
                var = var->next;
            }
            break;
        }

        case AST_PRINTF_STMT: {
            ASTNode *arg = node->data.printf_stmt.arg_list;
            if (arg) {
                gen_printf(ctx, arg);
            }
            break;
        }

        case AST_BLOCK_STMT: {
            /* For blocks, process all statements in the list */
            ASTNode *stmt = node->data.block.statements;
            while (stmt) {
                /* Process this statement (but don't recurse on next) */
                switch (stmt->type) {
                        case AST_ASSIGN_STMT: {
                        gen_expression(ctx, stmt->data.assign.value);
                        int offset = get_var_offset(stmt->data.assign.var_name);
                        fprintf(ctx->output, "    movq %%rax, %d(%%rbp)\n", offset);
                        break;
                    }
                    case AST_SCANF_STMT: {
                        ASTNode *var = stmt->data.scanf_stmt.var_list;
                        while (var) {
                            gen_scanf(ctx, var);
                            var = var->next;
                        }
                        break;
                    }
                    case AST_PRINTF_STMT: {
                        ASTNode *arg = stmt->data.printf_stmt.arg_list;
                        if (arg) {
                            gen_printf(ctx, arg);
                        }
                        break;
                    }
                    case AST_BLOCK_STMT:
                        gen_statement(ctx, stmt);  /* Recursive for nested blocks */
                        break;
                    case AST_RETURN_STMT:
                        if (stmt->data.return_stmt.value) {
                            gen_expression(ctx, stmt->data.return_stmt.value);
                        }
                        gen_func_epilogue(ctx);
                        break;
                    default:
                        break;
                }
                stmt = stmt->next;
            }
            break;
        }

        case AST_RETURN_STMT:
            if (node->data.return_stmt.value) {
                gen_expression(ctx, node->data.return_stmt.value);
            }
            gen_func_epilogue(ctx);
            break;

        default:
            break;
    }
}

/* Count variables (for stack allocation) */
int count_local_vars(ASTNode *body) {
    int count = 0;
    if (body && body->type == AST_BLOCK_STMT) {
        ASTNode *stmt = body->data.block.statements;
        while (stmt) {
            if (stmt->type == AST_VAR_DECL) {
                count++;
            }
            stmt = stmt->next;
        }
    }
    return count;
}

/* Generate function */
void gen_function(CodeGenContext *ctx, ASTNode *node) {
    fprintf(ctx->output, "%s:\n", node->data.func_decl.name);

    /* Count local variables (only those not already registered as global) */
    ASTNode *body = node->data.func_decl.body;
    int total_vars = 0;

    /* Count how many vars we already have registered globally */
    for (VarEntry *e = var_table; e != NULL; e = e->next) {
        total_vars++;
    }

    gen_func_prologue(ctx, total_vars);

    /* Generate function body */
    if (body) {
        gen_statement(ctx, body);
    }

    gen_func_epilogue(ctx);
}

/* Generate program */
void gen_program(CodeGenContext *ctx, ASTNode *node) {
    gen_prologue(ctx);

    /* Register global variables */
    ASTNode *decl = node->data.program.declarations;
    int var_count = 0;
    while (decl) {
        if (decl->type == AST_VAR_DECL) {
            var_count++;
            int offset = -(var_count * 8);
            register_variable(decl->data.var_decl.name, offset);
        }
        decl = decl->next;
    }

    /* Generate main function */
    if (node->data.program.main_func) {
        gen_function(ctx, node->data.program.main_func);
    }
}

/* Main entry point */
void generate_x86_code(ASTNode *root, FILE *output) {
    CodeGenContext ctx = {
        .output = output,
        .label_counter = 0,
        .temp_counter = 0,
        .var_count = 0,
        .stack_offset = 0
    };

    if (root && root->type == AST_PROGRAM) {
        gen_program(&ctx, root);
    }
}
