package org.example.server.service;

import org.example.common.config.ServerConfig;
import org.example.common.model.Appointment;
import org.example.common.model.AppointmentStatus;
import org.example.common.model.Location;
import org.example.server.db.AppointmentDAO;
import org.example.server.db.PaymentDAO;

import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

public class VerificationService {
    private final AppointmentDAO appointmentDAO;
    private final PaymentDAO paymentDAO;
    private final ServerConfig config;
    private final String logFileName;

    public VerificationService(AppointmentDAO appointmentDAO, PaymentDAO paymentDAO,
                                ServerConfig config, String logFileName) {
        this.appointmentDAO = appointmentDAO;
        this.paymentDAO = paymentDAO;
        this.config = config;
        this.logFileName = logFileName;
    }

    public void runVerification() {
        StringBuilder report = new StringBuilder();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm:ss");
        report.append("\n=== Verification ").append(LocalDateTime.now().format(formatter)).append(" ===\n");

        try {
            double totalBalance = 0;

            for (int locationId = 1; locationId <= config.getLocationsCount(); locationId++) {
                double locationBalance = paymentDAO.getTotalByLocation(locationId);
                totalBalance += locationBalance;

                report.append("Location S").append(locationId).append(": balance=")
                        .append(String.format("%.0f", locationBalance)).append(" RON\n");

                // Find unpaid appointments
                List<Appointment> appointments = appointmentDAO.findByLocation(locationId);
                List<Appointment> unpaid = appointments.stream()
                        .filter(a -> a.getStatus() == AppointmentStatus.RESERVED)
                        .toList();

                if (!unpaid.isEmpty()) {
                    report.append("  Unpaid appointments: ");
                    StringJoiner sj = new StringJoiner(", ", "[", "]");
                    for (Appointment a : unpaid) {
                        sj.add("id=" + a.getId() + " time=" + a.getAppointmentTime() + " T" + a.getTreatmentId());
                    }
                    report.append(sj).append("\n");
                }

                // Check for overlaps
                List<String> overlaps = findOverlaps(appointments, locationId);
                if (overlaps.isEmpty()) {
                    report.append("  Overlaps: NONE\n");
                } else {
                    report.append("  Overlaps: ").append(String.join(", ", overlaps)).append("\n");
                }
            }

            report.append("Total balance: ").append(String.format("%.0f", totalBalance)).append(" RON\n");

            // Write to log file
            writeToLog(report.toString());
            System.out.println(report);

        } catch (SQLException e) {
            String error = "Verification error: " + e.getMessage();
            System.err.println(error);
            writeToLog(error);
        }
    }

    private List<String> findOverlaps(List<Appointment> appointments, int locationId) {
        List<String> overlaps = new ArrayList<>();

        // Group by treatment and time
        Map<String, List<Appointment>> grouped = new HashMap<>();
        for (Appointment a : appointments) {
            if (a.getStatus() != AppointmentStatus.CANCELLED) {
                String key = a.getTreatmentId() + "_" + a.getAppointmentDate() + "_" + a.getAppointmentTime();
                grouped.computeIfAbsent(key, k -> new ArrayList<>()).add(a);
            }
        }

        // Check capacity violations
        Location location = config.getLocation(locationId);
        for (Map.Entry<String, List<Appointment>> entry : grouped.entrySet()) {
            List<Appointment> group = entry.getValue();
            if (!group.isEmpty()) {
                int treatmentId = group.get(0).getTreatmentId();
                int capacity = location.getCapacity(treatmentId);
                if (group.size() > capacity) {
                    overlaps.add("T" + treatmentId + " at " + group.get(0).getAppointmentTime() +
                            " has " + group.size() + "/" + capacity + " appointments");
                }
            }
        }

        return overlaps;
    }

    private void writeToLog(String content) {
        try (PrintWriter writer = new PrintWriter(new FileWriter(logFileName, true))) {
            writer.print(content);
        } catch (IOException e) {
            System.err.println("Failed to write to log: " + e.getMessage());
        }
    }

    public void cleanupExpiredReservations(int timeoutSeconds) {
        try {
            List<Appointment> expired = appointmentDAO.findUnpaidOlderThan(timeoutSeconds);
            for (Appointment appointment : expired) {
                appointmentDAO.updateStatus(appointment.getId(), AppointmentStatus.CANCELLED);
                System.out.println("Cancelled expired reservation: " + appointment.getId());
            }
        } catch (SQLException e) {
            System.err.println("Cleanup error: " + e.getMessage());
        }
    }
}
