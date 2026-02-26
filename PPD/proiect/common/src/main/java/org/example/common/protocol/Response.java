package org.example.common.protocol;

public class Response {
    private boolean success;
    private String message;
    private int appointmentId;
    private String type;  // For special responses like SERVER_SHUTDOWN
    private double amount; // For payment responses

    public Response() {
    }

    public static Response success(String message) {
        Response response = new Response();
        response.success = true;
        response.message = message;
        return response;
    }

    public static Response success(String message, int appointmentId) {
        Response response = new Response();
        response.success = true;
        response.message = message;
        response.appointmentId = appointmentId;
        return response;
    }

    public static Response success(String message, int appointmentId, double amount) {
        Response response = new Response();
        response.success = true;
        response.message = message;
        response.appointmentId = appointmentId;
        response.amount = amount;
        return response;
    }

    public static Response failure(String message) {
        Response response = new Response();
        response.success = false;
        response.message = message;
        return response;
    }

    public static Response serverShutdown() {
        Response response = new Response();
        response.type = "SERVER_SHUTDOWN";
        response.message = "Server is shutting down";
        return response;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public int getAppointmentId() {
        return appointmentId;
    }

    public void setAppointmentId(int appointmentId) {
        this.appointmentId = appointmentId;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public boolean isShutdown() {
        return "SERVER_SHUTDOWN".equals(type);
    }

    @Override
    public String toString() {
        return "Response{success=" + success + ", message='" + message +
                "', appointmentId=" + appointmentId + ", type='" + type + "'}";
    }
}
