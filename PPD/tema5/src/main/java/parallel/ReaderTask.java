package parallel;

import database.DatabaseManager;
import model.GradePair;
import queue.BoundedQueue;

import java.util.List;

public class ReaderTask implements Runnable {
    private final int projectNum;
    private final BoundedQueue queue;

    public ReaderTask(int projectNum, BoundedQueue queue) {
        this.projectNum = projectNum;
        this.queue = queue;
    }

    @Override
    public void run() {
        try {
            List<GradePair> pairs = DatabaseManager.readGrades(projectNum);
            for (GradePair pair : pairs) {
                queue.enqueue(pair);
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            System.err.println("Reader task interrupted: " + e.getMessage());
        }
    }
}
