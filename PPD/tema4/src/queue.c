#include <stdlib.h>
#include "queue.h"

GradeQueue* createQueue() {
    GradeQueue* queue = malloc(sizeof(GradeQueue));
    queue->head = NULL;
    queue->tail = NULL;
    pthread_mutex_init(&queue->mutex, NULL);
    sem_init(&queue->items, 0, 0);
    queue->readers_done = 0;
    pthread_mutex_init(&queue->done_mutex, NULL);
    return queue;
}

void destroyQueue(GradeQueue* queue) {
    QueueNode* current = queue->head;
    while (current != NULL) {
        QueueNode* next = current->next;
        free(current);
        current = next;
    }
    pthread_mutex_destroy(&queue->mutex);
    sem_destroy(&queue->items);
    pthread_mutex_destroy(&queue->done_mutex);
    free(queue);
}

void enqueue(GradeQueue* queue, GradePair pair) {
    QueueNode* node = malloc(sizeof(QueueNode));
    node->data = pair;
    node->next = NULL;

    pthread_mutex_lock(&queue->mutex);
    if (queue->tail == NULL) {
        queue->head = queue->tail = node;
    } else {
        queue->tail->next = node;
        queue->tail = node;
    }
    pthread_mutex_unlock(&queue->mutex);

    sem_post(&queue->items);
}

int dequeue(GradeQueue* queue, GradePair* pair) {
    if (sem_trywait(&queue->items) == 0) {
        pthread_mutex_lock(&queue->mutex);
        if (queue->head != NULL) {
            QueueNode* node = queue->head;
            *pair = node->data;
            queue->head = node->next;
            if (queue->head == NULL) {
                queue->tail = NULL;
            }
            pthread_mutex_unlock(&queue->mutex);
            free(node);
            return 1;
        }
        pthread_mutex_unlock(&queue->mutex);
    }

    pthread_mutex_lock(&queue->done_mutex);
    int done = queue->readers_done;
    pthread_mutex_unlock(&queue->done_mutex);

    if (done) {
        return 0;
    }

    if (sem_wait(&queue->items) == 0) {
        pthread_mutex_lock(&queue->mutex);
        if (queue->head == NULL) {
            pthread_mutex_unlock(&queue->mutex);
            return 0;
        }
        QueueNode* node = queue->head;
        *pair = node->data;
        queue->head = node->next;
        if (queue->head == NULL) {
            queue->tail = NULL;
        }
        pthread_mutex_unlock(&queue->mutex);
        free(node);
        return 1;
    }

    return 0;
}

void markReadersDone(GradeQueue* queue) {
    pthread_mutex_lock(&queue->done_mutex);
    queue->readers_done = 1;
    pthread_mutex_unlock(&queue->done_mutex);

    for (int i = 0; i < 100; i++) {
        sem_post(&queue->items);
    }
}
