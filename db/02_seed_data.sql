-- ======================================================================================
-- Corporate Training Resource & Lab Infrastructure Management System
-- DATABASE SEED DATA SCRIPT: 02_seed_data.sql
-- Architecture: MySQL 8.0+ / InnoDB / utf8mb4
-- Mentor Note: All records are strictly consistent with constraints and 2026 timelines.
-- ======================================================================================

USE corporate_training_lab_db;

-- --------------------------------------------------------------------------------------
-- SECURITY & PASSWORD HASHING METHODOLOGY (FOR SPRING SECURITY BCRYPT):
-- Demo Password for all accounts: "Admin@123"
-- Method/Tool: Spring Security 6.x BCryptPasswordEncoder with cost factor 10.
-- Generated BCrypt String:
--   $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
-- Character Verification: Exactly 60 characters long.
--   - Prefix "$2a$10$" (7 chars): BCrypt identifier with log2 rounds (2^10 = 1024 iterations).
--   - Salt "N9qo8uLOickgx2ZMRZoMye" (22 chars): 128-bit cryptographically secure random salt.
--   - Hash "IjZAgcfl7p92ldGxad68LJZdL17lhWy" (31 chars): 184-bit ciphertext digest.
-- Never store plaintext passwords in a production database!
-- --------------------------------------------------------------------------------------

SET @BCRYPT_PASSWORD = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy';

-- --------------------------------------------------------------------------------------
-- 1. UPDATE EXISTING USERS & SEED 20 NEW USERS (1 Admin, 4 Trainers, 20 Trainees = 25 Users)
-- --------------------------------------------------------------------------------------

-- 1.1 Update existing 5 users with genuine BCrypt hashes and phone numbers
UPDATE users 
SET password_hash = @BCRYPT_PASSWORD, phone = '+1-555-0101', updated_at = CURRENT_TIMESTAMP 
WHERE id = 1; -- Sarah Jenkins (Admin, IT Infrastructure)

UPDATE users 
SET password_hash = @BCRYPT_PASSWORD, phone = '+1-555-0102', updated_at = CURRENT_TIMESTAMP 
WHERE id = 2; -- David Kumar (Trainer, Cloud & DevOps)

UPDATE users 
SET password_hash = @BCRYPT_PASSWORD, phone = '+1-555-0103', updated_at = CURRENT_TIMESTAMP 
WHERE id = 3; -- Elena Rostova (Trainer, Data Science & AI)

UPDATE users 
SET password_hash = @BCRYPT_PASSWORD, phone = '+1-555-0104', updated_at = CURRENT_TIMESTAMP 
WHERE id = 4; -- Rahul Sharma (Trainee, Graduate Engineering)

UPDATE users 
SET password_hash = @BCRYPT_PASSWORD, phone = '+1-555-0105', updated_at = CURRENT_TIMESTAMP 
WHERE id = 5; -- Priya Patel (Trainee, Graduate Engineering)

-- 1.2 Seed Additional Trainers (Total 4 Trainers: IDs 2, 3, 6, 7)
INSERT INTO users (id, full_name, email, password_hash, phone, role, department_id, is_active) VALUES
(6, 'Marcus Vance', 'marcus.vance@company.com', @BCRYPT_PASSWORD, '+1-555-0106', 'TRAINER', 1, TRUE), -- IT Infrastructure & Security
(7, 'Ananya Sen', 'ananya.sen@company.com', @BCRYPT_PASSWORD, '+1-555-0107', 'TRAINER', 2, TRUE)        -- Full Stack Java & Cloud
ON DUPLICATE KEY UPDATE full_name = VALUES(full_name), phone = VALUES(phone);

-- 1.3 Seed 18 Additional Trainees across all departments (Total 20 Trainees: IDs 4, 5, 8 through 25)
INSERT INTO users (id, full_name, email, password_hash, phone, role, department_id, is_active) VALUES
-- Graduate Engineering (Dept ID: 4)
(8, 'Vikram Malhotra', 'vikram.m@company.com', @BCRYPT_PASSWORD, '+1-555-0108', 'TRAINEE', 4, TRUE),
(9, 'Neha Deshmukh', 'neha.d@company.com', @BCRYPT_PASSWORD, '+1-555-0109', 'TRAINEE', 4, TRUE),
(10, 'Aarav Mehta', 'aarav.m@company.com', @BCRYPT_PASSWORD, '+1-555-0110', 'TRAINEE', 4, TRUE),
(11, 'Kavita Reddy', 'kavita.r@company.com', @BCRYPT_PASSWORD, '+1-555-0111', 'TRAINEE', 4, TRUE),

