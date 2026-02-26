package org.example.common.protocol;

public class Request {
    private RequestType type;
    private String name;
    private String cnp;
    private int locationId;
    private int treatmentId;
    private String date;  // Format: yyyy-MM-dd
    private String time;  // Format: HH:mm
    private int appointmentId;

    public Request() {
    }

    public static Request createAppointmentRequest(String name, String cnp, int locationId,
                                                    int treatmentId, String date, String time) {
        Request request = new Request();
        request.type = RequestType.APPOINTMENT;
        request.name = name;
        request.cnp = cnp;
        request.locationId = locationId;
        request.treatmentId = treatmentId;
        request.date = date;
        request.time = time;
        return request;
    }

    public static Request createPaymentRequest(int appointmentId, String cnp) {
        Request request = new Request();
        request.type = RequestType.PAYMENT;
        request.appointmentId = appointmentId;
        request.cnp = cnp;
        return request;
    }

    public static Request createCancelRequest(int appointmentId) {
        Request request = new Request();
        request.type = RequestType.CANCEL;
        request.appointmentId = appointmentId;
        return request;
    }

    public RequestType getType() {
        return type;
    }

    public void setType(RequestType type) {
        this.type = type;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCnp() {
        return cnp;
    }

    public void setCnp(String cnp) {
        this.cnp = cnp;
    }

    public int getLocationId() {
        return locationId;
    }

    public void setLocationId(int locationId) {
        this.locationId = locationId;
    }

    public int getTreatmentId() {
        return treatmentId;
    }

    public void setTreatmentId(int treatmentId) {
        this.treatmentId = treatmentId;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getTime() {
        return time;
    }

    public void setTime(String time) {
        this.time = time;
    }

    public int getAppointmentId() {
        return appointmentId;
    }

    public void setAppointmentId(int appointmentId) {
        this.appointmentId = appointmentId;
    }

    @Override
    public String toString() {
        return "Request{type=" + type + ", name='" + name + "', cnp='" + cnp +
                "', locationId=" + locationId + ", treatmentId=" + treatmentId +
                ", date='" + date + "', time='" + time + "', appointmentId=" + appointmentId + "}";
    }
}
