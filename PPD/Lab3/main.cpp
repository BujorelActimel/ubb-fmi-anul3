#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char* argv[]) {
    int id, numProc;

    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &numProc);
    MPI_Comm_rank(MPI_COMM_WORLD, &id);

    const int n = 10;
    int* a = (int*)malloc(n * sizeof(int));
    int* b = (int*)malloc(n * sizeof(int));
    int* c = (int*)malloc(n * sizeof(int));

    if (id == 0) {
        for (int i = 0; i < n; i++) {
            a[i] = i;
            b[i] = i;
        }

        int div = n / (numProc-1);
        int mod  = n % (numProc-1);

        int start = 0;
        int end = div;

        for (int i = 1; i < numProc; i++) {
            if (i == numProc - 1) {
                end += mod;
            }

            int count = end - start;

            int buffer_size;
            MPI_Pack_size(3, MPI_INT, MPI_COMM_WORLD, &buffer_size);
            int array_size;
            MPI_Pack_size(count, MPI_INT, MPI_COMM_WORLD, &array_size);
            buffer_size += 2 * array_size;

            char* buffer = (char*)malloc(buffer_size);
            int position = 0;

            MPI_Pack(&start, 1, MPI_INT, buffer, buffer_size, &position, MPI_COMM_WORLD);
            MPI_Pack(&end, 1, MPI_INT, buffer, buffer_size, &position, MPI_COMM_WORLD);
            MPI_Pack(&count, 1, MPI_INT, buffer, buffer_size, &position, MPI_COMM_WORLD);

            MPI_Pack(&a[start], count, MPI_INT, buffer, buffer_size, &position, MPI_COMM_WORLD);
            MPI_Pack(&b[start], count, MPI_INT, buffer, buffer_size, &position, MPI_COMM_WORLD);

            MPI_Send(buffer, position, MPI_PACKED, i, 0, MPI_COMM_WORLD);

            free(buffer);

            start = end;
            end = start + div;
        }

        for (int i = 1; i < numProc; i++) {
            int workerStart;
            MPI_Recv(&workerStart, 1, MPI_INT, i, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            int count;
            MPI_Recv(&count, 1, MPI_INT, i, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            MPI_Recv(&c[workerStart], count, MPI_INT, i, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        }

        printf("Result: ");
        for (int i = 0; i < n; i++) {
            printf("%d ", c[i]);
        }
        printf("\n");
    }
    else {
        // Probe to get message size
        MPI_Status status;
        MPI_Probe(0, 0, MPI_COMM_WORLD, &status);

        int buffer_size;
        MPI_Get_count(&status, MPI_PACKED, &buffer_size);

        char* buffer = (char*)malloc(buffer_size);
        MPI_Recv(buffer, buffer_size, MPI_PACKED, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

        // Unpack data
        int position = 0;
        int start, end, count;
        MPI_Unpack(buffer, buffer_size, &position, &start, 1, MPI_INT, MPI_COMM_WORLD);
        MPI_Unpack(buffer, buffer_size, &position, &end, 1, MPI_INT, MPI_COMM_WORLD);
        MPI_Unpack(buffer, buffer_size, &position, &count, 1, MPI_INT, MPI_COMM_WORLD);

        int* local_a = (int*)malloc(count * sizeof(int));
        int* local_b = (int*)malloc(count * sizeof(int));
        int* local_c = (int*)malloc(count * sizeof(int));

        MPI_Unpack(buffer, buffer_size, &position, local_a, count, MPI_INT, MPI_COMM_WORLD);
        MPI_Unpack(buffer, buffer_size, &position, local_b, count, MPI_INT, MPI_COMM_WORLD);

        free(buffer);

        for (int i = 0; i < count; i++) {
            local_c[i] = local_a[i] + local_b[i];
        }

        printf("rank = %d: %d -> %d\n", id, start, end);

        MPI_Send(&start, 1, MPI_INT, 0, 0, MPI_COMM_WORLD);
        MPI_Send(&count, 1, MPI_INT, 0, 0, MPI_COMM_WORLD);
        MPI_Send(local_c, count, MPI_INT, 0, 0, MPI_COMM_WORLD);

        free(local_a);
        free(local_b);
        free(local_c);
    }

    free(a);
    free(b);
    free(c);

    MPI_Finalize();
    return 0;
}
