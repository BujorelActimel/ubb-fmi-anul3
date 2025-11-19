package main

import "time"

type User struct {
	ID           int       `json:"id"`
	Username     string    `json:"username"`
	Email        string    `json:"email"`
	PasswordHash string    `json:"-"`
	CreatedAt    time.Time `json:"created_at"`
}

type Trail struct {
	ID            int       `json:"id"`
	UserID        int       `json:"user_id"`
	Name          string    `json:"name"`
	Description   string    `json:"description"`
	Difficulty    string    `json:"difficulty"` // easy, moderate, hard
	Distance      float64   `json:"distance"`   // in km
	ElevationGain float64   `json:"elevation_gain"` // in meters
	StartLat      float64   `json:"start_lat"`
	StartLng      float64   `json:"start_lng"`
	EndLat        float64   `json:"end_lat"`
	EndLng        float64   `json:"end_lng"`
	Status        string    `json:"status"` // planned, completed, in_progress
	Synced        bool      `json:"synced"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

type Waypoint struct {
	ID          int       `json:"id"`
	TrailID     int       `json:"trail_id"`
	Lat         float64   `json:"lat"`
	Lng         float64   `json:"lng"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	OrderIndex  int       `json:"order_index"`
	CreatedAt   time.Time `json:"created_at"`
}

type Photo struct {
	ID          int       `json:"id"`
	TrailID     int       `json:"trail_id"`
	WaypointID  *int      `json:"waypoint_id"`
	Filename    string    `json:"filename"`
	ServerURL   string    `json:"server_url"`
	Uploaded    bool      `json:"uploaded"`
	CreatedAt   time.Time `json:"created_at"`
}

// Request/Response types
type RegisterRequest struct {
	Username string `json:"username"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type AuthResponse struct {
	Token string `json:"token"`
	User  User   `json:"user"`
}

type TrailWithDetails struct {
	Trail
	Waypoints []Waypoint `json:"waypoints"`
	Photos    []Photo    `json:"photos"`
}

type PaginatedTrails struct {
	Trails []Trail `json:"trails"`
	Total  int     `json:"total"`
	Page   int     `json:"page"`
	Limit  int     `json:"limit"`
}

// WebSocket message types
type WSMessage struct {
	Type    string      `json:"type"`
	Payload interface{} `json:"payload"`
}

type TrailUpdateMessage struct {
	TrailID int    `json:"trail_id"`
	UserID  int    `json:"user_id"`
	Message string `json:"message"`
}
