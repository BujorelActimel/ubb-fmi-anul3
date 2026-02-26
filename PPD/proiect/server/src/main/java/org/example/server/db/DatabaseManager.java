package org.example.server.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

public class DatabaseManager {
    private static final String DB_URL = "jdbc:sqlite:clinic.db";
    private static DatabaseManager instance;
    private Connection connection;

    private DatabaseManager() throws SQLException {
        connection = DriverManager.getConnection(DB_URL);
        initDatabase();
    }

    public static synchronized DatabaseManager getInstance() throws SQLException {
        if (instance == null) {
            instance = new DatabaseManager();
        }
        return instance;
    }

    private void initDatabase() throws SQLException {
        try (Statement stmt = connection.createStatement()) {
            stmt.execute("""
                CREATE TABLE IF NOT EXISTS appointments (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL,
                    cnp TEXT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    location_id INTEGER NOT NULL,
                    treatment_id INTEGER NOT NULL,
                    appointment_date DATE NOT NULL,
                    appointment_time TIME NOT NULL,
                    status TEXT CHECK(status IN ('RESERVED', 'PAID', 'CANCELLED'))
                )
            """);

            stmt.execute("""
                CREATE TABLE IF NOT EXISTS payments (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    cnp TEXT NOT NULL,
                    amount REAL NOT NULL,
                    appointment_id INTEGER REFERENCES appointments(id)
                )
            """);

            stmt.execute("CREATE INDEX IF NOT EXISTS idx_appointments_slot ON appointments(location_id, appointment_date, appointment_time, treatment_id)");
            stmt.execute("CREATE INDEX IF NOT EXISTS idx_appointments_status ON appointments(status)");
        }
    }

    public Connection getConnection() {
        return connection;
    }

    public void close() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void resetDatabase() throws SQLException {
        try (Statement stmt = connection.createStatement()) {
            stmt.execute("DELETE FROM payments");
            stmt.execute("DELETE FROM appointments");
            stmt.execute("DELETE FROM sqlite_sequence WHERE name='appointments' OR name='payments'");
        }
    }
}
