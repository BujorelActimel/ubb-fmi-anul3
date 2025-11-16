#include <pthread.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include "thread_safe_list.h"
#include "queue.h"
#include "list.h"

typedef struct {
    GradeQueue* queue;
    char** filenames;
    int start_file;
    int end_file;
} ReaderArgs;

typedef struct {
    GradeQueue* queue;
    ThreadSafeList* tsList;
} WorkerArgs;

void* readerThread(void* arg) {
    ReaderArgs* args = (ReaderArgs*)arg;

    for (int i = args->start_file; i < args->end_file; i++) {
        FILE* file = fopen(args->filenames[i], "r");
        if (file == NULL) {
            fprintf(stderr, "Warning: Could not open %s\n", args->filenames[i]);
            continue;
        }

        char line[256];
        int id, grade;
        while (fgets(line, sizeof(line), file) != NULL) {
            if (sscanf(line, "(%d, %d)", &id, &grade) == 2) {
                GradePair pair = {id, grade};
                enqueue(args->queue, pair);
            }
        }

        fclose(file);
    }

    return NULL;
}

void* workerThread(void* arg) {
    WorkerArgs* args = (WorkerArgs*)arg;

    GradePair pair;
    while (dequeue(args->queue, &pair)) {
        threadSafeAddGrade(args->tsList, pair.id, pair.grade);
    }

    return NULL;
}

double run_parallel(int p, int p_r, const char* output_file) {
    int p_w = p - p_r;

    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);

    GradeQueue* queue = createQueue();
    ThreadSafeList* tsList = createThreadSafeList();

    char* filenames[10];
    for (int i = 0; i < 10; i++) {
        filenames[i] = malloc(50);
        sprintf(filenames[i], "data/proiect%d.txt", i + 1);
    }

    pthread_t* readers = malloc(p_r * sizeof(pthread_t));
    ReaderArgs* readerArgs = malloc(p_r * sizeof(ReaderArgs));
    int files_per_reader = 10 / p_r;
    for (int i = 0; i < p_r; i++) {
        readerArgs[i].queue = queue;
        readerArgs[i].filenames = filenames;
        readerArgs[i].start_file = i * files_per_reader;
        readerArgs[i].end_file = (i == p_r - 1) ? 10 : (i + 1) * files_per_reader;
        pthread_create(&readers[i], NULL, readerThread, &readerArgs[i]);
    }

    WorkerArgs workerArgs = {queue, tsList};
    pthread_t* workers = malloc(p_w * sizeof(pthread_t));
    for (int i = 0; i < p_w; i++) {
        pthread_create(&workers[i], NULL, workerThread, &workerArgs);
    }

    for (int i = 0; i < p_r; i++) {
        pthread_join(readers[i], NULL);
    }
    markReadersDone(queue);

    for (int i = 0; i < p_w; i++) {
        pthread_join(workers[i], NULL);
    }

    clock_gettime(CLOCK_MONOTONIC, &end);

    saveToFile(getList(tsList), output_file);

    double time_spent = (end.tv_sec - start.tv_sec) +
                        (end.tv_nsec - start.tv_nsec) / 1e9;

    destroyThreadSafeList(tsList);
    destroyQueue(queue);
    for (int i = 0; i < 10; i++) {
        free(filenames[i]);
    }
    free(readers);
    free(readerArgs);
    free(workers);

    return time_spent;
}
