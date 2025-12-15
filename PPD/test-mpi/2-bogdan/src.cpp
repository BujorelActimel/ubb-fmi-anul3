#include <iostream>
#include <fstream>
#include <vector>
#include <mpi.h>

using namespace std;

int f(int numar, int x) {
    int sum = 0;
    while (numar) {
        sum += (numar % 10);
        numar /= 10;
    }
    return sum < x ? 1 : 2;
}

int pow(int base, int exponent) {
    int ans = 1;
    for (int i = 1; i <= exponent; i++) {
        ans *= base;
    }
    return ans;
}

int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);

    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    int x;
    int chunk_size;
    vector<int> numbers;

    // ETAPA 1
    if (rank == 0) {
        scanf("%d", &x);
        printf("Sunt procesul master\n Am citit X = %d\n", x);

        int number;

        ifstream fin("numbers.txt");
        while (fin >> number) {
            numbers.push_back(number);
        }
        fin.close();
        printf("Am citit %ld numere din fisier\n", numbers.size());

        chunk_size = numbers.size()/size;
    }

    MPI_Bcast(&x, 1, MPI_INT, 0, MPI_COMM_WORLD);
    MPI_Bcast(&chunk_size, 1, MPI_INT, 0, MPI_COMM_WORLD);

    vector<int> localBuffer(chunk_size);

    MPI_Scatter(
        numbers.data(), 
        chunk_size, 
        MPI_INT, 
        localBuffer.data(),
        chunk_size,
        MPI_INT,
        0,
        MPI_COMM_WORLD
    );

    // ETAPA 2
    int counterA = 0;
    int counterB = 0;
    for (int i = 0; i < chunk_size; i++) {
        if (f(localBuffer[i], x) == 1) {
            counterA++;
        }
        else {
            counterB++;
        }
    }
    if (counterA > counterB) {
        for (int i = 0; i < chunk_size; i++) {
            localBuffer[i] *= pow(2, counterA-counterB);
        }
    }
    if (counterB > counterA) {
        for (int i = 0; i < chunk_size; i++) {
            localBuffer[i] /= pow(2, counterB-counterA);
        }
    }

    MPI_Gather(
        localBuffer.data(),
        chunk_size,
        MPI_INT,
        numbers.data(),
        chunk_size,
        MPI_INT,
        0,
        MPI_COMM_WORLD
    );

    vector<int> allA, allB;
    if (rank == 1) {
        allA.resize(size);
        allB.resize(size);
    }

    MPI_Gather(
        &counterA,
        1,
        MPI_INT,
        allA.data(),
        1,
        MPI_INT,
        1,
        MPI_COMM_WORLD
    );

    MPI_Gather(
        &counterB,
        1,
        MPI_INT,
        allB.data(),
        1,
        MPI_INT,
        1,
        MPI_COMM_WORLD
    );
    
    // ETAPA 3
    if (rank == 0) {
        ofstream fout("result.txt");
        for (int num: numbers) {
            fout << num << ' ';
        }
        fout.close();
    }
    if (rank == 1) {
        for (int i = 0; i < size; i++) {
            printf("procesul %d:\n  A=%d\n  B=%d\n", i, allA[i], allB[i]);
        }
    }


    MPI_Finalize();
    return 0;
}
