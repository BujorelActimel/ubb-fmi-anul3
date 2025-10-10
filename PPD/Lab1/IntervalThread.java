public class IntervalThread extends Thread {
    private int start;
    private int end;
    int[] A;
    int[] B;
    int[] C;

    IntervalThread(int start, int end, int[] A, int[] B, int[] C) {
        this.start = start;
        this.end = end;
        this.A = A;
        this.B = B;
        this.C = C;
    }

    public void run() {
        for (int i = start; i < end; i++) {
            this.C[i] = this.A[i] + this.B[i];
        }
    }
}
