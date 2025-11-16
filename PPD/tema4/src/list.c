#include <stdlib.h>
#include <stdio.h>
#include "list.h"

List* createList() {
    List* list = malloc(sizeof(List));
    list->head = NULL;
    list->tail = NULL;
    return list;
}

void destroyList(List* list) {
    Node* current = list->head;
    while (current != NULL) {
        Node* next = current->next;
        free(current);
        current = next;
    }
    free(list);
}

void addNode(List* list, Data data) {
    Node* newNode = malloc(sizeof(Node));
    newNode->data = data;
    newNode->next = NULL;

    if (list->head == NULL) {
        list->head = newNode;
        list->tail = newNode;
    } else {
        list->tail->next = newNode;
        list->tail = newNode;
    }
}

void addGrade(List* list, int id, int grade) {
    Node* current = list->head;
    while (current != NULL) {
        if (current->data.id == id) {
            current->data.totalGrade += grade;
            return;
        }
        current = current->next;
    }
    Data data = {id, grade};
    addNode(list, data);
}

void printList(List* list) {
    Node* current = list->head;
    while (current != NULL) {
        printf("ID: %d, Total Grade: %d\n", current->data.id, current->data.totalGrade);
        current = current->next;
    }
}

void readFromFile(List* list, const char* filename) {
    FILE* file = fopen(filename, "r");
    if (file == NULL) {
        printf("Warning: Could not open file %s\n", filename);
        return;
    }

    char line[256];
    int id, grade;
    while (fgets(line, sizeof(line), file) != NULL) {
        if (sscanf(line, "(%d, %d)", &id, &grade) == 2) {
            addGrade(list, id, grade);
        }
    }

    fclose(file);
}

void sortList(List* list) {
    if (list->head == NULL || list->head->next == NULL) {
        return;
    }

    int swapped;
    do {
        swapped = 0;
        Node* current = list->head;

        while (current->next != NULL) {
            if (current->data.id > current->next->data.id) {
                Data temp = current->data;
                current->data = current->next->data;
                current->next->data = temp;
                swapped = 1;
            }
            current = current->next;
        }
    } while (swapped);
}

void saveToFile(List* list, const char* filename) {
    FILE* file = fopen(filename, "w");
    if (file == NULL) {
        printf("Error: Could not create file %s\n", filename);
        return;
    }

    sortList(list);

    Node* current = list->head;
    while (current != NULL) {
        fprintf(file, "(%d, %d)\n", current->data.id, current->data.totalGrade);
        current = current->next;
    }

    fclose(file);
}
