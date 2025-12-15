#include <iostream>
#include <fstream>
#include <vector>
#include <mpi.h>

using namespace std;

int f(int numar, int x) {
    int sum = 0;
    while (numar) {
        sum += numar % 10;
        numar /= 10;
    }
    return (sum < x) ? 1 : 2;
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
    int chunkSize;
    int len;
    vector<int> numbers;
    vector<int> localNums;   

    if (rank == 0) {
        cin >> x;
    }
    MPI_Bcast(&x, 1, MPI_INT, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        int num;
        ifstream fin("numbers.txt");
        while(fin >> num) {
            numbers.push_back(num);
        }
        fin.close();

        len = numbers.size();

        chunkSize = len / size;
        for (int id = 1; id < size; id++) {
            MPI_Send(&chunkSize, 1, MPI_INT, id, 0, MPI_COMM_WORLD);
        }
        for (int i = 0; i < len; i+= (2*chunkSize)) {
            localNums.push_back(numbers[i]);
        }
        for (int id = 1; id < size; id++) {
            vector<int> numsToSend;
            for (int i = id; i < len; i += (2*chunkSize)) {
                numsToSend.push_back(numbers[i]);
            }
            MPI_Send(numsToSend.data(), chunkSize, MPI_INT, id, 0, MPI_COMM_WORLD);
        }
    }

    if (rank > 0) {
        MPI_Recv(&chunkSize, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, NULL);
        localNums.resize(chunkSize);

        MPI_Recv(localNums.data(), chunkSize, MPI_INT, 0, 0, MPI_COMM_WORLD, NULL);
    }

    int countA = 0;
    int countB = 0;
    for (int num: localNums) {
        if (f(num, x) == 1) {
            countA++;
        }
        else {
            countB++;
        }
    }

    if (countA > countB) {
        for (int i = 0; i < chunkSize; i++) {
            localNums[i] *= pow(2, countA-countB);
        }
    }
    if (countB>countA) {
        for (int i = 0; i < chunkSize; i++) {
            localNums[i] /= pow(2, countB-countA);
        }
    }

    if (rank == 0) {
        for (int id = 1; id < size; id++) {
            vector<int> numsToRecv(chunkSize);
            MPI_Recv(numsToRecv.data(), chunkSize, MPI_INT, id, 0, MPI_COMM_WORLD, NULL);
            int idx = 0;
            for (int i = id; i < len; i += (2*chunkSize)) {
                numbers[i] = numsToRecv[idx++];
            }
        }

        ofstream fout("result.txt");
        for (int num: numbers) {
            fout << num << ' ';
        }
        fout.close();
    }
    else {
        MPI_Send(localNums.data(), chunkSize, MPI_INT, 0, 0, MPI_COMM_WORLD);
    }

    if (rank == 1) {
        for (int i = 0; i < size; i++) {
            int A, B;
            if (i == 1) {
                A = countA;
                B = countB;
            }
            else {
                MPI_Recv(&A, 1, MPI_INT, i, 0, MPI_COMM_WORLD, NULL);
                MPI_Recv(&B, 1, MPI_INT, i, 0, MPI_COMM_WORLD, NULL);
            }
            printf("Pentru procesul %d A=%d B=%d\n", i, A, B);

        }
    }
    else {
        MPI_Send(&countA, 1, MPI_INT, 1, 0, MPI_COMM_WORLD);
        MPI_Send(&countB, 1, MPI_INT, 1, 0, MPI_COMM_WORLD);
    }

    MPI_Finalize();
    return 0;
}


// p = 5 -> 0 master

// n = 20

// p0 3 7 11 15 19
// p1 0 4 8  12 16
// p2 1 5 9  13 17
// p3 2 6 10 14 18