-- Cloud & DevOps (Dept ID: 2)
(12, 'James O-Connor', 'james.oc@company.com', @BCRYPT_PASSWORD, '+1-555-0112', 'TRAINEE', 2, TRUE),
(13, 'Sophia Chen', 'sophia.c@company.com', @BCRYPT_PASSWORD, '+1-555-0113', 'TRAINEE', 2, TRUE),
(14, 'Tariq Al-Mansoor', 'tariq.m@company.com', @BCRYPT_PASSWORD, '+1-555-0114', 'TRAINEE', 2, TRUE),

-- Data Science & AI (Dept ID: 3)
(15, 'Lucas Silva', 'lucas.s@company.com', @BCRYPT_PASSWORD, '+1-555-0115', 'TRAINEE', 3, TRUE),
(16, 'Chloe Martin', 'chloe.m@company.com', @BCRYPT_PASSWORD, '+1-555-0116', 'TRAINEE', 3, TRUE),
(17, 'Aiden Zhang', 'aiden.z@company.com', @BCRYPT_PASSWORD, '+1-555-0117', 'TRAINEE', 3, TRUE),

-- IT Infrastructure (Dept ID: 1)
(18, 'Daniel Kim', 'daniel.k@company.com', @BCRYPT_PASSWORD, '+1-555-0118', 'TRAINEE', 1, TRUE),
(19, 'Fatima Zahra', 'fatima.z@company.com', @BCRYPT_PASSWORD, '+1-555-0119', 'TRAINEE', 1, TRUE),
(20, 'Ethan Brooks', 'ethan.b@company.com', @BCRYPT_PASSWORD, '+1-555-0120', 'TRAINEE', 1, TRUE),

-- HR (Dept ID: 5)
(21, 'Jessica Taylor', 'jessica.t@company.com', @BCRYPT_PASSWORD, '+1-555-0121', 'TRAINEE', 5, TRUE),
(22, 'Rohan Kapoor', 'rohan.k@company.com', @BCRYPT_PASSWORD, '+1-555-0122', 'TRAINEE', 5, TRUE),

-- Finance (Dept ID: 6)
(23, 'Emma Watson', 'emma.w@company.com', @BCRYPT_PASSWORD, '+1-555-0123', 'TRAINEE', 6, TRUE),
(24, 'Karthik Iyer', 'karthik.i@company.com', @BCRYPT_PASSWORD, '+1-555-0124', 'TRAINEE', 6, TRUE),
(25, 'Zoe Washington', 'zoe.w@company.com', @BCRYPT_PASSWORD, '+1-555-0125', 'TRAINEE', 6, TRUE)
ON DUPLICATE KEY UPDATE full_name = VALUES(full_name), phone = VALUES(phone);


-- --------------------------------------------------------------------------------------
-- 2. SEED COURSES (8 Courses across DRAFT, OPEN, ONGOING, COMPLETED, CANCELLED)
-- --------------------------------------------------------------------------------------
-- Update existing courses (IDs 1 and 2) to ongoing status with capacity
UPDATE training_courses 
SET category = 'Cloud Infrastructure', capacity = 30, status = 'ONGOING', start_date = '2026-11-01', end_date = '2026-11-20' 
WHERE id = 1;

UPDATE training_courses 
SET category = 'Artificial Intelligence', capacity = 25, status = 'ONGOING', start_date = '2026-11-05', end_date = '2026-11-25' 
WHERE id = 2;

-- Insert 6 additional courses
INSERT INTO training_courses (id, course_code, course_title, category, description, trainer_id, capacity, status, start_date, end_date) VALUES
(3, 'SEC-401', 'Enterprise Zero Trust & Cyber Defense Architecture', 'Cybersecurity', 'In-depth hands-on security auditing, firewalls, threat hunting, and access containment.', 6, 25, 'OPEN', '2026-11-25', '2026-12-15'),
(4, 'FSJ-101', 'Full Stack Enterprise Java with Spring Boot & Microservices', 'Software Engineering', 'Building decoupled, resilient REST APIs with Spring Data, Docker, and Kafka integration.', 7, 35, 'OPEN', '2026-12-01', '2026-12-24'),
(5, 'DAT-202', 'High-Throughput Streaming with Apache Kafka & Spark', 'Data Engineering', 'Real-time telemetry streaming, partitioning strategies, and in-memory aggregation.', 3, 20, 'COMPLETED', '2026-10-01', '2026-10-22'),
(6, 'AGL-101', 'Agile Engineering Practices & Continuous Delivery', 'Leadership & Methodology', 'Scrum ceremonies, branch strategies, test-driven development, and release engineering.', 2, 40, 'COMPLETED', '2026-09-15', '2026-10-05'),
(7, 'GEN-501', 'Generative AI Pipeline Engineering & LLM Finetuning', 'Artificial Intelligence', 'Practical application of transformer architectures, LoRA tuning, and vector search.', 3, 15, 'DRAFT', '2026-12-10', '2026-12-30'),
(8, 'LEG-090', 'Monolithic Service Migration & Legacy Refactoring', 'Software Engineering', 'Architectural patterns for strangling legacy monoliths into cloud-native microservices.', 7, 20, 'CANCELLED', '2026-10-15', '2026-10-30')
ON DUPLICATE KEY UPDATE course_title = VALUES(course_title), status = VALUES(status), capacity = VALUES(capacity);


