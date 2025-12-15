import generator.DataGenerator;
import list.FineGrainList;
import list.Node;
import list.SortedList;
import model.Student;
import parallel.ReaderTask;
import parallel.WorkerThread;
import queue.BoundedQueue;
import sequential.Sequential;

import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

public class Main {
    private static final int NUM_PROJECTS = 10;
    private static final int QUEUE_CAPACITY = 100;
    private static final int P_R = 4;

    public static void main(String[] args) {
        System.out.println("=== Generating Test Data (Database) ===");
        DataGenerator.generate(500, 80, 0.05);

        System.out.println("\n=== Running Sequential Version (Database) ===");
        runSequential();

        System.out.println("\n=== Running Parallel Versions (Database) ===");
        int[] pWorkers = {2, 4, 8};

        for (int pW : pWorkers) {
            System.out.println("\n--- p_r=" + P_R + ", p_w=" + pW + " ---");
            runParallel(P_R, pW);
        }
    }

    private static void runSequential() {
        Set<Integer> cheaters = new HashSet<>();
        long startTime = System.nanoTime();

        List<Student> results = Sequential.process(cheaters);

        long endTime = System.nanoTime();
        double timeSeconds = (endTime - startTime) / 1_000_000_000.0;

        System.out.printf("Sequential: %.6f seconds%n", timeSeconds);
        System.out.println("Total students: " + results.size());
        System.out.println("Cheaters found: " + cheaters.size());

        writeResults(results, "data/rezultate_sequential.txt");
        writeCheaters(cheaters, "data/cheateri_sequential.txt");
    }

    private static void runParallel(int pR, int pW) {
        Set<Integer> cheaters = Collections.synchronizedSet(new HashSet<>());
        BoundedQueue queue = new BoundedQueue(QUEUE_CAPACITY);
        FineGrainList list = new FineGrainList();

        long startTime = System.nanoTime();

        ExecutorService readerPool = Executors.newFixedThreadPool(pR);
        WorkerThread[] workers = new WorkerThread[pW];

        for (int i = 1; i <= NUM_PROJECTS; i++) {
            readerPool.submit(new ReaderTask(i, queue));
        }

        for (int i = 0; i < pW; i++) {
            workers[i] = new WorkerThread(queue, list, cheaters);
            workers[i].start();
        }

        readerPool.shutdown();
        try {
            readerPool.awaitTermination(Long.MAX_VALUE, TimeUnit.NANOSECONDS);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            System.err.println("Interrupted waiting for readers: " + e.getMessage());
        }

        queue.markReadersDone();

        for (WorkerThread worker : workers) {
            try {
                worker.join();
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                System.err.println("Interrupted waiting for workers: " + e.getMessage());
            }
        }

        SortedList sortedList = new SortedList();
        Thread[] sortingWorkers = new Thread[pW];

        for (int i = 0; i < pW; i++) {
            sortingWorkers[i] = new Thread(() -> {
                while (true) {
                    Node node = list.removeFirst();
                    if (node == null) {
                        break;
                    }
                    sortedList.insertSorted(node.id, node.grade);
                }
            });
            sortingWorkers[i].start();
        }

        for (Thread worker : sortingWorkers) {
            try {
                worker.join();
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                System.err.println("Interrupted waiting for sorting workers: " + e.getMessage());
            }
        }

        long endTime = System.nanoTime();
        double timeSeconds = (endTime - startTime) / 1_000_000_000.0;

        List<Student> allResults = sortedList.toList();
        List<Student> results = new ArrayList<>();
        for (Student student : allResults) {
            if (!cheaters.contains(student.id)) {
                results.add(student);
            }
        }

        System.out.printf("Parallel p_r=%d p_w=%d: %.6f seconds%n", pR, pW, timeSeconds);
        System.out.println("Total students: " + results.size());
        System.out.println("Cheaters found: " + cheaters.size());

        writeResults(results, "data/rezultate_parallel_pr" + pR + "_pw" + pW + ".txt");
        writeCheaters(cheaters, "data/cheateri_parallel_pr" + pR + "_pw" + pW + ".txt");
    }

    private static void writeResults(List<Student> students, String filename) {
        try (PrintWriter writer = new PrintWriter(new FileWriter(filename))) {
            for (Student student : students) {
                writer.println(student);
            }
        } catch (IOException e) {
            System.err.println("Error writing results to " + filename + ": " + e.getMessage());
        }
    }
    
    private static void writeCheaters(Set<Integer> cheaters, String filename) {
        try (PrintWriter writer = new PrintWriter(new FileWriter(filename))) {
            List<Integer> sortedCheaters = new ArrayList<>(cheaters);
            Collections.sort(sortedCheaters);
            for (int id : sortedCheaters) {
                writer.println("Student ID: " + id);
            }
        } catch (IOException e) {
            System.err.println("Error writing cheaters to " + filename + ": " + e.getMessage());
        }
    }
}
