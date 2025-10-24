# Convolution Performance Results

**Generated:** 2025-10-20 02:51:10
**Runs per test:** 10

## C++ Results

| Matrix Size | Kernel | Memory Type | Mode | Threads | Strategy | Time (ms) | Speedup |
|-------------|--------|-------------|------|---------|----------|-----------|---------|
| 1000x1000 | 5x5 | static | sequential | - | - | 28.20 | 1.00x |
|  |  |  | parallel | 1 | horizontal | 28.70 | 0.98x |
|  |  |  |  |  | vertical | 28.90 | 0.98x |
|  |  |  |  |  | block | 25.90 | 1.09x |
|  |  |  |  | 2 | horizontal | 15.00 | 1.88x |
|  |  |  |  |  | vertical | 14.70 | 1.92x |
|  |  |  |  |  | block | 13.80 | 2.04x |
|  |  |  |  | 4 | horizontal | 7.90 | 3.57x |
|  |  |  |  |  | vertical | 8.10 | 3.48x |
|  |  |  |  |  | block | 7.00 | 4.03x |
|  |  |  |  | 8 | horizontal | 7.00 | 4.03x |
|  |  |  |  |  | vertical | 8.20 | 3.44x |
|  |  |  |  |  | block | 7.00 | 4.03x |
|  |  |  |  | 16 | horizontal | 7.80 | 3.62x |
|  |  |  |  |  | vertical | 8.20 | 3.44x |
|  |  |  |  |  | block | 6.90 | 4.09x |
|  |  | vector | sequential | - | - | 22.00 | 1.00x |
|  |  |  | parallel | 1 | horizontal | 22.50 | 0.98x |
|  |  |  |  |  | vertical | 22.40 | 0.98x |
|  |  |  |  |  | block | 22.90 | 0.96x |
|  |  |  |  | 2 | horizontal | 11.90 | 1.85x |
|  |  |  |  |  | vertical | 12.00 | 1.83x |
|  |  |  |  |  | block | 12.00 | 1.83x |
|  |  |  |  | 4 | horizontal | 6.60 | 3.33x |
|  |  |  |  |  | vertical | 6.00 | 3.67x |
|  |  |  |  |  | block | 6.00 | 3.67x |
|  |  |  |  | 8 | horizontal | 6.00 | 3.67x |
|  |  |  |  |  | vertical | 6.00 | 3.67x |
|  |  |  |  |  | block | 6.00 | 3.67x |
|  |  |  |  | 16 | horizontal | 6.20 | 3.55x |
|  |  |  |  |  | vertical | 6.10 | 3.61x |
|  |  |  |  |  | block | 6.40 | 3.44x |
| 10x10000 | 5x5 | static | sequential | - | - | 2.60 | 1.00x |
|  |  |  | parallel | 2 | horizontal | 1.00 | 2.60x |
|  |  |  |  |  | vertical | 1.00 | 2.60x |
|  |  |  |  |  | block | 1.00 | 2.60x |
|  |  |  |  | 4 | horizontal | 0.60 | 4.33x |
|  |  |  |  |  | block | 0.10 | 26.00x |
|  |  |  |  | 8 | horizontal | 0.40 | 6.50x |
|  |  |  |  | 16 | horizontal | 1.00 | 2.60x |
|  |  |  |  |  | vertical | 0.10 | 26.00x |
|  |  |  |  |  | block | 0.20 | 13.00x |
|  |  | vector | sequential | - | - | 2.00 | 1.00x |
|  |  |  | parallel | 2 | horizontal | 1.00 | 2.00x |
|  |  |  |  |  | vertical | 1.00 | 2.00x |
|  |  |  |  |  | block | 1.00 | 2.00x |
|  |  |  |  | 4 | horizontal | 0.10 | 20.00x |
|  |  |  |  |  | vertical | 0.10 | 20.00x |
|  |  |  |  | 8 | vertical | 0.10 | 20.00x |
|  |  |  |  |  | block | 0.10 | 20.00x |
|  |  |  |  | 16 | horizontal | 0.10 | 20.00x |
| 10000x10 | 5x5 | static | sequential | - | - | 13.50 | 1.00x |
|  |  |  | parallel | 2 | horizontal | 7.60 | 1.78x |
|  |  |  |  |  | vertical | 12.00 | 1.12x |
|  |  |  |  |  | block | 11.80 | 1.14x |
|  |  |  |  | 4 | horizontal | 4.70 | 2.87x |
|  |  |  |  |  | vertical | 12.00 | 1.12x |
|  |  |  |  |  | block | 6.00 | 2.25x |
|  |  |  |  | 8 | horizontal | 4.40 | 3.07x |
|  |  |  |  |  | vertical | 15.10 | 0.89x |
|  |  |  |  |  | block | 8.00 | 1.69x |
|  |  |  |  | 16 | horizontal | 4.40 | 3.07x |
|  |  |  |  |  | vertical | 15.00 | 0.90x |
|  |  |  |  |  | block | 6.30 | 2.14x |
|  |  | vector | sequential | - | - | 2.00 | 1.00x |
|  |  |  | parallel | 2 | horizontal | 1.00 | 2.00x |
|  |  |  |  |  | vertical | 1.00 | 2.00x |
|  |  |  |  |  | block | 1.00 | 2.00x |
|  |  |  |  | 4 | horizontal | 0.20 | 10.00x |
|  |  |  |  |  | vertical | 0.10 | 20.00x |
|  |  |  |  |  | block | 0.10 | 20.00x |
|  |  |  |  | 8 | horizontal | 0.10 | 20.00x |
|  |  |  |  |  | vertical | 0.10 | 20.00x |
|  |  |  |  |  | block | 0.10 | 20.00x |
|  |  |  |  | 16 | vertical | 0.20 | 10.00x |
|  |  |  |  |  | block | 0.10 | 20.00x |
| 10000x10000 | 5x5 | static | sequential | - | - | 2740.00 | 1.00x |
|  |  |  | parallel | 2 | horizontal | 1481.80 | 1.85x |
|  |  |  |  |  | vertical | 1476.90 | 1.86x |
|  |  |  |  |  | block | 1355.10 | 2.02x |
|  |  |  |  | 4 | horizontal | 772.30 | 3.55x |
|  |  |  |  |  | vertical | 751.30 | 3.65x |
|  |  |  |  |  | block | 682.40 | 4.02x |
|  |  |  |  | 8 | horizontal | 703.30 | 3.90x |
|  |  |  |  |  | vertical | 736.20 | 3.72x |
|  |  |  |  |  | block | 691.40 | 3.96x |
|  |  |  |  | 16 | horizontal | 750.40 | 3.65x |
|  |  |  |  |  | vertical | 757.50 | 3.62x |
|  |  |  |  |  | block | 679.60 | 4.03x |
|  |  | vector | sequential | - | - | 2242.50 | 1.00x |
|  |  |  | parallel | 2 | horizontal | 1194.60 | 1.88x |
|  |  |  |  |  | vertical | 1212.80 | 1.85x |
|  |  |  |  |  | block | 1222.60 | 1.83x |
|  |  |  |  | 4 | horizontal | 646.50 | 3.47x |
|  |  |  |  |  | vertical | 682.00 | 3.29x |
|  |  |  |  |  | block | 641.00 | 3.50x |
|  |  |  |  | 8 | horizontal | 593.80 | 3.78x |
|  |  |  |  |  | vertical | 591.00 | 3.79x |
|  |  |  |  |  | block | 592.80 | 3.78x |
|  |  |  |  | 16 | horizontal | 606.10 | 3.70x |
|  |  |  |  |  | vertical | 607.20 | 3.69x |
|  |  |  |  |  | block | 636.80 | 3.52x |