-- --------------------------------------------------------------------------------------
-- 3. SEED LABS (3 Facilities) & LAB MACHINES (14 Nodes across 3 Labs)
-- --------------------------------------------------------------------------------------
INSERT INTO labs (id, lab_name, location, capacity, description, status) VALUES
(1, 'Cloud Lab A', 'Tech Tower B, Floor 3, Room 302', 35, 'High-bandwidth facility configured for Kubernetes and Cloud clustering.', 'ACTIVE'),
(2, 'AI Research Lab', 'Innovation Hub, Floor 4, Suite 410', 20, 'Specialized climate-controlled lab equipped with high-density GPU compute racks.', 'ACTIVE'),
(3, 'Dev Lab B', 'Engineering Wing, Ground Floor, Room 105', 30, 'General development environment with dual-boot Linux/Windows workstations.', 'ACTIVE')
ON DUPLICATE KEY UPDATE location = VALUES(location), capacity = VALUES(capacity);

-- Ensure all 14 nodes exist with proper lab_id references and varied statuses
INSERT INTO lab_machines (id, lab_id, machine_name, ip_address, os_type, ram_gb, cpu_cores, status) VALUES
-- Cloud Lab A (Lab ID 1)
(1, 1, 'SRV-K8S-MASTER', '192.168.10.101', 'Ubuntu 22.04 LTS', 64, 16, 'AVAILABLE'),
(2, 1, 'NODE-K8S-W1', '192.168.10.102', 'Ubuntu 22.04 LTS', 32, 8, 'AVAILABLE'),
(3, 1, 'NODE-K8S-W2', '192.168.10.103', 'Ubuntu 22.04 LTS', 32, 8, 'AVAILABLE'),
(7, 1, 'NODE-K8S-W3', '192.168.10.104', 'Ubuntu 22.04 LTS', 32, 8, 'MAINTENANCE'),
(8, 1, 'SRV-STORAGE-01', '192.168.10.110', 'Red Hat Enterprise Linux 9', 128, 24, 'AVAILABLE'),

-- AI Research Lab (Lab ID 2)
(4, 2, 'GPU-RIG-RTX4090', '192.168.20.201', 'Ubuntu 22.04 LTS', 128, 32, 'AVAILABLE'),
(5, 2, 'GPU-RIG-A100', '192.168.20.202', 'Ubuntu 22.04 LTS', 256, 64, 'MAINTENANCE'),
(9, 2, 'GPU-RIG-H100', '192.168.20.203', 'Ubuntu 22.04 LTS', 512, 128, 'AVAILABLE'),
(10, 2, 'AI-EDGE-JETSON', '192.168.20.210', 'Ubuntu 22.04 LTS', 16, 6, 'AVAILABLE'),

-- Dev Lab B (Lab ID 3)
(6, 3, 'DEV-WS-01', '192.168.30.15', 'Windows Server 2022', 32, 8, 'AVAILABLE'),
(11, 3, 'DEV-WS-02', '192.168.30.16', 'Windows Server 2022', 32, 8, 'AVAILABLE'),
(12, 3, 'DEV-WS-03', '192.168.30.17', 'Ubuntu 22.04 LTS', 32, 8, 'AVAILABLE'),
(13, 3, 'DEV-WS-04', '192.168.30.18', 'Windows 11 Enterprise', 16, 4, 'RETIRED'),
(14, 3, 'DEV-WS-05', '192.168.30.19', 'Ubuntu 22.04 LTS', 32, 8, 'AVAILABLE')
ON DUPLICATE KEY UPDATE status = VALUES(status), ram_gb = VALUES(ram_gb);


-- --------------------------------------------------------------------------------------
-- 4. SEED TRAINING SESSIONS (27 Sessions across 2026 Timelines)
-- --------------------------------------------------------------------------------------
INSERT INTO training_sessions (id, course_id, trainer_id, lab_id, session_title, session_date, start_time, end_time, status) VALUES
-- Past Completed Course: DAT-202 (Kafka & Spark) - Completed October 2026
(1, 5, 3, 2, 'Kafka Broker Architecture & ZooKeeper Quorums', '2026-10-02', '09:00:00', '12:00:00', 'COMPLETED'),
(2, 5, 3, 2, 'Topic Partitioning & Consumer Rebalancing', '2026-10-05', '09:00:00', '12:00:00', 'COMPLETED'),
(3, 5, 3, 2, 'Kafka Streams & Exactly-Once Semantics', '2026-10-09', '09:00:00', '12:00:00', 'COMPLETED'),
(4, 5, 3, 2, 'Spark Streaming Pipeline Deployment', '2026-10-16', '13:00:00', '16:00:00', 'COMPLETED'),

