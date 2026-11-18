-- ====================================================================
-- Corporate Training Resource & Lab Infrastructure Management Platform
-- Database Schema Script for XAMPP (MySQL / phpMyAdmin)
-- ====================================================================

-- 1. Create Database if it doesn't already exist
CREATE DATABASE IF NOT EXISTS corporate_training_lab_db;
USE corporate_training_lab_db;

-- ====================================================================
-- Table 1: USERS
-- Purpose: Stores login and profile details of Trainees, Trainers, and Admins.
-- ====================================================================
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('ADMIN', 'TRAINER', 'TRAINEE') NOT NULL DEFAULT 'TRAINEE',
    department VARCHAR(100) DEFAULT 'Engineering',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================================
-- Table 2: TRAINING_COURSES
-- Purpose: Tracks corporate training programs offered.
-- Links to: users table (trainer_id)
-- ====================================================================
CREATE TABLE IF NOT EXISTS training_courses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    course_title VARCHAR(150) NOT NULL,
    description TEXT,
    trainer_id INT,
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (trainer_id) REFERENCES users(id) ON DELETE SET NULL
);

-- ====================================================================
-- Table 3: TRAINING_RESOURCES
-- Purpose: Stores study documents, slides, manuals, or lab guides.
-- Links to: training_courses table (course_id)
-- ====================================================================
CREATE TABLE IF NOT EXISTS training_resources (
    id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    resource_type ENUM('PDF', 'VIDEO', 'LAB_GUIDE', 'CODE_REPO') NOT NULL,
    resource_url VARCHAR(255) NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES training_courses(id) ON DELETE CASCADE
);

-- ====================================================================
-- Table 4: LAB_INFRASTRUCTURE
-- Purpose: Tracks physical and virtual lab machines, their specifications,
--          and current operational status.
-- ====================================================================
CREATE TABLE IF NOT EXISTS lab_infrastructure (
    id INT AUTO_INCREMENT PRIMARY KEY,
    lab_name VARCHAR(50) NOT NULL,            -- e.g., 'Cloud Lab A', 'AI Lab 2'
    machine_name VARCHAR(50) NOT NULL UNIQUE,  -- e.g., 'SRV-K8S-MASTER', 'DEV-WS-01'
    ip_address VARCHAR(45),
    os_type VARCHAR(50) NOT NULL,             -- e.g., 'Ubuntu 22.04 LTS', 'Windows Server 2022'
    ram_gb INT NOT NULL,                      -- e.g., 32, 64
    cpu_cores INT NOT NULL,                   -- e.g., 8, 16
    status ENUM('AVAILABLE', 'IN_USE', 'MAINTENANCE') NOT NULL DEFAULT 'AVAILABLE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================================
-- Table 5: LAB_BOOKINGS
-- Purpose: Handles reservation of lab machines by trainees/trainers.
-- Links to: lab_infrastructure (machine_id) and users (user_id)
-- ====================================================================
CREATE TABLE IF NOT EXISTS lab_bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    machine_id INT NOT NULL,
    user_id INT NOT NULL,
    booking_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    purpose VARCHAR(255) NOT NULL,
    booking_status ENUM('CONFIRMED', 'CANCELLED', 'COMPLETED') NOT NULL DEFAULT 'CONFIRMED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (machine_id) REFERENCES lab_infrastructure(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ====================================================================
-- SAMPLE DEMO DATA
-- (This ensures you have realistic records to show your guide!)
-- ====================================================================

-- 1. Insert Sample Users
INSERT INTO users (full_name, email, password_hash, role, department) VALUES
('Sarah Jenkins', 'sarah.jenkins@company.com', 'hashed_pass_123', 'ADMIN', 'IT Infrastructure'),
('David Kumar', 'david.kumar@company.com', 'hashed_pass_456', 'TRAINER', 'Cloud & DevOps'),
('Elena Rostova', 'elena.rostova@company.com', 'hashed_pass_789', 'TRAINER', 'Data Science & AI'),
('Rahul Sharma', 'rahul.s@company.com', 'hashed_pass_321', 'TRAINEE', 'Graduate Engineering'),
('Priya Patel', 'priya.p@company.com', 'hashed_pass_654', 'TRAINEE', 'Graduate Engineering');

-- 2. Insert Training Courses
INSERT INTO training_courses (course_code, course_title, description, trainer_id, start_date, end_date) VALUES
('DEV-201', 'Cloud Infrastructure & Kubernetes Administration', 'Hands-on training covering container orchestration, pods, and cluster scaling.', 2, '2026-11-01', '2026-11-20'),
('AI-301', 'Deep Learning & Neural Networks Hands-On', 'Comprehensive lab training on PyTorch, GPU acceleration, and model deployment.', 3, '2026-11-05', '2026-11-25');

-- 3. Insert Training Resources
INSERT INTO training_resources (course_id, title, resource_type, resource_url) VALUES
(1, 'Kubernetes Lab Setup Guide v1.2', 'LAB_GUIDE', 'https://docs.company.com/labs/k8s-guide.pdf'),
(1, 'Cluster Architecture Cheatsheet', 'PDF', 'https://docs.company.com/labs/k8s-arch.pdf'),
(2, 'PyTorch GPU Acceleration Walkthrough', 'LAB_GUIDE', 'https://docs.company.com/labs/pytorch-gpu.pdf'),
(2, 'Model Training Exercise Starter Code', 'CODE_REPO', 'https://github.com/company-internal/ai301-labs');

-- 4. Insert Lab Infrastructure (Machines)
INSERT INTO lab_infrastructure (lab_name, machine_name, ip_address, os_type, ram_gb, cpu_cores, status) VALUES
('Cloud Lab A', 'SRV-K8S-MASTER', '192.168.10.101', 'Ubuntu 22.04 LTS', 64, 16, 'AVAILABLE'),
('Cloud Lab A', 'NODE-K8S-W1', '192.168.10.102', 'Ubuntu 22.04 LTS', 32, 8, 'IN_USE'),
('Cloud Lab A', 'NODE-K8S-W2', '192.168.10.103', 'Ubuntu 22.04 LTS', 32, 8, 'AVAILABLE'),
('AI Research Lab', 'GPU-RIG-RTX4090', '192.168.20.201', 'Ubuntu 22.04 LTS', 128, 32, 'IN_USE'),
('AI Research Lab', 'GPU-RIG-A100', '192.168.20.202', 'Ubuntu 22.04 LTS', 256, 64, 'MAINTENANCE'),
('Dev Lab B', 'DEV-WS-01', '192.168.30.15', 'Windows Server 2022', 32, 8, 'AVAILABLE');

-- 5. Insert Sample Lab Bookings
INSERT INTO lab_bookings (machine_id, user_id, booking_date, start_time, end_time, purpose, booking_status) VALUES
(2, 4, '2026-11-02', '09:00:00', '12:00:00', 'Kubernetes Pod Deployment Lab Session', 'CONFIRMED'),
(4, 5, '2026-11-03', '14:00:00', '17:00:00', 'Deep Learning Model Training Practice', 'CONFIRMED');
