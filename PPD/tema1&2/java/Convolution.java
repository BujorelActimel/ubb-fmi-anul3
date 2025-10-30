import java.io.*;

public class Convolution {
    private static int[][] F;
    private static int[][] V;
    private static int[][] C;
    private static int n, m, k;
    
    private static void readInput(String filename) throws IOException {
        BufferedReader br = new BufferedReader(new FileReader(filename));
        
        String[] dims = br.readLine().split(" ");
        n = Integer.parseInt(dims[0]);
        m = Integer.parseInt(dims[1]);
        k = Integer.parseInt(dims[2]);
        
        F = new int[n][m];
        V = new int[n][m];
        C = new int[k][k];
        
        for (int i = 0; i < n; i++) {
            String[] line = br.readLine().split(" ");
            for (int j = 0; j < m; j++) {
                F[i][j] = Integer.parseInt(line[j]);
            }
        }
        
        for (int i = 0; i < k; i++) {
            String[] line = br.readLine().split(" ");
            for (int j = 0; j < k; j++) {
                C[i][j] = Integer.parseInt(line[j]);
            }
        }
        
        br.close();
    }
    
    private static void writeOutput(String filename) throws IOException {
        PrintWriter pw = new PrintWriter(new FileWriter(filename));

        pw.println(n + " " + m);
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < m; j++) {
                pw.print(V[i][j]);
                if (j < m - 1) pw.print(" ");
            }
            pw.println();
        }

        pw.close();
    }

    private static void writeOutputInPlace(String filename) throws IOException {
        PrintWriter pw = new PrintWriter(new FileWriter(filename));

        pw.println(n + " " + m);
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < m; j++) {
                pw.print(F[i][j]);  // Write from F (in-place result)
                if (j < m - 1) pw.print(" ");
            }
            pw.println();
        }

        pw.close();
    }
    
    private static void printUsage() {
        System.out.println("Usage: java Convolution [options]");
        System.out.println();
        System.out.println("Options:");
        System.out.println("  -i <file>        Input file (required)");
        System.out.println("  -o <file>        Output file (default: output.txt)");
        System.out.println("  -e <mode>        Execution mode: seq|par (default: seq)");
        System.out.println("  -t <num>         Number of threads (required if -e par)");
        System.out.println("  -s <strategy>    Strategy: horizontal|vertical|block (default: horizontal)");
        System.out.println("  --inplace        Use in-place convolution (Lab 2)");
        System.out.println("  -h               Show this help");
        System.out.println();
        System.out.println("Examples:");
        System.out.println("  java Convolution -i date.txt -e seq");
        System.out.println("  java Convolution -i date.txt -e par -t 4");
        System.out.println("  java Convolution -i date.txt -e par -t 8 -s vertical");
        System.out.println("  java Convolution -i date.txt --inplace -e seq");
        System.out.println("  java Convolution -i date.txt --inplace -e par -t 4");
    }
    
    public static void main(String[] args) {
        if (args.length < 2) {
            printUsage();
            return;
        }
        
        String inputFile = null;
        String outputFile = "output.txt";
        boolean parallel = false;
        int numThreads = 1;
        String strategy = "horizontal";
        boolean inPlace = false;

        for (int i = 0; i < args.length; i++) {
            switch (args[i]) {
                case "-h":
                    printUsage();
                    return;
                case "--inplace":
                    inPlace = true;
                    break;
                case "-i":
                    inputFile = args[++i];
                    break;
                case "-o":
                    outputFile = args[++i];
                    break;
                case "-e":
                    String mode = args[++i];
                    parallel = mode.equals("par");
                    break;
                case "-t":
                    numThreads = Integer.parseInt(args[++i]);
                    break;
                case "-s":
                    strategy = args[++i];
                    break;
            }
        }
        
        if (inputFile == null) {
            System.err.println("Error: Input file is required");
            printUsage();
            return;
        }
        
        if (parallel && numThreads < 1) {
            System.err.println("Error: Parallel mode requires number of threads (-t)");
            return;
        }
        
        try {
            long startTotal = System.currentTimeMillis();
            
            readInput(inputFile);
            
            System.out.println();
            System.out.println("============================================================");
            System.out.println("CONVOLUTION CONFIGURATION");
            System.out.println("============================================================");
            System.out.println("Input file:    " + inputFile);
            System.out.println("Output file:   " + outputFile);
            System.out.println("Matrix size:   " + n + "x" + m);
            System.out.println("Kernel size:   " + k + "x" + k);
            System.out.println("Memory type:   Java arrays");
            System.out.println("Mode:          " + (inPlace ? "In-place (Lab 2)" : "Standard (Lab 1)"));
            System.out.println("Execution:     " + (parallel ? "Parallel" : "Sequential"));

            if (parallel) {
                System.out.println("Threads:       " + numThreads);
                if (!inPlace) {
                    System.out.println("Strategy:      " + strategy);
                } else {
                    System.out.println("Strategy:      horizontal (in-place)");
                }
            }

            System.out.println("============================================================");
            System.out.println();
            System.out.println("Processing...");

            long start = System.currentTimeMillis();

            ConvolutionStrategy convolution;
            if (inPlace) {
                // In-place convolution (Lab 2)
                convolution = new InPlaceStrategy(parallel ? numThreads : 1);
            } else {
                // Standard convolution (Lab 1)
                if (parallel) {
                    if (strategy.equals("vertical")) {
                        convolution = new VerticalStrategy(numThreads);
                    } else if (strategy.equals("horizontal")) {
                        convolution = new HorizontalStrategy(numThreads);
                    } else {
                        convolution = new BlockStrategy(numThreads);
                    }
                } else {
                    convolution = new SequentialStrategy();
                }
            }

            convolution.applyConvolution(F, V, C, n, m, k);

            long end = System.currentTimeMillis();

            if (inPlace) {
                writeOutputInPlace(outputFile);
            } else {
                writeOutput(outputFile);
            }
            
            System.out.println();
            System.out.println("------------------------------------------------------------");
            System.out.println("Convolution time: " + (end - start) + " ms");
            System.out.println("Total time:       " + (System.currentTimeMillis() - startTotal) + " ms");
            System.out.println("Output saved to:  " + outputFile);
            System.out.println("============================================================");
            System.out.println();
            
        } catch (IOException e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
