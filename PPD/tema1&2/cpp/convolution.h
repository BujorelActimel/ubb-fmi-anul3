#ifndef CONVOLUTION_H
#define CONVOLUTION_H

#include <vector>
#include <string>

const int MAX_SIZE = 10000;
const int MAX_KERNEL = 10;

enum class Strategy {
    HORIZONTAL,
    VERTICAL,
    BLOCK
};

struct ConvolutionConfig {
    std::string inputFile;
    std::string outputFile;
    bool useStatic;
    bool parallel;
    int numThreads;
    Strategy strategy;
    bool inPlace;
};

namespace StaticArray {
    void readInput(const std::string& filename, int& n, int& m, int& k);
    void writeOutput(const std::string& filename, int n, int m);
    
    void applyConvolution(int n, int m, int k);
    void applyConvolutionParallelHorizontal(int n, int m, int k, int numThreads);
    void applyConvolutionParallelVertical(int n, int m, int k, int numThreads);
    void applyConvolutionParallelBlock(int n, int m, int k, int numThreads);
    
    extern int F[MAX_SIZE][MAX_SIZE];
    extern int V[MAX_SIZE][MAX_SIZE];
    extern int C[MAX_KERNEL][MAX_KERNEL];
}

namespace VectorImpl {
    struct ConvolutionData {
        std::vector<std::vector<int>> F;
        std::vector<std::vector<int>> V;
        std::vector<std::vector<int>> C;
        int n, m, k;
    };
    
    ConvolutionData readInput(const std::string& filename);
    void writeOutput(const std::string& filename, const ConvolutionData& data);
    void writeOutputInPlace(const std::string& filename, const ConvolutionData& data);

    void applyConvolution(ConvolutionData& data);
    void applyConvolutionParallelHorizontal(ConvolutionData& data, int numThreads);
    void applyConvolutionParallelVertical(ConvolutionData& data, int numThreads);
    void applyConvolutionParallelBlock(ConvolutionData& data, int numThreads);

    void applyConvolutionInPlace(ConvolutionData& data);
    void applyConvolutionInPlaceParallel(ConvolutionData& data, int numThreads);

    void applyConvolutionInPlaceParallelBarrier(ConvolutionData& data, int numThreads);
}

#endif // CONVOLUTION_H
