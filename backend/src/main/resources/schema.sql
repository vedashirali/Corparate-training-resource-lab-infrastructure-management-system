-- ====================================================================
-- CorpLab Nexus | Master MySQL Relational Database Schema
-- Architecture: 3-Tier Enterprise Persistence Layer
-- Target Server: MySQL 8.0+ / MariaDB (XAMPP phpMyAdmin)
-- Port: 3306 (Standard) or 3307
-- Database Name: corplab_enterprise_db
-- ====================================================================

CREATE DATABASE IF NOT EXISTS `corplab_enterprise_db`
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `corplab_enterprise_db`;

-- --------------------------------------------------------------------
-- 1. Table: users (Authentication, Identity & RBAC)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `users` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(50) NOT NULL UNIQUE,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `full_name` VARCHAR(100),
    `password_hash` VARCHAR(255) NOT NULL,
    `role` VARCHAR(30) NOT NULL DEFAULT 'EMPLOYEE',
    `department` VARCHAR(100) DEFAULT 'Engineering',
    `phone` VARCHAR(20),
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_users_role` (`role`),
    INDEX `idx_users_username` (`username`),
    INDEX `idx_users_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 2. Table: labs (Physical & Virtual Laboratory Facilities)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `labs` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL UNIQUE,
    `location` VARCHAR(150),
    `capacity` INT NOT NULL DEFAULT 30,
    `description` TEXT,
    `status` VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_labs_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 3. Table: training_programs (Corporate Curriculum Tracks)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `training_programs` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `program_code` VARCHAR(30) NOT NULL UNIQUE,
    `title` VARCHAR(150) NOT NULL,
    `category` VARCHAR(50) NOT NULL,
    `description` TEXT,
    `trainer_name` VARCHAR(100),
    `duration` VARCHAR(50) DEFAULT '4 Weeks',
    `start_date` VARCHAR(30),
    `end_date` VARCHAR(30),
    `enrolled_count` INT NOT NULL DEFAULT 0,
    `status` VARCHAR(30) NOT NULL DEFAULT 'OPEN',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_programs_category` (`category`),
    INDEX `idx_programs_code` (`program_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 4. Table: lab_resources (Compute Nodes, Hardware & GPU Rigs)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `lab_resources` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(120) NOT NULL,
    `category` VARCHAR(60) NOT NULL,
    `capacity` INT DEFAULT 64,
    `status` VARCHAR(30) NOT NULL DEFAULT 'AVAILABLE',
    `description` TEXT,
    `created_by` BIGINT DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_resources_status` (`status`),
    INDEX `idx_resources_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 5. Table: resource_requests (Hardware Booking & Allocation Queue)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `resource_requests` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `resource_name` VARCHAR(120) NOT NULL,
    `requester_name` VARCHAR(100) NOT NULL,
    `purpose` VARCHAR(255) NOT NULL,
    `request_date` VARCHAR(30) NOT NULL,
    `time_slot` VARCHAR(50) NOT NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_requests_status` (`status`),
    INDEX `idx_requests_requester` (`requester_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 6. Table: activity_logs (System Security & Chronological Audit Trail)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `activity_logs` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `actor` VARCHAR(100) NOT NULL,
    `action` VARCHAR(50) NOT NULL,
    `details` TEXT,
    `timestamp` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_logs_actor` (`actor`),
    INDEX `idx_logs_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
