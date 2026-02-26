package org.example.server.service;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.locks.ReentrantReadWriteLock;

public class SlotLockManager {
    private final ConcurrentHashMap<String, ReentrantReadWriteLock> locks = new ConcurrentHashMap<>();

    private String getKey(int locationId, LocalDate date, LocalTime time, int treatmentId) {
        return locationId + "_" + date + "_" + time + "_" + treatmentId;
    }

    public ReentrantReadWriteLock getLock(int locationId, LocalDate date, LocalTime time, int treatmentId) {
        String key = getKey(locationId, date, time, treatmentId);
        return locks.computeIfAbsent(key, k -> new ReentrantReadWriteLock());
    }

    public void readLock(int locationId, LocalDate date, LocalTime time, int treatmentId) {
        getLock(locationId, date, time, treatmentId).readLock().lock();
    }

    public void readUnlock(int locationId, LocalDate date, LocalTime time, int treatmentId) {
        getLock(locationId, date, time, treatmentId).readLock().unlock();
    }

    public void writeLock(int locationId, LocalDate date, LocalTime time, int treatmentId) {
        getLock(locationId, date, time, treatmentId).writeLock().lock();
    }

    public void writeUnlock(int locationId, LocalDate date, LocalTime time, int treatmentId) {
        getLock(locationId, date, time, treatmentId).writeLock().unlock();
    }
}
