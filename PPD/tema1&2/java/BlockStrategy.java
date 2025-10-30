public class BlockStrategy implements ConvolutionStrategy {
    private final int numThreads;
    
    public BlockStrategy(int numThreads) {
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
        int halfK = k / 2;
        
        int gridRows = (int) Math.sqrt(numThreads);
        int gridCols = numThreads / gridRows;
        
        while (gridRows * gridCols < numThreads) {
            gridCols++;
        }
        
        int rowsPerBlock = n / gridRows;
        int colsPerBlock = m / gridCols;
        int extraRows = n % gridRows;
        int extraCols = m % gridCols;
        
        Thread[] threads = new Thread[numThreads];
        int threadIndex = 0;
        
        int startRow = 0;
        for (int gr = 0; gr < gridRows && threadIndex < numThreads; gr++) {
            int endRow = startRow + rowsPerBlock + (gr < extraRows ? 1 : 0);
            
            int startCol = 0;
            for (int gc = 0; gc < gridCols && threadIndex < numThreads; gc++) {
                int endCol = startCol + colsPerBlock + (gc < extraCols ? 1 : 0);
                
                final int blockStartRow = startRow;
                final int blockEndRow = endRow;
                final int blockStartCol = startCol;
                final int blockEndCol = endCol;
                
                threads[threadIndex] = new Thread(() -> {
                    for (int i = blockStartRow; i < blockEndRow; i++) {
                        for (int j = blockStartCol; j < blockEndCol; j++) {
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
                
                threads[threadIndex].start();
                threadIndex++;
                
                startCol = endCol;
            }
            
            startRow = endRow;
        }
        
        for (int i = 0; i < threadIndex; i++) {
            try {
                threads[i].join();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}