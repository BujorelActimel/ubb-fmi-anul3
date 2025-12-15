#include <iostream>
#include <fstream>
#include <vector>
#include <mpi.h>

using namespace std;

int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);

    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    int lines;
    int n;
    vector<int> localLine;

    if (rank == 0) {
        ifstream fin("input2.txt");
        fin >> n;
        for (int i = 1; i < size; i++) {
            lines = n/(size-1) + ((i <= n%(size-1)) ? 1 : 0);
            MPI_Send(&lines, 1, MPI_INT, i, 0, MPI_COMM_WORLD);
        }
        for (int i = 0; i < n; i++) {
            MPI_Send(&n, 1, MPI_INT, i%(size-1)+1, 0, MPI_COMM_WORLD);
            vector<int> line;
            for (int j = 0; j < n; j++) {
                int elem;
                fin >> elem;
                line.push_back(elem);
            }
            MPI_Send(line.data(), n, MPI_INT, i%(size-1)+1, 0, MPI_COMM_WORLD);
        }

        vector<int> finalResult(n);
        
        for (int id = 1; id < size; id++) {
            lines = n/(size-1) + ((id <= n%(size-1)) ? 1 : 0);
            vector<int> localResult(lines);
            MPI_Recv(localResult.data(), lines, MPI_INT, id, 0, MPI_COMM_WORLD, NULL);

            int idx = 0;

            for (int i = id-1; i < n; i += (size-1)) {
                finalResult[i] = localResult[idx++];
            }
        }

        ofstream fout("output.txt");
        for (int num: finalResult) {
            fout << num << ' ';
        }
        fout.close();
    }
    else {
        MPI_Recv(&lines, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, NULL);
        vector<int> localResult;

        for (int i = 0; i < lines; i++) {
            MPI_Recv(&n, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, NULL);
            localLine.resize(n);
            MPI_Recv(localLine.data(), n, MPI_INT, 0, 0, MPI_COMM_WORLD, NULL);

            int sum = 0;

            for (int num: localLine) {
                sum += num;
            }
            localResult.push_back(sum);
        }

        MPI_Send(localResult.data(), lines, MPI_INT, 0, 0, MPI_COMM_WORLD);
    }

    MPI_Finalize();
    return 0;
}
