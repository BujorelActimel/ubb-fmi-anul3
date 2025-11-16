#include <stdio.h>
#include <time.h>
#include "list.c"

int main() {
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);

    List* gradeList = createList();

    for (int i = 1; i <= 10; i++) {
        char filename[50];
        sprintf(filename, "data/proiect%d.txt", i);
        readFromFile(gradeList, filename);
    }

    saveToFile(gradeList, "rezultate.txt");

    clock_gettime(CLOCK_MONOTONIC, &end);

    double time_spent = (end.tv_sec - start.tv_sec) +
                        (end.tv_nsec - start.tv_nsec) / 1000000000.0;

    printf("Sequential execution time: %.6f seconds\n", time_spent);

    destroyList(gradeList);
    return 0;
}
