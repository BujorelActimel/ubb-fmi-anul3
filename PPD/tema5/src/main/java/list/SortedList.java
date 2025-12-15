package list;

import model.Student;
import java.util.ArrayList;
import java.util.List;

public class SortedList {
    private final Node head;
    private final Node tail;

    public SortedList() {
        head = new Node(Integer.MAX_VALUE, Integer.MAX_VALUE);
        tail = new Node(Integer.MIN_VALUE, Integer.MIN_VALUE);
        head.next = tail;
    }

    public void insertSorted(int id, int grade) {
        head.lock();
        Node pred = head;
        try {
            Node curr = pred.next;
            curr.lock();
            try {
                while (curr != tail && curr.grade > grade) {
                    Node next = curr.next;
                    next.lock();
                    pred.unlock();
                    pred = curr;
                    curr = next;
                }

                Node newNode = new Node(id, grade);
                newNode.next = curr;
                pred.next = newNode;
            } finally {
                curr.unlock();
            }
        } finally {
            pred.unlock();
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
}
