#include "convolution.h"
#include <iostream>
#include <chrono>
#include <string>
#include <cstring>

using namespace std;
using namespace std::chrono;

void printUsage(const char* progName) {
    cout << "Usage: " << progName << " [options]\n\n";
    cout << "Options:\n";
    cout << "  -i <file>        Input file (required)\n";
    cout << "  -o <file>        Output file (default: output.txt)\n";
    cout << "  -m <type>        Memory type: static|vector (default: vector)\n";
    cout << "  -e <mode>        Execution mode: seq|par (default: seq)\n";
    cout << "  -t <num>         Number of threads (required if -e par)\n";
    cout << "  -s <strategy>    Strategy: horizontal|vertical|block (default: horizontal)\n";
    cout << "  --inplace        Use in-place convolution (Lab 2, vector only)\n";
    cout << "  -h               Show this help\n\n";
    cout << "Examples:\n";
    cout << "  " << progName << " -i date.txt -e seq\n";
    cout << "  " << progName << " -i date.txt -e par -t 4\n";
    cout << "  " << progName << " -i date.txt -m static -e par -t 8 -s vertical\n";
    cout << "  " << progName << " -i date.txt -m vector -e par -t 4 -s block\n";
    cout << "  " << progName << " -i date.txt --inplace -e seq\n";
    cout << "  " << progName << " -i date.txt --inplace -e par -t 4\n";
}

ConvolutionConfig parseArgs(int argc, char* argv[]) {
    ConvolutionConfig config;
    config.outputFile = "output.txt";
    config.useStatic = false;
    config.parallel = false;
    config.numThreads = 1;
    config.strategy = Strategy::HORIZONTAL;
    config.inPlace = false;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-h") == 0) {
            printUsage(argv[0]);
            exit(0);
        }
        else if (strcmp(argv[i], "-i") == 0 && i + 1 < argc) {
            config.inputFile = argv[++i];
        }
        else if (strcmp(argv[i], "-o") == 0 && i + 1 < argc) {
            config.outputFile = argv[++i];
        }
        else if (strcmp(argv[i], "-m") == 0 && i + 1 < argc) {
            string type = argv[++i];
            if (type == "static") {
                config.useStatic = true;
            } else if (type == "vector") {
                config.useStatic = false;
            } else {
                cerr << "Error: Invalid memory type '" << type << "'\n";
                exit(1);
            }
        }
        else if (strcmp(argv[i], "-e") == 0 && i + 1 < argc) {
            string mode = argv[++i];
            if (mode == "seq") {
                config.parallel = false;
            } else if (mode == "par") {
                config.parallel = true;
            } else {
                cerr << "Error: Invalid execution mode '" << mode << "'\n";
                exit(1);
            }
        }
        else if (strcmp(argv[i], "-t") == 0 && i + 1 < argc) {
            config.numThreads = stoi(argv[++i]);
            if (config.numThreads < 1) {
                cerr << "Error: Number of threads must be >= 1\n";
                exit(1);
            }
        }
        else if (strcmp(argv[i], "-s") == 0 && i + 1 < argc) {
            string strategy = argv[++i];
            if (strategy == "horizontal" || strategy == "h") {
                config.strategy = Strategy::HORIZONTAL;
            } else if (strategy == "vertical" || strategy == "v") {
                config.strategy = Strategy::VERTICAL;
            } else if (strategy == "block" || strategy == "b") {
                config.strategy = Strategy::BLOCK;
            } else {
                cerr << "Error: Invalid strategy '" << strategy << "'\n";
                exit(1);
            }
        }
        else if (strcmp(argv[i], "--inplace") == 0) {
            config.inPlace = true;
        }
    }
    
    if (config.inputFile.empty()) {
        cerr << "Error: Input file is required\n";
        printUsage(argv[0]);
        exit(1);
    }
    
    if (config.parallel && config.numThreads < 1) {
        cerr << "Error: Parallel mode requires number of threads (-t)\n";
        exit(1);
    }
    
    return config;
}

