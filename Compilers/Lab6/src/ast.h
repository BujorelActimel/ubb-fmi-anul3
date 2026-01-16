#ifndef AST_H
#define AST_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum {
    AST_PROGRAM,
    AST_DECLARATION_LIST,
    AST_STATEMENT_LIST,

    AST_VAR_DECL,
    AST_FUNC_DECL,

    AST_ASSIGN_STMT,
    AST_IF_STMT,
    AST_RETURN_STMT,
    AST_SCANF_STMT,
    AST_PRINTF_STMT,
    AST_BLOCK_STMT,

    AST_BINARY_EXPR,
    AST_UNARY_EXPR,
    AST_IDENTIFIER,
    AST_INTEGER_CONST,
    AST_STRING_CONST
} ASTNodeType;

typedef enum {
    OP_ADD,      // +
    OP_SUB,      // -
    OP_MUL,      // *
    OP_DIV,      // /
    OP_MOD,      // %
    OP_EQ,       // ==
    OP_NE,       // !=
    OP_LT,       // <
    OP_LE,       // <=
    OP_GT,       // >
    OP_GE,       // >=
    OP_AND,      // &&
    OP_OR        // ||
} BinaryOp;

typedef enum {
    OP_NEG,      // -
    OP_NOT,      // !
    OP_ADDR      // & (address-of)
} UnaryOp;

typedef enum {
    TYPE_INT,
    TYPE_VOID
} DataType;

struct ASTNode;

typedef struct ASTNode {
    ASTNodeType type;

    union {
        struct {
            char *package_name;
            struct ASTNode *declarations;
            struct ASTNode *main_func;
        } program;

        struct {
            char *name;
            DataType data_type;
            struct ASTNode *init_value;
        } var_decl;

        struct {
            char *name;
            DataType return_type;
            struct ASTNode *params;
            struct ASTNode *body;
        } func_decl;

        struct {
            char *var_name;
            struct ASTNode *value;
        } assign;

        struct {
            struct ASTNode *value;
        } return_stmt;

        struct {
            char *format;
            struct ASTNode *var_list;
        } scanf_stmt;

        struct {
            char *format;
            struct ASTNode *arg_list;
        } printf_stmt;

        struct {
            struct ASTNode *statements;
        } block;

        struct {
            BinaryOp op;
            struct ASTNode *left;
            struct ASTNode *right;
        } binary;

        struct {
            UnaryOp op;
            struct ASTNode *operand;
        } unary;

        struct {
            char *name;
        } identifier;

        struct {
            int value;
        } int_const;

        struct {
            char *value;
        } string_const;
    } data;

    struct ASTNode *next;

    int line;
    int column;
} ASTNode;

ASTNode* create_program_node(char *package_name, ASTNode *declarations, ASTNode *main_func);
ASTNode* create_declaration_list_node(ASTNode *first);
ASTNode* create_statement_list_node(ASTNode *first);

ASTNode* create_var_decl_node(char *name, DataType type, ASTNode *init_value);
ASTNode* create_func_decl_node(char *name, DataType return_type, ASTNode *params, ASTNode *body);

ASTNode* create_assign_stmt_node(char *var_name, ASTNode *value);
ASTNode* create_if_stmt_node(ASTNode *condition, ASTNode *then_block, ASTNode *else_block);
ASTNode* create_return_stmt_node(ASTNode *value);
ASTNode* create_scanf_stmt_node(char *format, ASTNode *var_list);
ASTNode* create_printf_stmt_node(char *format, ASTNode *arg_list);
ASTNode* create_block_stmt_node(ASTNode *statements);

ASTNode* create_binary_expr_node(BinaryOp op, ASTNode *left, ASTNode *right);
ASTNode* create_unary_expr_node(UnaryOp op, ASTNode *operand);
ASTNode* create_identifier_node(char *name);
ASTNode* create_int_const_node(int value);
ASTNode* create_string_const_node(char *value);

ASTNode* append_node(ASTNode *list, ASTNode *node);

void print_ast(ASTNode *node, int indent);
void free_ast(ASTNode *node);

const char* get_op_string(BinaryOp op);
const char* get_unary_op_string(UnaryOp op);
const char* get_type_string(DataType type);

#endif /* AST_H */
