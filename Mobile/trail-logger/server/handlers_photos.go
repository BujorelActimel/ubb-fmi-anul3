package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"time"
)

func (app *App) handleGetPhotos(w http.ResponseWriter, r *http.Request) {
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

	rows, err := app.db.conn.Query(
		"SELECT id, trail_id, filename, server_url, uploaded, created_at FROM photos WHERE trail_id = ? ORDER BY created_at DESC",
		trailID,
	)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "failed to fetch photos"})
		return
	}
	defer rows.Close()

	var photos []Photo
	for rows.Next() {
		var p Photo
		if err := rows.Scan(&p.ID, &p.TrailID, &p.Filename, &p.ServerURL, &p.Uploaded, &p.CreatedAt); err != nil {
			continue
		}
		photos = append(photos, p)
	}

	if photos == nil {
		photos = []Photo{}
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{"photos": photos})
}

func (app *App) handleUploadPhoto(w http.ResponseWriter, r *http.Request) {
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

	// Parse multipart form
	err = r.ParseMultipartForm(10 << 20) // 10 MB max
	if err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "file too large"})
		return
	}

	file, header, err := r.FormFile("photo")
	if err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "missing photo file"})
		return
	}
	defer file.Close()

	// Generate unique filename
	ext := filepath.Ext(header.Filename)
	filename := fmt.Sprintf("%d_%d%s", trailID, time.Now().Unix(), ext)
	filePath := filepath.Join(app.config.UploadDir, filename)

	// Create uploads directory if it doesn't exist
	os.MkdirAll(app.config.UploadDir, 0755)

	// Save file
	dst, err := os.Create(filePath)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "failed to save file"})
		return
	}
	defer dst.Close()

	if _, err := io.Copy(dst, file); err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "failed to save file"})
		return
	}

	// Save to database
	serverURL := fmt.Sprintf("/uploads/%s", filename)
	result, err := app.db.conn.Exec(
		"INSERT INTO photos (trail_id, filename, server_url, uploaded, created_at) VALUES (?, ?, ?, ?, ?)",
		trailID, filename, serverURL, true, time.Now(),
	)

	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "failed to save photo record"})
		return
	}

	photoID, _ := result.LastInsertId()

	photo := Photo{
		ID:        int(photoID),
		TrailID:   trailID,
		Filename:  filename,
		ServerURL: serverURL,
		Uploaded:  true,
		CreatedAt: time.Now(),
	}

	respondJSON(w, http.StatusCreated, photo)
}

func (app *App) handleDeletePhoto(w http.ResponseWriter, r *http.Request) {
	userID, ok := getUserID(r)
	if !ok {
		respondJSON(w, http.StatusUnauthorized, map[string]string{"error": "unauthorized"})
		return
	}

	photoID, err := strconv.Atoi(r.URL.Query().Get("id"))
	if err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid photo ID"})
		return
	}

	// Get photo info and verify ownership
	var filename string
	var ownerID int
	err = app.db.conn.QueryRow(
		"SELECT p.filename, t.user_id FROM photos p JOIN trails t ON p.trail_id = t.id WHERE p.id = ?",
		photoID,
	).Scan(&filename, &ownerID)

	if err != nil || ownerID != userID {
		respondJSON(w, http.StatusForbidden, map[string]string{"error": "forbidden"})
		return
	}

	// Delete file
	filePath := filepath.Join(app.config.UploadDir, filename)
	os.Remove(filePath)

	// Delete from database
	_, err = app.db.conn.Exec("DELETE FROM photos WHERE id = ?", photoID)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "failed to delete photo"})
		return
	}

	respondJSON(w, http.StatusOK, map[string]string{"message": "photo deleted"})
}

func (app *App) handleServePhoto(w http.ResponseWriter, r *http.Request) {
	filename := filepath.Base(r.URL.Path)
	filePath := filepath.Join(app.config.UploadDir, filename)

	// Check if file exists
	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		http.NotFound(w, r)
		return
	}

	http.ServeFile(w, r, filePath)
}
