#include "convolution.h"
#include <fstream>
#include <iostream>
#include <thread>
#include <vector>
#include <cmath>

namespace StaticArray {

int F[MAX_SIZE][MAX_SIZE];
int V[MAX_SIZE][MAX_SIZE];
int C[MAX_KERNEL][MAX_KERNEL];

static int global_n, global_m, global_k;

static int getElement(int i, int j) {
    if (i < 0) i = 0;
    if (i >= global_n) i = global_n - 1;
    if (j < 0) j = 0;
    if (j >= global_m) j = global_m - 1;
    return F[i][j];
}

void readInput(const std::string& filename, int& n, int& m, int& k) {
    std::ifstream fin(filename);
    if (!fin) {
        std::cerr << "Error opening file: " << filename << std::endl;
        exit(1);
    }
    
    fin >> n >> m >> k;
    global_n = n; global_m = m; global_k = k;
    
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            fin >> F[i][j];
        }
    }
    
    for (int i = 0; i < k; i++) {
        for (int j = 0; j < k; j++) {
            fin >> C[i][j];
        }
    }
    
    fin.close();
}

void writeOutput(const std::string& filename, int n, int m) {
    std::ofstream fout(filename);
    if (!fout) {
        std::cerr << "Error opening file: " << filename << std::endl;
        exit(1);
    }
    
    fout << n << " " << m << "\n";
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            fout << V[i][j];
            if (j < m - 1) fout << " ";
        }
        fout << "\n";
    }
    
    fout.close();
}

void applyConvolution(int n, int m, int k) {
    global_n = n; global_m = m; global_k = k;
    int halfK = k / 2;
    
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            int sum = 0;
            for (int ki = 0; ki < k; ki++) {
                for (int kj = 0; kj < k; kj++) {
                    int fi = i + ki - halfK;
                    int fj = j + kj - halfK;
                    sum += getElement(fi, fj) * C[ki][kj];
                }
            }
            V[i][j] = sum;
        }
    }
}

static void workerRows(int startRow, int endRow) {
    int halfK = global_k / 2;
    
    for (int i = startRow; i < endRow; i++) {
        for (int j = 0; j < global_m; j++) {
            int sum = 0;
            for (int ki = 0; ki < global_k; ki++) {
                for (int kj = 0; kj < global_k; kj++) {
                    int fi = i + ki - halfK;
                    int fj = j + kj - halfK;
                    sum += getElement(fi, fj) * C[ki][kj];
                }
            }
            V[i][j] = sum;
        }
    }
}

void applyConvolutionParallelHorizontal(int n, int m, int k, int numThreads) {
    global_n = n; global_m = m; global_k = k;
    std::vector<std::thread> threads;
    
    int rowsPerThread = n / numThreads;
    int extraRows = n % numThreads;
    
    int startRow = 0;
    for (int t = 0; t < numThreads; t++) {
        int endRow = startRow + rowsPerThread + (t < extraRows ? 1 : 0);
        threads.emplace_back(workerRows, startRow, endRow);
        startRow = endRow;
    }
    
    for (auto& th : threads) {
        th.join();
    }
}

static void workerColumns(int startCol, int endCol) {
    int halfK = global_k / 2;
    
    for (int i = 0; i < global_n; i++) {
        for (int j = startCol; j < endCol; j++) {
            int sum = 0;
            for (int ki = 0; ki < global_k; ki++) {
                for (int kj = 0; kj < global_k; kj++) {
                    int fi = i + ki - halfK;
                    int fj = j + kj - halfK;
                    sum += getElement(fi, fj) * C[ki][kj];
                }
            }
            V[i][j] = sum;
        }
    }
}

void applyConvolutionParallelVertical(int n, int m, int k, int numThreads) {
    global_n = n; global_m = m; global_k = k;
    std::vector<std::thread> threads;
    
    int colsPerThread = m / numThreads;
    int extraCols = m % numThreads;
    
    int startCol = 0;
    for (int t = 0; t < numThreads; t++) {
        int endCol = startCol + colsPerThread + (t < extraCols ? 1 : 0);
        threads.emplace_back(workerColumns, startCol, endCol);
        startCol = endCol;
    }
    
    for (auto& th : threads) {
        th.join();
    }
}

static void workerBlock(int startRow, int endRow, int startCol, int endCol) {
    int halfK = global_k / 2;
    
    for (int i = startRow; i < endRow; i++) {
        for (int j = startCol; j < endCol; j++) {
            int sum = 0;
            for (int ki = 0; ki < global_k; ki++) {
                for (int kj = 0; kj < global_k; kj++) {
                    int fi = i + ki - halfK;
                    int fj = j + kj - halfK;
                    sum += getElement(fi, fj) * C[ki][kj];
                }
            }
            V[i][j] = sum;
        }
    }
}

void applyConvolutionParallelBlock(int n, int m, int k, int numThreads) {
    global_n = n; global_m = m; global_k = k;
    std::vector<std::thread> threads;
    
    int gridRows = (int)std::sqrt(numThreads);
    int gridCols = numThreads / gridRows;
    
    while (gridRows * gridCols < numThreads) gridCols++;
    
    int rowsPerBlock = n / gridRows;
    int colsPerBlock = m / gridCols;
    int extraRows = n % gridRows;
    int extraCols = m % gridCols;
    
    int startRow = 0;
    for (int gr = 0; gr < gridRows; gr++) {
        int endRow = startRow + rowsPerBlock + (gr < extraRows ? 1 : 0);
        
        int startCol = 0;
        for (int gc = 0; gc < gridCols; gc++) {
            int endCol = startCol + colsPerBlock + (gc < extraCols ? 1 : 0);
            
            if (threads.size() < (size_t)numThreads) {
                threads.emplace_back(workerBlock, startRow, endRow, startCol, endCol);
            }
            
            startCol = endCol;
        }
        
        startRow = endRow;
    }
    
    for (auto& th : threads) {
        th.join();
    }
}

} // namespace StaticArray
