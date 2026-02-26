package org.example.common.config;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;

public class ClientConfig {
    private String host;
    private int port;
    private int requestIntervalSeconds;

    public static ClientConfig load(String path) throws IOException {
        Properties props = new Properties();
        try (FileInputStream fis = new FileInputStream(path)) {
            props.load(fis);
        }

        ClientConfig config = new ClientConfig();
        config.host = props.getProperty("server.host", "localhost");
        config.port = Integer.parseInt(props.getProperty("server.port", "8080"));
        config.requestIntervalSeconds = Integer.parseInt(props.getProperty("request.interval.seconds", "2"));

        return config;
    }

    public String getHost() {
        return host;
    }

    public int getPort() {
        return port;
    }

    public int getRequestIntervalSeconds() {
        return requestIntervalSeconds;
    }

    @Override
    public String toString() {
        return "ClientConfig{host='" + host + "', port=" + port +
                ", requestIntervalSeconds=" + requestIntervalSeconds + "}";
    }
}
