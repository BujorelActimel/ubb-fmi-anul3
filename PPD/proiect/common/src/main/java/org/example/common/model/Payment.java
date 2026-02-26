package org.example.common.model;

import java.time.LocalDateTime;

public class Payment {
    private int id;
    private LocalDateTime createdAt;
    private String cnp;
    private double amount;
    private int appointmentId;

    public Payment() {
    }

    public Payment(String cnp, double amount, int appointmentId) {
        this.cnp = cnp;
        this.amount = amount;
        this.appointmentId = appointmentId;
        this.createdAt = LocalDateTime.now();
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getCnp() {
        return cnp;
    }

    public void setCnp(String cnp) {
        this.cnp = cnp;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public int getAppointmentId() {
        return appointmentId;
    }

    public void setAppointmentId(int appointmentId) {
        this.appointmentId = appointmentId;
    }

    @Override
    public String toString() {
        return "Payment{id=" + id + ", cnp='" + cnp + "', amount=" + amount +
                ", appointmentId=" + appointmentId + "}";
    }
}
