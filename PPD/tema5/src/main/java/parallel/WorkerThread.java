package parallel;

import list.FineGrainList;
import model.GradePair;
import queue.BoundedQueue;

import java.util.Set;

public class WorkerThread extends Thread {
    private final BoundedQueue queue;
    private final FineGrainList list;
    private final Set<Integer> cheaters;

    public WorkerThread(BoundedQueue queue, FineGrainList list, Set<Integer> cheaters) {
        this.queue = queue;
        this.list = list;
        this.cheaters = cheaters;
    }

    @Override
    public void run() {
        try {
            while (true) {
                GradePair pair = queue.dequeue();

                if (pair == null) {
                    break;
                }

                if (pair.grade == -1) {
                    synchronized (cheaters) {
                        cheaters.add(pair.id);
                    }
                } else {
                    boolean isCheater;
                    synchronized (cheaters) {
                        isCheater = cheaters.contains(pair.id);
                    }

                    if (!isCheater) {
                        list.addOrUpdateGrade(pair.id, pair.grade);
                    }
                }
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            System.err.println("Worker thread interrupted: " + e.getMessage());
        }
    }
}
