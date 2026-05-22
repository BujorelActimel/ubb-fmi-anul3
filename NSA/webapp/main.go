package main

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"database/sql"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"log"
	"net"
	"net/http"
	"net/smtp"
	"os"
	"strconv"
	"strings"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"golang.org/x/crypto/bcrypt"
)

var (
	db        *sql.DB
	jwtSecret []byte
)

func main() {
	jwtSecret = []byte(env("JWT_SECRET", "change-me"))

	var err error
	db, err = sql.Open("mysql", env("DB_DSN", "app:app@tcp(mysql-master:3306)/bookshelf?parseTime=true"))
	if err != nil {
		log.Fatal(err)
	}
	for i := 0; i < 30; i++ {
		if err = db.Ping(); err == nil {
			break
		}
		log.Printf("waiting for db (%d/30)...", i+1)
		time.Sleep(2 * time.Second)
	}
	if err != nil {
		log.Fatal("db unreachable:", err)
	}
	log.Println("connected to database")

	mux := http.NewServeMux()

	mux.Handle("/", http.FileServer(http.Dir("./static")))

	mux.HandleFunc("GET /api/info", handleInfo)
	mux.HandleFunc("POST /api/auth/register", handleRegister)
	mux.HandleFunc("GET /api/auth/confirm", handleConfirm)
	mux.HandleFunc("POST /api/auth/login", handleLogin)
	mux.HandleFunc("POST /api/auth/logout", handleLogout)
	mux.HandleFunc("GET /api/auth/me", guard(handleMe))
	mux.HandleFunc("GET /api/books", guard(handleListBooks))
	mux.HandleFunc("POST /api/books", guard(handleCreateBook))
	mux.HandleFunc("PUT /api/books/{id}", guard(handleUpdateBook))
	mux.HandleFunc("DELETE /api/books/{id}", guard(handleDeleteBook))

	port := env("PORT", "8080")
	log.Printf("listening on :%s", port)
	log.Fatal(http.ListenAndServe(":"+port, mux))
}

// --- helpers ---

func env(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(v)
}

func fail(w http.ResponseWriter, msg string, status int) {
	writeJSON(w, status, map[string]string{"error": msg})
}

func serverIP() string {
	addrs, _ := net.InterfaceAddrs()
	for _, a := range addrs {
		if ipnet, ok := a.(*net.IPNet); ok && !ipnet.IP.IsLoopback() && ipnet.IP.To4() != nil {
			return ipnet.IP.String()
		}
	}
	return "unknown"
}

// --- JWT (HS256, stdlib crypto) ---

func makeJWT(userID int) string {
	hdr := base64.RawURLEncoding.EncodeToString([]byte(`{"alg":"HS256","typ":"JWT"}`))
	now := time.Now().Unix()
	pay := base64.RawURLEncoding.EncodeToString([]byte(
		fmt.Sprintf(`{"sub":%d,"exp":%d}`, userID, now+7*24*3600),
	))
	return hdr + "." + pay + "." + jwtSign(hdr+"."+pay)
}

func jwtSign(data string) string {
	mac := hmac.New(sha256.New, jwtSecret)
	mac.Write([]byte(data))
	return base64.RawURLEncoding.EncodeToString(mac.Sum(nil))
}

func parseJWT(token string) (int, bool) {
	parts := strings.Split(token, ".")
	if len(parts) != 3 || jwtSign(parts[0]+"."+parts[1]) != parts[2] {
		return 0, false
	}
	raw, err := base64.RawURLEncoding.DecodeString(parts[1])
	if err != nil {
		return 0, false
	}
	var claims struct {
		Sub int   `json:"sub"`
		Exp int64 `json:"exp"`
	}
	if err := json.Unmarshal(raw, &claims); err != nil || time.Now().Unix() > claims.Exp {
		return 0, false
	}
	return claims.Sub, true
}

