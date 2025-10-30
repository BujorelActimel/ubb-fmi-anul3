package main

import (
	"bufio"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strings"

	"revolut-clone-server/database"
	"revolut-clone-server/handlers"
	"revolut-clone-server/middleware"
)

func main() {
	// Load environment variables from .env file
	loadEnv()

	// Initialize database
	if err := database.InitDB(); err != nil {
		log.Fatalf("Failed to initialize database: %v", err)
	}
	defer database.CloseDB()

	// Create HTTP mux
	mux := http.NewServeMux()

	// Public routes
	mux.HandleFunc("/auth/login", corsMiddleware(handlers.InitiateOAuth))
	mux.HandleFunc("/auth/callback", corsMiddleware(handlers.HandleOAuthCallback))
	mux.HandleFunc("/auth/logout", corsMiddleware(handlers.Logout))

	// Protected routes
	mux.HandleFunc("/api/transactions", corsMiddleware(middleware.AuthMiddleware(handlers.HandleTransactions)))
	mux.HandleFunc("/api/transactions/", corsMiddleware(middleware.AuthMiddleware(handlers.HandleTransactionByID)))

	// WebSocket endpoint
	mux.HandleFunc("/ws", corsMiddleware(middleware.WSAuthMiddleware(handlers.HandleWebSocket)))

	// Health check
	mux.HandleFunc("/health", corsMiddleware(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
	}))

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	if err := http.ListenAndServe(":"+port, mux); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}

// loadEnv loads environment variables from .env file
func loadEnv() {
	file, err := os.Open(".env")
	if err != nil {
		log.Println("No .env file found, using environment variables")
		return
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		parts := strings.SplitN(line, "=", 2)
		if len(parts) == 2 {
			key := strings.TrimSpace(parts[0])
			value := strings.TrimSpace(parts[1])
			os.Setenv(key, value)
		}
	}

	if err := scanner.Err(); err != nil {
		log.Printf("Error reading .env file: %v", err)
	}
}

// corsMiddleware adds CORS headers to responses
func corsMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Origin, Content-Type, Authorization")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next(w, r)
	}
}
