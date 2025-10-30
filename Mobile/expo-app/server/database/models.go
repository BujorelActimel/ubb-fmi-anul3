package database

import (
	"time"
)

// CustomTransaction represents a user-created transaction stored in the database
type CustomTransaction struct {
	ID          string    `json:"id" db:"id"`
	UserID      string    `json:"userId" db:"user_id"`
	AccountID   string    `json:"accountId" db:"account_id"`
	Amount      float64   `json:"amount" db:"amount"`
	Currency    string    `json:"currency" db:"currency"`
	Description string    `json:"description" db:"description"`
	Type        string    `json:"type" db:"type"` // "credit" or "debit"
	Status      string    `json:"status" db:"status"` // "booked" or "pending"
	Date        time.Time `json:"date" db:"date"`
	CreatedAt   time.Time `json:"createdAt" db:"created_at"`
}

// Transaction represents the unified transaction model (from both Revolut and custom)
type Transaction struct {
	ID          string    `json:"id"`
	AccountID   string    `json:"accountId"`
	Amount      float64   `json:"amount"`
	Currency    string    `json:"currency"`
	Description string    `json:"description"`
	Type        string    `json:"type"` // "credit" or "debit"
	Status      string    `json:"status"` // "booked" or "pending"
	Date        time.Time `json:"date"`
	Source      string    `json:"source"` // "revolut" or "custom"
	Synced      bool      `json:"synced"`
}

// UserSession stores active user sessions with Revolut tokens
type UserSession struct {
	UserID       string    `json:"userId" db:"user_id"`
	AccessToken  string    `json:"accessToken" db:"access_token"`
	RefreshToken string    `json:"refreshToken" db:"refresh_token"`
	ExpiresAt    time.Time `json:"expiresAt" db:"expires_at"`
	CreatedAt    time.Time `json:"createdAt" db:"created_at"`
}