func guard(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		cookie, err := r.Cookie("session")
		if err != nil {
			fail(w, "unauthorized", http.StatusUnauthorized)
			return
		}
		uid, ok := parseJWT(cookie.Value)
		if !ok {
			fail(w, "unauthorized", http.StatusUnauthorized)
			return
		}
		r.Header.Set("X-UID", strconv.Itoa(uid))
		next(w, r)
	}
}

func uid(r *http.Request) int {
	id, _ := strconv.Atoi(r.Header.Get("X-UID"))
	return id
}

// --- auth handlers ---

func handleInfo(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{"ip": serverIP()})
}

func handleRegister(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || req.Email == "" || len(req.Password) < 6 {
		fail(w, "email and password (min 6 chars) required", http.StatusBadRequest)
		return
	}

	var exists int
	db.QueryRow("SELECT COUNT(*) FROM users WHERE email=?", req.Email).Scan(&exists)
	if exists > 0 {
		fail(w, "email already registered", http.StatusConflict)
		return
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		fail(w, "server error", http.StatusInternalServerError)
		return
	}

	token := randomToken()
	if _, err := db.Exec(
		"INSERT INTO users (email, password_hash, confirm_token) VALUES (?,?,?)",
		req.Email, string(hash), token,
	); err != nil {
		fail(w, "server error", http.StatusInternalServerError)
		return
	}

	domain := env("DOMAIN", "nsa.local")
	link := fmt.Sprintf("http://%s:8080/api/auth/confirm?token=%s", domain, token)
	go sendMail(req.Email, "Confirm your Bookshelf account",
		"Welcome!\n\nConfirm your account by visiting:\n"+link+"\n")

	writeJSON(w, http.StatusCreated, map[string]string{"message": "check your email to confirm"})
}

func handleConfirm(w http.ResponseWriter, r *http.Request) {
	token := r.URL.Query().Get("token")
	if token == "" {
		http.Error(w, "missing token", http.StatusBadRequest)
		return
	}
	res, err := db.Exec(
		"UPDATE users SET confirmed=TRUE, confirm_token=NULL WHERE confirm_token=? AND confirmed=FALSE",
		token,
	)
	if err != nil {
		http.Error(w, "server error", http.StatusInternalServerError)
		return
	}
	if n, _ := res.RowsAffected(); n == 0 {
		http.Error(w, "invalid or expired token", http.StatusBadRequest)
		return
	}
	http.Redirect(w, r, "/?confirmed=1", http.StatusFound)
}

func handleLogin(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		fail(w, "invalid request", http.StatusBadRequest)
		return
	}

	var id int
	var hash string
	var confirmed bool
	err := db.QueryRow("SELECT id, password_hash, confirmed FROM users WHERE email=?", req.Email).
		Scan(&id, &hash, &confirmed)
	if err == sql.ErrNoRows {
		fail(w, "invalid credentials", http.StatusUnauthorized)
		return
	}
	if err != nil {
		fail(w, "server error", http.StatusInternalServerError)
		return
	}
	if bcrypt.CompareHashAndPassword([]byte(hash), []byte(req.Password)) != nil {
		fail(w, "invalid credentials", http.StatusUnauthorized)
		return
	}
	if !confirmed {
		fail(w, "please confirm your email first", http.StatusForbidden)
		return
	}

	http.SetCookie(w, &http.Cookie{
		Name:     "session",
		Value:    makeJWT(id),
		Path:     "/",
		HttpOnly: true,
		SameSite: http.SameSiteLaxMode,
		MaxAge:   7 * 24 * 3600,
	})
	writeJSON(w, http.StatusOK, map[string]string{"message": "ok"})
}

func handleLogout(w http.ResponseWriter, r *http.Request) {
	http.SetCookie(w, &http.Cookie{Name: "session", Value: "", Path: "/", MaxAge: -1})
	w.WriteHeader(http.StatusOK)
}

func handleMe(w http.ResponseWriter, r *http.Request) {
	var email string
	db.QueryRow("SELECT email FROM users WHERE id=?", uid(r)).Scan(&email)
	writeJSON(w, http.StatusOK, map[string]any{
		"id":    uid(r),
		"email": email,
		"ip":    serverIP(),
	})
}

