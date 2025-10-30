# Lab 2 - In-Place Convolution Performance Results

**Generated:** 2025-10-27 09:19:40
**Runs per test:** 1

## C++ Results

| Matrix Size | Kernel | Mode | Threads | Strategy | Time (ms) | Speedup |
|-------------|--------|------|---------|----------|-----------|---------|
| 1000x1000 | 3x3 | sequential | - | in-place | 17.00 | 1.00x |
|  |  | parallel | 2 | in-place | 18.00 | 0.94x |
|  |  |  | 4 | in-place | 5.00 | 3.40x |
|  |  |  | 8 | in-place | 4.00 | 4.25x |
|  |  |  | 16 | in-place | 5.00 | 3.40x |
| 10000x10000 | 3x3 | sequential | - | in-place | 1700.00 | 1.00x |
|  |  | parallel | 2 | in-place | 916.00 | 1.86x |
|  |  |  | 4 | in-place | 506.00 | 3.36x |
|  |  |  | 8 | in-place | 442.00 | 3.85x |
|  |  |  | 16 | in-place | 443.00 | 3.84x |

## Java Results

| Matrix Size | Kernel | Mode | Threads | Strategy | Time (ms) | Speedup |
|-------------|--------|------|---------|----------|-----------|----------|
| 10x10 | 3x3 | parallel | 2 | in-place | 4.00 | 0.00x |
| 1000x1000 | 3x3 | sequential | - | in-place | 40.00 | 1.00x |
|  |  | parallel | 2 | in-place | 56.00 | 0.71x |
|  |  |  | 4 | in-place | 77.00 | 0.52x |
|  |  |  | 8 | in-place | 65.00 | 0.62x |
|  |  |  | 16 | in-place | 220.00 | 0.18x |
| 10000x10000 | 3x3 | sequential | - | in-place | 3005.00 | 1.00x |
|  |  | parallel | 2 | in-place | 1275.00 | 2.36x |
|  |  |  | 4 | in-place | 993.00 | 3.03x |
|  |  |  | 8 | in-place | 1041.00 | 2.89x |
|  |  |  | 16 | in-place | 908.00 | 3.31x |


## Observations

The algorithm used for the in place convolution is a sliding window buffer that saves the current, previous and next line 
of the matrix to compute the convolution. The parallel implementation works the same, only difference being that first it 
computes the borders of each thread.

- C++ implementation runs about 2x faster compared to the Java implementation
- N.O. Thread sweet spot is 4 this time
