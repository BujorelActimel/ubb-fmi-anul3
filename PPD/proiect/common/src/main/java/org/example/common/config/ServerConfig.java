package org.example.common.config;

import org.example.common.model.Location;
import org.example.common.model.Treatment;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.*;

public class ServerConfig {
    private int port;
    private int threadPoolSize;
    private int runtimeMinutes;
    private int verificationIntervalSeconds;
    private int paymentTimeoutSeconds;
    private int locationsCount;
    private int treatmentsCount;
    private int operatingHoursStart;
    private int operatingHoursEnd;
    private List<Treatment> treatments;
    private List<Location> locations;
    private int[] baseCapacity;

    public static ServerConfig load(String path) throws IOException {
        Properties props = new Properties();
        try (FileInputStream fis = new FileInputStream(path)) {
            props.load(fis);
        }

        ServerConfig config = new ServerConfig();
        config.port = Integer.parseInt(props.getProperty("server.port", "8080"));
        config.threadPoolSize = Integer.parseInt(props.getProperty("server.thread.pool.size", "10"));
        config.runtimeMinutes = Integer.parseInt(props.getProperty("server.runtime.minutes", "3"));
        config.verificationIntervalSeconds = Integer.parseInt(props.getProperty("verification.interval.seconds", "5"));
        config.paymentTimeoutSeconds = Integer.parseInt(props.getProperty("payment.timeout.seconds", "10"));
        config.locationsCount = Integer.parseInt(props.getProperty("locations.count", "5"));
        config.treatmentsCount = Integer.parseInt(props.getProperty("treatments.count", "5"));
        config.operatingHoursStart = Integer.parseInt(props.getProperty("operating.hours.start", "10"));
        config.operatingHoursEnd = Integer.parseInt(props.getProperty("operating.hours.end", "18"));

        // Parse treatment costs
        String[] costs = props.getProperty("treatments.costs", "50,20,40,100,30").split(",");
        String[] durations = props.getProperty("treatments.durations", "120,20,30,60,30").split(",");

        config.treatments = new ArrayList<>();
        for (int i = 0; i < config.treatmentsCount; i++) {
            double cost = Double.parseDouble(costs[i].trim());
            int duration = Integer.parseInt(durations[i].trim());
            config.treatments.add(new Treatment(i + 1, cost, duration));
        }

        // Parse base capacity
        String[] capacities = props.getProperty("treatments.base.capacity", "3,1,1,2,1").split(",");
        config.baseCapacity = new int[capacities.length];
        for (int i = 0; i < capacities.length; i++) {
            config.baseCapacity[i] = Integer.parseInt(capacities[i].trim());
        }

        // Create locations with capacity N(i,j) = N(1,j) * i
        config.locations = new ArrayList<>();
        for (int i = 1; i <= config.locationsCount; i++) {
            Map<Integer, Integer> treatmentCapacity = new HashMap<>();
            for (int j = 0; j < config.treatmentsCount; j++) {
                int capacity = config.baseCapacity[j] * i;
                treatmentCapacity.put(j + 1, capacity);
            }
            config.locations.add(new Location(i, treatmentCapacity));
        }

        return config;
    }

    public int getPort() {
        return port;
    }

    public int getThreadPoolSize() {
        return threadPoolSize;
    }

    public int getRuntimeMinutes() {
        return runtimeMinutes;
    }

    public int getVerificationIntervalSeconds() {
        return verificationIntervalSeconds;
    }

    public int getPaymentTimeoutSeconds() {
        return paymentTimeoutSeconds;
    }

    public int getLocationsCount() {
        return locationsCount;
    }

    public int getTreatmentsCount() {
        return treatmentsCount;
    }

    public int getOperatingHoursStart() {
        return operatingHoursStart;
    }

    public int getOperatingHoursEnd() {
        return operatingHoursEnd;
    }

    public List<Treatment> getTreatments() {
        return treatments;
    }

    public Treatment getTreatment(int id) {
        return treatments.get(id - 1);
    }

    public List<Location> getLocations() {
        return locations;
    }

    public Location getLocation(int id) {
        return locations.get(id - 1);
    }

    public int[] getBaseCapacity() {
        return baseCapacity;
    }

    @Override
    public String toString() {
        return "ServerConfig{port=" + port + ", threadPoolSize=" + threadPoolSize +
                ", runtimeMinutes=" + runtimeMinutes + ", locations=" + locationsCount +
                ", treatments=" + treatmentsCount + "}";
    }
}