-- Past Completed Course: AGL-101 (Agile Practices) - Completed September/October 2026
(5, 6, 2, 3, 'Test-Driven Development with JUnit 5 & Mockito', '2026-09-18', '10:00:00', '13:00:00', 'COMPLETED'),
(6, 6, 2, 3, 'Trunk-Based Development & Feature Toggles', '2026-09-25', '10:00:00', '13:00:00', 'COMPLETED'),
(7, 6, 2, 3, 'CI/CD Pipeline Automation with GitHub Actions', '2026-10-02', '10:00:00', '13:00:00', 'COMPLETED'),

-- Ongoing Course: DEV-201 (Cloud & Kubernetes) - Nov 2026
(8, 1, 2, 1, 'Container Runtime Internals & Dockerfile Hardening', '2026-11-02', '09:00:00', '12:00:00', 'COMPLETED'),
(9, 1, 2, 1, 'Pod Lifecycle, ReplicaSets & Deployments', '2026-11-04', '09:00:00', '12:00:00', 'COMPLETED'),
(10, 1, 2, 1, 'Cluster Networking, CoreDNS & Service Meshes', '2026-11-06', '09:00:00', '12:00:00', 'SCHEDULED'),
(11, 1, 2, 1, 'Persistent Volumes & StatefulSets Deployment', '2026-11-09', '09:00:00', '12:00:00', 'SCHEDULED'),
(12, 1, 2, 1, 'Ingress Controllers, Cert-Manager & TLS', '2026-11-11', '09:00:00', '12:00:00', 'SCHEDULED'),
(13, 1, 2, 1, 'Horizontal Pod Autoscaling & Prometheus Telemetry', '2026-11-13', '09:00:00', '12:00:00', 'SCHEDULED'),
(14, 1, 2, 1, 'Kubernetes Production Cluster Disaster Recovery', '2026-11-18', '09:00:00', '13:00:00', 'SCHEDULED'),

-- Ongoing Course: AI-301 (Deep Learning) - Nov 2026
(15, 2, 3, 2, 'PyTorch Tensor Fundamentals & Autograd Mechanics', '2026-11-06', '14:00:00', '17:00:00', 'SCHEDULED'),
(16, 2, 3, 2, 'Multi-GPU Distributed Data Parallel (DDP) Setup', '2026-11-09', '14:00:00', '17:00:00', 'SCHEDULED'),
(17, 2, 3, 2, 'Convolutional Backbones & Vision Transformers', '2026-11-12', '14:00:00', '17:00:00', 'SCHEDULED'),
(18, 2, 3, 2, 'Transformer Attention Mechanisms & Tokenization', '2026-11-16', '14:00:00', '17:00:00', 'SCHEDULED'),
(19, 2, 3, 2, 'TensorRT Inference Optimization & Triton Serving', '2026-11-20', '14:00:00', '17:00:00', 'SCHEDULED'),

-- Upcoming Course: SEC-401 (Zero Trust Security) - Late Nov/Dec 2026
(20, 3, 6, 1, 'Zero Trust Network Architecture & Identity Perimeters', '2026-11-26', '10:00:00', '13:00:00', 'SCHEDULED'),
(21, 3, 6, 1, 'Automated Vulnerability Scanning with Trivy & Snyk', '2026-11-30', '10:00:00', '13:00:00', 'SCHEDULED'),
(22, 3, 6, 1, 'eBPF Kernel Monitoring & Runtime Intrusion Detection', '2026-12-04', '10:00:00', '13:00:00', 'SCHEDULED'),
(23, 3, 6, 1, 'Enterprise Incident Response & Forensics Drill', '2026-12-08', '10:00:00', '14:00:00', 'SCHEDULED'),

-- Upcoming Course: FSJ-101 (Full Stack Java Microservices) - Dec 2026
(24, 4, 7, 3, 'Spring Boot 3 Core Architecture & Virtual Threads', '2026-12-02', '09:30:00', '12:30:00', 'SCHEDULED'),
(25, 4, 7, 3, 'Resilient Microservices with Resilience4j & Feign', '2026-12-07', '09:30:00', '12:30:00', 'SCHEDULED'),
(26, 4, 7, 3, 'Reactive Streams with Project Reactor & WebFlux', '2026-12-11', '09:30:00', '12:30:00', 'SCHEDULED'),

