package org.example.server.db;

import org.example.common.model.Payment;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class PaymentDAO {
    private final Connection connection;

    public PaymentDAO(Connection connection) {
        this.connection = connection;
    }

    public synchronized int create(Payment payment) throws SQLException {
        String sql = """
            INSERT INTO payments (cnp, amount, appointment_id)
            VALUES (?, ?, ?)
        """;

        try (PreparedStatement stmt = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, payment.getCnp());
            stmt.setDouble(2, payment.getAmount());
            stmt.setInt(3, payment.getAppointmentId());
            stmt.executeUpdate();

            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    public synchronized Payment findByAppointmentId(int appointmentId) throws SQLException {
        String sql = "SELECT * FROM payments WHERE appointment_id = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, appointmentId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        }
        return null;
    }

    public synchronized List<Payment> findAll() throws SQLException {
        String sql = "SELECT * FROM payments";
        List<Payment> payments = new ArrayList<>();
        try (Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                payments.add(mapResultSet(rs));
            }
        }
        return payments;
    }

    public synchronized List<Payment> findByLocation(int locationId) throws SQLException {
        String sql = """
            SELECT p.* FROM payments p
            JOIN appointments a ON p.appointment_id = a.id
            WHERE a.location_id = ?
        """;
        List<Payment> payments = new ArrayList<>();
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, locationId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    payments.add(mapResultSet(rs));
                }
            }
        }
        return payments;
    }

    public synchronized double getTotalByLocation(int locationId) throws SQLException {
        String sql = """
            SELECT COALESCE(SUM(p.amount), 0) as total FROM payments p
            JOIN appointments a ON p.appointment_id = a.id
            WHERE a.location_id = ?
        """;
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, locationId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("total");
                }
            }
        }
        return 0;
    }

    public synchronized double getTotal() throws SQLException {
        String sql = "SELECT COALESCE(SUM(amount), 0) as total FROM payments";
        try (Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getDouble("total");
            }
        }
        return 0;
    }

    private Payment mapResultSet(ResultSet rs) throws SQLException {
        Payment payment = new Payment();
        payment.setId(rs.getInt("id"));

        String createdAt = rs.getString("created_at");
        if (createdAt != null) {
            payment.setCreatedAt(LocalDateTime.parse(createdAt.replace(" ", "T")));
        }

        payment.setCnp(rs.getString("cnp"));
        payment.setAmount(rs.getDouble("amount"));
        payment.setAppointmentId(rs.getInt("appointment_id"));

        return payment;
    }
}
