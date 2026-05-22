CREATE DATABASE IF NOT EXISTS bookshelf;
USE bookshelf;

CREATE TABLE IF NOT EXISTS users (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    email         VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    confirmed     BOOLEAN DEFAULT FALSE,
    confirm_token VARCHAR(255),
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS books (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT NOT NULL,
    title      VARCHAR(255) NOT NULL,
    author     VARCHAR(255) NOT NULL DEFAULT '',
    genre      VARCHAR(100) DEFAULT '',
    year       SMALLINT,
    status     ENUM('want','reading','read') DEFAULT 'want',
    rating     TINYINT CHECK (rating BETWEEN 1 AND 5),
    notes      TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Replication user (used by slave)
CREATE USER IF NOT EXISTS 'replicator'@'%' IDENTIFIED WITH mysql_native_password BY 'repl_pass';
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';
FLUSH PRIVILEGES;
