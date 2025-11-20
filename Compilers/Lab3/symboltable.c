#include "symboltable.h"

static Node* create_node(const char *symbol, int position) {
    Node *node = (Node*)malloc(sizeof(Node));
    node->symbol = strdup(symbol);
    node->position = position;
    node->left = NULL;
    node->right = NULL;
    return node;
}

static Node* insert_node(Node *root, const char *symbol, int position) {
    if (root == NULL) {
        return create_node(symbol, position);
    }

    int cmp = strcmp(symbol, root->symbol);
    if (cmp < 0) {
        root->left = insert_node(root->left, symbol, position);
    } else if (cmp > 0) {
        root->right = insert_node(root->right, symbol, position);
    }

    return root;
}

static int search_node(Node *root, const char *symbol) {
    if (root == NULL) {
        return -1;
    }

    int cmp = strcmp(symbol, root->symbol);
    if (cmp == 0) {
        return root->position;
    } else if (cmp < 0) {
        return search_node(root->left, symbol);
    } else {
        return search_node(root->right, symbol);
    }
}

static void inorder_save(Node *root, FILE *file) {
    if (root != NULL) {
        inorder_save(root->left, file);
        fprintf(file, "%d,%s\n", root->position, root->symbol);
        inorder_save(root->right, file);
    }
}

static void free_nodes(Node *root) {
    if (root != NULL) {
        free_nodes(root->left);
        free_nodes(root->right);
        free(root->symbol);
        free(root);
    }
}

SymbolTable* st_create() {
    SymbolTable *st = (SymbolTable*)malloc(sizeof(SymbolTable));
    st->root = NULL;
    st->size = 0;
    return st;
}

int st_insert(SymbolTable *st, const char *symbol) {
    int pos = st_search(st, symbol);
    if (pos != -1) {
        return pos;
    }

    int new_pos = st->size;
    st->root = insert_node(st->root, symbol, new_pos);
    st->size++;
    return new_pos;
}

int st_search(SymbolTable *st, const char *symbol) {
    return search_node(st->root, symbol);
}

void st_save_to_csv(SymbolTable *st, const char *filename) {
    FILE *file = fopen(filename, "w");
    if (file == NULL) {
        fprintf(stderr, "Error: Cannot open file %s for writing\n", filename);
        return;
    }

    fprintf(file, "Position,Symbol\n");
    inorder_save(st->root, file);
    fclose(file);
}

void st_destroy(SymbolTable *st) {
    if (st != NULL) {
        free_nodes(st->root);
        free(st);
    }
}
