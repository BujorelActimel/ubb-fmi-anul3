package revolut

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"time"
)

const (
	revolutFinancialID = "001580000103UAvAAM"
)

// Client represents a Revolut API client
type Client struct {
	httpClient  *http.Client
	apiURL      string
	authURL     string
	tokenURL    string
	clientID    string
	clientSecret string
	redirectURI string
}

// NewClient creates a new Revolut API client
func NewClient() *Client {
	return &Client{
		httpClient:   &http.Client{Timeout: 30 * time.Second},
		apiURL:       os.Getenv("REVOLUT_API_URL"),
		authURL:      os.Getenv("REVOLUT_AUTH_URL"),
		tokenURL:     os.Getenv("REVOLUT_TOKEN_URL"),
		clientID:     os.Getenv("REVOLUT_CLIENT_ID"),
		clientSecret: os.Getenv("REVOLUT_CLIENT_SECRET"),
		redirectURI:  os.Getenv("REVOLUT_REDIRECT_URI"),
	}
}

// GetAuthorizationURL returns the URL for OAuth authorization
func (c *Client) GetAuthorizationURL(state string) string {
	params := url.Values{}
	params.Add("client_id", c.clientID)
	params.Add("redirect_uri", c.redirectURI)
	params.Add("response_type", "code")
	params.Add("scope", "accounts transactions")
	params.Add("state", state)

	return c.authURL + "?" + params.Encode()
}

// TokenResponse represents the OAuth token response
type TokenResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	TokenType    string `json:"token_type"`
	ExpiresIn    int    `json:"expires_in"`
}

// ExchangeCodeForToken exchanges an authorization code for access token
func (c *Client) ExchangeCodeForToken(code string) (*TokenResponse, error) {
	data := url.Values{}
	data.Set("grant_type", "authorization_code")
	data.Set("code", code)
	data.Set("client_id", c.clientID)
	data.Set("client_secret", c.clientSecret)
	data.Set("redirect_uri", c.redirectURI)

	req, err := http.NewRequest("POST", c.tokenURL, bytes.NewBufferString(data.Encode()))
	if err != nil {
		return nil, err
	}

	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("token exchange failed: %s - %s", resp.Status, string(body))
	}

	var tokenResp TokenResponse
	if err := json.NewDecoder(resp.Body).Decode(&tokenResp); err != nil {
		return nil, err
	}

	return &tokenResp, nil
}

// Account represents a Revolut account
type Account struct {
	AccountID string `json:"AccountId"`
	Currency  string `json:"Currency"`
	Nickname  string `json:"Nickname"`
}

// GetAccounts retrieves the list of accounts
func (c *Client) GetAccounts(accessToken string) ([]Account, error) {
	req, err := http.NewRequest("GET", c.apiURL+"/accounts", nil)
	if err != nil {
		return nil, err
	}

	req.Header.Set("Authorization", "Bearer "+accessToken)
	req.Header.Set("x-fapi-financial-id", revolutFinancialID)

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("get accounts failed: %s - %s", resp.Status, string(body))
	}

	var result struct {
		Data struct {
			Account []Account `json:"Account"`
		} `json:"Data"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, err
	}

	return result.Data.Account, nil
}

// RevolutTransaction represents a transaction from Revolut API
type RevolutTransaction struct {
	AccountID            string    `json:"AccountId"`
	TransactionID        string    `json:"TransactionId"`
	CreditDebitIndicator string    `json:"CreditDebitIndicator"`
	Status               string    `json:"Status"`
	BookingDateTime      time.Time `json:"BookingDateTime"`
	Amount               struct {
		Amount   string `json:"Amount"`
		Currency string `json:"Currency"`
	} `json:"Amount"`
	TransactionInformation string `json:"TransactionInformation"`
}

// GetTransactions retrieves transactions for an account
func (c *Client) GetTransactions(accessToken, accountID string, fromDate, toDate *time.Time) ([]RevolutTransaction, error) {
	endpoint := fmt.Sprintf("%s/accounts/%s/transactions", c.apiURL, accountID)

	req, err := http.NewRequest("GET", endpoint, nil)
	if err != nil {
		return nil, err
	}

	// Add query parameters for date filtering if provided
	if fromDate != nil || toDate != nil {
		q := req.URL.Query()
		if fromDate != nil {
			q.Add("fromBookingDateTime", fromDate.Format(time.RFC3339))
		}
		if toDate != nil {
			q.Add("toBookingDateTime", toDate.Format(time.RFC3339))
		}
		req.URL.RawQuery = q.Encode()
	}

	req.Header.Set("Authorization", "Bearer "+accessToken)
	req.Header.Set("x-fapi-financial-id", revolutFinancialID)

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("get transactions failed: %s - %s", resp.Status, string(body))
	}

	var result struct {
		Data struct {
			Transaction []RevolutTransaction `json:"Transaction"`
		} `json:"Data"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, err
	}

	return result.Data.Transaction, nil
}
