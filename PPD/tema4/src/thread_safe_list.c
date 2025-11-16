#include <stdlib.h>
#include "thread_safe_list.h"

ThreadSafeList* createThreadSafeList() {
    ThreadSafeList* tsList = malloc(sizeof(ThreadSafeList));
    tsList->list = createList();
    pthread_mutex_init(&tsList->mutex, NULL);
    return tsList;
}

void destroyThreadSafeList(ThreadSafeList* tsList) {
    destroyList(tsList->list);
    pthread_mutex_destroy(&tsList->mutex);
    free(tsList);
}

void threadSafeAddGrade(ThreadSafeList* tsList, int id, int grade) {
    pthread_mutex_lock(&tsList->mutex);
    addGrade(tsList->list, id, grade);
    pthread_mutex_unlock(&tsList->mutex);
}

List* getList(ThreadSafeList* tsList) {
    return tsList->list;
}
