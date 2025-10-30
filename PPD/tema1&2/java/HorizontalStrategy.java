public class HorizontalStrategy implements ConvolutionStrategy {
    private final int numThreads;
    
    public HorizontalStrategy(int numThreads) {
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
        Thread[] threads = new Thread[numThreads];
        int halfK = k / 2;
        
        int rowsPerThread = n / numThreads;
        int extraRows = n % numThreads;
        
        int startRow = 0;
        for (int t = 0; t < numThreads; t++) {
            int endRow = startRow + rowsPerThread + (t < extraRows ? 1 : 0);
            
            final int threadStart = startRow;
            final int threadEnd = endRow;
            
            threads[t] = new Thread(() -> {
                for (int i = threadStart; i < threadEnd; i++) {
                    for (int j = 0; j < m; j++) {
                        int sum = 0;
                        
                        for (int ki = 0; ki < k; ki++) {
                            for (int kj = 0; kj < k; kj++) {
                                int fi = i + ki - halfK;
                                int fj = j + kj - halfK;
                                sum += getElement(F, fi, fj, n, m) * C[ki][kj];
                            }
                        }
                        
                        V[i][j] = sum;
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
