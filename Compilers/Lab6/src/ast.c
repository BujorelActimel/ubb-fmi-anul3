#define _GNU_SOURCE
#include "ast.h"

static ASTNode* create_node(ASTNodeType type) {
    ASTNode *node = (ASTNode*)malloc(sizeof(ASTNode));
    if (!node) {
        fprintf(stderr, "Error: Failed to allocate memory for AST node\n");
        exit(1);
    }
    memset(node, 0, sizeof(ASTNode));
    node->type = type;
    node->next = NULL;
    node->line = 0;
    node->column = 0;
    return node;
}

ASTNode* create_program_node(char *package_name, ASTNode *declarations, ASTNode *main_func) {
    ASTNode *node = create_node(AST_PROGRAM);
    node->data.program.package_name = package_name ? strdup(package_name) : NULL;
    node->data.program.declarations = declarations;
    node->data.program.main_func = main_func;
    return node;
}

ASTNode* create_declaration_list_node(ASTNode *first) {
    ASTNode *node = create_node(AST_DECLARATION_LIST);
    node->next = first;
    return node;
}

ASTNode* create_statement_list_node(ASTNode *first) {
    ASTNode *node = create_node(AST_STATEMENT_LIST);
    node->next = first;
    return node;
}

ASTNode* create_var_decl_node(char *name, DataType type, ASTNode *init_value) {
    ASTNode *node = create_node(AST_VAR_DECL);
    node->data.var_decl.name = name ? strdup(name) : NULL;
    node->data.var_decl.data_type = type;
    node->data.var_decl.init_value = init_value;
    return node;
}

ASTNode* create_func_decl_node(char *name, DataType return_type, ASTNode *params, ASTNode *body) {
    ASTNode *node = create_node(AST_FUNC_DECL);
    node->data.func_decl.name = name ? strdup(name) : NULL;
    node->data.func_decl.return_type = return_type;
    node->data.func_decl.params = params;
    node->data.func_decl.body = body;
    return node;
}

ASTNode* create_assign_stmt_node(char *var_name, ASTNode *value) {
    ASTNode *node = create_node(AST_ASSIGN_STMT);
    node->data.assign.var_name = var_name ? strdup(var_name) : NULL;
    node->data.assign.value = value;
    return node;
}

ASTNode* create_return_stmt_node(ASTNode *value) {
    ASTNode *node = create_node(AST_RETURN_STMT);
    node->data.return_stmt.value = value;
    return node;
}

ASTNode* create_scanf_stmt_node(char *format, ASTNode *var_list) {
    ASTNode *node = create_node(AST_SCANF_STMT);
    node->data.scanf_stmt.format = format ? strdup(format) : NULL;
    node->data.scanf_stmt.var_list = var_list;
    return node;
}

ASTNode* create_printf_stmt_node(char *format, ASTNode *arg_list) {
    ASTNode *node = create_node(AST_PRINTF_STMT);
    node->data.printf_stmt.format = format ? strdup(format) : NULL;
    node->data.printf_stmt.arg_list = arg_list;
    return node;
}

ASTNode* create_block_stmt_node(ASTNode *statements) {
    ASTNode *node = create_node(AST_BLOCK_STMT);
    node->data.block.statements = statements;
    return node;
}

ASTNode* create_binary_expr_node(BinaryOp op, ASTNode *left, ASTNode *right) {
    ASTNode *node = create_node(AST_BINARY_EXPR);
    node->data.binary.op = op;
    node->data.binary.left = left;
    node->data.binary.right = right;
    return node;
}

ASTNode* create_unary_expr_node(UnaryOp op, ASTNode *operand) {
    ASTNode *node = create_node(AST_UNARY_EXPR);
    node->data.unary.op = op;
    node->data.unary.operand = operand;
    return node;
}

ASTNode* create_identifier_node(char *name) {
    ASTNode *node = create_node(AST_IDENTIFIER);
    node->data.identifier.name = name ? strdup(name) : NULL;
    return node;
}

ASTNode* create_int_const_node(int value) {
    ASTNode *node = create_node(AST_INTEGER_CONST);
    node->data.int_const.value = value;
    return node;
}

ASTNode* create_string_const_node(char *value) {
    ASTNode *node = create_node(AST_STRING_CONST);
    node->data.string_const.value = value ? strdup(value) : NULL;
    return node;
}

ASTNode* append_node(ASTNode *list, ASTNode *node) {
    if (!list) {
        return node;
    }

    ASTNode *current = list;
    while (current->next) {
        current = current->next;
    }
    current->next = node;
    return list;
}

const char* get_op_string(BinaryOp op) {
    switch (op) {
        case OP_ADD: return "+";
        case OP_SUB: return "-";
        case OP_MUL: return "*";
        case OP_DIV: return "/";
        case OP_MOD: return "%";
        case OP_EQ:  return "==";
        case OP_NE:  return "!=";
        case OP_LT:  return "<";
        case OP_LE:  return "<=";
        case OP_GT:  return ">";
        case OP_GE:  return ">=";
        case OP_AND: return "&&";
        case OP_OR:  return "||";
        default:     return "?";
    }
}