void printConfig(const ConvolutionConfig& config, int n, int m, int k) {
    cout << "\n" << string(60, '=') << "\n";
    cout << "CONVOLUTION CONFIGURATION\n";
    cout << string(60, '=') << "\n";
    cout << "Input file:    " << config.inputFile << "\n";
    cout << "Output file:   " << config.outputFile << "\n";
    cout << "Matrix size:   " << n << "x" << m << "\n";
    cout << "Kernel size:   " << k << "x" << k << "\n";
    cout << "Memory type:   " << (config.useStatic ? "Static array" : "std::vector") << "\n";
    if (config.inPlace) {
        cout << "Mode:          In-place (Lab 2)\n";
    }
    cout << "Execution:     " << (config.parallel ? "Parallel" : "Sequential") << "\n";

    if (config.parallel) {
        cout << "Threads:       " << config.numThreads << "\n";
        cout << "Strategy:      ";
        if (config.inPlace) {
            cout << "Horizontal (in-place)";
        } else {
            switch (config.strategy) {
                case Strategy::HORIZONTAL: cout << "Horizontal (rows)"; break;
                case Strategy::VERTICAL: cout << "Vertical (columns)"; break;
                case Strategy::BLOCK: cout << "Block (2D)"; break;
            }
        }
        cout << "\n";
    }
    
    cout << string(60, '=') << "\n\n";
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        printUsage(argv[0]);
        return 1;
    }
    
    ConvolutionConfig config = parseArgs(argc, argv);
    
    auto startTotal = high_resolution_clock::now();
    auto start = high_resolution_clock::now();
    auto end = high_resolution_clock::now();
    
    if (config.useStatic) {
        int n, m, k;
        
        StaticArray::readInput(config.inputFile, n, m, k);
        printConfig(config, n, m, k);
        
        start = high_resolution_clock::now();
        
        if (config.parallel) {
            switch (config.strategy) {
                case Strategy::HORIZONTAL:
                    StaticArray::applyConvolutionParallelHorizontal(n, m, k, config.numThreads);
                    break;
                case Strategy::VERTICAL:
                    StaticArray::applyConvolutionParallelVertical(n, m, k, config.numThreads);
                    break;
                case Strategy::BLOCK:
                    StaticArray::applyConvolutionParallelBlock(n, m, k, config.numThreads);
                    break;
            }
        } else {
            StaticArray::applyConvolution(n, m, k);
        }
        
        end = high_resolution_clock::now();
        
        StaticArray::writeOutput(config.outputFile, n, m);
        
    } else {
        VectorImpl::ConvolutionData data = VectorImpl::readInput(config.inputFile);
        printConfig(config, data.n, data.m, data.k);

        start = high_resolution_clock::now();

        if (config.inPlace) {
            if (config.parallel) {
                VectorImpl::applyConvolutionInPlaceParallel(data, config.numThreads);
            } else {
                VectorImpl::applyConvolutionInPlace(data);
            }
        } else {
            if (config.parallel) {
                switch (config.strategy) {
                    case Strategy::HORIZONTAL:
                        VectorImpl::applyConvolutionParallelHorizontal(data, config.numThreads);
                        break;
                    case Strategy::VERTICAL:
                        VectorImpl::applyConvolutionParallelVertical(data, config.numThreads);
                        break;
                    case Strategy::BLOCK:
                        VectorImpl::applyConvolutionParallelBlock(data, config.numThreads);
                        break;
                }
            } else {
                VectorImpl::applyConvolution(data);
            }
        }

        end = high_resolution_clock::now();

        if (config.inPlace) {
            VectorImpl::writeOutputInPlace(config.outputFile, data);
        } else {
            VectorImpl::writeOutput(config.outputFile, data);
        }
    }
    
    auto duration = duration_cast<milliseconds>(end - start);
    auto endTotal = high_resolution_clock::now();
    auto durationTotal = duration_cast<milliseconds>(endTotal - startTotal);
    
    cout << "\n" << string(60, '-') << "\n";
    cout << "Convolution time: " << duration.count() << " ms\n";
    cout << "Total time:       " << durationTotal.count() << " ms\n";
    cout << "Output saved to:  " << config.outputFile << "\n";
    cout << string(60, '=') << "\n\n";
    
    return 0;
}
