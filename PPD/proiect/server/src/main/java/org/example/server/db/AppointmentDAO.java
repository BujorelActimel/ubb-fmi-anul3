package org.example.server.db;

import org.example.common.model.Appointment;
import org.example.common.model.AppointmentStatus;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

public class AppointmentDAO {
    private final Connection connection;

    public AppointmentDAO(Connection connection) {
        this.connection = connection;
    }

    public synchronized int create(Appointment appointment) throws SQLException {
        String sql = """
            INSERT INTO appointments (name, cnp, location_id, treatment_id,
                appointment_date, appointment_time, status)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """;

        try (PreparedStatement stmt = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, appointment.getName());
            stmt.setString(2, appointment.getCnp());
            stmt.setInt(3, appointment.getLocationId());
            stmt.setInt(4, appointment.getTreatmentId());
            stmt.setString(5, appointment.getAppointmentDate().toString());
            stmt.setString(6, appointment.getAppointmentTime().toString());
            stmt.setString(7, appointment.getStatus().name());
            stmt.executeUpdate();

            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    public synchronized Appointment findById(int id) throws SQLException {
        String sql = "SELECT * FROM appointments WHERE id = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        }
        return null;
    }

    public synchronized List<Appointment> findByLocationAndDate(int locationId, LocalDate date) throws SQLException {
        String sql = "SELECT * FROM appointments WHERE location_id = ? AND appointment_date = ? AND status != 'CANCELLED'";
        List<Appointment> appointments = new ArrayList<>();
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, locationId);
            stmt.setString(2, date.toString());
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    appointments.add(mapResultSet(rs));
                }
            }
        }
        return appointments;
    }

    public synchronized List<Appointment> findByLocationDateTimeAndTreatment(int locationId, LocalDate date,
            LocalTime time, int treatmentId) throws SQLException {
        String sql = """
            SELECT * FROM appointments
            WHERE location_id = ? AND appointment_date = ? AND appointment_time = ?
            AND treatment_id = ? AND status != 'CANCELLED'
        """;
        List<Appointment> appointments = new ArrayList<>();
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, locationId);
            stmt.setString(2, date.toString());
            stmt.setString(3, time.toString());
            stmt.setInt(4, treatmentId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    appointments.add(mapResultSet(rs));
                }
            }
        }
        return appointments;
    }

    public synchronized List<Appointment> findUnpaidOlderThan(int seconds) throws SQLException {
        String sql = """
            SELECT * FROM appointments
            WHERE status = 'RESERVED'
            AND datetime(created_at) < datetime('now', '-' || ? || ' seconds')
        """;
        List<Appointment> appointments = new ArrayList<>();
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, seconds);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    appointments.add(mapResultSet(rs));
                }
            }
        }
        return appointments;
    }

    public synchronized List<Appointment> findByStatus(AppointmentStatus status) throws SQLException {
        String sql = "SELECT * FROM appointments WHERE status = ?";
        List<Appointment> appointments = new ArrayList<>();
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, status.name());
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    appointments.add(mapResultSet(rs));
                }
            }
        }
        return appointments;
    }

    public synchronized List<Appointment> findByLocation(int locationId) throws SQLException {
        String sql = "SELECT * FROM appointments WHERE location_id = ? AND status != 'CANCELLED'";
        List<Appointment> appointments = new ArrayList<>();
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, locationId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    appointments.add(mapResultSet(rs));
                }
            }
        }
        return appointments;
    }

    public synchronized List<Appointment> findAll() throws SQLException {
        String sql = "SELECT * FROM appointments";
        List<Appointment> appointments = new ArrayList<>();
        try (Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                appointments.add(mapResultSet(rs));
            }
        }
        return appointments;
    }

    public synchronized void updateStatus(int id, AppointmentStatus status) throws SQLException {
        String sql = "UPDATE appointments SET status = ? WHERE id = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, status.name());
            stmt.setInt(2, id);
            stmt.executeUpdate();
        }
    }

    public synchronized void delete(int id) throws SQLException {
        String sql = "DELETE FROM appointments WHERE id = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, id);
            stmt.executeUpdate();
        }
    }

    private Appointment mapResultSet(ResultSet rs) throws SQLException {
        Appointment appointment = new Appointment();
        appointment.setId(rs.getInt("id"));
        appointment.setName(rs.getString("name"));
        appointment.setCnp(rs.getString("cnp"));

        String createdAt = rs.getString("created_at");
        if (createdAt != null) {
            appointment.setCreatedAt(LocalDateTime.parse(createdAt.replace(" ", "T")));
        }

        appointment.setLocationId(rs.getInt("location_id"));
        appointment.setTreatmentId(rs.getInt("treatment_id"));
        appointment.setAppointmentDate(LocalDate.parse(rs.getString("appointment_date")));
        appointment.setAppointmentTime(LocalTime.parse(rs.getString("appointment_time")));
        appointment.setStatus(AppointmentStatus.valueOf(rs.getString("status")));

        return appointment;
    }
}
