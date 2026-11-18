-- ======================================================================================
-- LAB EXERCISE DATABASE SCRIPT: user_management_setup.sql
-- Problem Statement: User Login and Dashboard Navigation
-- Architecture: MySQL 8.0+ / InnoDB / utf8mb4
-- Description: Creates the 'user_management' database, 'users' table, and inserts
--              5 sample user records with authentic BCrypt password hashes.
-- ======================================================================================

-- 1. Create and select the database
CREATE DATABASE IF NOT EXISTS user_management
    DEFAULT CHARACTER SET utf8mb4 
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE user_management;

-- 2. Drop table if re-running
DROP TABLE IF EXISTS users;

-- ======================================================================================
-- Table: users
-- Required Columns (As per Lab Assignment Specifications):
--   - id:       INT, Primary Key, Auto Increment
--   - username: VARCHAR(50), Unique
--   - email:    VARCHAR(100), Unique
--   - password: VARCHAR(255), Stored as 60-character BCrypt hash
--   - role:     VARCHAR(30)
-- ======================================================================================
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(30) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ======================================================================================
-- 3. INSERT AT LEAST 5 SAMPLE USER RECORDS (Requirement 1.A)
-- Password for ALL demo accounts: "Admin@123"
-- Cryptographic Hash: Spring Security BCryptPasswordEncoder (work factor 10)
-- BCrypt String: $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
-- ======================================================================================

INSERT INTO users (id, username, email, password, role) VALUES
(101, 'john_doe',     'john.doe@example.com',     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Admin'),
(102, 'david_kumar',  'david.kumar@example.com',  '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Trainer'),
(103, 'elena_rostova','elena.rostova@example.com','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Trainer'),
(104, 'rahul_sharma', 'rahul.sharma@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Trainee'),
(105, 'priya_patel',  'priya.patel@example.com',  '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Trainee');

-- ======================================================================================
-- VERIFICATION QUERY
-- Run this to verify the 5 records are inserted properly
-- ======================================================================================
SELECT id, username, email, role, created_at FROM users;
