package main

import (
	"database/sql"
	"log"

	_ "modernc.org/sqlite"
)

type Database struct {
	conn *sql.DB
}

func NewDatabase(dbPath string) (*Database, error) {
	conn, err := sql.Open("sqlite", dbPath)
	if err != nil {
		return nil, err
	}

	if err := conn.Ping(); err != nil {
		return nil, err
	}

	db := &Database{conn: conn}
	if err := db.migrate(); err != nil {
		return nil, err
	}

	return db, nil
}

func (db *Database) migrate() error {
	schema := `
	CREATE TABLE IF NOT EXISTS users (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		username TEXT UNIQUE NOT NULL,
		email TEXT UNIQUE NOT NULL,
		password_hash TEXT NOT NULL,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);

	CREATE TABLE IF NOT EXISTS trails (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		user_id INTEGER NOT NULL,
		name TEXT NOT NULL,
		description TEXT,
		difficulty TEXT,
		distance REAL,
		elevation_gain REAL,
		start_lat REAL,
		start_lng REAL,
		end_lat REAL,
		end_lng REAL,
		status TEXT,
		synced BOOLEAN DEFAULT TRUE,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		FOREIGN KEY (user_id) REFERENCES users(id)
	);

	CREATE TABLE IF NOT EXISTS waypoints (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		trail_id INTEGER NOT NULL,
		lat REAL NOT NULL,
		lng REAL NOT NULL,
		name TEXT,
		description TEXT,
		order_index INTEGER,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		FOREIGN KEY (trail_id) REFERENCES trails(id) ON DELETE CASCADE
	);

	CREATE TABLE IF NOT EXISTS photos (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		trail_id INTEGER NOT NULL,
		waypoint_id INTEGER,
		filename TEXT NOT NULL,
		server_url TEXT,
		uploaded BOOLEAN DEFAULT FALSE,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		FOREIGN KEY (trail_id) REFERENCES trails(id) ON DELETE CASCADE,
		FOREIGN KEY (waypoint_id) REFERENCES waypoints(id) ON DELETE SET NULL
	);

	CREATE INDEX IF NOT EXISTS idx_trails_user_id ON trails(user_id);
	CREATE INDEX IF NOT EXISTS idx_waypoints_trail_id ON waypoints(trail_id);
	CREATE INDEX IF NOT EXISTS idx_photos_trail_id ON photos(trail_id);
	`

	_, err := db.conn.Exec(schema)
	if err != nil {
		log.Printf("Migration error: %v", err)
		return err
	}

	// Add end_lat and end_lng columns if they don't exist
	alterSQL := `
	ALTER TABLE trails ADD COLUMN end_lat REAL;
	ALTER TABLE trails ADD COLUMN end_lng REAL;
	`
	// Ignore errors if columns already exist
	db.conn.Exec(alterSQL)

	return nil
}

func (db *Database) Close() error {
	return db.conn.Close()
}
