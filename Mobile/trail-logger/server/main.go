package main

import (
	"encoding/json"
	"log"
	"net/http"
	"strings"
)

type App struct {
	config *Config
	db     *Database
	hub    *Hub
}

func main() {
	config := LoadConfig()

	db, err := NewDatabase(config.DBPath)
	if err != nil {
		log.Fatalf("Failed to initialize database: %v", err)
	}
	defer db.Close()

	hub := NewHub()
	go hub.Run()

	app := &App{
		config: config,
		db:     db,
		hub:    hub,
	}

	mux := http.NewServeMux()

	// Auth routes
	mux.HandleFunc("/auth/register", app.loggingMiddleware(app.corsMiddleware(app.handleRegister)))
	mux.HandleFunc("/auth/login", app.loggingMiddleware(app.corsMiddleware(app.handleLogin)))
	mux.HandleFunc("/auth/me", app.loggingMiddleware(app.corsMiddleware(app.authMiddleware(app.handleMe))))

	// Trail routes
	mux.HandleFunc("/api/trails", app.loggingMiddleware(app.corsMiddleware(app.authMiddleware(handleTrailsRouter(app)))))
	mux.HandleFunc("/api/trail", app.loggingMiddleware(app.corsMiddleware(app.authMiddleware(handleTrailRouter(app)))))

	// Waypoint routes
	mux.HandleFunc("/api/waypoints", app.loggingMiddleware(app.corsMiddleware(app.authMiddleware(handleWaypointsRouter(app)))))

	// Photo routes
	mux.HandleFunc("/api/photos", app.loggingMiddleware(app.corsMiddleware(app.authMiddleware(handlePhotosRouter(app)))))
	mux.HandleFunc("/uploads/", app.loggingMiddleware(app.handleServePhoto))

	// WebSocket route
	mux.HandleFunc("/ws", app.handleWebSocket)

	log.Printf("Server starting on port %s", config.Port)
	if err := http.ListenAndServe(":"+config.Port, mux); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}

// Router helpers
func handleTrailsRouter(app *App) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		switch r.Method {
		case "GET":
			app.handleGetTrails(w, r)
		case "POST":
			app.handleCreateTrail(w, r)
		default:
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		}
	}
}

func handleTrailRouter(app *App) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		switch r.Method {
		case "GET":
			app.handleGetTrail(w, r)
		case "PUT":
			app.handleUpdateTrail(w, r)
		case "DELETE":
			app.handleDeleteTrail(w, r)
		default:
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		}
	}
}

func handleWaypointsRouter(app *App) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		switch r.Method {
		case "POST":
			app.handleCreateWaypoint(w, r)
		case "DELETE":
			app.handleDeleteWaypoint(w, r)
		default:
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		}
	}
}

func handlePhotosRouter(app *App) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		switch r.Method {
		case "GET":
			app.handleGetPhotos(w, r)
		case "POST":
			app.handleUploadPhoto(w, r)
		case "DELETE":
			app.handleDeletePhoto(w, r)
		default:
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		}
	}
}

// Helper function
func respondJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(data)
}

// Extract path parameter helper
func getPathParam(path, prefix string) string {
	return strings.TrimPrefix(path, prefix)
}
