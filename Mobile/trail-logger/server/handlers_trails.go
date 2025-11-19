package main

import (
	"database/sql"
	"encoding/json"
	"net/http"
	"strconv"
	"strings"
	"time"
)

func (app *App) handleGetTrails(w http.ResponseWriter, r *http.Request) {
	userID, ok := getUserID(r)
	if !ok {
		respondJSON(w, http.StatusUnauthorized, map[string]string{"error": "unauthorized"})
		return
	}

	// Parse query parameters
	page, _ := strconv.Atoi(r.URL.Query().Get("page"))
	if page < 1 {
		page = 1
	}
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	if limit < 1 || limit > 100 {
		limit = 20
	}
	offset := (page - 1) * limit

	difficulty := r.URL.Query().Get("difficulty")
	status := r.URL.Query().Get("status")
	search := r.URL.Query().Get("search")

	// Build query
	query := "SELECT id, user_id, name, description, difficulty, distance, elevation_gain, start_lat, start_lng, end_lat, end_lng, status, synced, created_at, updated_at FROM trails WHERE user_id = ?"
	args := []interface{}{userID}

	if difficulty != "" {
		query += " AND difficulty = ?"
		args = append(args, difficulty)
	}
	if status != "" {
		query += " AND status = ?"
		args = append(args, status)
	}
	if search != "" {
		query += " AND (name LIKE ? OR description LIKE ?)"
		searchPattern := "%" + search + "%"
		args = append(args, searchPattern, searchPattern)
	}

	// Count total
	countQuery := strings.Replace(query, "SELECT id, user_id, name, description, difficulty, distance, elevation_gain, start_lat, start_lng, end_lat, end_lng, status, synced, created_at, updated_at", "SELECT COUNT(*)", 1)
	var total int
	app.db.conn.QueryRow(countQuery, args...).Scan(&total)

	// Add pagination
	query += " ORDER BY updated_at DESC LIMIT ? OFFSET ?"
	args = append(args, limit, offset)

	rows, err := app.db.conn.Query(query, args...)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "database error"})
		return
	}
	defer rows.Close()

	trails := []Trail{}
	for rows.Next() {
		var trail Trail
		err := rows.Scan(
			&trail.ID, &trail.UserID, &trail.Name, &trail.Description,
			&trail.Difficulty, &trail.Distance, &trail.ElevationGain,
			&trail.StartLat, &trail.StartLng, &trail.EndLat, &trail.EndLng,
			&trail.Status, &trail.Synced, &trail.CreatedAt, &trail.UpdatedAt,
		)
		if err != nil {
			continue
		}
		trails = append(trails, trail)
	}

	respondJSON(w, http.StatusOK, PaginatedTrails{
		Trails: trails,
		Total:  total,
		Page:   page,
		Limit:  limit,
	})
}

func (app *App) handleGetTrail(w http.ResponseWriter, r *http.Request) {
	userID, ok := getUserID(r)
	if !ok {
		respondJSON(w, http.StatusUnauthorized, map[string]string{"error": "unauthorized"})
		return
	}

	trailID, err := strconv.Atoi(r.URL.Query().Get("id"))
	if err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid trail ID"})
		return
	}

	var trail Trail
	err = app.db.conn.QueryRow(
		"SELECT id, user_id, name, description, difficulty, distance, elevation_gain, start_lat, start_lng, end_lat, end_lng, status, synced, created_at, updated_at FROM trails WHERE id = ? AND user_id = ?",
		trailID, userID,
	).Scan(
		&trail.ID, &trail.UserID, &trail.Name, &trail.Description,
		&trail.Difficulty, &trail.Distance, &trail.ElevationGain,
		&trail.StartLat, &trail.StartLng, &trail.EndLat, &trail.EndLng,
		&trail.Status, &trail.Synced, &trail.CreatedAt, &trail.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		respondJSON(w, http.StatusNotFound, map[string]string{"error": "trail not found"})
		return
	}
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "database error"})
		return
	}

	// Get waypoints
	waypoints := []Waypoint{}
	rows, err := app.db.conn.Query(
		"SELECT id, trail_id, lat, lng, name, description, order_index, created_at FROM waypoints WHERE trail_id = ? ORDER BY order_index",
		trailID,
	)
	if err == nil {
		defer rows.Close()
		for rows.Next() {
			var wp Waypoint
			rows.Scan(&wp.ID, &wp.TrailID, &wp.Lat, &wp.Lng, &wp.Name, &wp.Description, &wp.OrderIndex, &wp.CreatedAt)
			waypoints = append(waypoints, wp)
		}
	}

	// Get photos
	photos := []Photo{}
	rows2, err := app.db.conn.Query(
		"SELECT id, trail_id, waypoint_id, filename, server_url, uploaded, created_at FROM photos WHERE trail_id = ?",
		trailID,
	)
	if err == nil {
		defer rows2.Close()
		for rows2.Next() {
			var photo Photo
			rows2.Scan(&photo.ID, &photo.TrailID, &photo.WaypointID, &photo.Filename, &photo.ServerURL, &photo.Uploaded, &photo.CreatedAt)
			photos = append(photos, photo)
		}
	}

	respondJSON(w, http.StatusOK, TrailWithDetails{
		Trail:     trail,
		Waypoints: waypoints,
		Photos:    photos,
	})
}

