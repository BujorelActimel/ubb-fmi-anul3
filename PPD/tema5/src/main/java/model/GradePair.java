package model;

public class GradePair {
    public final int id;
    public final int grade;

    public GradePair(int id, int grade) {
        this.id = id;
        this.grade = grade;
    }

    @Override
    public String toString() {
        return "(" + id + ", " + grade + ")";
    }
}
