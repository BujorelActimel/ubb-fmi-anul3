import * as SQLite from 'expo-sqlite';

const db = SQLite.openDatabaseSync('trails.db');

export const database = {
  init: () => {
    db.execSync(`
      CREATE TABLE IF NOT EXISTS trails (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        distance REAL,
        difficulty TEXT,
        status TEXT,
        description TEXT,
        elevation_gain REAL,
        start_lat TEXT,
        start_lng TEXT,
        end_lat TEXT,
        end_lng TEXT,
        created_at TEXT,
        updated_at TEXT
      );
      CREATE TABLE IF NOT EXISTS photos (
        id INTEGER PRIMARY KEY,
        trail_id INTEGER,
        filename TEXT,
        server_url TEXT,
        created_at TEXT
      );
    `);
  },

  saveTrails: (trails: any[]) => {
    db.withTransactionSync(() => {
      for (const trail of trails) {
        db.runSync(
          `INSERT OR REPLACE INTO trails (id, name, distance, difficulty, status, description, elevation_gain, start_lat, start_lng, end_lat, end_lng, created_at, updated_at)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            trail.id,
            trail.name,
            trail.distance,
            trail.difficulty,
            trail.status,
            trail.description || null,
            trail.elevation_gain || null,
            trail.start_lat || null,
            trail.start_lng || null,
            trail.end_lat || null,
            trail.end_lng || null,
            trail.created_at || null,
            trail.updated_at || null,
          ]
        );
      }
    });
  },

  getTrails: (page: number = 1, limit: number = 10, search?: string, difficulty?: string): any[] => {
    const offset = (page - 1) * limit;
    let query = 'SELECT * FROM trails WHERE 1=1';
    const params: any[] = [];

    if (search) {
      query += ' AND name LIKE ?';
      params.push(`%${search}%`);
    }

    if (difficulty) {
      query += ' AND difficulty = ?';
      params.push(difficulty);
    }

    query += ' ORDER BY id DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    return db.getAllSync(query, params);
  },

  clearTrails: () => {
    db.runSync('DELETE FROM trails');
  },

  deleteTrail: (id: number) => {
    db.runSync('DELETE FROM trails WHERE id = ?', [id]);
  },

  savePhotos: (trailId: number, photos: any[]) => {
    db.withTransactionSync(() => {
      // Clear existing photos for this trail
      db.runSync('DELETE FROM photos WHERE trail_id = ?', [trailId]);
      // Insert new photos
      for (const photo of photos) {
        db.runSync(
          `INSERT INTO photos (id, trail_id, filename, server_url, created_at)
           VALUES (?, ?, ?, ?, ?)`,
          [
            photo.id,
            trailId,
            photo.filename || null,
            photo.server_url,
            photo.created_at || null,
          ]
        );
      }
    });
  },

  getPhotos: (trailId: number): any[] => {
    return db.getAllSync(
      'SELECT * FROM photos WHERE trail_id = ? ORDER BY created_at DESC',
      [trailId]
    );
  },
};
