package org.example.common.model;

import java.util.Map;

public class Location {
    private final int id;
    private final Map<Integer, Integer> treatmentCapacity; // treatmentId -> capacity

    public Location(int id, Map<Integer, Integer> treatmentCapacity) {
        this.id = id;
        this.treatmentCapacity = treatmentCapacity;
    }

    public int getId() {
        return id;
    }

    public int getCapacity(int treatmentId) {
        return treatmentCapacity.getOrDefault(treatmentId, 0);
    }

    public Map<Integer, Integer> getTreatmentCapacity() {
        return treatmentCapacity;
    }

    @Override
    public String toString() {
        return "Location{id=" + id + ", capacity=" + treatmentCapacity + "}";
    }
}
