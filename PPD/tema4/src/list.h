#ifndef LIST_H
#define LIST_H

typedef struct {
    int id;
    int totalGrade;
} Data;

typedef struct Node {
    Data data;
    struct Node* next;
} Node;

typedef struct List {
    Node* head;
    Node* tail;
} List;

List* createList();
void destroyList(List* list);
void addNode(List* list, Data data);
void addGrade(List* list, int id, int grade);
void printList(List* list);
void readFromFile(List* list, const char* filename);
void saveToFile(List* list, const char* filename);

#endif