-- Cancelled Course Session: LEG-090
(27, 8, 7, 3, 'Monolith Strangler Pattern Pilot Session', '2026-10-18', '14:00:00', '17:00:00', 'CANCELLED')
ON DUPLICATE KEY UPDATE session_title = VALUES(session_title), status = VALUES(status);


-- --------------------------------------------------------------------------------------
-- 5. SEED ENROLLMENTS (44 Enrollments across Courses & Trainees)
-- --------------------------------------------------------------------------------------
INSERT INTO enrollments (id, user_id, course_id, enrolled_at, status, progress_percent) VALUES
-- DEV-201 (Course 1 - Ongoing, ~40% progress)
(1, 4, 1, '2026-10-25 09:15:00', 'ENROLLED', 45),
(2, 5, 1, '2026-10-25 10:20:00', 'ENROLLED', 40),
(3, 8, 1, '2026-10-26 11:00:00', 'ENROLLED', 45),
(4, 9, 1, '2026-10-26 14:30:00', 'ENROLLED', 30),
(5, 12, 1, '2026-10-27 08:45:00', 'ENROLLED', 50),
(6, 13, 1, '2026-10-27 12:10:00', 'ENROLLED', 45),
(7, 18, 1, '2026-10-28 15:00:00', 'ENROLLED', 40),
(8, 19, 1, '2026-10-28 16:30:00', 'ENROLLED', 25),

-- AI-301 (Course 2 - Ongoing, ~20% progress)
(9, 4, 2, '2026-10-28 10:00:00', 'ENROLLED', 20),
(10, 10, 2, '2026-10-29 09:30:00', 'ENROLLED', 25),
(11, 15, 2, '2026-10-29 11:15:00', 'ENROLLED', 25),
(12, 16, 2, '2026-10-29 14:00:00', 'ENROLLED', 15),
(13, 17, 2, '2026-10-30 08:50:00', 'ENROLLED', 25),
(14, 23, 2, '2026-10-30 16:20:00', 'ENROLLED', 10),

-- SEC-401 (Course 3 - Open, 0% progress)
(15, 5, 3, '2026-11-01 10:00:00', 'ENROLLED', 0),
(16, 12, 3, '2026-11-01 11:20:00', 'ENROLLED', 0),
(17, 14, 3, '2026-11-01 13:45:00', 'ENROLLED', 0),
(18, 18, 3, '2026-11-02 09:10:00', 'ENROLLED', 0),
(19, 20, 3, '2026-11-02 14:00:00', 'ENROLLED', 0),
(20, 24, 3, '2026-11-02 16:30:00', 'ENROLLED', 0),

-- FSJ-101 (Course 4 - Open, 0% progress)
(21, 8, 4, '2026-11-01 09:00:00', 'ENROLLED', 0),
(22, 9, 4, '2026-11-01 10:30:00', 'ENROLLED', 0),
(23, 10, 4, '2026-11-01 11:00:00', 'ENROLLED', 0),
(24, 11, 4, '2026-11-02 08:30:00', 'ENROLLED', 0),
(25, 13, 4, '2026-11-02 10:15:00', 'ENROLLED', 0),
(26, 19, 4, '2026-11-02 13:00:00', 'ENROLLED', 0),
(27, 21, 4, '2026-11-02 15:45:00', 'ENROLLED', 0),

-- DAT-202 (Course 5 - Completed, 100% progress)
(28, 4, 5, '2026-09-20 09:00:00', 'COMPLETED', 100),
(29, 10, 5, '2026-09-20 10:15:00', 'COMPLETED', 100),
(30, 15, 5, '2026-09-21 11:30:00', 'COMPLETED', 100),
(31, 16, 5, '2026-09-21 14:00:00', 'COMPLETED', 100),
(32, 17, 5, '2026-09-22 09:45:00', 'COMPLETED', 100),
(33, 23, 5, '2026-09-22 13:10:00', 'COMPLETED', 100),
(34, 25, 5, '2026-09-23 15:00:00', 'DROPPED', 35), -- Dropped after session 2

-- AGL-101 (Course 6 - Completed, 100% progress)
(35, 5, 6, '2026-09-01 09:00:00', 'COMPLETED', 100),
(36, 8, 6, '2026-09-01 10:00:00', 'COMPLETED', 100),
(37, 9, 6, '2026-09-01 11:00:00', 'COMPLETED', 100),
(38, 11, 6, '2026-09-02 08:30:00', 'COMPLETED', 100),
(39, 12, 6, '2026-09-02 12:00:00', 'COMPLETED', 100),
(40, 14, 6, '2026-09-02 14:30:00', 'COMPLETED', 100),
(41, 18, 6, '2026-09-03 10:15:00', 'COMPLETED', 100),
(42, 21, 6, '2026-09-03 11:45:00', 'COMPLETED', 100),
(43, 22, 6, '2026-09-03 15:30:00', 'COMPLETED', 100),
(44, 24, 6, '2026-09-04 09:10:00', 'COMPLETED', 100)
ON DUPLICATE KEY UPDATE status = VALUES(status), progress_percent = VALUES(progress_percent);


