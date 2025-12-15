package queue;

import model.GradePair;
import java.util.LinkedList;
import java.util.Queue;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class BoundedQueue {
    private final int capacity;
    private final Queue<GradePair> queue;
    private final Lock lock;
    private final Condition notFull;
    private final Condition notEmpty;
    private volatile boolean readersDone;

    public BoundedQueue(int capacity) {
        this.capacity = capacity;
        this.queue = new LinkedList<>();
        this.lock = new ReentrantLock();
        this.notFull = lock.newCondition();
        this.notEmpty = lock.newCondition();
        this.readersDone = false;
    }

    public void enqueue(GradePair pair) throws InterruptedException {
        lock.lock();
        try {
            while (queue.size() >= capacity) {
                notFull.await();
            }

            queue.add(pair);
            notEmpty.signal();
        } finally {
            lock.unlock();
        }
    }

    public GradePair dequeue() throws InterruptedException {
        lock.lock();
        try {
            while (queue.isEmpty() && !readersDone) {
                notEmpty.await();
            }

            if (queue.isEmpty() && readersDone) {
                return null;
            }

            GradePair pair = queue.poll();
            notFull.signal();
            return pair;
        } finally {
            lock.unlock();
        }
    }

    public void markReadersDone() {
        lock.lock();
        try {
            readersDone = true;
            notEmpty.signalAll();
        } finally {
            lock.unlock();
        }
    }

    public int size() {
        lock.lock();
        try {
            return queue.size();
        } finally {
            lock.unlock();
        }
    }
}
