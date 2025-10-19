#include <iostream>
#include <random>
#include <vector>
#include <thread>
#include <chrono>
#include <iomanip>

const int VEC_SIZE = 1000000;
const int NO_THREADS = 4;

std::vector<int> generateVector(int size, int upperBound) {
    std::vector<int> vec(size);
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> dist(0, upperBound - 1);

    for (int i = 0; i < size; ++i) {
        vec[i] = dist(gen);
    }
    return vec;
}

void printVector(const std::vector<int>& vec) {
    for (int val : vec) {
        std::cout << val << " ";
    }
    std::cout << '\n';
}

std::vector<int> sumVectorsSeq(const std::vector<int>& A, const std::vector<int>& B) {
    int size = A.size();
    std::vector<int> C(size);

    for (int i = 0; i < size; i++) {
        C[i] = A[i] + B[i];
    }

    return C;
}

void intervalThreadFunc(int start, int end,
                       const std::vector<int>& A,
                       const std::vector<int>& B,
                       std::vector<int>& C) {
    for (int i = start; i < end; i++) {
        C[i] = A[i] + B[i];
    }
}

std::vector<int> sumVectorsInterval(const std::vector<int>& A,
                                    const std::vector<int>& B,
                                    int noThreads) {
    int size = A.size();
    std::vector<int> C(size);
    std::vector<std::thread> threads;
    int chunkSize = size / noThreads;

    for (int i = 0; i < noThreads; i++) {
        int start = i * chunkSize;
        int end = (i == noThreads - 1) ? size : (i + 1) * chunkSize;
        threads.emplace_back(intervalThreadFunc, start, end,
                           std::ref(A), std::ref(B), std::ref(C));
    }

    for (auto& thread : threads) {
        thread.join();
    }

    return C;
}

template<typename Func>
std::vector<int> timeVectorSum(const std::string& label, Func sumFunction) {
    auto startTime = std::chrono::high_resolution_clock::now();
    std::vector<int> result = sumFunction();
    auto endTime = std::chrono::high_resolution_clock::now();

    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(endTime - startTime);
    std::cout << label << " time: " << duration.count() << " ms" << std::endl;

    return result;
}

int main() {
    std::cout << "PPD - Lab2 (C++ Implementation)" << std::endl;
    std::cout << "Vector size: " << VEC_SIZE << std::endl;
    std::cout << "Number of threads: " << NO_THREADS << std::endl;
    std::cout << std::endl;

    std::vector<int> a = generateVector(VEC_SIZE, 10);
    std::vector<int> b = generateVector(VEC_SIZE, 10);

    std::vector<int> c_seq = timeVectorSum("Sequential",
        [&]() { return sumVectorsSeq(a, b); });

    if (VEC_SIZE <= 10) {
        std::cout << "Vector A: ";
        printVector(a);
        std::cout << "Vector B: ";
        printVector(b);
        std::cout << "Vector C (Sequential): ";
        printVector(c_seq);
        std::cout << std::endl;
    }

    std::vector<int> c_int = timeVectorSum("Interval",
        [&]() { return sumVectorsInterval(a, b, NO_THREADS); });

    if (VEC_SIZE <= 10) {
        std::cout << "Vector C (Interval): ";
        printVector(c_int);
        std::cout << std::endl;
    }

    return 0;
}
