#include <stdio.h>
#include <string.h>
#include "data_generator.h"
#include "sequential.h"
#include "parallel.h"

#define NUM_STUDENTS 200
#define NUM_PROJECTS 10
#define MIN_GRADES_PER_FILE 80
#define MAX_GRADE 10

int compare_results(const char* file1, const char* file2) {
    FILE* f1 = fopen(file1, "r");
    FILE* f2 = fopen(file2, "r");

    if (!f1 || !f2) {
        if (f1) fclose(f1);
        if (f2) fclose(f2);
        return -1;
    }

    char line1[256], line2[256];

    while (1) {
        char* r1 = fgets(line1, sizeof(line1), f1);
        char* r2 = fgets(line2, sizeof(line2), f2);

        if (r1 == NULL && r2 == NULL) {
            fclose(f1);
            fclose(f2);
            return 0;
        }

        if (r1 == NULL || r2 == NULL || strcmp(line1, line2) != 0) {
            fclose(f1);
            fclose(f2);
            return 1;
        }
    }
}

int main() {
    generate_test_data(NUM_STUDENTS, NUM_PROJECTS, MIN_GRADES_PER_FILE, MAX_GRADE);

    double seq_time = run_sequential("rezultate_seq.txt");
    printf("Sequential: %.6f seconds\n", seq_time);

    printf("Parallel:\n");
    printf("---------------------------------------------------------------\n");
    printf("Configuration        | Time (s)   | Speed_diff | Valid | T_seq/T_par\n");
    printf("---------------------------------------------------------------\n");

    int configs[][2] = {
        {4, 1}, {4, 2},
        {8, 1}, {8, 2},
        {16, 1}, {16, 2}
    };
    int num_configs = 6;

    for (int i = 0; i < num_configs; i++) {
        int p = configs[i][0];
        int p_r = configs[i][1];
        int p_w = p - p_r;

        double time = run_parallel(p, p_r, "rezultate.txt");

        int valid = (compare_results("rezultate_seq.txt", "rezultate.txt") == 0);
        double speed_diff = seq_time - time;
        double ratio = seq_time / time;

        printf("p=%2d, p_r=%d, p_w=%2d | %10.6f | %10.6f | %5s | %11.3f\n",
               p, p_r, p_w, time, speed_diff, valid ? "OK" : "FAIL", ratio);

        if (!valid) {
            printf("  WARNING: Results do not match sequential output!\n");
        }
    }
    return 0;
}
