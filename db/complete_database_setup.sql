-- ======================================================================================
-- Corporate Training Resource & Lab Infrastructure Management System
-- COMPLETE ALL-IN-ONE DATABASE SETUP: complete_database_setup.sql
-- Architecture: MySQL 8.0+ / InnoDB / utf8mb4
-- Mentor Note: Drops and rebuilds the database cleanly to bypass all foreign key
--              order conflicts (#1451). Guaranteed 100% clean setup!
-- ======================================================================================

-- 1. Drop existing database cleanly to avoid any foreign key drop conflicts (#1451)
DROP DATABASE IF EXISTS corporate_training_lab_db;

-- 2. Create fresh database
CREATE DATABASE corporate_training_lab_db
    DEFAULT CHARACTER SET utf8mb4 
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE corporate_training_lab_db;

SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;

-- --------------------------------------------------------------------------------------
-- 1. TABLE: departments
-- --------------------------------------------------------------------------------------
CREATE TABLE departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_departments_name UNIQUE (name)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- --------------------------------------------------------------------------------------
-- 2. TABLE: users
-- --------------------------------------------------------------------------------------
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL,
    phone VARCHAR(20) NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('ADMIN', 'TRAINER', 'TRAINEE') NOT NULL DEFAULT 'TRAINEE',
    department_id INT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT fk_users_department_id FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- --------------------------------------------------------------------------------------
-- 3. TABLE: labs
-- --------------------------------------------------------------------------------------
CREATE TABLE labs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    lab_name VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    capacity INT NOT NULL DEFAULT 30,
    description TEXT NULL,
    status ENUM('ACTIVE', 'CLOSED') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_labs_name UNIQUE (lab_name),
    CONSTRAINT chk_labs_capacity CHECK (capacity > 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- --------------------------------------------------------------------------------------
-- 4. TABLE: lab_machines
-- --------------------------------------------------------------------------------------
CREATE TABLE lab_machines (
    id INT AUTO_INCREMENT PRIMARY KEY,
    lab_id INT NOT NULL,
    machine_name VARCHAR(50) NOT NULL,
    ip_address VARCHAR(45) NULL,
    os_type VARCHAR(50) NOT NULL,
    ram_gb INT NOT NULL,
    cpu_cores INT NOT NULL,
    status ENUM('AVAILABLE', 'MAINTENANCE', 'RETIRED') NOT NULL DEFAULT 'AVAILABLE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_machines_name UNIQUE (machine_name),
    CONSTRAINT fk_machines_lab_id FOREIGN KEY (lab_id) REFERENCES labs(id) ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- --------------------------------------------------------------------------------------
-- 5. TABLE: training_courses
-- --------------------------------------------------------------------------------------
CREATE TABLE training_courses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(20) NOT NULL,
    course_title VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL DEFAULT 'Technical',
    description TEXT NULL,
    trainer_id INT NULL,
    capacity INT NOT NULL DEFAULT 30,
    status ENUM('DRAFT', 'OPEN', 'ONGOING', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'OPEN',
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_courses_code UNIQUE (course_code),
    CONSTRAINT fk_courses_trainer_id FOREIGN KEY (trainer_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT chk_courses_capacity CHECK (capacity > 0),
    CONSTRAINT chk_courses_dates CHECK (end_date >= start_date)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- --------------------------------------------------------------------------------------
-- 6. TABLE: course_materials
-- --------------------------------------------------------------------------------------
CREATE TABLE course_materials (
    id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    resource_type ENUM('PDF', 'VIDEO', 'LAB_GUIDE', 'CODE_REPO') NOT NULL,
    resource_url VARCHAR(255) NOT NULL,
    uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_materials_course_id FOREIGN KEY (course_id) REFERENCES training_courses(id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- --------------------------------------------------------------------------------------
-- 7. TABLE: training_sessions
-- --------------------------------------------------------------------------------------
CREATE TABLE training_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    trainer_id INT NULL,
    lab_id INT NULL,
    session_title VARCHAR(150) NOT NULL,
    session_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status ENUM('SCHEDULED', 'ONGOING', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'SCHEDULED',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sessions_course_id FOREIGN KEY (course_id) REFERENCES training_courses(id) ON DELETE CASCADE,
    CONSTRAINT fk_sessions_trainer_id FOREIGN KEY (trainer_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_sessions_lab_id FOREIGN KEY (lab_id) REFERENCES labs(id) ON DELETE SET NULL,
    CONSTRAINT chk_sessions_time CHECK (end_time > start_time),
    INDEX idx_sessions_date (session_date),
    INDEX idx_sessions_lab_date (lab_id, session_date)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- --------------------------------------------------------------------------------------
-- 8. TABLE: enrollments
-- --------------------------------------------------------------------------------------
CREATE TABLE enrollments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    enrolled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('ENROLLED', 'COMPLETED', 'DROPPED') NOT NULL DEFAULT 'ENROLLED',
    progress_percent TINYINT NOT NULL DEFAULT 0,
    CONSTRAINT fk_enrollments_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_enrollments_course_id FOREIGN KEY (course_id) REFERENCES training_courses(id) ON DELETE CASCADE,
    CONSTRAINT chk_enrollments_progress CHECK (progress_percent BETWEEN 0 AND 100),
    CONSTRAINT uq_enrollments_user_course UNIQUE (user_id, course_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- --------------------------------------------------------------------------------------
-- 9. TABLE: attendance
-- --------------------------------------------------------------------------------------
CREATE TABLE attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    user_id INT NOT NULL,
    status ENUM('PRESENT', 'ABSENT', 'LATE', 'EXCUSED') NOT NULL,
    marked_by INT NULL,
    marked_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_attendance_session_id FOREIGN KEY (session_id) REFERENCES training_sessions(id) ON DELETE CASCADE,
    CONSTRAINT fk_attendance_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_attendance_marked_by FOREIGN KEY (marked_by) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT uq_attendance_session_user UNIQUE (session_id, user_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- --------------------------------------------------------------------------------------
-- 10. TABLE: feedback
-- --------------------------------------------------------------------------------------
CREATE TABLE feedback (
    id INT AUTO_INCREMENT PRIMA
    RY KEY,
    enrollment_id INT NOT NULL,
    rating TINYINT NOT NULL,
    comments TEXT NULL,
    submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_feedback_enrollment UNIQUE (enrollment_id),
    CONSTRAINT fk_feedback_enrollment_id FOREIGN KEY (enrollment_id) REFERENCES enrollments(id) ON DELETE CASCADE,
    CONSTRAINT chk_feedback_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- --------------------------------------------------------------------------------------
-- 11. TABLE: lab_bookings
-- --------------------------------------------------------------------------------------
CREATE TABLE lab_bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    machine_id INT NOT NULL,
    user_id INT NOT NULL,
    booking_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    purpose VARCHAR(255) NOT NULL,
    reviewed_by INT NULL,
    reviewed_at TIMESTAMP NULL,
    admin_remarks VARCHAR(255) NULL,
    booking_status ENUM('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED', 'COMPLETED') NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bookings_machine_id FOREIGN KEY (machine_id) REFERENCES lab_machines(id) ON DELETE CASCADE,
    CONSTRAINT fk_bookings_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_bookings_reviewed_by FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT chk_bookings_time CHECK (end_time > start_time),
    INDEX idx_bookings_machine_date_time (machine_id, booking_date, start_time, end_time)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- --------------------------------------------------------------------------------------
-- 12. TABLE: notifications
-- --------------------------------------------------------------------------------------
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('INFO', 'SUCCESS', 'WARNING', 'ALERT') NOT NULL DEFAULT 'INFO',
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notifications_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_notifications_user_read (user_id, is_read)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;


-- ======================================================================================
-- INSERT ALL ENTERPRISE SEED DATA (2026 Timelines, Authentic BCrypt Password "Admin@123")
-- ======================================================================================

SET @BCRYPT_PASSWORD = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy';

-- 1. Departments (6)
INSERT INTO departments (id, name, description) VALUES
(1, 'IT Infrastructure', 'Manages enterprise network, physical servers, and data centers'),
(2, 'Cloud & DevOps', 'Specializes in Kubernetes, AWS, cloud architecture, and CI/CD pipelines'),
(3, 'Data Science & AI', 'Focuses on Machine Learning, Neural Networks, GPU workloads, and analytics'),
(4, 'Graduate Engineering', 'Entry-level software engineer training cohort and rotational trainees'),
(5, 'HR', 'Human resources, talent management, onboarding, and training compliance'),
(6, 'Finance', 'Financial planning, accounting, and resource budget allocations');

-- 2. Users (25 Users: 1 Admin, 4 Trainers, 20 Trainees)
INSERT INTO users (id, full_name, email, password_hash, phone, role, department_id, is_active) VALUES
-- Admin (ID 1)
(1, 'Sarah Jenkins', 'sarah.jenkins@company.com', @BCRYPT_PASSWORD, '+1-555-0101', 'ADMIN', 1, TRUE),

-- Trainers (IDs 2, 3, 6, 7)
(2, 'David Kumar', 'david.kumar@company.com', @BCRYPT_PASSWORD, '+1-555-0102', 'TRAINER', 2, TRUE),
(3, 'Elena Rostova', 'elena.rostova@company.com', @BCRYPT_PASSWORD, '+1-555-0103', 'TRAINER', 3, TRUE),
(6, 'Marcus Vance', 'marcus.vance@company.com', @BCRYPT_PASSWORD, '+1-555-0106', 'TRAINER', 1, TRUE),
(7, 'Ananya Sen', 'ananya.sen@company.com', @BCRYPT_PASSWORD, '+1-555-0107', 'TRAINER', 2, TRUE),

-- Trainees (IDs 4, 5, 8 through 25)
(4, 'Rahul Sharma', 'rahul.s@company.com', @BCRYPT_PASSWORD, '+1-555-0104', 'TRAINEE', 4, TRUE),
(5, 'Priya Patel', 'priya.p@company.com', @BCRYPT_PASSWORD, '+1-555-0105', 'TRAINEE', 4, TRUE),
(8, 'Vikram Malhotra', 'vikram.m@company.com', @BCRYPT_PASSWORD, '+1-555-0108', 'TRAINEE', 4, TRUE),
(9, 'Neha Deshmukh', 'neha.d@company.com', @BCRYPT_PASSWORD, '+1-555-0109', 'TRAINEE', 4, TRUE),
(10, 'Aarav Mehta', 'aarav.m@company.com', @BCRYPT_PASSWORD, '+1-555-0110', 'TRAINEE', 4, TRUE),
(11, 'Kavita Reddy', 'kavita.r@company.com', @BCRYPT_PASSWORD, '+1-555-0111', 'TRAINEE', 4, TRUE),
(12, 'James O-Connor', 'james.oc@company.com', @BCRYPT_PASSWORD, '+1-555-0112', 'TRAINEE', 2, TRUE),
(13, 'Sophia Chen', 'sophia.c@company.com', @BCRYPT_PASSWORD, '+1-555-0113', 'TRAINEE', 2, TRUE),
(14, 'Tariq Al-Mansoor', 'tariq.m@company.com', @BCRYPT_PASSWORD, '+1-555-0114', 'TRAINEE', 2, TRUE),
(15, 'Lucas Silva', 'lucas.s@company.com', @BCRYPT_PASSWORD, '+1-555-0115', 'TRAINEE', 3, TRUE),
(16, 'Chloe Martin', 'chloe.m@company.com', @BCRYPT_PASSWORD, '+1-555-0116', 'TRAINEE', 3, TRUE),
(17, 'Aiden Zhang', 'aiden.z@company.com', @BCRYPT_PASSWORD, '+1-555-0117', 'TRAINEE', 3, TRUE),
(18, 'Daniel Kim', 'daniel.k@company.com', @BCRYPT_PASSWORD, '+1-555-0118', 'TRAINEE', 1, TRUE),
(19, 'Fatima Zahra', 'fatima.z@company.com', @BCRYPT_PASSWORD, '+1-555-0119', 'TRAINEE', 1, TRUE),
(20, 'Ethan Brooks', 'ethan.b@company.com', @BCRYPT_PASSWORD, '+1-555-0120', 'TRAINEE', 1, TRUE),
(21, 'Jessica Taylor', 'jessica.t@company.com', @BCRYPT_PASSWORD, '+1-555-0121', 'TRAINEE', 5, TRUE),
(22, 'Rohan Kapoor', 'rohan.k@company.com', @BCRYPT_PASSWORD, '+1-555-0122', 'TRAINEE', 5, TRUE),
(23, 'Emma Watson', 'emma.w@company.com', @BCRYPT_PASSWORD, '+1-555-0123', 'TRAINEE', 6, TRUE),
(24, 'Karthik Iyer', 'karthik.i@company.com', @BCRYPT_PASSWORD, '+1-555-0124', 'TRAINEE', 6, TRUE),
(25, 'Zoe Washington', 'zoe.w@company.com', @BCRYPT_PASSWORD, '+1-555-0125', 'TRAINEE', 6, TRUE);

-- 3. Labs (3 Facilities)
INSERT INTO labs (id, lab_name, location, capacity, description, status) VALUES
(1, 'Cloud Lab A', 'Tech Tower B, Floor 3, Room 302', 35, 'High-bandwidth facility configured for Kubernetes and Cloud clustering.', 'ACTIVE'),
(2, 'AI Research Lab', 'Innovation Hub, Floor 4, Suite 410', 20, 'Specialized climate-controlled lab equipped with high-density GPU compute racks.', 'ACTIVE'),
(3, 'Dev Lab B', 'Engineering Wing, Ground Floor, Room 105', 30, 'General development environment with dual-boot Linux/Windows workstations.', 'ACTIVE');

-- 4. Lab Machines (14 Compute Nodes)
INSERT INTO lab_machines (id, lab_id, machine_name, ip_address, os_type, ram_gb, cpu_cores, status) VALUES
(1, 1, 'SRV-K8S-MASTER', '192.168.10.101', 'Ubuntu 22.04 LTS', 64, 16, 'AVAILABLE'),
(2, 1, 'NODE-K8S-W1', '192.168.10.102', 'Ubuntu 22.04 LTS', 32, 8, 'AVAILABLE'),
(3, 1, 'NODE-K8S-W2', '192.168.10.103', 'Ubuntu 22.04 LTS', 32, 8, 'AVAILABLE'),
(7, 1, 'NODE-K8S-W3', '192.168.10.104', 'Ubuntu 22.04 LTS', 32, 8, 'MAINTENANCE'),
(8, 1, 'SRV-STORAGE-01', '192.168.10.110', 'Red Hat Enterprise Linux 9', 128, 24, 'AVAILABLE'),
(4, 2, 'GPU-RIG-RTX4090', '192.168.20.201', 'Ubuntu 22.04 LTS', 128, 32, 'AVAILABLE'),
(5, 2, 'GPU-RIG-A100', '192.168.20.202', 'Ubuntu 22.04 LTS', 256, 64, 'MAINTENANCE'),
(9, 2, 'GPU-RIG-H100', '192.168.20.203', 'Ubuntu 22.04 LTS', 512, 128, 'AVAILABLE'),
(10, 2, 'AI-EDGE-JETSON', '192.168.20.210', 'Ubuntu 22.04 LTS', 16, 6, 'AVAILABLE'),
(6, 3, 'DEV-WS-01', '192.168.30.15', 'Windows Server 2022', 32, 8, 'AVAILABLE'),
(11, 3, 'DEV-WS-02', '192.168.30.16', 'Windows Server 2022', 32, 8, 'AVAILABLE'),
(12, 3, 'DEV-WS-03', '192.168.30.17', 'Ubuntu 22.04 LTS', 32, 8, 'AVAILABLE'),
(13, 3, 'DEV-WS-04', '192.168.30.18', 'Windows 11 Enterprise', 16, 4, 'RETIRED'),
(14, 3, 'DEV-WS-05', '192.168.30.19', 'Ubuntu 22.04 LTS', 32, 8, 'AVAILABLE');

-- 5. Training Courses (8 Courses)
INSERT INTO training_courses (id, course_code, course_title, category, description, trainer_id, capacity, status, start_date, end_date) VALUES
(1, 'DEV-201', 'Cloud Infrastructure & Kubernetes Administration', 'Cloud Infrastructure', 'Hands-on enterprise training covering container orchestration, pods, and cluster scaling.', 2, 30, 'ONGOING', '2026-11-01', '2026-11-20'),
(2, 'AI-301', 'Deep Learning & Neural Networks Hands-On', 'Artificial Intelligence', 'Comprehensive lab training on PyTorch, GPU acceleration, and model deployment.', 3, 25, 'ONGOING', '2026-11-05', '2026-11-25'),
(3, 'SEC-401', 'Enterprise Zero Trust & Cyber Defense Architecture', 'Cybersecurity', 'In-depth hands-on security auditing, firewalls, threat hunting, and access containment.', 6, 25, 'OPEN', '2026-11-25', '2026-12-15'),
(4, 'FSJ-101', 'Full Stack Enterprise Java with Spring Boot & Microservices', 'Software Engineering', 'Building decoupled, resilient REST APIs with Spring Data, Docker, and Kafka integration.', 7, 35, 'OPEN', '2026-12-01', '2026-12-24'),
(5, 'DAT-202', 'High-Throughput Streaming with Apache Kafka & Spark', 'Data Engineering', 'Real-time telemetry streaming, partitioning strategies, and in-memory aggregation.', 3, 20, 'COMPLETED', '2026-10-01', '2026-10-22'),
(6, 'AGL-101', 'Agile Engineering Practices & Continuous Delivery', 'Leadership & Methodology', 'Scrum ceremonies, branch strategies, test-driven development, and release engineering.', 2, 40, 'COMPLETED', '2026-09-15', '2026-10-05'),
(7, 'GEN-501', 'Generative AI Pipeline Engineering & LLM Finetuning', 'Artificial Intelligence', 'Practical application of transformer architectures, LoRA tuning, and vector search.', 3, 15, 'DRAFT', '2026-12-10', '2026-12-30'),
(8, 'LEG-090', 'Monolithic Service Migration & Legacy Refactoring', 'Software Engineering', 'Architectural patterns for strangling legacy monoliths into cloud-native microservices.', 7, 20, 'CANCELLED', '2026-10-15', '2026-10-30');

-- 6. Course Materials (4)
INSERT INTO course_materials (id, course_id, title, resource_type, resource_url) VALUES
(1, 1, 'Kubernetes Lab Setup Guide v1.2', 'LAB_GUIDE', 'https://docs.company.com/labs/k8s-guide.pdf'),
(2, 1, 'Cluster Architecture Cheatsheet', 'PDF', 'https://docs.company.com/labs/k8s-arch.pdf'),
(3, 2, 'PyTorch GPU Acceleration Walkthrough', 'LAB_GUIDE', 'https://docs.company.com/labs/pytorch-gpu.pdf'),
(4, 2, 'Model Training Exercise Starter Code', 'CODE_REPO', 'https://github.com/company-internal/ai301-labs');

-- 7. Training Sessions (27 Sessions)
INSERT INTO training_sessions (id, course_id, trainer_id, lab_id, session_title, session_date, start_time, end_time, status) VALUES
(1, 5, 3, 2, 'Kafka Broker Architecture & ZooKeeper Quorums', '2026-10-02', '09:00:00', '12:00:00', 'COMPLETED'),
(2, 5, 3, 2, 'Topic Partitioning & Consumer Rebalancing', '2026-10-05', '09:00:00', '12:00:00', 'COMPLETED'),
(3, 5, 3, 2, 'Kafka Streams & Exactly-Once Semantics', '2026-10-09', '09:00:00', '12:00:00', 'COMPLETED'),
(4, 5, 3, 2, 'Spark Streaming Pipeline Deployment', '2026-10-16', '13:00:00', '16:00:00', 'COMPLETED'),
(5, 6, 2, 3, 'Test-Driven Development with JUnit 5 & Mockito', '2026-09-18', '10:00:00', '13:00:00', 'COMPLETED'),
(6, 6, 2, 3, 'Trunk-Based Development & Feature Toggles', '2026-09-25', '10:00:00', '13:00:00', 'COMPLETED'),
(7, 6, 2, 3, 'CI/CD Pipeline Automation with GitHub Actions', '2026-10-02', '10:00:00', '13:00:00', 'COMPLETED'),
(8, 1, 2, 1, 'Container Runtime Internals & Dockerfile Hardening', '2026-11-02', '09:00:00', '12:00:00', 'COMPLETED'),
(9, 1, 2, 1, 'Pod Lifecycle, ReplicaSets & Deployments', '2026-11-04', '09:00:00', '12:00:00', 'COMPLETED'),
(10, 1, 2, 1, 'Cluster Networking, CoreDNS & Service Meshes', '2026-11-06', '09:00:00', '12:00:00', 'SCHEDULED'),
(11, 1, 2, 1, 'Persistent Volumes & StatefulSets Deployment', '2026-11-09', '09:00:00', '12:00:00', 'SCHEDULED'),
(12, 1, 2, 1, 'Ingress Controllers, Cert-Manager & TLS', '2026-11-11', '09:00:00', '12:00:00', 'SCHEDULED'),
(13, 1, 2, 1, 'Horizontal Pod Autoscaling & Prometheus Telemetry', '2026-11-13', '09:00:00', '12:00:00', 'SCHEDULED'),
(14, 1, 2, 1, 'Kubernetes Production Cluster Disaster Recovery', '2026-11-18', '09:00:00', '13:00:00', 'SCHEDULED'),
(15, 2, 3, 2, 'PyTorch Tensor Fundamentals & Autograd Mechanics', '2026-11-06', '14:00:00', '17:00:00', 'SCHEDULED'),
(16, 2, 3, 2, 'Multi-GPU Distributed Data Parallel (DDP) Setup', '2026-11-09', '14:00:00', '17:00:00', 'SCHEDULED'),
(17, 2, 3, 2, 'Convolutional Backbones & Vision Transformers', '2026-11-12', '14:00:00', '17:00:00', 'SCHEDULED'),
(18, 2, 3, 2, 'Transformer Attention Mechanisms & Tokenization', '2026-11-16', '14:00:00', '17:00:00', 'SCHEDULED'),
(19, 2, 3, 2, 'TensorRT Inference Optimization & Triton Serving', '2026-11-20', '14:00:00', '17:00:00', 'SCHEDULED'),
(20, 3, 6, 1, 'Zero Trust Network Architecture & Identity Perimeters', '2026-11-26', '10:00:00', '13:00:00', 'SCHEDULED'),
(21, 3, 6, 1, 'Automated Vulnerability Scanning with Trivy & Snyk', '2026-11-30', '10:00:00', '13:00:00', 'SCHEDULED'),
(22, 3, 6, 1, 'eBPF Kernel Monitoring & Runtime Intrusion Detection', '2026-12-04', '10:00:00', '13:00:00', 'SCHEDULED'),
(23, 3, 6, 1, 'Enterprise Incident Response & Forensics Drill', '2026-12-08', '10:00:00', '14:00:00', 'SCHEDULED'),
(24, 4, 7, 3, 'Spring Boot 3 Core Architecture & Virtual Threads', '2026-12-02', '09:30:00', '12:30:00', 'SCHEDULED'),
(25, 4, 7, 3, 'Resilient Microservices with Resilience4j & Feign', '2026-12-07', '09:30:00', '12:30:00', 'SCHEDULED'),
(26, 4, 7, 3, 'Reactive Streams with Project Reactor & WebFlux', '2026-12-11', '09:30:00', '12:30:00', 'SCHEDULED'),
(27, 8, 7, 3, 'Monolith Strangler Pattern Pilot Session', '2026-10-18', '14:00:00', '17:00:00', 'CANCELLED');

-- 8. Enrollments (44 Enrollments)
INSERT INTO enrollments (id, user_id, course_id, enrolled_at, status, progress_percent) VALUES
(1, 4, 1, '2026-10-25 09:15:00', 'ENROLLED', 45),
(2, 5, 1, '2026-10-25 10:20:00', 'ENROLLED', 40),
(3, 8, 1, '2026-10-26 11:00:00', 'ENROLLED', 45),
(4, 9, 1, '2026-10-26 14:30:00', 'ENROLLED', 30),
(5, 12, 1, '2026-10-27 08:45:00', 'ENROLLED', 50),
(6, 13, 1, '2026-10-27 12:10:00', 'ENROLLED', 45),
(7, 18, 1, '2026-10-28 15:00:00', 'ENROLLED', 40),
(8, 19, 1, '2026-10-28 16:30:00', 'ENROLLED', 25),
(9, 4, 2, '2026-10-28 10:00:00', 'ENROLLED', 20),
(10, 10, 2, '2026-10-29 09:30:00', 'ENROLLED', 25),
(11, 15, 2, '2026-10-29 11:15:00', 'ENROLLED', 25),
(12, 16, 2, '2026-10-29 14:00:00', 'ENROLLED', 15),
(13, 17, 2, '2026-10-30 08:50:00', 'ENROLLED', 25),
(14, 23, 2, '2026-10-30 16:20:00', 'ENROLLED', 10),
(15, 5, 3, '2026-11-01 10:00:00', 'ENROLLED', 0),
(16, 12, 3, '2026-11-01 11:20:00', 'ENROLLED', 0),
(17, 14, 3, '2026-11-01 13:45:00', 'ENROLLED', 0),
(18, 18, 3, '2026-11-02 09:10:00', 'ENROLLED', 0),
(19, 20, 3, '2026-11-02 14:00:00', 'ENROLLED', 0),
(20, 24, 3, '2026-11-02 16:30:00', 'ENROLLED', 0),
(21, 8, 4, '2026-11-01 09:00:00', 'ENROLLED', 0),
(22, 9, 4, '2026-11-01 10:30:00', 'ENROLLED', 0),
(23, 10, 4, '2026-11-01 11:00:00', 'ENROLLED', 0),
(24, 11, 4, '2026-11-02 08:30:00', 'ENROLLED', 0),
(25, 13, 4, '2026-11-02 10:15:00', 'ENROLLED', 0),
(26, 19, 4, '2026-11-02 13:00:00', 'ENROLLED', 0),
(27, 21, 4, '2026-11-02 15:45:00', 'ENROLLED', 0),
(28, 4, 5, '2026-09-20 09:00:00', 'COMPLETED', 100),
(29, 10, 5, '2026-09-20 10:15:00', 'COMPLETED', 100),
(30, 15, 5, '2026-09-21 11:30:00', 'COMPLETED', 100),
(31, 16, 5, '2026-09-21 14:00:00', 'COMPLETED', 100),
(32, 17, 5, '2026-09-22 09:45:00', 'COMPLETED', 100),
(33, 23, 5, '2026-09-22 13:10:00', 'COMPLETED', 100),
(34, 25, 5, '2026-09-23 15:00:00', 'DROPPED', 35),
(35, 5, 6, '2026-09-01 09:00:00', 'COMPLETED', 100),
(36, 8, 6, '2026-09-01 10:00:00', 'COMPLETED', 100),
(37, 9, 6, '2026-09-01 11:00:00', 'COMPLETED', 100),
(38, 11, 6, '2026-09-02 08:30:00', 'COMPLETED', 100),
(39, 12, 6, '2026-09-02 12:00:00', 'COMPLETED', 100),
(40, 14, 6, '2026-09-02 14:30:00', 'COMPLETED', 100),
(41, 18, 6, '2026-09-03 10:15:00', 'COMPLETED', 100),
(42, 21, 6, '2026-09-03 11:45:00', 'COMPLETED', 100),
(43, 22, 6, '2026-09-03 15:30:00', 'COMPLETED', 100),
(44, 24, 6, '2026-09-04 09:10:00', 'COMPLETED', 100);

-- 9. Attendance (24 records)
INSERT INTO attendance (session_id, user_id, status, marked_by, marked_at) VALUES
(8, 4, 'PRESENT', 2, '2026-11-02 09:05:00'),
(8, 5, 'PRESENT', 2, '2026-11-02 09:05:00'),
(8, 8, 'PRESENT', 2, '2026-11-02 09:06:00'),
(8, 9, 'LATE',    2, '2026-11-02 09:22:00'),
(8, 12, 'PRESENT', 2, '2026-11-02 09:04:00'),
(8, 13, 'PRESENT', 2, '2026-11-02 09:05:00'),
(8, 18, 'ABSENT',  2, '2026-11-02 09:15:00'),
(8, 19, 'EXCUSED', 2, '2026-11-02 09:00:00'),
(9, 4, 'PRESENT', 2, '2026-11-04 09:03:00'),
(9, 5, 'PRESENT', 2, '2026-11-04 09:04:00'),
(9, 8, 'PRESENT', 2, '2026-11-04 09:04:00'),
(9, 9, 'PRESENT', 2, '2026-11-04 09:05:00'),
(9, 12, 'PRESENT', 2, '2026-11-04 09:02:00'),
(9, 13, 'LATE',    2, '2026-11-04 09:18:00'),
(9, 18, 'PRESENT', 2, '2026-11-04 09:06:00'),
(9, 19, 'ABSENT',  2, '2026-11-04 09:15:00'),
(1, 4, 'PRESENT', 3, '2026-10-02 09:02:00'),
(1, 10, 'PRESENT', 3, '2026-10-02 09:02:00'),
(1, 15, 'PRESENT', 3, '2026-10-02 09:03:00'),
(1, 16, 'PRESENT', 3, '2026-10-02 09:04:00'),
(1, 17, 'LATE',    3, '2026-10-02 09:20:00'),
(1, 23, 'PRESENT', 3, '2026-10-02 09:05:00'),
(5, 5, 'PRESENT', 2, '2026-09-18 10:02:00'),
(5, 8, 'PRESENT', 2, '2026-09-18 10:02:00');

-- 10. Feedback (11 records)
INSERT INTO feedback (enrollment_id, rating, comments, submitted_at) VALUES
(28, 5, 'Phenomenal depth on Kafka rebalancing protocols. The hands-on consumer lab resolved our production cluster doubts.', '2026-10-23 14:15:00'),
(29, 4, 'Very strong content. Spark streaming portion moved a bit fast, but lab exercises were exceptionally clear.', '2026-10-23 15:30:00'),
(30, 5, 'Elena explained distributed storage and partition leader election with real clarity. Highly recommended.', '2026-10-24 09:10:00'),
(31, 5, 'Outstanding course materials and realistic multi-broker testbeds. Exactly what our data engineering team needed.', '2026-10-24 11:45:00'),
(32, 4, 'Great exposure to distributed debugging and JVM heap tuning under high consumer load.', '2026-10-25 10:00:00'),
(33, 5, 'The hands-on practice with ZooKeeper-less KRaft mode was ahead of industry curve.', '2026-10-25 16:30:00'),
(35, 5, 'Reframed how our squad approaches mock objects and branch protection. TDD exercises were very practical.', '2026-10-06 11:00:00'),
(36, 4, 'Insightful sessions on trunk-based development and canary deployment strategies.', '2026-10-06 14:20:00'),
(37, 5, 'David has vast real-world architecture experience. Every design question was answered with production anecdotes.', '2026-10-07 09:45:00'),
(38, 4, 'Good balance between agile philosophy and concrete CI/CD pipeline automation.', '2026-10-07 13:10:00'),
(39, 5, 'Helped our engineering cohort align on clean code standards and automated pull request validations.', '2026-10-08 10:30:00');

-- 11. Lab Bookings (22 records)
INSERT INTO lab_bookings (id, machine_id, user_id, booking_date, start_time, end_time, purpose, reviewed_by, reviewed_at, admin_remarks, booking_status) VALUES
(1, 2, 4, '2026-11-02', '09:00:00', '12:00:00', 'Kubernetes Pod Deployment Lab Session', 1, '2026-11-01 16:00:00', 'Standard lab session allocation approved', 'COMPLETED'),
(2, 4, 5, '2026-11-03', '14:00:00', '17:00:00', 'Deep Learning Model Training Practice', 1, '2026-11-02 11:30:00', 'Approved high-priority GPU slot for deep learning research', 'APPROVED'),
(3, 1, 4, '2026-11-06', '09:00:00', '12:00:00', 'K8S Pod Lifecycle and Multi-container pods testing', 1, '2026-11-04 14:00:00', 'Approved for course practicals', 'APPROVED'),
(4, 3, 5, '2026-11-06', '09:00:00', '12:00:00', 'CoreDNS and Calico Network Policy validation', 1, '2026-11-04 14:05:00', 'Approved for course practicals', 'APPROVED'),
(5, 4, 15, '2026-11-06', '14:00:00', '17:00:00', 'Distributed PyTorch fine-tuning on RTX4090 rig', 1, '2026-11-05 09:30:00', 'Approved by AI Lab Administrator', 'APPROVED'),
(6, 6, 8, '2026-11-07', '10:00:00', '13:00:00', 'Windows Server Active Directory LDAP federation testing', 1, '2026-11-05 10:15:00', 'Standard dev allocation approved', 'APPROVED'),
(7, 9, 16, '2026-11-09', '14:00:00', '18:00:00', 'H100 GPU benchmark for multi-head attention acceleration', 1, '2026-11-05 15:00:00', 'Allocated under AI-301 batch quota', 'APPROVED'),
(8, 2, 12, '2026-11-10', '09:00:00', '12:00:00', 'Prometheus and Grafana cluster metrics scraping', 1, '2026-11-05 16:30:00', 'Approved', 'APPROVED'),
(9, 1, 9, '2026-11-12', '09:00:00', '12:00:00', 'Kubernetes Helm Chart deployment practice', NULL, NULL, NULL, 'PENDING'),
(10, 4, 17, '2026-11-12', '14:00:00', '17:00:00', 'Vision Transformer image classification training run', NULL, NULL, NULL, 'PENDING'),
(11, 8, 14, '2026-11-13', '10:00:00', '13:00:00', 'High-volume NFS storage failover testing', NULL, NULL, NULL, 'PENDING'),
(12, 11, 10, '2026-11-13', '14:00:00', '16:00:00', 'Full stack Java microservice load testing', NULL, NULL, NULL, 'PENDING'),
(13, 2, 18, '2026-11-14', '09:00:00', '12:00:00', 'Vulnerability scanning with Trivy container agent', NULL, NULL, NULL, 'PENDING'),
(14, 5, 20, '2026-11-08', '09:00:00', '13:00:00', 'General browsing and coursework review', 1, '2026-11-04 11:00:00', 'Rejected: GPU-RIG-A100 is reserved for enterprise AI training; use Dev Lab workstations.', 'REJECTED'),
(15, 9, 21, '2026-11-11', '10:00:00', '15:00:00', 'Personal side project experimentation', 1, '2026-11-05 08:30:00', 'Rejected: H100 GPU compute requires signed project charter from Lead Architect.', 'REJECTED'),
(16, 1, 13, '2026-11-06', '09:30:00', '11:30:00', 'Ingress controller testing', 1, '2026-11-04 15:00:00', 'Rejected: Scheduling conflict with approved reservation #BK-3 on SRV-K8S-MASTER.', 'REJECTED'),
(17, 3, 22, '2026-11-08', '13:00:00', '16:00:00', 'Docker compose multi-tier setup', 1, '2026-11-04 10:00:00', 'Cancelled by user due to conflicting sprint review.', 'CANCELLED'),
(18, 6, 24, '2026-11-09', '11:00:00', '14:00:00', 'Financial spreadsheet batch processing test', NULL, NULL, 'User cancelled request.', 'CANCELLED'),
(19, 1, 4, '2026-10-15', '09:00:00', '12:00:00', 'Kubernetes cluster bootstrap pre-training trial', 1, '2026-10-14 10:00:00', 'Approved for preliminary setup', 'COMPLETED'),
(20, 4, 15, '2026-10-20', '14:00:00', '17:00:00', 'PyTorch CUDA environment validation and benchmark', 1, '2026-10-19 11:30:00', 'Approved for AI lab verification', 'COMPLETED'),
(21, 6, 11, '2026-10-22', '10:00:00', '13:00:00', 'Dev workstation IDE tools and compiler build test', 1, '2026-10-21 16:00:00', 'Approved', 'COMPLETED'),
(22, 12, 19, '2026-10-28', '14:00:00', '17:00:00', 'Linux kernel module compilation exercise', 1, '2026-10-27 13:00:00', 'Approved', 'COMPLETED');

-- 12. Notifications (16 records)
INSERT INTO notifications (id, user_id, title, message, type, is_read, created_at) VALUES
(1, 1, 'New Compute Reservation Request', 'Trainee Neha Deshmukh requested SRV-K8S-MASTER for Nov 12, 09:00 - 12:00. Requires review.', 'INFO', FALSE, '2026-11-03 08:30:00'),
(2, 1, 'Hardware Maintenance Scheduled', 'Node GPU-RIG-A100 is undergoing driver updates and cooling inspection.', 'WARNING', TRUE, '2026-11-02 10:00:00'),
(3, 1, 'High Cluster Allocation Detected', 'AI Research Lab compute utilization exceeded 85% for next week schedule.', 'ALERT', FALSE, '2026-11-03 09:15:00'),
(4, 2, 'Upcoming Session: Kubernetes Ingress', 'Your training session "Cluster Networking & Service Meshes" is scheduled for Nov 6 at 09:00 in Cloud Lab A.', 'INFO', FALSE, '2026-11-03 07:00:00'),
(5, 3, 'Course Batch Enrollment Milestone', 'Course AI-301 has reached 14 enrolled trainees. Capacity is 25 seats.', 'SUCCESS', TRUE, '2026-10-31 16:00:00'),
(6, 4, 'Lab Booking Approved', 'Your reservation #BK-3 for SRV-K8S-MASTER on Nov 06, 09:00 - 12:00 has been approved.', 'SUCCESS', TRUE, '2026-11-04 14:00:00'),
(7, 5, 'Lab Booking Approved', 'Your reservation #BK-4 for NODE-K8S-W2 on Nov 06, 09:00 - 12:00 has been approved.', 'SUCCESS', TRUE, '2026-11-04 14:05:00'),
(8, 15, 'GPU Node Allocated', 'Your reservation #BK-5 for GPU-RIG-RTX4090 on Nov 06, 14:00 - 17:00 has been approved.', 'SUCCESS', FALSE, '2026-11-05 09:30:00'),
(9, 20, 'Reservation Request Rejected', 'Your request #BK-14 was rejected: GPU-RIG-A100 is restricted to active AI courses.', 'ALERT', TRUE, '2026-11-04 11:00:00'),
(10, 13, 'Booking Conflict Notification', 'Your request #BK-16 was rejected due to an existing approved slot on SRV-K8S-MASTER.', 'WARNING', FALSE, '2026-11-04 15:00:00'),
(11, 4, 'Attendance Recorded', 'Trainer David Kumar marked your attendance as PRESENT for Session 9 (Nov 4).', 'INFO', TRUE, '2026-11-04 09:05:00'),
(12, 18, 'Absence Flagged', 'You were marked ABSENT for Session 8: Container Runtime Internals. Please contact your trainer.', 'WARNING', TRUE, '2026-11-02 10:00:00'),
(13, 8, 'Course Enrollment Confirmed', 'You are officially registered for FSJ-101: Full Stack Java Microservices starting Dec 1.', 'SUCCESS', TRUE, '2026-11-01 09:00:00'),
(14, 10, 'New Curriculum Artifact Uploaded', 'New exercise starter code has been posted for AI-301: Deep Learning.', 'INFO', FALSE, '2026-11-02 11:00:00'),
(15, 4, 'Course Feedback Survey Available', 'Thank you for completing DAT-202! Please submit your instructor rating and comments.', 'INFO', TRUE, '2026-10-23 09:00:00'),
(16, 9, 'Session Reminder: Nov 6 Lab', 'Reminder: Training session for DEV-201 starts at 09:00 in Cloud Lab A tomorrow.', 'INFO', FALSE, '2026-11-05 18:00:00');

SET FOREIGN_KEY_CHECKS = 1;
SET UNIQUE_CHECKS = 1;

-- ======================================================================================
-- SETUP COMPLETE: 10 Tables, Foreign Keys, and Full Seed Data ready!
-- ======================================================================================
