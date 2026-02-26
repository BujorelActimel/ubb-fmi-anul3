package org.example.client;

import com.google.gson.Gson;
import org.example.common.config.ClientConfig;
import org.example.common.protocol.Request;
import org.example.common.protocol.Response;

import java.io.*;
import java.net.Socket;
import java.util.Random;
import java.util.concurrent.TimeUnit;

public class Client {
    private final ClientConfig config;
    private final String clientId;
    private final RequestGenerator requestGenerator;
    private final ResponseHandler responseHandler;
    private final Gson gson;
    private final Random random;

    private Socket socket;
    private BufferedReader reader;
    private PrintWriter writer;
    private volatile boolean running = true;

    // Server parameters (should match server config)
    private static final int LOCATIONS_COUNT = 5;
    private static final int TREATMENTS_COUNT = 5;
    private static final int START_HOUR = 10;
    private static final int END_HOUR = 18;

    public Client(String configPath, String clientId) throws IOException {
        this.config = ClientConfig.load(configPath);
        this.clientId = clientId;
        this.requestGenerator = new RequestGenerator(LOCATIONS_COUNT, TREATMENTS_COUNT, START_HOUR, END_HOUR);
        this.responseHandler = new ResponseHandler(clientId);
        this.gson = new Gson();
        this.random = new Random();

        System.out.println("[" + clientId + "] Loaded config: " + config);
    }

    public void connect() throws IOException {
        socket = new Socket(config.getHost(), config.getPort());
        reader = new BufferedReader(new InputStreamReader(socket.getInputStream()));
        writer = new PrintWriter(socket.getOutputStream(), true);
        System.out.println("[" + clientId + "] Connected to server");
    }

    public void run() {
        try {
            connect();

            while (running) {
                // Generate and send appointment request
                Request appointmentRequest = requestGenerator.generateAppointmentRequest();
                System.out.println("[" + clientId + "] Sending: " + appointmentRequest);

                writer.println(gson.toJson(appointmentRequest));
                String responseLine = reader.readLine();

                if (responseLine == null) {
                    System.out.println("[" + clientId + "] Server closed connection");
                    break;
                }

                Response response = gson.fromJson(responseLine, Response.class);

                if (response.isShutdown()) {
                    responseHandler.handleResponse(response);
                    break;
                }

                responseHandler.handleResponse(response);

                // If appointment was successful, send payment
                if (response.isSuccess() && response.getAppointmentId() > 0) {
                    // Simulate some delay before payment (random 0-3 seconds)
                    Thread.sleep(random.nextInt(3000));

                    // Decide whether to pay (80% chance of payment)
                    if (random.nextDouble() < 0.8) {
                        Request paymentRequest = Request.createPaymentRequest(
                                response.getAppointmentId(),
                                appointmentRequest.getCnp()
                        );
                        System.out.println("[" + clientId + "] Sending payment for appointment " +
                                response.getAppointmentId());

                        writer.println(gson.toJson(paymentRequest));
                        String paymentResponseLine = reader.readLine();

                        if (paymentResponseLine == null) {
                            System.out.println("[" + clientId + "] Server closed connection");
                            break;
                        }

                        Response paymentResponse = gson.fromJson(paymentResponseLine, Response.class);

                        if (paymentResponse.isShutdown()) {
                            responseHandler.handleResponse(paymentResponse);
                            break;
                        }

                        responseHandler.handleResponse(paymentResponse);
                    } else {
                        System.out.println("[" + clientId + "] Skipping payment for appointment " +
                                response.getAppointmentId());
                    }
                }

                // Wait before next request
                TimeUnit.SECONDS.sleep(config.getRequestIntervalSeconds());
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        } catch (IOException e) {
            if (running) {
                System.err.println("[" + clientId + "] Error: " + e.getMessage());
            }
        } finally {
            close();
        }
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
        System.out.println("[" + clientId + "] Disconnected");
    }

    public static void main(String[] args) {
        String configPath = args.length > 0 ? args[0] : "config/client.properties";
        String clientId = args.length > 1 ? args[1] : "Client-" + System.currentTimeMillis() % 1000;

        try {
            Client client = new Client(configPath, clientId);
            client.run();
        } catch (Exception e) {
            System.err.println("Failed to start client: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