// --- book handlers ---

type Book struct {
	ID     int    `json:"id"`
	Title  string `json:"title"`
	Author string `json:"author"`
	Genre  string `json:"genre"`
	Year   *int   `json:"year"`
	Status string `json:"status"`
	Rating *int   `json:"rating"`
	Notes  string `json:"notes"`
}

func handleListBooks(w http.ResponseWriter, r *http.Request) {
	status := r.URL.Query().Get("status")
	var (
		rows *sql.Rows
		err  error
	)
	if status != "" {
		rows, err = db.Query(
			"SELECT id,title,author,genre,year,status,rating,notes FROM books WHERE user_id=? AND status=? ORDER BY created_at DESC",
			uid(r), status,
		)
	} else {
		rows, err = db.Query(
			"SELECT id,title,author,genre,year,status,rating,notes FROM books WHERE user_id=? ORDER BY created_at DESC",
			uid(r),
		)
	}
	if err != nil {
		fail(w, "server error", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	books := []Book{}
	for rows.Next() {
		var b Book
		rows.Scan(&b.ID, &b.Title, &b.Author, &b.Genre, &b.Year, &b.Status, &b.Rating, &b.Notes)
		books = append(books, b)
	}
	writeJSON(w, http.StatusOK, books)
}

func handleCreateBook(w http.ResponseWriter, r *http.Request) {
	var b Book
	if err := json.NewDecoder(r.Body).Decode(&b); err != nil || strings.TrimSpace(b.Title) == "" {
		fail(w, "title required", http.StatusBadRequest)
		return
	}
	if b.Status == "" {
		b.Status = "want"
	}
	res, err := db.Exec(
		"INSERT INTO books (user_id,title,author,genre,year,status,rating,notes) VALUES (?,?,?,?,?,?,?,?)",
		uid(r), b.Title, b.Author, b.Genre, b.Year, b.Status, b.Rating, b.Notes,
	)
	if err != nil {
		fail(w, "server error", http.StatusInternalServerError)
		return
	}
	id, _ := res.LastInsertId()
	b.ID = int(id)
	writeJSON(w, http.StatusCreated, b)
}

func handleUpdateBook(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(r.PathValue("id"))
	if err != nil {
		fail(w, "invalid id", http.StatusBadRequest)
		return
	}
	var b Book
	if err := json.NewDecoder(r.Body).Decode(&b); err != nil {
		fail(w, "invalid request", http.StatusBadRequest)
		return
	}
	if _, err := db.Exec(
		"UPDATE books SET title=?,author=?,genre=?,year=?,status=?,rating=?,notes=? WHERE id=? AND user_id=?",
		b.Title, b.Author, b.Genre, b.Year, b.Status, b.Rating, b.Notes, id, uid(r),
	); err != nil {
		fail(w, "server error", http.StatusInternalServerError)
		return
	}
	b.ID = id
	writeJSON(w, http.StatusOK, b)
}

func handleDeleteBook(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(r.PathValue("id"))
	if err != nil {
		fail(w, "invalid id", http.StatusBadRequest)
		return
	}
	db.Exec("DELETE FROM books WHERE id=? AND user_id=?", id, uid(r))
	w.WriteHeader(http.StatusNoContent)
}

// --- mail ---

func sendMail(to, subject, body string) {
	host := env("SMTP_HOST", "mailpit")
	port := env("SMTP_PORT", "1025")
	from := env("MAIL_FROM", "noreply@nsa.local")
	msg := []byte("From: " + from + "\r\nTo: " + to + "\r\nSubject: " + subject + "\r\n\r\n" + body)
	if err := smtp.SendMail(host+":"+port, nil, from, []string{to}, msg); err != nil {
		log.Printf("mail error: %v", err)
	}
}

// --- util ---

func randomToken() string {
	b := make([]byte, 32)
	rand.Read(b)
	return base64.URLEncoding.EncodeToString(b)
}
