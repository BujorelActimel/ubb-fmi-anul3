#include <time.h>
#include <stdio.h>
#include "list.h"

double run_sequential(const char* output_file) {
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);

    List* gradeList = createList();

    for (int i = 1; i <= 10; i++) {
        char filename[50];
        sprintf(filename, "data/proiect%d.txt", i);
        readFromFile(gradeList, filename);
    }

    saveToFile(gradeList, output_file);

    clock_gettime(CLOCK_MONOTONIC, &end);

    double time_spent = (end.tv_sec - start.tv_sec) +
                        (end.tv_nsec - start.tv_nsec) / 1e9;

    destroyList(gradeList);

    return time_spent;
}
