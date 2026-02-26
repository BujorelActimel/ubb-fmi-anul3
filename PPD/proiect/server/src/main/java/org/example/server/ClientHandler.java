package org.example.server;

import com.google.gson.Gson;
import org.example.common.protocol.Request;
import org.example.common.protocol.Response;
import org.example.server.service.AppointmentService;
import org.example.server.service.PaymentService;

import java.io.*;
import java.net.Socket;
import java.time.LocalDate;
import java.time.LocalTime;

public class ClientHandler implements Runnable {
    private final Socket socket;
    private final AppointmentService appointmentService;
    private final PaymentService paymentService;
    private final Gson gson;
    private BufferedReader reader;
    private PrintWriter writer;
    private volatile boolean running = true;

    public ClientHandler(Socket socket, AppointmentService appointmentService, PaymentService paymentService) {
        this.socket = socket;
        this.appointmentService = appointmentService;
        this.paymentService = paymentService;
        this.gson = new Gson();
    }

    @Override
    public void run() {
        try {
            reader = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            writer = new PrintWriter(socket.getOutputStream(), true);

            System.out.println("Client connected: " + socket.getRemoteSocketAddress());

            String line;
            while (running && (line = reader.readLine()) != null) {
                try {
                    Request request = gson.fromJson(line, Request.class);
                    Response response = processRequest(request);
                    writer.println(gson.toJson(response));
                } catch (Exception e) {
                    Response error = Response.failure("Error processing request: " + e.getMessage());
                    writer.println(gson.toJson(error));
                }
            }
        } catch (IOException e) {
            if (running) {
                System.err.println("Client error: " + e.getMessage());
            }
        } finally {
            close();
        }
    }

    private Response processRequest(Request request) {
        System.out.println("Processing request: " + request);

        return switch (request.getType()) {
            case APPOINTMENT -> appointmentService.createAppointment(
                    request.getName(),
                    request.getCnp(),
                    request.getLocationId(),
                    request.getTreatmentId(),
                    LocalDate.parse(request.getDate()),
                    LocalTime.parse(request.getTime())
            );
            case PAYMENT -> paymentService.processPayment(
                    request.getAppointmentId(),
                    request.getCnp()
            );
            case CANCEL -> appointmentService.cancelAppointment(request.getAppointmentId());
        };
    }

    public void sendShutdown() {
        if (writer != null) {
            Response shutdown = Response.serverShutdown();
            writer.println(gson.toJson(shutdown));
        }
        running = false;
    }

    public void close() {
        running = false;
        try {
            if (reader != null) reader.close();
            if (writer != null) writer.close();
            if (socket != null && !socket.isClosed()) socket.close();
        } catch (IOException e) {
            // Ignore
        }
    }

    public boolean isRunning() {
        return running && !socket.isClosed();
    }
}