-- --------------------------------------------------------------------------------------
-- 6. SEED ATTENDANCE (For Completed Sessions: 1, 2, 3, 4, 5, 6, 7, 8, 9)
-- --------------------------------------------------------------------------------------
INSERT INTO attendance (session_id, user_id, status, marked_by, marked_at) VALUES
-- Session 8: DEV-201 (Nov 2, marked by David Kumar ID 2)
(8, 4, 'PRESENT', 2, '2026-11-02 09:05:00'),
(8, 5, 'PRESENT', 2, '2026-11-02 09:05:00'),
(8, 8, 'PRESENT', 2, '2026-11-02 09:06:00'),
(8, 9, 'LATE',    2, '2026-11-02 09:22:00'),
(8, 12, 'PRESENT', 2, '2026-11-02 09:04:00'),
(8, 13, 'PRESENT', 2, '2026-11-02 09:05:00'),
(8, 18, 'ABSENT',  2, '2026-11-02 09:15:00'),
(8, 19, 'EXCUSED', 2, '2026-11-02 09:00:00'),

-- Session 9: DEV-201 (Nov 4, marked by David Kumar ID 2)
(9, 4, 'PRESENT', 2, '2026-11-04 09:03:00'),
(9, 5, 'PRESENT', 2, '2026-11-04 09:04:00'),
(9, 8, 'PRESENT', 2, '2026-11-04 09:04:00'),
(9, 9, 'PRESENT', 2, '2026-11-04 09:05:00'),
(9, 12, 'PRESENT', 2, '2026-11-04 09:02:00'),
(9, 13, 'LATE',    2, '2026-11-04 09:18:00'),
(9, 18, 'PRESENT', 2, '2026-11-04 09:06:00'),
(9, 19, 'ABSENT',  2, '2026-11-04 09:15:00'),

-- Session 1: DAT-202 (Oct 2, marked by Elena Rostova ID 3)
(1, 4, 'PRESENT', 3, '2026-10-02 09:02:00'),
(1, 10, 'PRESENT', 3, '2026-10-02 09:02:00'),
(1, 15, 'PRESENT', 3, '2026-10-02 09:03:00'),
(1, 16, 'PRESENT', 3, '2026-10-02 09:04:00'),
(1, 17, 'LATE',    3, '2026-10-02 09:20:00'),
(1, 23, 'PRESENT', 3, '2026-10-02 09:05:00'),

-- Session 5: AGL-101 (Sep 18, marked by David Kumar ID 2)
(5, 5, 'PRESENT', 2, '2026-09-18 10:02:00'),
(5, 8, 'PRESENT', 2, '2026-09-18 10:02:00'),
(5, 9, 'PRESENT', 2, '2026-09-18 10:03:00'),
(5, 11, 'PRESENT', 2, '2026-09-18 10:04:00'),
(5, 12, 'EXCUSED', 2, '2026-09-18 09:50:00'),
(5, 14, 'PRESENT', 2, '2026-09-18 10:05:00'),
(5, 18, 'PRESENT', 2, '2026-09-18 10:05:00'),
(5, 21, 'PRESENT', 2, '2026-09-18 10:06:00'),
(5, 22, 'PRESENT', 2, '2026-09-18 10:06:00'),
(5, 24, 'PRESENT', 2, '2026-09-18 10:07:00')
ON DUPLICATE KEY UPDATE status = VALUES(status);


-- --------------------------------------------------------------------------------------
-- 7. SEED FEEDBACK (11 Rows for Completed Enrollments, Ratings 1-5)
-- --------------------------------------------------------------------------------------
INSERT INTO feedback (enrollment_id, rating, comments, submitted_at) VALUES
-- Feedback for Course 5 (DAT-202 Kafka & Spark)
(28, 5, 'Phenomenal depth on Kafka rebalancing protocols. The hands-on consumer lab resolved our production cluster doubts.', '2026-10-23 14:15:00'),
(29, 4, 'Very strong content. Spark streaming portion moved a bit fast, but lab exercises were exceptionally clear.', '2026-10-23 15:30:00'),
(30, 5, 'Elena explained distributed storage and partition leader election with real clarity. Highly recommended.', '2026-10-24 09:10:00'),
(31, 5, 'Outstanding course materials and realistic multi-broker testbeds. Exactly what our data engineering team needed.', '2026-10-24 11:45:00'),
(32, 4, 'Great exposure to distributed debugging and JVM heap tuning under high consumer load.', '2026-10-25 10:00:00'),
(33, 5, 'The hands-on practice with ZooKeeper-less KRaft mode was ahead of industry curve.', '2026-10-25 16:30:00'),