## Java Results

| Matrix Size | Kernel | Mode | Threads | Strategy | Time (ms) | Speedup |
|-------------|--------|------|---------|----------|-----------|----------|
| 10x10 | 3x3 | sequential | - | - | 0.30 | 1.00x |
|  |  | parallel | 4 | horizontal | 3.30 | 0.09x |
|  |  |  |  | vertical | 3.40 | 0.09x |
|  |  |  |  | block | 3.50 | 0.09x |
| 1000x1000 | 5x5 | sequential | - | - | 68.60 | 1.00x |
|  |  | parallel | 1 | horizontal | 78.50 | 0.87x |
|  |  |  |  | vertical | 82.20 | 0.83x |
|  |  |  |  | block | 73.50 | 0.93x |
|  |  |  | 2 | horizontal | 58.50 | 1.17x |
|  |  |  |  | vertical | 59.70 | 1.15x |
|  |  |  |  | block | 60.60 | 1.13x |
|  |  |  | 4 | horizontal | 59.00 | 1.16x |
|  |  |  |  | vertical | 58.70 | 1.17x |
|  |  |  |  | block | 58.10 | 1.18x |
|  |  |  | 8 | horizontal | 56.20 | 1.22x |
|  |  |  |  | vertical | 58.40 | 1.17x |
|  |  |  |  | block | 54.40 | 1.26x |
|  |  |  | 16 | horizontal | 72.60 | 0.94x |
|  |  |  |  | vertical | 73.20 | 0.94x |
|  |  |  |  | block | 75.40 | 0.91x |
| 10x10000 | 5x5 | sequential | - | - | 20.40 | 1.00x |
|  |  | parallel | 2 | horizontal | 51.30 | 0.40x |
|  |  |  |  | vertical | 56.70 | 0.36x |
|  |  |  |  | block | 57.40 | 0.36x |
|  |  |  | 4 | horizontal | 67.90 | 0.30x |
|  |  |  |  | vertical | 44.70 | 0.46x |
|  |  |  |  | block | 61.60 | 0.33x |
|  |  |  | 8 | horizontal | 73.10 | 0.28x |
|  |  |  |  | vertical | 65.20 | 0.31x |
|  |  |  |  | block | 72.70 | 0.28x |
|  |  |  | 16 | horizontal | 73.80 | 0.28x |
|  |  |  |  | vertical | 79.60 | 0.26x |
|  |  |  |  | block | 75.30 | 0.27x |
| 10000x10 | 5x5 | sequential | - | - | 13.50 | 1.00x |
|  |  | parallel | 2 | horizontal | 29.80 | 0.45x |
|  |  |  |  | vertical | 31.20 | 0.43x |
|  |  |  |  | block | 32.70 | 0.41x |
|  |  |  | 4 | horizontal | 29.90 | 0.45x |
|  |  |  |  | vertical | 30.30 | 0.45x |
|  |  |  |  | block | 31.80 | 0.42x |
|  |  |  | 8 | horizontal | 46.10 | 0.29x |
|  |  |  |  | vertical | 51.80 | 0.26x |
|  |  |  |  | block | 44.90 | 0.30x |
|  |  |  | 16 | horizontal | 70.30 | 0.19x |
|  |  |  |  | vertical | 61.40 | 0.22x |
|  |  |  |  | block | 66.30 | 0.20x |
| 10000x10000 | 5x5 | sequential | - | - | 5840.60 | 1.00x |
|  |  | parallel | 2 | horizontal | 2420.30 | 2.41x |
|  |  |  |  | vertical | 2187.50 | 2.67x |
|  |  |  |  | block | 2599.20 | 2.25x |
|  |  |  | 4 | horizontal | 1785.90 | 3.27x |
|  |  |  |  | vertical | 1739.60 | 3.36x |
|  |  |  |  | block | 1109.80 | 5.26x |
|  |  |  | 8 | horizontal | 1536.60 | 3.80x |
|  |  |  |  | vertical | 1652.30 | 3.53x |
|  |  |  |  | block | 1589.30 | 3.67x |
|  |  |  | 16 | horizontal | 1422.80 | 4.11x |
|  |  |  |  | vertical | 1626.00 | 3.59x |
|  |  |  |  | block | 1341.90 | 4.35x |

