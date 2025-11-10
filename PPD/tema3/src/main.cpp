#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <chrono>
#include <mpi.h>
#include "BigNumber.h"
#include "utils.h"
#include "operations.h"

void printUsage(const char* programName) {
    printf("Usage: %s <variant> <input1> <input2> <output>\n", programName);
    printf("\nVariants:\n");
    printf("  sequential    - Sequential addition (Variant 0)\n");
    printf("  mpi1          - MPI standard communication (Variant 1)\n");
    printf("  mpi1opt       - MPI optimized (Variant 1.1)\n");
    printf("  mpi2          - MPI scatter/gather (Variant 2)\n");
    printf("  mpi3          - MPI asynchronous (Variant 3)\n");
    printf("\nExample:\n");
    printf("  %s sequential data/Numar1.txt data/Numar2.txt data/Numar3.txt\n", programName);
}

int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);

    int rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    if (argc != 5) {
        if (rank == 0) {
            printUsage(argv[0]);
        }
        MPI_Finalize();
        return 1;
    }

    const char* variant = argv[1];
    const char* input1 = argv[2];
    const char* input2 = argv[3];
    const char* output = argv[4];

    srand(time(NULL));

    auto start = std::chrono::high_resolution_clock::now();

    BigNumber a = readFromFile(input1);
    BigNumber b = readFromFile(input2);

    BigNumber result(1, 0);

    if (strcmp(variant, "sequential") == 0) {
        result = addSequential(a, b);
    } 
    else if (strcmp(variant, "mpi1") == 0) {
        result = addMPI1(a, b);
    } 
    else if (strcmp(variant, "mpi1opt") == 0) {
        result = addMPI1_Optimized(a, b);
    } 
    else if (strcmp(variant, "mpi2") == 0) {
        result = addMPI2_ScatterGather(a, b);
    } 
    else if (strcmp(variant, "mpi3") == 0) {
        if (rank == 0) {
            printf("Error: MPI Variant 3 not yet implemented\n");
        }
        MPI_Finalize();
        return 1;
    } 
    else {
        if (rank == 0) {
            printf("Error: Unknown variant '%s'\n", variant);
            printUsage(argv[0]);
        }
        MPI_Finalize();
        return 1;
    }

    if (rank == 0) {
        writeToFile(output, result);

        auto end = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);

        printf("%ld\n", duration.count());
    }

    MPI_Finalize();
    return 0;
}
