package model;

public class Student {
    public final int id;
    public final int totalGrade;

    public Student(int id, int totalGrade) {
        this.id = id;
        this.totalGrade = totalGrade;
    }

    @Override
    public String toString() {
        return "(" + id + ", " + totalGrade + ")";
    }
}