const char* get_unary_op_string(UnaryOp op) {
    switch (op) {
        case OP_NEG:  return "-";
        case OP_NOT:  return "!";
        case OP_ADDR: return "&";
        default:      return "?";
    }
}

const char* get_type_string(DataType type) {
    switch (type) {
        case TYPE_INT:  return "int";
        case TYPE_VOID: return "void";
        default:        return "unknown";
    }
}

static void print_indent(int indent) {
    for (int i = 0; i < indent; i++) {
        printf("  ");
    }
}

void print_ast(ASTNode *node, int indent) {
    if (!node) {
        return;
    }

    print_indent(indent);

    switch (node->type) {
        case AST_PROGRAM:
            printf("Program: package %s\n", node->data.program.package_name);
            print_ast(node->data.program.declarations, indent + 1);
            print_ast(node->data.program.main_func, indent + 1);
            break;

        case AST_VAR_DECL:
            printf("VarDecl: %s (%s)\n",
                   node->data.var_decl.name,
                   get_type_string(node->data.var_decl.data_type));
            if (node->data.var_decl.init_value) {
                print_ast(node->data.var_decl.init_value, indent + 1);
            }
            break;

        case AST_FUNC_DECL:
            printf("FuncDecl: %s -> %s\n",
                   node->data.func_decl.name,
                   get_type_string(node->data.func_decl.return_type));
            if (node->data.func_decl.params) {
                print_indent(indent + 1);
                printf("Parameters:\n");
                print_ast(node->data.func_decl.params, indent + 2);
            }
            print_indent(indent + 1);
            printf("Body:\n");
            print_ast(node->data.func_decl.body, indent + 2);
            break;

        case AST_ASSIGN_STMT:
            printf("Assignment: %s =\n", node->data.assign.var_name);
            print_ast(node->data.assign.value, indent + 1);
            break;

        case AST_RETURN_STMT:
            printf("Return Statement\n");
            if (node->data.return_stmt.value) {
                print_ast(node->data.return_stmt.value, indent + 1);
            }
            break;

        case AST_SCANF_STMT:
            printf("Scanf: %s\n", node->data.scanf_stmt.format);
            print_ast(node->data.scanf_stmt.var_list, indent + 1);
            break;

        case AST_PRINTF_STMT:
            printf("Printf: %s\n", node->data.printf_stmt.format);
            if (node->data.printf_stmt.arg_list) {
                print_ast(node->data.printf_stmt.arg_list, indent + 1);
            }
            break;

        case AST_BLOCK_STMT:
            printf("Block:\n");
            print_ast(node->data.block.statements, indent + 1);
            break;

        case AST_BINARY_EXPR:
            printf("BinaryOp: %s\n", get_op_string(node->data.binary.op));
            print_ast(node->data.binary.left, indent + 1);
            print_ast(node->data.binary.right, indent + 1);
            break;

        case AST_UNARY_EXPR:
            printf("UnaryOp: %s\n", get_unary_op_string(node->data.unary.op));
            print_ast(node->data.unary.operand, indent + 1);
            break;

        case AST_IDENTIFIER:
            printf("Identifier: %s\n", node->data.identifier.name);
            break;

        case AST_INTEGER_CONST:
            printf("Integer: %d\n", node->data.int_const.value);
            break;

        case AST_STRING_CONST:
            printf("String: %s\n", node->data.string_const.value);
            break;

        default:
            printf("Unknown node type\n");
            break;
    }

    if (node->next) {
        print_ast(node->next, indent);
    }
}

void free_ast(ASTNode *node) {
    if (!node) {
        return;
    }

    switch (node->type) {
        case AST_PROGRAM:
            free(node->data.program.package_name);
            free_ast(node->data.program.declarations);
            free_ast(node->data.program.main_func);
            break;

        case AST_VAR_DECL:
            free(node->data.var_decl.name);
            free_ast(node->data.var_decl.init_value);
            break;

        case AST_FUNC_DECL:
            free(node->data.func_decl.name);
            free_ast(node->data.func_decl.params);
            free_ast(node->data.func_decl.body);
            break;

        case AST_ASSIGN_STMT:
            free(node->data.assign.var_name);
            free_ast(node->data.assign.value);
            break;

        case AST_RETURN_STMT:
            free_ast(node->data.return_stmt.value);
            break;

        case AST_SCANF_STMT:
            free(node->data.scanf_stmt.format);
            free_ast(node->data.scanf_stmt.var_list);
            break;

        case AST_PRINTF_STMT:
            free(node->data.printf_stmt.format);
            free_ast(node->data.printf_stmt.arg_list);
            break;

        case AST_BLOCK_STMT:
            free_ast(node->data.block.statements);
            break;

        case AST_BINARY_EXPR:
            free_ast(node->data.binary.left);
            free_ast(node->data.binary.right);
            break;

        case AST_UNARY_EXPR:
            free_ast(node->data.unary.operand);
            break;

        case AST_IDENTIFIER:
            free(node->data.identifier.name);
            break;

        case AST_STRING_CONST:
            free(node->data.string_const.value);
            break;

        default:
            break;
    }

    free_ast(node->next);
    free(node);
}
