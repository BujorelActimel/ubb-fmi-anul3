package org.example.client;

import org.example.common.protocol.Request;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.Random;

public class RequestGenerator {
    private static final String[] NAMES = {"Ion", "Maria", "Andrei", "Elena", "George", "Ana", "Mihai", "Ioana", "Alex", "Diana"};
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm");
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    private final Random random;
    private final int locationsCount;
    private final int treatmentsCount;
    private final int startHour;
    private final int endHour;

    public RequestGenerator(int locationsCount, int treatmentsCount, int startHour, int endHour) {
        this.random = new Random();
        this.locationsCount = locationsCount;
        this.treatmentsCount = treatmentsCount;
        this.startHour = startHour;
        this.endHour = endHour;
    }

    public Request generateAppointmentRequest() {
        String name = NAMES[random.nextInt(NAMES.length)];
        String cnp = generateCnp();
        int locationId = random.nextInt(locationsCount) + 1;
        int treatmentId = random.nextInt(treatmentsCount) + 1;

        // Generate random date (today or tomorrow)
        LocalDate date = LocalDate.now().plusDays(random.nextInt(2));

        // Generate random time within operating hours (on the hour or half hour)
        int hour = startHour + random.nextInt(endHour - startHour);
        int minute = random.nextBoolean() ? 0 : 30;
        LocalTime time = LocalTime.of(hour, minute);

        return Request.createAppointmentRequest(
                name,
                cnp,
                locationId,
                treatmentId,
                date.format(DATE_FORMATTER),
                time.format(TIME_FORMATTER)
        );
    }

    private String generateCnp() {
        StringBuilder cnp = new StringBuilder();
        cnp.append(random.nextInt(3) + 1); // First digit 1-3
        for (int i = 0; i < 12; i++) {
            cnp.append(random.nextInt(10));
        }
        return cnp.toString();
    }
}
