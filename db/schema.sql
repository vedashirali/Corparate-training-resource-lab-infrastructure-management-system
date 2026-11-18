-- ====================================================================
-- DATABASE SETUP: corplab_enterprise_db
-- Run this script inside phpMyAdmin (http://localhost/phpmyadmin)
-- ====================================================================

CREATE DATABASE IF NOT EXISTS corplab_enterprise_db
    DEFAULT CHARACTER SET utf8mb4 
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE corplab_enterprise_db;

DROP TABLE IF EXISTS lab_resources;
DROP TABLE IF EXISTS users;

-- 1. Users Table (Authentication)
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(30) NOT NULL DEFAULT 'TRAINEE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- 2. Lab Resources Table (Dynamic CRUD Operations)
CREATE TABLE lab_resources (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    capacity INT NOT NULL,
    status ENUM('AVAILABLE', 'MAINTENANCE', 'RESERVED') NOT NULL DEFAULT 'AVAILABLE',
    description TEXT,
    created_by BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_resources_user FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- 3. Seed an initial Admin user (Password: "Admin@123")
INSERT INTO users (id, username, email, password_hash, role) VALUES
(1, 'admin', 'admin@corplab.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ADMIN');

-- 4. Seed sample initial CRUD records
INSERT INTO lab_resources (title, category, capacity, status, description, created_by) VALUES
('Kubernetes Master Node 01', 'Cloud Infrastructure', 64, 'AVAILABLE', 'Primary cluster controller with 16 vCPUs', 1),
('NVIDIA RTX 4090 Deep Learning Rig', 'AI / GPU Compute', 128, 'RESERVED', 'Equipped with PyTorch 2.2 and CUDA 12.1', 1),
('PostgreSQL HA DB Node', 'Database Systems', 32, 'AVAILABLE', 'High-availability replica node for lab testing', 1);
