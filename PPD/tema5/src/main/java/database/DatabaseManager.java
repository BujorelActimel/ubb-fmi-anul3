package database;

import model.GradePair;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DatabaseManager {
    private static final String DB_URL = "jdbc:sqlite:data/grades.db";

    public static void initializeDatabase() {
        try (Connection conn = DriverManager.getConnection(DB_URL)) {
            Statement stmt = conn.createStatement();

            for (int i = 1; i <= 10; i++) {
                String createTableSQL =
                    "CREATE TABLE IF NOT EXISTS project" + i + " (" +
                    "    id INTEGER NOT NULL," +
                    "    grade INTEGER NOT NULL" +
                    ")";
                stmt.execute(createTableSQL);
            }

            System.out.println("Database initialized successfully.");
        } catch (SQLException e) {
            System.err.println("Error initializing database: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public static void insertGrade(int projectNum, int studentId, int grade) {
        String sql = "INSERT INTO project" + projectNum + " (id, grade) VALUES (?, ?)";

        try (Connection conn = DriverManager.getConnection(DB_URL);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, studentId);
            pstmt.setInt(2, grade);
            pstmt.executeUpdate();

        } catch (SQLException e) {
            System.err.println("Error inserting grade: " + e.getMessage());
        }
    }

    public static List<GradePair> readGrades(int projectNum) {
        List<GradePair> grades = new ArrayList<>();
        String sql = "SELECT id, grade FROM project" + projectNum;

        try (Connection conn = DriverManager.getConnection(DB_URL);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                int id = rs.getInt("id");
                int grade = rs.getInt("grade");
                grades.add(new GradePair(id, grade));
            }

        } catch (SQLException e) {
            System.err.println("Error reading grades from project" + projectNum + ": " + e.getMessage());
        }

        return grades;
    }

    public static void clearAllTables() {
        try (Connection conn = DriverManager.getConnection(DB_URL);
             Statement stmt = conn.createStatement()) {

            for (int i = 1; i <= 10; i++) {
                stmt.execute("DELETE FROM project" + i);
            }

            System.out.println("All tables cleared.");
        } catch (SQLException e) {
            System.err.println("Error clearing tables: " + e.getMessage());
        }
    }

    public static void dropAllTables() {
        try (Connection conn = DriverManager.getConnection(DB_URL);
             Statement stmt = conn.createStatement()) {

            for (int i = 1; i <= 10; i++) {
                stmt.execute("DROP TABLE IF EXISTS project" + i);
            }

            System.out.println("All tables dropped.");
        } catch (SQLException e) {
            System.err.println("Error dropping tables: " + e.getMessage());
        }
    }
}
