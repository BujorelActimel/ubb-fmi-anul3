package org.example.client;

import org.example.common.protocol.Response;

public class ResponseHandler {
    private final String clientId;

    public ResponseHandler(String clientId) {
        this.clientId = clientId;
    }

    public void handleResponse(Response response) {
        if (response.isShutdown()) {
            System.out.println("[" + clientId + "] Server is shutting down");
            return;
        }

        if (response.isSuccess()) {
            if (response.getAppointmentId() > 0) {
                System.out.println("[" + clientId + "] SUCCESS: " + response.getMessage() +
                        " (ID: " + response.getAppointmentId() + ", Amount: " + response.getAmount() + " RON)");
            } else {
                System.out.println("[" + clientId + "] SUCCESS: " + response.getMessage());
            }
        } else {
            System.out.println("[" + clientId + "] FAILED: " + response.getMessage());
        }
    }
}
