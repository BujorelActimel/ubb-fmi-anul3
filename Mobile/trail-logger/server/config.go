package main

import (
	"os"
)

type Config struct {
	Port      string
	JWTSecret string
	DBPath    string
	UploadDir string
}

func LoadConfig() *Config {
	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		jwtSecret = "your-secret-key-change-in-production"
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	dbPath := os.Getenv("DB_PATH")
	if dbPath == "" {
		dbPath = "./trail-logger.db"
	}

	uploadDir := os.Getenv("UPLOAD_DIR")
	if uploadDir == "" {
		uploadDir = "./uploads"
	}

	return &Config{
		Port:      port,
		JWTSecret: jwtSecret,
		DBPath:    dbPath,
		UploadDir: uploadDir,
	}
}
