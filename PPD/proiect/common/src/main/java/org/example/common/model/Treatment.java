package org.example.common.model;

public class Treatment {
    private final int id;
    private final double cost;
    private final int durationMinutes;

    public Treatment(int id, double cost, int durationMinutes) {
        this.id = id;
        this.cost = cost;
        this.durationMinutes = durationMinutes;
    }

    public int getId() {
        return id;
    }

    public double getCost() {
        return cost;
    }

    public int getDurationMinutes() {
        return durationMinutes;
    }

    @Override
    public String toString() {
        return "Treatment{id=" + id + ", cost=" + cost + ", duration=" + durationMinutes + "min}";
    }
}
