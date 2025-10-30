import java.util.concurrent.CyclicBarrier;
import java.util.concurrent.BrokenBarrierException;

public class InPlaceStrategy implements ConvolutionStrategy {
    private final int numThreads;

    public InPlaceStrategy(int numThreads) {
        this.numThreads = numThreads;
    }

    private int getElement(int[][] F, int i, int j, int n, int m) {
        if (i < 0) i = 0;
        if (i >= n) i = n - 1;
        if (j < 0) j = 0;
        if (j >= m) j = m - 1;
        return F[i][j];
    }

    @Override
    public void applyConvolution(int[][] F, int[][] V, int[][] C, int n, int m, int k) {
        assert(k == 3);
        int halfK = k / 2;

        if (numThreads <= 1) {
            applySequential(F, C, n, m, k, halfK);
        } else {
            applyParallelWithBarrier(F, C, n, m, k, halfK);
        }
    }

    private void applySequential(int[][] F, int[][] C, int n, int m, int k, int halfK) {
        int[][] lineBuffer = new int[k][m];

        for (int i = 0; i < Math.min(k - 1, n); i++) {
            System.arraycopy(F[i], 0, lineBuffer[i], 0, m);
        }

        int[] newLine = new int[m];

        for (int i = 0; i < n; i++) {
            System.arraycopy(F[i], 0, lineBuffer[i % k], 0, m);

            for (int j = 0; j < m; j++) {
                int sum = 0;

                for (int ki = 0; ki < k; ki++) {
                    for (int kj = 0; kj < k; kj++) {
                        int fi = i + ki - halfK;
                        int fj = j + kj - halfK;

                        int value;
                        if (fi >= 0 && fi < n && fi >= i - k + 1 && fi <= i) {
                            int bufIdx = fi % k;
                            if (fj >= 0 && fj < m) {
                                value = lineBuffer[bufIdx][fj];
                            } else {
                                value = getElement(F, fi, fj, n, m);
                            }
                        } else {
                            value = getElement(F, fi, fj, n, m);
                        }

                        sum += value * C[ki][kj];
                    }
                }

                newLine[j] = sum;
            }

            System.arraycopy(newLine, 0, F[i], 0, m);
        }
    }

    private void applyParallelWithBarrier(int[][] F, int[][] C, int n, int m, int k, int halfK) {
        CyclicBarrier barrier = new CyclicBarrier(numThreads);
        Thread[] threads = new Thread[numThreads];

        int rowsPerThread = n / numThreads;
        int extraRows = n % numThreads;

        int[][] topBorders = new int[numThreads][halfK * m];
        int[][] bottomBorders = new int[numThreads][halfK * m];

        int startRow = 0;
        for (int t = 0; t < numThreads; t++) {
            int endRow = startRow + rowsPerThread + (t < extraRows ? 1 : 0);

            final int threadId = t;
            final int threadStart = startRow;
            final int threadEnd = endRow;

            threads[t] = new Thread(() -> {
                int borderRows = Math.min(halfK, threadEnd - threadStart);
                for (int i = threadStart; i < threadStart + borderRows; i++) {
                    for (int j = 0; j < m; j++) {
                        int sum = 0;
                        for (int ki = 0; ki < k; ki++) {
                            for (int kj = 0; kj < k; kj++) {
                                int fi = i + ki - halfK;
                                int fj = j + kj - halfK;
                                sum += getElement(F, fi, fj, n, m) * C[ki][kj];
                            }
                        }
                        topBorders[threadId][(i - threadStart) * m + j] = sum;
                    }
                }

                int bottomStart = Math.max(threadStart, threadEnd - halfK);
                for (int i = bottomStart; i < threadEnd; i++) {
                    for (int j = 0; j < m; j++) {
                        int sum = 0;
                        for (int ki = 0; ki < k; ki++) {
                            for (int kj = 0; kj < k; kj++) {
                                int fi = i + ki - halfK;
                                int fj = j + kj - halfK;
                                sum += getElement(F, fi, fj, n, m) * C[ki][kj];
                            }
                        }
                        bottomBorders[threadId][(i - bottomStart) * m + j] = sum;
                    }
                }

                try {
                    barrier.await();
                } catch (InterruptedException | BrokenBarrierException e) {
                    e.printStackTrace();
                }

                int[][] lineBuffer = new int[k][m];
                int[] newLine = new int[m];

                for (int i = threadStart; i < threadEnd; i++) {
                    boolean isTopBorder = (i < threadStart + halfK);
                    boolean isBottomBorder = (i >= threadEnd - halfK);

                    if (isTopBorder) {
                        for (int j = 0; j < m; j++) {
                            F[i][j] = topBorders[threadId][(i - threadStart) * m + j];
                        }
                    } else if (isBottomBorder) {
                        for (int j = 0; j < m; j++) {
                            F[i][j] = bottomBorders[threadId][(i - (threadEnd - halfK)) * m + j];
                        }
                    } else {
                        System.arraycopy(F[i], 0, lineBuffer[i % k], 0, m);

                        for (int j = 0; j < m; j++) {
                            int sum = 0;
                            for (int ki = 0; ki < k; ki++) {
                                for (int kj = 0; kj < k; kj++) {
                                    int fi = i + ki - halfK;
                                    int fj = j + kj - halfK;

                                    int value;
                                    if (fi >= threadStart && fi < threadEnd && fi >= i - k + 1 && fi < i) {
                                        int bufIdx = fi % k;
                                        if (fj >= 0 && fj < m) {
                                            value = lineBuffer[bufIdx][fj];
                                        } else {
                                            value = getElement(F, fi, fj, n, m);
                                        }
                                    } else {
                                        value = getElement(F, fi, fj, n, m);
                                    }

                                    sum += value * C[ki][kj];
                                }
                            }
                            newLine[j] = sum;
                        }

                        System.arraycopy(newLine, 0, F[i], 0, m);
                    }
                }
            });

            threads[t].start();
            startRow = endRow;
        }

        for (Thread thread : threads) {
            try {
                thread.join();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}
