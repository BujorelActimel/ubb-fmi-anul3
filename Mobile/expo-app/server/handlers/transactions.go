package handlers

import (
	"encoding/json"
	"net/http"
	"sort"
	"strconv"
	"strings"
	"time"

	"revolut-clone-server/database"
	"revolut-clone-server/middleware"
)

// HandleTransactions handles GET and POST for /api/transactions
func HandleTransactions(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		getTransactions(w, r)
	case http.MethodPost:
		createTransaction(w, r)
	default:
		respondJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "Method not allowed"})
	}
}

// HandleTransactionByID handles DELETE for /api/transactions/:id
func HandleTransactionByID(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodDelete {
		respondJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "Method not allowed"})
		return
	}

	// Extract transaction ID from path
	path := strings.TrimPrefix(r.URL.Path, "/api/transactions/")
	if path == "" || path == r.URL.Path {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "Transaction ID required"})
		return
	}

	deleteTransaction(w, r, path)
}

// getTransactions retrieves merged transactions from Revolut and custom sources
func getTransactions(w http.ResponseWriter, r *http.Request) {
	userID := r.Context().Value(middleware.UserIDKey).(string)

	// Get pagination parameters
	query := r.URL.Query()
	page, _ := strconv.Atoi(query.Get("page"))
	limit, _ := strconv.Atoi(query.Get("limit"))
	searchQuery := query.Get("search")

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 20
	}

	// Get user session to fetch Revolut transactions
	session, err := database.GetUserSession(userID)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "Failed to get session"})
		return
	}

	var allTransactions []database.Transaction

	// Fetch Revolut transactions if session exists and not expired
	if session != nil && time.Now().Before(session.ExpiresAt) {
		revolutTxs, err := revolutClient.GetTransactions(session.AccessToken, userID, nil, nil)
		if err == nil {
			// Convert Revolut transactions to unified format
			for _, tx := range revolutTxs {
				amount, _ := strconv.ParseFloat(tx.Amount.Amount, 64)

				txType := "debit"
				if tx.CreditDebitIndicator == "Credit" {
					txType = "credit"
				}

				status := strings.ToLower(tx.Status)

				transaction := database.Transaction{
					ID:          tx.TransactionID,
					AccountID:   tx.AccountID,
					Amount:      amount,
					Currency:    tx.Amount.Currency,
					Description: tx.TransactionInformation,
					Type:        txType,
					Status:      status,
					Date:        tx.BookingDateTime,
					Source:      "revolut",
					Synced:      true,
				}

				allTransactions = append(allTransactions, transaction)
			}
		}
	}

	// Fetch custom transactions
	customTxs, err := database.GetCustomTransactionsByUser(userID)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "Failed to get custom transactions"})
		return
	}

	// Convert custom transactions to unified format
	for _, tx := range customTxs {
		transaction := database.Transaction{
			ID:          tx.ID,
			AccountID:   tx.AccountID,
			Amount:      tx.Amount,
			Currency:    tx.Currency,
			Description: tx.Description,
			Type:        tx.Type,
			Status:      tx.Status,
			Date:        tx.Date,
			Source:      "custom",
			Synced:      true,
		}

		allTransactions = append(allTransactions, transaction)
	}

	// Filter by search query if provided
	if searchQuery != "" {
		filtered := []database.Transaction{}
		searchLower := strings.ToLower(searchQuery)
		for _, tx := range allTransactions {
			if strings.Contains(strings.ToLower(tx.Description), searchLower) {
				filtered = append(filtered, tx)
			}
		}
		allTransactions = filtered
	}

	// Sort by date (most recent first)
	sort.Slice(allTransactions, func(i, j int) bool {
		return allTransactions[i].Date.After(allTransactions[j].Date)
	})

	// Calculate pagination
	total := len(allTransactions)
	start := (page - 1) * limit
	end := start + limit

	if start > total {
		start = total
	}
	if end > total {
		end = total
	}

	paginatedTransactions := allTransactions[start:end]

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"transactions": paginatedTransactions,
		"pagination": map[string]interface{}{
			"page":       page,
			"limit":      limit,
			"total":      total,
			"totalPages": (total + limit - 1) / limit,
			"hasMore":    end < total,
		},
	})
}

// CreateTransactionRequest represents the request body for creating a transaction
type CreateTransactionRequest struct {
	AccountID   string  `json:"accountId"`
	Amount      float64 `json:"amount"`
	Currency    string  `json:"currency"`
	Description string  `json:"description"`
	Type        string  `json:"type"`
	Status      string  `json:"status"`
	Date        string  `json:"date"`
}

// createTransaction creates a new custom transaction
func createTransaction(w http.ResponseWriter, r *http.Request) {
	userID := r.Context().Value(middleware.UserIDKey).(string)

	var req CreateTransactionRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "Invalid request body"})
		return
	}

	// Validate required fields
	if req.AccountID == "" || req.Amount == 0 || req.Currency == "" || req.Description == "" || req.Type == "" {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "Missing required fields"})
		return
	}

	// Validate type
	if req.Type != "credit" && req.Type != "debit" {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "Type must be 'credit' or 'debit'"})
		return
	}

	// Set default status if not provided
	if req.Status == "" {
		req.Status = "booked"
	}

	// Validate status
	if req.Status != "booked" && req.Status != "pending" {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "Status must be 'booked' or 'pending'"})
		return
	}

	// Parse date or use current time
	var txDate time.Time
	var err error
	if req.Date != "" {
		txDate, err = time.Parse(time.RFC3339, req.Date)
		if err != nil {
			respondJSON(w, http.StatusBadRequest, map[string]string{"error": "Invalid date format, use RFC3339"})
			return
		}
	} else {
		txDate = time.Now()
	}

	// Create transaction
	tx := &database.CustomTransaction{
		UserID:      userID,
		AccountID:   req.AccountID,
		Amount:      req.Amount,
		Currency:    req.Currency,
		Description: req.Description,
		Type:        req.Type,
		Status:      req.Status,
		Date:        txDate,
	}

	if err := database.CreateCustomTransaction(tx); err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "Failed to create transaction"})
		return
	}

	// Convert to unified transaction format
	transaction := database.Transaction{
		ID:          tx.ID,
		AccountID:   tx.AccountID,
		Amount:      tx.Amount,
		Currency:    tx.Currency,
		Description: tx.Description,
		Type:        tx.Type,
		Status:      tx.Status,
		Date:        tx.Date,
		Source:      "custom",
		Synced:      true,
	}

	// Broadcast to WebSocket clients
	BroadcastTransactionUpdate(userID, transaction)

	respondJSON(w, http.StatusCreated, map[string]interface{}{"transaction": transaction})
}

// deleteTransaction deletes a custom transaction
func deleteTransaction(w http.ResponseWriter, r *http.Request, transactionID string) {
	userID := r.Context().Value(middleware.UserIDKey).(string)

	if err := database.DeleteCustomTransaction(transactionID, userID); err != nil {
		respondJSON(w, http.StatusNotFound, map[string]string{"error": err.Error()})
		return
	}

	// Broadcast deletion to WebSocket clients
	BroadcastTransactionDeletion(userID, transactionID)

	respondJSON(w, http.StatusOK, map[string]string{"message": "Transaction deleted successfully"})
}