-- Feedback for Course 6 (AGL-101 Agile & TDD)
(35, 5, 'Reframed how our squad approaches mock objects and branch protection. TDD exercises were very practical.', '2026-10-06 11:00:00'),
(36, 4, 'Insightful sessions on trunk-based development and canary deployment strategies.', '2026-10-06 14:20:00'),
(37, 5, 'David has vast real-world architecture experience. Every design question was answered with production anecdotes.', '2026-10-07 09:45:00'),
(38, 4, 'Good balance between agile philosophy and concrete CI/CD pipeline automation.', '2026-10-07 13:10:00'),
(39, 5, 'Helped our engineering cohort align on clean code standards and automated pull request validations.', '2026-10-08 10:30:00')
ON DUPLICATE KEY UPDATE rating = VALUES(rating), comments = VALUES(comments);


-- --------------------------------------------------------------------------------------
-- 8. SEED LAB BOOKINGS (22 Bookings across all 5 Statuses: PENDING, APPROVED, REJECTED, CANCELLED, COMPLETED)
-- --------------------------------------------------------------------------------------
-- Update existing legacy bookings (IDs 1 and 2) with review audit trail
UPDATE lab_bookings 
SET booking_status = 'COMPLETED', reviewed_by = 1, reviewed_at = '2026-11-01 16:00:00', admin_remarks = 'Standard lab session allocation approved' 
WHERE id = 1;

UPDATE lab_bookings 
SET booking_status = 'APPROVED', reviewed_by = 1, reviewed_at = '2026-11-02 11:30:00', admin_remarks = 'Approved high-priority GPU slot for deep learning research' 
WHERE id = 2;

-- Insert 20 additional realistic bookings
INSERT INTO lab_bookings (id, machine_id, user_id, booking_date, start_time, end_time, purpose, reviewed_by, reviewed_at, admin_remarks, booking_status) VALUES
-- Approved Bookings (Future dates in Nov 2026)
(3, 1, 4, '2026-11-06', '09:00:00', '12:00:00', 'K8S Pod Lifecycle and Multi-container pods testing', 1, '2026-11-04 14:00:00', 'Approved for course practicals', 'APPROVED'),
(4, 3, 5, '2026-11-06', '09:00:00', '12:00:00', 'CoreDNS and Calico Network Policy validation', 1, '2026-11-04 14:05:00', 'Approved for course practicals', 'APPROVED'),
(5, 4, 15, '2026-11-06', '14:00:00', '17:00:00', 'Distributed PyTorch fine-tuning on RTX4090 rig', 1, '2026-11-05 09:30:00', 'Approved by AI Lab Administrator', 'APPROVED'),
(6, 6, 8, '2026-11-07', '10:00:00', '13:00:00', 'Windows Server Active Directory LDAP federation testing', 1, '2026-11-05 10:15:00', 'Standard dev allocation approved', 'APPROVED'),
(7, 9, 16, '2026-11-09', '14:00:00', '18:00:00', 'H100 GPU benchmark for multi-head attention acceleration', 1, '2026-11-05 15:00:00', 'Allocated under AI-301 batch quota', 'APPROVED'),
(8, 2, 12, '2026-11-10', '09:00:00', '12:00:00', 'Prometheus and Grafana cluster metrics scraping', 1, '2026-11-05 16:30:00', 'Approved', 'APPROVED'),

-- Pending Bookings (Awaiting Admin Sarah Jenkins review)
(9, 1, 9, '2026-11-12', '09:00:00', '12:00:00', 'Kubernetes Helm Chart deployment practice', NULL, NULL, NULL, 'PENDING'),
(10, 4, 17, '2026-11-12', '14:00:00', '17:00:00', 'Vision Transformer image classification training run', NULL, NULL, NULL, 'PENDING'),
(11, 8, 14, '2026-11-13', '10:00:00', '13:00:00', 'High-volume NFS storage failover testing', NULL, NULL, NULL, 'PENDING'),
(12, 11, 10, '2026-11-13', '14:00:00', '16:00:00', 'Full stack Java microservice load testing', NULL, NULL, NULL, 'PENDING'),
(13, 2, 18, '2026-11-14', '09:00:00', '12:00:00', 'Vulnerability scanning with Trivy container agent', NULL, NULL, NULL, 'PENDING'),

