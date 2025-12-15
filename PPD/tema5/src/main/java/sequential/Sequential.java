package sequential;

import database.DatabaseManager;
import model.GradePair;
import model.Student;

import java.util.*;

public class Sequential {
    private static final int NUM_PROJECTS = 10;

    public static List<Student> process(Set<Integer> cheaters) {
        Map<Integer, Integer> grades = new HashMap<>();

        for (int i = 1; i <= NUM_PROJECTS; i++) {
            List<GradePair> pairs = DatabaseManager.readGrades(i);
            for (GradePair pair : pairs) {
                if (pair.grade == -1) {
                    cheaters.add(pair.id);
                    grades.remove(pair.id);
                } else if (!cheaters.contains(pair.id)) {
                    grades.put(pair.id, grades.getOrDefault(pair.id, 0) + pair.grade);
                }
            }
        }

        return sortResults(grades);
    }

    private static List<Student> sortResults(Map<Integer, Integer> grades) {
        List<Student> students = new ArrayList<>();
        for (Map.Entry<Integer, Integer> entry : grades.entrySet()) {
            students.add(new Student(entry.getKey(), entry.getValue()));
        }

        students.sort((s1, s2) -> Integer.compare(s2.totalGrade, s1.totalGrade));
        return students;
    }
}
