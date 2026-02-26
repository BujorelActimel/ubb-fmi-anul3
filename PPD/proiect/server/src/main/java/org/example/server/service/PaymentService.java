package org.example.server.service;

import org.example.common.config.ServerConfig;
import org.example.common.model.Appointment;
import org.example.common.model.AppointmentStatus;
import org.example.common.model.Payment;
import org.example.common.protocol.Response;
import org.example.server.db.AppointmentDAO;
import org.example.server.db.PaymentDAO;

import java.sql.SQLException;

public class PaymentService {
    private final PaymentDAO paymentDAO;
    private final AppointmentDAO appointmentDAO;
    private final ServerConfig config;

    public PaymentService(PaymentDAO paymentDAO, AppointmentDAO appointmentDAO, ServerConfig config) {
        this.paymentDAO = paymentDAO;
        this.appointmentDAO = appointmentDAO;
        this.config = config;
    }

    public synchronized Response processPayment(int appointmentId, String cnp) {
        try {
            Appointment appointment = appointmentDAO.findById(appointmentId);

            if (appointment == null) {
                return Response.failure("Appointment not found");
            }

            if (!appointment.getCnp().equals(cnp)) {
                return Response.failure("CNP does not match appointment");
            }

            if (appointment.getStatus() == AppointmentStatus.PAID) {
                return Response.failure("Appointment already paid");
            }

            if (appointment.getStatus() == AppointmentStatus.CANCELLED) {
                return Response.failure("Cannot pay for cancelled appointment");
            }

            // Check if already paid
            Payment existingPayment = paymentDAO.findByAppointmentId(appointmentId);
            if (existingPayment != null) {
                return Response.failure("Payment already exists for this appointment");
            }

            // Get treatment cost
            double amount = config.getTreatment(appointment.getTreatmentId()).getCost();

            // Create payment
            Payment payment = new Payment(cnp, amount, appointmentId);
            int paymentId = paymentDAO.create(payment);

            if (paymentId > 0) {
                // Update appointment status
                appointmentDAO.updateStatus(appointmentId, AppointmentStatus.PAID);
                return Response.success("Payment successful", appointmentId, amount);
            } else {
                return Response.failure("Failed to process payment");
            }
        } catch (SQLException e) {
            return Response.failure("Database error: " + e.getMessage());
        }
    }

    public double getTotalByLocation(int locationId) throws SQLException {
        return paymentDAO.getTotalByLocation(locationId);
    }

    public double getTotal() throws SQLException {
        return paymentDAO.getTotal();
    }
}
