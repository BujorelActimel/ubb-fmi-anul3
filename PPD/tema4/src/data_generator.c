#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/stat.h>
#include <sys/types.h>
#include "data_generator.h"

void generate_test_data(int num_students, int num_projects, int min_grades_per_file, int max_grade) {
    mkdir("data", 0755);

    srand(time(NULL));

    for (int project = 1; project <= num_projects; project++) {
        char filename[50];
        sprintf(filename, "data/proiect%d.txt", project);

        FILE* file = fopen(filename, "w");
        if (file == NULL) {
            fprintf(stderr, "Error: Could not create %s\n", filename);
            continue;
        }

        int num_grades = min_grades_per_file + rand() % 51;

        int* submitted = calloc(num_students + 1, sizeof(int));

        int* students = malloc(num_grades * sizeof(int));
        int count = 0;
        while (count < num_grades) {
            int student_id = 1 + rand() % num_students;
            if (!submitted[student_id]) {
                submitted[student_id] = 1;
                students[count++] = student_id;
            }
        }

        for (int i = 0; i < num_grades - 1; i++) {
            for (int j = i + 1; j < num_grades; j++) {
                if (students[i] > students[j]) {
                    int temp = students[i];
                    students[i] = students[j];
                    students[j] = temp;
                }
            }
        }

        for (int i = 0; i < num_grades; i++) {
            int grade = 1 + rand() % max_grade;
            fprintf(file, "(%d, %d)\n", students[i], grade);
        }

        free(submitted);
        free(students);
        fclose(file);
    }
}
