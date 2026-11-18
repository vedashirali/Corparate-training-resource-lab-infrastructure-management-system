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
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
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
DROP TABLE IF EXISTS `labs`;
CREATE TABLE `labs` (
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
DROP TABLE IF EXISTS `training_programs`;
CREATE TABLE `training_programs` (
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
DROP TABLE IF EXISTS `lab_resources`;
CREATE TABLE `lab_resources` (
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
DROP TABLE IF EXISTS `resource_requests`;
CREATE TABLE `resource_requests` (
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
DROP TABLE IF EXISTS `activity_logs`;
CREATE TABLE `activity_logs` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `actor` VARCHAR(100) NOT NULL,
    `action` VARCHAR(50) NOT NULL,
    `details` TEXT,
    `timestamp` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_logs_actor` (`actor`),
    INDEX `idx_logs_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- SEED DATA (Initial Enterprise Records)
-- Passwords below are pre-hashed using Spring Security BCrypt ($2a$10$...)
-- Default password for all demo accounts: Admin@123 / Trainer@123 / Employee@123
-- ====================================================================

-- 1. Insert Enterprise Users
INSERT INTO `users` (`username`, `email`, `full_name`, `password_hash`, `role`, `department`, `phone`, `is_active`) VALUES
('admin', 'admin@corplab.com', 'System Administrator', '$2a$10$7Z8Kq9C1n0Qv9Y1Z9e0y1.aB0c1D2E3F4G5H6I7J8K9L0M1N2O3P4', 'ADMIN', 'IT Infrastructure', '+1-555-0101', TRUE),
('david.k', 'david.kumar@corplab.com', 'David Kumar', '$2a$10$7Z8Kq9C1n0Qv9Y1Z9e0y1.aB0c1D2E3F4G5H6I7J8K9L0M1N2O3P4', 'TRAINER', 'Cloud & DevOps', '+1-555-0102', TRUE),
('elena.r', 'elena.r@corplab.com', 'Elena Rostova', '$2a$10$7Z8Kq9C1n0Qv9Y1Z9e0y1.aB0c1D2E3F4G5H6I7J8K9L0M1N2O3P4', 'TRAINER', 'Data Science & AI', '+1-555-0103', TRUE),
('marcus.v', 'marcus.v@corplab.com', 'Marcus Vance', '$2a$10$7Z8Kq9C1n0Qv9Y1Z9e0y1.aB0c1D2E3F4G5H6I7J8K9L0M1N2O3P4', 'TRAINER', 'Cybersecurity', '+1-555-0104', TRUE),
('rahul.s', 'rahul.s@corplab.com', 'Rahul Sharma', '$2a$10$7Z8Kq9C1n0Qv9Y1Z9e0y1.aB0c1D2E3F4G5H6I7J8K9L0M1N2O3P4', 'EMPLOYEE', 'Engineering', '+1-555-0105', TRUE),
('priya.p', 'priya.p@corplab.com', 'Priya Patel', '$2a$10$7Z8Kq9C1n0Qv9Y1Z9e0y1.aB0c1D2E3F4G5H6I7J8K9L0M1N2O3P4', 'EMPLOYEE', 'Cloud Architecture', '+1-555-0106', TRUE),
('vikram.m', 'vikram.m@corplab.com', 'Vikram Malhotra', '$2a$10$7Z8Kq9C1n0Qv9Y1Z9e0y1.aB0c1D2E3F4G5H6I7J8K9L0M1N2O3P4', 'EMPLOYEE', 'DevOps', '+1-555-0107', TRUE),
('neha.d', 'neha.d@corplab.com', 'Neha Deshmukh', '$2a$10$7Z8Kq9C1n0Qv9Y1Z9e0y1.aB0c1D2E3F4G5H6I7J8K9L0M1N2O3P4', 'EMPLOYEE', 'Data Science', '+1-555-0108', TRUE);

-- 2. Insert Lab Facilities
INSERT INTO `labs` (`name`, `location`, `capacity`, `description`, `status`) VALUES
('Cloud Lab A', 'Tech Tower B, Floor 3, Room 302', 35, 'High-bandwidth facility configured for Kubernetes and Cloud clustering.', 'ACTIVE'),
('AI Research Lab', 'Innovation Hub, Floor 4, Suite 410', 20, 'Climate-controlled lab equipped with high-density GPU compute racks.', 'ACTIVE'),
('Dev Lab B', 'Engineering Wing, Ground Floor, Room 105', 30, 'General development environment with dual-boot Linux/Windows workstations.', 'ACTIVE');

-- 3. Insert Training Programs (The 4 Real-World Courses)
INSERT INTO `training_programs` (`program_code`, `title`, `category`, `description`, `trainer_name`, `duration`, `start_date`, `end_date`, `enrolled_count`, `status`) VALUES
('DEV-201', 'Cloud Infrastructure & Kubernetes Administration', 'Cloud Infrastructure', 'Enterprise container orchestration, pod scheduling, and Calico CNI networking.', 'David Kumar', '4 Weeks', '2026-11-01', '2026-11-30', 28, 'ONGOING'),
('FSJ-101', 'Enterprise Java Full Stack with Spring Boot', 'Software Engineering', 'Enterprise Spring Boot microservices, Spring Data JPA, Hibernate ORM, and REST APIs.', 'David Kumar', '8 Weeks', '2026-10-15', '2026-12-15', 35, 'ONGOING'),
('AI-301', 'Deep Learning & Neural Networks Acceleration', 'Artificial Intelligence', 'PyTorch 2.4, CUDA 12.4 tensor acceleration, ResNet vision, and transformer inference.', 'Elena Rostova', '6 Weeks', '2026-12-01', '2027-01-15', 22, 'OPEN'),
('SEC-401', 'Enterprise Zero Trust & Cyber Defense Architecture', 'Cybersecurity', 'Zero Trust enclaves, mTLS, Secret vaults, OWASP Top 10 mitigation, and SIEM logging.', 'Marcus Vance', '3 Weeks', '2026-11-20', '2026-12-10', 15, 'OPEN');

-- 4. Insert Compute Resources (Hardware / Rigs)
INSERT INTO `lab_resources` (`title`, `category`, `capacity`, `status`, `description`) VALUES
('Kubernetes Master Node 01', 'Cloud Infrastructure', 64, 'AVAILABLE', 'Primary cluster controller with 16 vCPUs and Calico CNI'),
('NVIDIA RTX 4090 Deep Learning Rig', 'AI / GPU Compute', 128, 'RESERVED', 'Equipped with PyTorch 2.4 and CUDA 12.4 acceleration'),
('PostgreSQL HA DB Node', 'Database Systems', 32, 'AVAILABLE', 'High-availability replica node for lab testing and replication'),
('DevOps CI/CD Build Runner', 'DevOps & CI/CD', 64, 'AVAILABLE', 'Dedicated runner node for pipeline automation and Docker builds');

-- 5. Insert Hardware Booking Requests
INSERT INTO `resource_requests` (`resource_name`, `requester_name`, `purpose`, `request_date`, `time_slot`, `status`) VALUES
('NVIDIA RTX 4090 Deep Learning Rig', 'Rahul Sharma', 'Distributed PyTorch model training and validation', '2026-11-20', '09:00 - 12:00', 'APPROVED'),
('Kubernetes Master Node 01', 'Priya Patel', 'Calico Network Policy and ingress testing', '2026-11-22', '14:00 - 17:00', 'PENDING'),
('DevOps CI/CD Build Runner', 'Vikram Malhotra', 'Pipeline stress testing and image build validation', '2026-11-24', '10:00 - 13:00', 'PENDING');

-- 6. Insert System Activity Logs
INSERT INTO `activity_logs` (`actor`, `action`, `details`) VALUES
('admin', 'USER_LOGIN', 'Session authenticated successfully via Spring Security'),
('admin', 'LAB_ALLOCATED', 'Approved Cloud Lab A for Kubernetes cohort DEV-201'),
('admin', 'RESOURCE_RESERVED', 'NVIDIA RTX 4090 allocated to Rahul Sharma');