func (app *App) handleCreateTrail(w http.ResponseWriter, r *http.Request) {
	userID, ok := getUserID(r)
	if !ok {
		respondJSON(w, http.StatusUnauthorized, map[string]string{"error": "unauthorized"})
		return
	}

	var trail Trail
	if err := json.NewDecoder(r.Body).Decode(&trail); err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid request"})
		return
	}

	trail.UserID = userID
	trail.Synced = true
	trail.CreatedAt = time.Now()
	trail.UpdatedAt = time.Now()

	result, err := app.db.conn.Exec(
		`INSERT INTO trails (user_id, name, description, difficulty, distance, elevation_gain, start_lat, start_lng, end_lat, end_lng, status, synced, created_at, updated_at)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
		trail.UserID, trail.Name, trail.Description, trail.Difficulty,
		trail.Distance, trail.ElevationGain, trail.StartLat, trail.StartLng,
		trail.EndLat, trail.EndLng, trail.Status, trail.Synced, trail.CreatedAt, trail.UpdatedAt,
	)

	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "failed to create trail"})
		return
	}

	id, _ := result.LastInsertId()
	trail.ID = int(id)

	// Notify via WebSocket
	app.broadcastTrailUpdate(trail.ID, userID, "Trail created")

	respondJSON(w, http.StatusCreated, trail)
}

func (app *App) handleUpdateTrail(w http.ResponseWriter, r *http.Request) {
	userID, ok := getUserID(r)
	if !ok {
		respondJSON(w, http.StatusUnauthorized, map[string]string{"error": "unauthorized"})
		return
	}

	trailID, err := strconv.Atoi(r.URL.Query().Get("id"))
	if err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid trail ID"})
		return
	}

	var trail Trail
	if err := json.NewDecoder(r.Body).Decode(&trail); err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid request"})
		return
	}

	trail.UpdatedAt = time.Now()

	result, err := app.db.conn.Exec(
		`UPDATE trails SET name = ?, description = ?, difficulty = ?, distance = ?, elevation_gain = ?,
		start_lat = ?, start_lng = ?, end_lat = ?, end_lng = ?, status = ?, updated_at = ? WHERE id = ? AND user_id = ?`,
		trail.Name, trail.Description, trail.Difficulty, trail.Distance, trail.ElevationGain,
		trail.StartLat, trail.StartLng, trail.EndLat, trail.EndLng, trail.Status, trail.UpdatedAt, trailID, userID,
	)

	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "failed to update trail"})
		return
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		respondJSON(w, http.StatusNotFound, map[string]string{"error": "trail not found"})
		return
	}

	trail.ID = trailID

	// Notify via WebSocket
	app.broadcastTrailUpdate(trail.ID, userID, "Trail updated")

	respondJSON(w, http.StatusOK, trail)
}

func (app *App) handleDeleteTrail(w http.ResponseWriter, r *http.Request) {
	userID, ok := getUserID(r)
	if !ok {
		respondJSON(w, http.StatusUnauthorized, map[string]string{"error": "unauthorized"})
		return
	}

	trailID, err := strconv.Atoi(r.URL.Query().Get("id"))
	if err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid trail ID"})
		return
	}

	result, err := app.db.conn.Exec("DELETE FROM trails WHERE id = ? AND user_id = ?", trailID, userID)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "failed to delete trail"})
		return
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		respondJSON(w, http.StatusNotFound, map[string]string{"error": "trail not found"})
		return
	}

	respondJSON(w, http.StatusOK, map[string]string{"message": "trail deleted"})
}
