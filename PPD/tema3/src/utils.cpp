#include "utils.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

BigNumber readFromFile(const char* filename) {
    FILE* file = fopen(filename, "r");
    if (!file) {
        fprintf(stderr, "Error: Could not open file %s\n", filename);
        exit(1);
    }

    int n;
    if (fscanf(file, "%d", &n) != 1) {
        fprintf(stderr, "Error: Could not read number of digits from %s\n", filename);
        fclose(file);
        exit(1);
    }

    char* numStr = (char*)malloc((n + 1) * sizeof(char));
    if (!numStr) {
        fprintf(stderr, "Error: Memory allocation failed\n");
        fclose(file);
        exit(1);
    }

    if (fscanf(file, "%s", numStr) != 1) {
        fprintf(stderr, "Error: Could not read number from %s\n", filename);
        free(numStr);
        fclose(file);
        exit(1);
    }

    fclose(file);

    if ((int)strlen(numStr) != n) {
        fprintf(stderr, "Warning: Number length mismatch in %s (expected %d, got %lu)\n",
                filename, n, strlen(numStr));
    }

    BigNumber result(numStr);
    free(numStr);

    return result;
}

void writeToFile(const char* filename, const BigNumber& num) {
    FILE* file = fopen(filename, "w");
    if (!file) {
        fprintf(stderr, "Error: Could not open file %s for writing\n", filename);
        exit(1);
    }

    fprintf(file, "%d\n", num.length);

    for (int i = num.length - 1; i >= 0; i--) {
        fprintf(file, "%d", num.digits[i]);
    }
    fprintf(file, "\n");

    fclose(file);
}

int min(int first, int second) {
    return (first < second ? first : second);
}

int max(int first, int second) {
    return (first > second ? first : second);
}
