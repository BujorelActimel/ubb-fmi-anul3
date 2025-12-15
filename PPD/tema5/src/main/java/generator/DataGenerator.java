package generator;

import database.DatabaseManager;
import java.util.*;

public class DataGenerator {
    private static final int NUM_PROJECTS = 10;
    private static final int MAX_GRADE = 10;
    private static final Random random = new Random();

    public static void generate(int numStudents, int minGradesPerProject,
                                 double cheatingProbability) {
        System.out.println("Generating data for " + numStudents + " students...");

        DatabaseManager.initializeDatabase();
        DatabaseManager.clearAllTables();

        for (int project = 1; project <= NUM_PROJECTS; project++) {
            List<Integer> studentIds = selectRandomStudents(numStudents, minGradesPerProject);
            generateProjectData(project, studentIds, cheatingProbability);
        }

        System.out.println("Data generation complete!");
    }

    private static List<Integer> selectRandomStudents(int numStudents, int minGradesPerProject) {
        Set<Integer> selectedIds = new HashSet<>();

        while (selectedIds.size() < minGradesPerProject) {
            selectedIds.add(random.nextInt(numStudents) + 1);
        }

        for (int id = 1; id <= numStudents; id++) {
            if (random.nextDouble() < 0.7) {
                selectedIds.add(id);
            }
        }

        List<Integer> studentIds = new ArrayList<>(selectedIds);
        Collections.shuffle(studentIds);
        return studentIds;
    }

    private static void generateProjectData(int projectNum, List<Integer> studentIds,
                                             double cheatingProbability) {
        for (int studentId : studentIds) {
            int grade;

            if (random.nextDouble() < cheatingProbability) {
                grade = -1;
            } else {
                grade = random.nextInt(MAX_GRADE + 1); // 0-10
            }

            DatabaseManager.insertGrade(projectNum, studentId, grade);
        }
    }

    public static void main(String[] args) {
        generate(500, 80, 0.05);
    }
}
