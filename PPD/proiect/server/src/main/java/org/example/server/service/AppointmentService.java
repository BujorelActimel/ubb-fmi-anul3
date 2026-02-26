package org.example.server.service;

import org.example.common.config.ServerConfig;
import org.example.common.model.Appointment;
import org.example.common.model.AppointmentStatus;
import org.example.common.model.Location;
import org.example.common.protocol.Response;
import org.example.server.db.AppointmentDAO;

import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

public class AppointmentService {
    private final AppointmentDAO appointmentDAO;
    private final ServerConfig config;
    private final SlotLockManager lockManager;

    public AppointmentService(AppointmentDAO appointmentDAO, ServerConfig config) {
        this.appointmentDAO = appointmentDAO;
        this.config = config;
        this.lockManager = new SlotLockManager();
    }

    public Response createAppointment(String name, String cnp, int locationId, int treatmentId,
                                       LocalDate date, LocalTime time) {
        // Validate location and treatment
        if (locationId < 1 || locationId > config.getLocationsCount()) {
            return Response.failure("Invalid location ID: " + locationId);
        }
        if (treatmentId < 1 || treatmentId > config.getTreatmentsCount()) {
            return Response.failure("Invalid treatment ID: " + treatmentId);
        }

        // Validate time is within operating hours
        int hour = time.getHour();
        if (hour < config.getOperatingHoursStart() || hour >= config.getOperatingHoursEnd()) {
            return Response.failure("Appointment time outside operating hours");
        }

        Location location = config.getLocation(locationId);
        int capacity = location.getCapacity(treatmentId);

        // Use write lock for the entire operation to ensure atomicity
        lockManager.writeLock(locationId, date, time, treatmentId);
        try {
            // Check current appointments for this slot
            List<Appointment> existingAppointments = appointmentDAO.findByLocationDateTimeAndTreatment(
                    locationId, date, time, treatmentId);

            if (existingAppointments.size() >= capacity) {
                return Response.failure("Slot is full - capacity " + capacity + " reached");
            }

            // Create the appointment
            Appointment appointment = new Appointment(name, cnp, locationId, treatmentId, date, time);
            int appointmentId = appointmentDAO.create(appointment);

            if (appointmentId > 0) {
                double cost = config.getTreatment(treatmentId).getCost();
                return Response.success("Appointment created successfully", appointmentId, cost);
            } else {
                return Response.failure("Failed to create appointment");
            }
        } catch (SQLException e) {
            return Response.failure("Database error: " + e.getMessage());
        } finally {
            lockManager.writeUnlock(locationId, date, time, treatmentId);
        }
    }

    public Response cancelAppointment(int appointmentId) {
        try {
            Appointment appointment = appointmentDAO.findById(appointmentId);
            if (appointment == null) {
                return Response.failure("Appointment not found");
            }

            if (appointment.getStatus() == AppointmentStatus.CANCELLED) {
                return Response.failure("Appointment already cancelled");
            }

            appointmentDAO.updateStatus(appointmentId, AppointmentStatus.CANCELLED);
            return Response.success("Appointment cancelled successfully");
        } catch (SQLException e) {
            return Response.failure("Database error: " + e.getMessage());
        }
    }

    public Appointment getAppointment(int id) throws SQLException {
        return appointmentDAO.findById(id);
    }

    public List<Appointment> getUnpaidAppointments(int timeoutSeconds) throws SQLException {
        return appointmentDAO.findUnpaidOlderThan(timeoutSeconds);
    }

    public void markAsPaid(int appointmentId) throws SQLException {
        appointmentDAO.updateStatus(appointmentId, AppointmentStatus.PAID);
    }

    public void deleteExpiredReservation(int appointmentId) throws SQLException {
        appointmentDAO.updateStatus(appointmentId, AppointmentStatus.CANCELLED);
    }
}