-- Rejected Bookings (With admin explanation)
(14, 5, 20, '2026-11-08', '09:00:00', '13:00:00', 'General browsing and coursework review', 1, '2026-11-04 11:00:00', 'Rejected: GPU-RIG-A100 is reserved for enterprise AI training; use Dev Lab workstations.', 'REJECTED'),
(15, 9, 21, '2026-11-11', '10:00:00', '15:00:00', 'Personal side project experimentation', 1, '2026-11-05 08:30:00', 'Rejected: H100 GPU compute requires signed project charter from Lead Architect.', 'REJECTED'),
(16, 1, 13, '2026-11-06', '09:30:00', '11:30:00', 'Ingress controller testing', 1, '2026-11-04 15:00:00', 'Rejected: Scheduling conflict with approved reservation #BK-3 on SRV-K8S-MASTER.', 'REJECTED'),

-- Cancelled Bookings (Cancelled by Trainee)
(17, 3, 22, '2026-11-08', '13:00:00', '16:00:00', 'Docker compose multi-tier setup', 1, '2026-11-04 10:00:00', 'Cancelled by user due to conflicting sprint review.', 'CANCELLED'),
(18, 6, 24, '2026-11-09', '11:00:00', '14:00:00', 'Financial spreadsheet batch processing test', NULL, NULL, 'User cancelled request.', 'CANCELLED'),

-- Completed Historic Bookings (Past dates in Oct 2026)
(19, 1, 4, '2026-10-15', '09:00:00', '12:00:00', 'Kubernetes cluster bootstrap pre-training trial', 1, '2026-10-14 10:00:00', 'Approved for preliminary setup', 'COMPLETED'),
(20, 4, 15, '2026-10-20', '14:00:00', '17:00:00', 'PyTorch CUDA environment validation and benchmark', 1, '2026-10-19 11:30:00', 'Approved for AI lab verification', 'COMPLETED'),
(21, 6, 11, '2026-10-22', '10:00:00', '13:00:00', 'Dev workstation IDE tools and compiler build test', 1, '2026-10-21 16:00:00', 'Approved', 'COMPLETED'),
(22, 12, 19, '2026-10-28', '14:00:00', '17:00:00', 'Linux kernel module compilation exercise', 1, '2026-10-27 13:00:00', 'Approved', 'COMPLETED')
ON DUPLICATE KEY UPDATE booking_status = VALUES(booking_status), reviewed_by = VALUES(reviewed_by), admin_remarks = VALUES(admin_remarks);


-- --------------------------------------------------------------------------------------
-- 9. SEED NOTIFICATIONS (16 Notifications across INFO, SUCCESS, WARNING, ALERT)
-- --------------------------------------------------------------------------------------
INSERT INTO notifications (id, user_id, title, message, type, is_read, created_at) VALUES
-- Admin Notifications (User 1)
(1, 1, 'New Compute Reservation Request', 'Trainee Neha Deshmukh requested SRV-K8S-MASTER for Nov 12, 09:00 - 12:00. Requires review.', 'INFO', FALSE, '2026-11-03 08:30:00'),
(2, 1, 'Hardware Maintenance Scheduled', 'Node GPU-RIG-A100 is undergoing driver updates and cooling inspection.', 'WARNING', TRUE, '2026-11-02 10:00:00'),
(3, 1, 'High Cluster Allocation Detected', 'AI Research Lab compute utilization exceeded 85% for next week schedule.', 'ALERT', FALSE, '2026-11-03 09:15:00'),

-- Trainer Notifications (Users 2 and 3)
(4, 2, 'Upcoming Session: Kubernetes Ingress', 'Your training session "Cluster Networking & Service Meshes" is scheduled for Nov 6 at 09:00 in Cloud Lab A.', 'INFO', FALSE, '2026-11-03 07:00:00'),
(5, 3, 'Course Batch Enrollment Milestone', 'Course AI-301 has reached 14 enrolled trainees. Capacity is 25 seats.', 'SUCCESS', TRUE, '2026-10-31 16:00:00'),

-- Trainee Notifications (Users 4, 5, 8, 9, 15, 20)
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
(16, 9, 'Session Reminder: Nov 6 Lab', 'Reminder: Training session for DEV-201 starts at 09:00 in Cloud Lab A tomorrow.', 'INFO', FALSE, '2026-11-05 18:00:00')
ON DUPLICATE KEY UPDATE message = VALUES(message), is_read = VALUES(is_read);

-- ======================================================================================
-- SEED SCRIPT COMPLETE!
-- Total: 25 Users, 8 Courses, 3 Labs, 14 Machines, 27 Sessions, 44 Enrollments,
--        24 Attendance rows, 11 Feedback rows, 22 Bookings, 16 Notifications.
-- ======================================================================================
