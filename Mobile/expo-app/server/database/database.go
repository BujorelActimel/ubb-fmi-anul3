package database

import (
	"crypto/rand"
	"database/sql"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"time"

	_ "github.com/mattn/go-sqlite3"
)

var db *sql.DB

// InitDB initializes the database connection and creates tables
func InitDB() error {
	dbPath := os.Getenv("DATABASE_PATH")
	if dbPath == "" {
		dbPath = "./data/transactions.db"
	}

	// Create data directory if it doesn't exist
	dir := filepath.Dir(dbPath)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return fmt.Errorf("failed to create data directory: %w", err)
	}

	var err error
	db, err = sql.Open("sqlite3", dbPath)
	if err != nil {
		return fmt.Errorf("failed to open database: %w", err)
	}

	if err := db.Ping(); err != nil {
		return fmt.Errorf("failed to ping database: %w", err)
	}

	// Create tables
	if err := createTables(); err != nil {
		return fmt.Errorf("failed to create tables: %w", err)
	}

	log.Println("Database initialized successfully")
	return nil
}

// CloseDB closes the database connection
func CloseDB() {
	if db != nil {
		db.Close()
	}
}

// createTables creates the necessary database tables
func createTables() error {
	schemas := []string{
		`CREATE TABLE IF NOT EXISTS custom_transactions (
			id TEXT PRIMARY KEY,
			user_id TEXT NOT NULL,
			account_id TEXT NOT NULL,
			amount REAL NOT NULL,
			currency TEXT NOT NULL,
			description TEXT NOT NULL,
			type TEXT NOT NULL CHECK(type IN ('credit', 'debit')),
			status TEXT NOT NULL CHECK(status IN ('booked', 'pending')),
			date DATETIME NOT NULL,
			created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
		)`,
		`CREATE INDEX IF NOT EXISTS idx_custom_transactions_user_id ON custom_transactions(user_id)`,
		`CREATE INDEX IF NOT EXISTS idx_custom_transactions_date ON custom_transactions(date DESC)`,

		`CREATE TABLE IF NOT EXISTS user_sessions (
			user_id TEXT PRIMARY KEY,
			access_token TEXT NOT NULL,
			refresh_token TEXT,
			expires_at DATETIME NOT NULL,
			created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
		)`,
	}

	for _, schema := range schemas {
		if _, err := db.Exec(schema); err != nil {
			return fmt.Errorf("failed to execute schema: %w", err)
		}
	}

	return nil
}

// generateUUID generates a UUID v4
func generateUUID() (string, error) {
	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	// Set version (4) and variant bits
	b[6] = (b[6] & 0x0f) | 0x40
	b[8] = (b[8] & 0x3f) | 0x80
	return fmt.Sprintf("%x-%x-%x-%x-%x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:16]), nil
}

// CreateCustomTransaction inserts a new custom transaction
func CreateCustomTransaction(tx *CustomTransaction) error {
	id, err := generateUUID()
	if err != nil {
		return err
	}
	tx.ID = id
	tx.CreatedAt = time.Now()

	query := `INSERT INTO custom_transactions
		(id, user_id, account_id, amount, currency, description, type, status, date, created_at)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`

	_, execErr := db.Exec(query, tx.ID, tx.UserID, tx.AccountID, tx.Amount, tx.Currency,
		tx.Description, tx.Type, tx.Status, tx.Date, tx.CreatedAt)

	return execErr
}

// GetCustomTransactionsByUser retrieves all custom transactions for a user
func GetCustomTransactionsByUser(userID string) ([]CustomTransaction, error) {
	query := `SELECT id, user_id, account_id, amount, currency, description, type, status, date, created_at
		FROM custom_transactions
		WHERE user_id = ?
		ORDER BY date DESC`

	rows, err := db.Query(query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var transactions []CustomTransaction
	for rows.Next() {
		var tx CustomTransaction
		err := rows.Scan(&tx.ID, &tx.UserID, &tx.AccountID, &tx.Amount, &tx.Currency,
			&tx.Description, &tx.Type, &tx.Status, &tx.Date, &tx.CreatedAt)
		if err != nil {
			return nil, err
		}
		transactions = append(transactions, tx)
	}

	return transactions, rows.Err()
}

// DeleteCustomTransaction deletes a custom transaction
func DeleteCustomTransaction(id, userID string) error {
	query := `DELETE FROM custom_transactions WHERE id = ? AND user_id = ?`
	result, err := db.Exec(query, id, userID)
	if err != nil {
		return err
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rows == 0 {
		return fmt.Errorf("transaction not found or unauthorized")
	}

	return nil
}

// SaveUserSession saves or updates a user session
func SaveUserSession(session *UserSession) error {
	query := `INSERT OR REPLACE INTO user_sessions
		(user_id, access_token, refresh_token, expires_at, created_at)
		VALUES (?, ?, ?, ?, ?)`

	_, err := db.Exec(query, session.UserID, session.AccessToken, session.RefreshToken,
		session.ExpiresAt, time.Now())

	return err
}

// GetUserSession retrieves a user session
func GetUserSession(userID string) (*UserSession, error) {
	query := `SELECT user_id, access_token, refresh_token, expires_at, created_at
		FROM user_sessions WHERE user_id = ?`

	var session UserSession
	err := db.QueryRow(query, userID).Scan(&session.UserID, &session.AccessToken,
		&session.RefreshToken, &session.ExpiresAt, &session.CreatedAt)

	if err == sql.ErrNoRows {
		return nil, nil
	}

	return &session, err
}

// DeleteUserSession deletes a user session (logout)
func DeleteUserSession(userID string) error {
	query := `DELETE FROM user_sessions WHERE user_id = ?`
	_, err := db.Exec(query, userID)
	return err
}
