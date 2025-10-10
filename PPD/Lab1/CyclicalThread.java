public class CyclicalThread extends Thread {
    private int id;
    private int VEC_SIZE;
    private int NO_THREADS;
    int[] A;
    int[] B;
    int[] C;

    CyclicalThread(int id, int NO_THREADS, int VEC_SIZE, int[] A, int[] B, int[] C) {
        this.id = id;
        this.VEC_SIZE = VEC_SIZE;
        this.NO_THREADS = NO_THREADS;
        this.A = A;
        this.B = B;
        this.C = C;
    }

    public void run() {
        for (int i = id; i < this.VEC_SIZE; i += this.NO_THREADS) {
            this.C[i] = this.A[i] + this.B[i];
        }
    }
}
