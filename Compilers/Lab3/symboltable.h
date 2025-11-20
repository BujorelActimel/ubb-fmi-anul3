#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Node {
    char *symbol;
    int position;
    struct Node *left;
    struct Node *right;
} Node;

typedef struct SymbolTable {
    Node *root;
    int size;
} SymbolTable;

SymbolTable* st_create();

int st_insert(SymbolTable *st, const char *symbol);

int st_search(SymbolTable *st, const char *symbol);

void st_save_to_csv(SymbolTable *st, const char *filename);

void st_destroy(SymbolTable *st);

#endif
