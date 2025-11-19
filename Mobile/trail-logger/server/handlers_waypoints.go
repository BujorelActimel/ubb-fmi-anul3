package main

import (
	"encoding/json"
	"net/http"
	"strconv"
	"time"
)

func (app *App) handleCreateWaypoint(w http.ResponseWriter, r *http.Request) {
	userID, ok := getUserID(r)
	if !ok {
		respondJSON(w, http.StatusUnauthorized, map[string]string{"error": "unauthorized"})
		return
	}

	trailID, err := strconv.Atoi(r.URL.Query().Get("trail_id"))
	if err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid trail ID"})
		return
	}

	// Verify trail ownership
	var ownerID int
	err = app.db.conn.QueryRow("SELECT user_id FROM trails WHERE id = ?", trailID).Scan(&ownerID)
	if err != nil || ownerID != userID {
		respondJSON(w, http.StatusForbidden, map[string]string{"error": "forbidden"})
		return
	}

	var waypoint Waypoint
	if err := json.NewDecoder(r.Body).Decode(&waypoint); err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid request"})
		return
	}

	waypoint.TrailID = trailID
	waypoint.CreatedAt = time.Now()

	result, err := app.db.conn.Exec(
		"INSERT INTO waypoints (trail_id, lat, lng, name, description, order_index, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)",
		waypoint.TrailID, waypoint.Lat, waypoint.Lng, waypoint.Name, waypoint.Description, waypoint.OrderIndex, waypoint.CreatedAt,
	)

	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "failed to create waypoint"})
		return
	}

	id, _ := result.LastInsertId()
	waypoint.ID = int(id)

	respondJSON(w, http.StatusCreated, waypoint)
}

func (app *App) handleDeleteWaypoint(w http.ResponseWriter, r *http.Request) {
	userID, ok := getUserID(r)
	if !ok {
		respondJSON(w, http.StatusUnauthorized, map[string]string{"error": "unauthorized"})
		return
	}

	waypointID, err := strconv.Atoi(r.URL.Query().Get("id"))
	if err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid waypoint ID"})
		return
	}

	// Verify ownership through trail
	var ownerID int
	err = app.db.conn.QueryRow(
		"SELECT t.user_id FROM waypoints w JOIN trails t ON w.trail_id = t.id WHERE w.id = ?",
		waypointID,
	).Scan(&ownerID)

	if err != nil || ownerID != userID {
		respondJSON(w, http.StatusForbidden, map[string]string{"error": "forbidden"})
		return
	}

	_, err = app.db.conn.Exec("DELETE FROM waypoints WHERE id = ?", waypointID)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "failed to delete waypoint"})
		return
	}

	respondJSON(w, http.StatusOK, map[string]string{"message": "waypoint deleted"})
}
