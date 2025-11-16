#ifndef QUEUE_H
#define QUEUE_H

#include <pthread.h>
#include <semaphore.h>

typedef struct {
    int id;
    int grade;
} GradePair;

typedef struct QueueNode {
    GradePair data;
    struct QueueNode* next;
} QueueNode;

typedef struct {
    QueueNode* head;
    QueueNode* tail;
    pthread_mutex_t mutex;
    sem_t items;
    int readers_done;
    pthread_mutex_t done_mutex;
} GradeQueue;

GradeQueue* createQueue();
void destroyQueue(GradeQueue* queue);
void enqueue(GradeQueue* queue, GradePair pair);
int dequeue(GradeQueue* queue, GradePair* pair);
void markReadersDone(GradeQueue* queue);

#endif