## Odin Results

| Matrix Size | Kernel | Mode | Threads | Strategy | Time (ms) | Speedup |
|-------------|--------|------|---------|----------|-----------|----------|
| 1000x1000 | 5x5 | sequential | - | - | 30.10 | 1.00x |
|  |  | parallel | 1 | horizontal | 30.80 | 0.98x |
|  |  |  |  | vertical | 30.90 | 0.97x |
|  |  |  |  | block | 30.70 | 0.98x |
|  |  |  | 2 | horizontal | 16.20 | 1.86x |
|  |  |  |  | vertical | 16.50 | 1.82x |
|  |  |  |  | block | 16.50 | 1.82x |
|  |  |  | 4 | horizontal | 8.90 | 3.38x |
|  |  |  |  | vertical | 9.00 | 3.34x |
|  |  |  |  | block | 8.80 | 3.42x |
|  |  |  | 8 | horizontal | 8.20 | 3.67x |
|  |  |  |  | vertical | 8.70 | 3.46x |
|  |  |  |  | block | 8.20 | 3.67x |
|  |  |  | 16 | horizontal | 9.00 | 3.34x |
|  |  |  |  | vertical | 9.50 | 3.17x |
|  |  |  |  | block | 9.30 | 3.24x |
| 10x10000 | 5x5 | sequential | - | - | 3.00 | 1.00x |
|  |  | parallel | 2 | horizontal | 1.00 | 3.00x |
|  |  |  |  | vertical | 1.00 | 3.00x |
|  |  |  |  | block | 1.00 | 3.00x |
|  |  |  | 4 | horizontal | 1.00 | 3.00x |
|  |  |  |  | vertical | 0.60 | 5.00x |
|  |  |  |  | block | 0.80 | 3.75x |
|  |  |  | 8 | horizontal | 1.00 | 3.00x |
|  |  |  |  | vertical | 0.20 | 15.00x |
|  |  |  |  | block | 0.10 | 30.00x |
|  |  |  | 16 | horizontal | 1.00 | 3.00x |
|  |  |  |  | vertical | 1.00 | 3.00x |
|  |  |  |  | block | 1.00 | 3.00x |
| 10000x10 | 5x5 | sequential | - | - | 3.00 | 1.00x |
|  |  | parallel | 2 | horizontal | 1.00 | 3.00x |
|  |  |  |  | vertical | 1.00 | 3.00x |
|  |  |  |  | block | 1.00 | 3.00x |
|  |  |  | 4 | horizontal | 1.00 | 3.00x |
|  |  |  |  | vertical | 1.00 | 3.00x |
|  |  |  |  | block | 1.00 | 3.00x |
|  |  |  | 8 | horizontal | 0.40 | 7.50x |
|  |  |  |  | vertical | 1.00 | 3.00x |
|  |  |  |  | block | 1.00 | 3.00x |
|  |  |  | 16 | horizontal | 1.00 | 3.00x |
|  |  |  |  | vertical | 1.00 | 3.00x |
|  |  |  |  | block | 0.80 | 3.75x |
| 10000x10000 | 5x5 | sequential | - | - | 3112.50 | 1.00x |
|  |  | parallel | 2 | horizontal | 1674.20 | 1.86x |
|  |  |  |  | vertical | 1692.10 | 1.84x |
|  |  |  |  | block | 1683.70 | 1.85x |
|  |  |  | 4 | horizontal | 858.40 | 3.63x |
|  |  |  |  | vertical | 868.90 | 3.58x |
|  |  |  |  | block | 859.10 | 3.62x |
|  |  |  | 8 | horizontal | 804.80 | 3.87x |
|  |  |  |  | vertical | 820.40 | 3.79x |
|  |  |  |  | block | 808.40 | 3.85x |
|  |  |  | 16 | horizontal | 823.40 | 3.78x |
|  |  |  |  | vertical | 833.20 | 3.74x |
|  |  |  |  | block | 816.20 | 3.81x |


## Observations

Language ranking:
1. c++
2. odin
3. java
