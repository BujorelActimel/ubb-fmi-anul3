package org.example.server;

import org.example.common.config.ServerConfig;
import org.example.server.db.AppointmentDAO;
import org.example.server.db.DatabaseManager;
import org.example.server.db.PaymentDAO;
import org.example.server.service.AppointmentService;
import org.example.server.service.PaymentService;
import org.example.server.service.VerificationService;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketTimeoutException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

public class Server {
    private final ServerConfig config;
    private final ThreadPoolManager threadPool;
    private final SchedulerService scheduler;
    private final AppointmentService appointmentService;
    private final PaymentService paymentService;
    private final VerificationService verificationService;
    private final DatabaseManager dbManager;
    private final List<ClientHandler> clients = new ArrayList<>();
    private volatile boolean running = true;
    private ServerSocket serverSocket;

    public Server(String configPath) throws IOException, SQLException {
        this.config = ServerConfig.load(configPath);
        System.out.println("Loaded config: " + config);

        this.dbManager = DatabaseManager.getInstance();
        dbManager.resetDatabase(); // Start fresh

        AppointmentDAO appointmentDAO = new AppointmentDAO(dbManager.getConnection());
        PaymentDAO paymentDAO = new PaymentDAO(dbManager.getConnection());

        this.appointmentService = new AppointmentService(appointmentDAO, config);
        this.paymentService = new PaymentService(paymentDAO, appointmentDAO, config);

        String logFile = "verification_" + config.getVerificationIntervalSeconds() + "s.log";
        this.verificationService = new VerificationService(appointmentDAO, paymentDAO, config, logFile);

        this.threadPool = new ThreadPoolManager(config.getThreadPoolSize());
        this.scheduler = new SchedulerService(verificationService, config);
    }

    public void start() {
        System.out.println("Starting server on port " + config.getPort());
        System.out.println("Thread pool size: " + config.getThreadPoolSize());
        System.out.println("Runtime: " + config.getRuntimeMinutes() + " minutes");
        System.out.println("Verification interval: " + config.getVerificationIntervalSeconds() + " seconds");

        // Start scheduler
        scheduler.start();

        // Schedule shutdown
        Thread shutdownThread = new Thread(() -> {
            try {
                TimeUnit.MINUTES.sleep(config.getRuntimeMinutes());
                System.out.println("\n=== Server runtime complete ===");
                shutdown();
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        });
        shutdownThread.setDaemon(true);
        shutdownThread.start();

        // Accept connections
        try {
            serverSocket = new ServerSocket(config.getPort());
            serverSocket.setSoTimeout(1000); // Check for shutdown every second

            System.out.println("Server listening on port " + config.getPort());

            while (running) {
                try {
                    Socket clientSocket = serverSocket.accept();
                    ClientHandler handler = new ClientHandler(clientSocket, appointmentService, paymentService);
                    synchronized (clients) {
                        clients.add(handler);
                    }
                    threadPool.submit(handler);
                } catch (SocketTimeoutException e) {
                    // Check if we should continue running
                }
            }
        } catch (IOException e) {
            if (running) {
                System.err.println("Server error: " + e.getMessage());
            }
        }
    }

    public void shutdown() {
        System.out.println("Shutting down server...");
        running = false;

        // Run final verification
        System.out.println("\n=== Final Verification ===");
        verificationService.runVerification();

        // Notify all clients
        synchronized (clients) {
            for (ClientHandler client : clients) {
                client.sendShutdown();
            }
        }

        // Close server socket
        try {
            if (serverSocket != null && !serverSocket.isClosed()) {
                serverSocket.close();
            }
        } catch (IOException e) {
            // Ignore
        }

        // Shutdown services
        scheduler.shutdown();
        threadPool.shutdown();
        dbManager.close();

        System.out.println("Server shutdown complete");
    }

    public static void main(String[] args) {
        String configPath = args.length > 0 ? args[0] : "config/server.properties";

        try {
            Server server = new Server(configPath);
            server.start();
        } catch (Exception e) {
            System.err.println("Failed to start server: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
