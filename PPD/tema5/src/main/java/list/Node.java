package list;

import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class Node {
    public int id;
    public int grade;
    public Node next;
    public final Lock lock;

    public Node() {
        this.id = -1;
        this.grade = 0;
        this.next = null;
        this.lock = new ReentrantLock();
    }

    public Node(int id, int grade) {
        this.id = id;
        this.grade = grade;
        this.next = null;
        this.lock = new ReentrantLock();
    }

    public void lock() {
        lock.lock();
    }

    public void unlock() {
        lock.unlock();
    }
}
