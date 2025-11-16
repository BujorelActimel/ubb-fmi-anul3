#ifndef THREAD_SAFE_LIST_H
#define THREAD_SAFE_LIST_H

#include <pthread.h>
#include "list.h"

typedef struct {
    List* list;
    pthread_mutex_t mutex;
} ThreadSafeList;

ThreadSafeList* createThreadSafeList();
void destroyThreadSafeList(ThreadSafeList* tsList);
void threadSafeAddGrade(ThreadSafeList* tsList, int id, int grade);
List* getList(ThreadSafeList* tsList);

#endif
