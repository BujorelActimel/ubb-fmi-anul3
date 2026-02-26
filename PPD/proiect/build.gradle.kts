plugins {
    base
}

allprojects {
    repositories {
        mavenCentral()
    }
}

tasks.register("cleanLogs") {
    group = "application"
    description = "Clean verification log files"
    doLast {
        delete(fileTree(".") {
            include("verification_*.log")
        })
        delete("clinic.db")
        println("Cleaned log files and database")
    }
}

tasks.register("runClients") {
    group = "application"
    description = "Print instructions for running multiple clients"
    doLast {
        println("""
            |
            |To run the system:
            |
            |1. Start the server (in one terminal):
            |   ./gradlew :server:run
            |
            |2. Start clients (in separate terminals):
            |   ./gradlew :client:run -PclientId=Client-1
            |   ./gradlew :client:run -PclientId=Client-2
            |   ... or use runClient1, runClient2, etc.
            |
            |3. Or run specific clients:
            |   ./gradlew :client:runClient1
            |   ./gradlew :client:runClient2
            |   ...
            |   ./gradlew :client:runClient10
            |
            |Server variants:
            |   ./gradlew :server:runWith5s   (5-second verification)
            |   ./gradlew :server:runWith10s  (10-second verification)
            |
        """.trimMargin())
    }
}
