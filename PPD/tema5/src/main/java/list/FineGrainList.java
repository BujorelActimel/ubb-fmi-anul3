package list;

import model.Student;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

public class FineGrainList {
    private final Node head;
    private final Node tail;
    private final AtomicInteger size;

    public FineGrainList() {
        head = new Node();
        tail = new Node();
        head.next = tail;
        size = new AtomicInteger(0);
    }

    public void addOrUpdateGrade(int id, int grade) {
        head.lock();
        Node pred = head;
        try {
            Node curr = pred.next;
            curr.lock();
            try {
                while (curr != tail) {
                    if (curr.id == id) {
                        curr.grade += grade;
                        return;
                    }
                    Node next = curr.next;
                    next.lock();
                    pred.unlock();
                    pred = curr;
                    curr = next;
                }

                Node newNode = new Node(id, grade);
                newNode.next = tail;
                pred.next = newNode;
                size.incrementAndGet();
            } finally {
                curr.unlock();
            }
        } finally {
            pred.unlock();
        }
    }

    public Node removeFirst() {
        head.lock();
        try {
            Node first = head.next;
            if (first == tail) {
                return null;
            }

            first.lock();
            try {
                head.next = first.next;
                size.decrementAndGet();
                return first;
            } finally {
                first.unlock();
            }
        } finally {
            head.unlock();
        }
    }

    public List<Student> toList() {
        List<Student> result = new ArrayList<>();
        head.lock();
        Node pred = head;
        try {
            Node curr = pred.next;
            curr.lock();
            try {
                while (curr != tail) {
                    result.add(new Student(curr.id, curr.grade));

                    Node next = curr.next;
                    next.lock();
                    pred.unlock();
                    pred = curr;
                    curr = next;
                }
            } finally {
                curr.unlock();
            }
        } finally {
            pred.unlock();
        }
        return result;
    }

    public int getSize() {
        return size.get();
    }

    public boolean isEmpty() {
        head.lock();
        try {
            return head.next == tail;
        } finally {
            head.unlock();
        }
    }
}
