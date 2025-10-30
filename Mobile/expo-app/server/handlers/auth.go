package handlers

import (
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"net/http"
	"time"

	"revolut-clone-server/database"
	"revolut-clone-server/middleware"
	"revolut-clone-server/revolut"
)

var (
	revolutClient = revolut.NewClient()
	// In production, store state in Redis or similar
	authStates = make(map[string]time.Time)
)

// generateState generates a random state string for OAuth
func generateState() (string, error) {
	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return hex.EncodeToString(b), nil
}

// InitiateOAuth initiates the OAuth flow
func InitiateOAuth(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		respondJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "Method not allowed"})
		return
	}

	state, err := generateState()
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "Failed to generate state"})
		return
	}

	// Store state with timestamp (clean up old states periodically)
	authStates[state] = time.Now()

	authURL := revolutClient.GetAuthorizationURL(state)
	respondJSON(w, http.StatusOK, map[string]string{
		"authUrl": authURL,
		"state":   state,
	})
}

// HandleOAuthCallback handles the OAuth callback
func HandleOAuthCallback(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		respondJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "Method not allowed"})
		return
	}

	code := r.URL.Query().Get("code")
	state := r.URL.Query().Get("state")

	if code == "" || state == "" {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "Missing code or state"})
		return
	}

	// Validate state
	if _, ok := authStates[state]; !ok {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "Invalid state"})
		return
	}

	// Clean up state
	delete(authStates, state)

	// Exchange code for token
	tokenResp, err := revolutClient.ExchangeCodeForToken(code)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]interface{}{
			"error":   "Failed to exchange code for token",
			"details": err.Error(),
		})
		return
	}

	// Get user's accounts to use the first account ID as user identifier
	accounts, err := revolutClient.GetAccounts(tokenResp.AccessToken)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]interface{}{
			"error":   "Failed to get accounts",
			"details": err.Error(),
		})
		return
	}

	if len(accounts) == 0 {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "No accounts found"})
		return
	}

	// Use first account ID as user ID
	userID := accounts[0].AccountID

	// Save session to database
	session := &database.UserSession{
		UserID:       userID,
		AccessToken:  tokenResp.AccessToken,
		RefreshToken: tokenResp.RefreshToken,
		ExpiresAt:    time.Now().Add(time.Duration(tokenResp.ExpiresIn) * time.Second),
	}

	if err := database.SaveUserSession(session); err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "Failed to save session"})
		return
	}

	// Generate JWT token
	jwtToken, err := middleware.GenerateJWT(userID)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "Failed to generate JWT"})
		return
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"token":    jwtToken,
		"userId":   userID,
		"accounts": accounts,
	})
}

// Logout handles user logout
func Logout(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		respondJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "Method not allowed"})
		return
	}

	// Extract JWT from header
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		respondJSON(w, http.StatusOK, map[string]string{"message": "Already logged out"})
		return
	}

	// Get user ID from JWT
	if len(authHeader) < 8 || authHeader[:7] != "Bearer " {
		respondJSON(w, http.StatusOK, map[string]string{"message": "Already logged out"})
		return
	}

	token := authHeader[7:] // Remove "Bearer "
	claims, err := middleware.ValidateJWT(token)
	if err != nil {
		respondJSON(w, http.StatusOK, map[string]string{"message": "Already logged out"})
		return
	}

	// Delete session from database
	if err := database.DeleteUserSession(claims.UserID); err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "Failed to logout"})
		return
	}

	respondJSON(w, http.StatusOK, map[string]string{"message": "Logged out successfully"})
}

// respondJSON writes JSON response
func respondJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(data)
}
