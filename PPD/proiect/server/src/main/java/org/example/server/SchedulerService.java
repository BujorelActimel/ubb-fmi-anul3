package org.example.server;

import org.example.common.config.ServerConfig;
import org.example.server.service.VerificationService;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class SchedulerService {
    private final ScheduledExecutorService scheduler;
    private final VerificationService verificationService;
    private final ServerConfig config;

    public SchedulerService(VerificationService verificationService, ServerConfig config) {
        this.scheduler = Executors.newScheduledThreadPool(2);
        this.verificationService = verificationService;
        this.config = config;
    }

    public void start() {
        // Schedule periodic verification
        scheduler.scheduleAtFixedRate(
                verificationService::runVerification,
                config.getVerificationIntervalSeconds(),
                config.getVerificationIntervalSeconds(),
                TimeUnit.SECONDS
        );

        // Schedule cleanup of expired reservations
        scheduler.scheduleAtFixedRate(
                () -> verificationService.cleanupExpiredReservations(config.getPaymentTimeoutSeconds()),
                config.getPaymentTimeoutSeconds(),
                config.getPaymentTimeoutSeconds() / 2,
                TimeUnit.SECONDS
        );

        System.out.println("Scheduler started: verification every " +
                config.getVerificationIntervalSeconds() + "s, cleanup every " +
                (config.getPaymentTimeoutSeconds() / 2) + "s");
    }

    public void shutdown() {
        scheduler.shutdown();
        try {
            if (!scheduler.awaitTermination(5, TimeUnit.SECONDS)) {
                scheduler.shutdownNow();
            }
        } catch (InterruptedException e) {
            scheduler.shutdownNow();
            Thread.currentThread().interrupt();
        }
    }
}
