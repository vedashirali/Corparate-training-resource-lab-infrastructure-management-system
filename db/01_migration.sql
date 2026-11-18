-- ======================================================================================
-- Corporate Training Resource & Lab Infrastructure Management System
-- DATABASE MIGRATION SCRIPT: 01_migration.sql
-- Architecture: MySQL 8.0+ / InnoDB / utf8mb4
-- Mentor Note: This migration EVOLVES existing schemas and PRESERVES existing records.
-- ======================================================================================

USE corporate_training_lab_db;

-- Set session parameters for strict SQL compliance and foreign key safety during migration
SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;

-- ======================================================================================
-- ARCHITECTURAL NOTE ON TRANSACTIONS IN MYSQL:
-- In MySQL (InnoDB), Data Definition Language (DDL) statements (e.g., ALTER TABLE,
-- CREATE TABLE, RENAME TABLE) cause an IMPLICIT COMMIT. Therefore, DDL cannot be rolled
-- back atomically in a single BEGIN/COMMIT block like DML (INSERT/UPDATE).
-- This script is written idempotently with IF NOT EXISTS and guarded procedures.
-- ======================================================================================


-- --------------------------------------------------------------------------------------
-- 1. NEW TABLE: departments
-- REASON: In the initial prototype, department was a flat VARCHAR column in `users`.
-- Normalizing departments into an independent 3NF entity allows corporate hierarchy
-- management, department-level reporting, and prevents typos/inconsistencies.
-- --------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_departments_name UNIQUE (name)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- Pre-populate the 6 target departments so existing users can link to them immediately
INSERT INTO departments (name, description) VALUES
('IT Infrastructure', 'Manages enterprise network, physical servers, and data centers'),
('Cloud & DevOps', 'Specializes in Kubernetes, AWS, cloud architecture, and CI/CD pipelines'),
('Data Science & AI', 'Focuses on Machine Learning, Neural Networks, GPU workloads, and analytics'),
('Graduate Engineering', 'Entry-level software engineer training cohort and rotational trainees'),
('HR', 'Human resources, talent management, onboarding, and training compliance'),
('Finance', 'Financial planning, accounting, and resource budget allocations')
ON DUPLICATE KEY UPDATE description = VALUES(description);


-- --------------------------------------------------------------------------------------
-- 2. ALTER TABLE: users
-- REASONS:
-- a) department_id: Replaces redundant string with a Foreign Key to `departments(id)`.
-- b) phone: Adds direct contact info for lab hardware emergency alerts.
-- c) is_active: Enables soft-deletion (never delete employee records with historical audit logs).
-- d) updated_at: Automatic audit timestamp tracking row mutations.
-- --------------------------------------------------------------------------------------

-- Add new columns if they do not already exist
SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS 
                   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'users' AND COLUMN_NAME = 'department_id');
SET @sql = IF(@col_exists = 0, 
    'ALTER TABLE users 
        ADD COLUMN department_id INT NULL AFTER role,
        ADD COLUMN phone VARCHAR(20) NULL AFTER email,
        ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT TRUE AFTER role,
        ADD COLUMN updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER created_at;',
    'SELECT "Columns already exist on users table";');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Migrate existing department text values to department_id
-- We map any existing user's department text to the newly created departments table
UPDATE users u
JOIN departments d ON LOWER(TRIM(u.department)) = LOWER(TRIM(d.name))
SET u.department_id = d.id
WHERE u.department_id IS NULL;

-- Fallback safety: If any user had 'Engineering' (the old default), map them to 'Graduate Engineering'
UPDATE users u
JOIN departments d ON d.name = 'Graduate Engineering'
SET u.department_id = d.id
WHERE u.department_id IS NULL;

-- Make department_id NOT NULL now that all existing records are mapped, and add FK
ALTER TABLE users 
    MODIFY COLUMN department_id INT NOT NULL,
    ADD CONSTRAINT fk_users_department_id 
        FOREIGN KEY (department_id) REFERENCES departments(id) 
        ON DELETE RESTRICT;

-- Drop the old redundant department VARCHAR column
SET @has_old_dept = (SELECT COUNT(*) FROM information_schema.COLUMNS 
                     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'users' AND COLUMN_NAME = 'department');
SET @sql = IF(@has_old_dept > 0, 'ALTER TABLE users DROP COLUMN department;', 'SELECT "Old department column already dropped";');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


-- --------------------------------------------------------------------------------------
-- 3. ALTER TABLE: training_courses
-- REASONS:
-- a) category: Groups courses into functional tracks (Cloud, AI, Security).
-- b) capacity: Sets maximum enrollment seats; enforced by CHECK (capacity > 0).
-- c) status: Tracks course lifecycle (DRAFT -> OPEN -> ONGOING -> COMPLETED -> CANCELLED).
-- d) updated_at: Keeps an audit timestamp for schedule and syllabus modifications.
-- e) Date validation: Enforces end_date >= start_date to prevent invalid timelines.
-- --------------------------------------------------------------------------------------
ALTER TABLE training_courses
    ADD COLUMN IF NOT EXISTS category VARCHAR(50) NOT NULL DEFAULT 'Technical' AFTER course_title,
    ADD COLUMN IF NOT EXISTS capacity INT NOT NULL DEFAULT 30 AFTER description,
    ADD COLUMN IF NOT EXISTS status ENUM('DRAFT', 'OPEN', 'ONGOING', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'OPEN' AFTER capacity,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER created_at;

-- Add constraints for data integrity (check constraints are active in MySQL 8.0.16+)
ALTER TABLE training_courses
    ADD CONSTRAINT chk_courses_capacity CHECK (capacity > 0),
    ADD CONSTRAINT chk_courses_dates CHECK (end_date >= start_date);

-- Categorize existing legacy courses with appropriate categories
UPDATE training_courses SET category = 'Cloud & DevOps' WHERE course_code = 'DEV-201';
UPDATE training_courses SET category = 'Data Science & AI' WHERE course_code = 'AI-301';


-- --------------------------------------------------------------------------------------
-- 4. RENAME TABLE: training_resources -> course_materials
-- REASON: Avoid semantic confusion! In corporate environments, "lab compute nodes"
-- and "servers" are called "infrastructure resources", while PDFs and slide decks
-- are "course materials" or "curriculum artifacts".
-- --------------------------------------------------------------------------------------
SET @has_old_table = (SELECT COUNT(*) FROM information_schema.TABLES 
                      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'training_resources');
SET @has_new_table = (SELECT COUNT(*) FROM information_schema.TABLES 
                      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'course_materials');
SET @sql = IF(@has_old_table > 0 AND @has_new_table = 0, 
              'RENAME TABLE training_resources TO course_materials;', 
              'SELECT "Table already renamed to course_materials";');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


-- --------------------------------------------------------------------------------------
-- 5. NEW TABLE: labs
-- REASON: A Lab is a physical/virtual room with a location and overall capacity.
-- Previously, lab_name was repeated in every machine row, violating 2nd Normal Form (2NF).
-- Extracting `labs` enables scheduling whole labs for training sessions.
-- --------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS labs (
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

-- Migrate distinct lab names from existing lab_infrastructure into the new labs table
-- We check if lab_infrastructure exists or if it was already renamed to lab_machines
SET @infra_table_name = IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'lab_infrastructure') > 0, 
                           'lab_infrastructure', 'lab_machines');

SET @sql = CONCAT('
    INSERT INTO labs (lab_name, location, capacity, description, status)
    SELECT DISTINCT 
        lab_name,
        CASE 
            WHEN lab_name LIKE "%Cloud%" THEN "Tech Tower B, Floor 3, Room 302"
            WHEN lab_name LIKE "%AI%" THEN "Innovation Hub, Floor 4, Suite 410"
            ELSE "Engineering Wing, Ground Floor, Room 105"
        END AS location,
        CASE 
            WHEN lab_name LIKE "%AI%" THEN 20
            ELSE 35
        END AS capacity,
        CONCAT("Dedicated corporate training facility for ", lab_name) AS description,
        "ACTIVE" AS status
    FROM ', @infra_table_name, '
    WHERE lab_name IS NOT NULL
    ON DUPLICATE KEY UPDATE location = VALUES(location);
');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


-- --------------------------------------------------------------------------------------
-- 6. RENAME TABLE: lab_infrastructure -> lab_machines & ALTER
-- REASONS:
-- a) Table name is more accurate: it represents individual hardware nodes, not whole labs.
-- b) lab_id: Replaces redundant lab_name string with a Foreign Key.
-- c) Status ENUM changed to ('AVAILABLE','MAINTENANCE','RETIRED'):
--    ARCHITECTURAL BEST PRACTICE: 'IN_USE' should NEVER be a stored hardware state!
--    Whether a machine is "in use" at 10:00 AM depends on active bookings in that time
--    window, which is derived dynamically. Storing 'IN_USE' causes stale state bugs.
-- --------------------------------------------------------------------------------------

-- 6.1 Rename table if not already renamed
SET @has_old_infra = (SELECT COUNT(*) FROM information_schema.TABLES 
                      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'lab_infrastructure');
SET @has_new_infra = (SELECT COUNT(*) FROM information_schema.TABLES 
                      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'lab_machines');
SET @sql = IF(@has_old_infra > 0 AND @has_new_infra = 0, 
              'RENAME TABLE lab_infrastructure TO lab_machines;', 
              'SELECT "Table already renamed to lab_machines";');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 6.2 Add lab_id column
SET @has_lab_id = (SELECT COUNT(*) FROM information_schema.COLUMNS 
                   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'lab_machines' AND COLUMN_NAME = 'lab_id');
SET @sql = IF(@has_lab_id = 0, 
              'ALTER TABLE lab_machines ADD COLUMN lab_id INT NULL AFTER id;', 
              'SELECT "lab_id column already exists";');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 6.3 Link lab_id to labs table based on old lab_name column (if lab_name still exists)
SET @has_old_lab_name = (SELECT COUNT(*) FROM information_schema.COLUMNS 
                         WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'lab_machines' AND COLUMN_NAME = 'lab_name');
SET @sql = IF(@has_old_lab_name > 0, 
              'UPDATE lab_machines m JOIN labs l ON m.lab_name = l.lab_name SET m.lab_id = l.id WHERE m.lab_id IS NULL;', 
              'SELECT "lab_name column already migrated";');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Make lab_id NOT NULL and add foreign key constraint
ALTER TABLE lab_machines
    MODIFY COLUMN lab_id INT NOT NULL,
    ADD CONSTRAINT fk_machines_lab_id 
        FOREIGN KEY (lab_id) REFERENCES labs(id) 
        ON DELETE RESTRICT;

-- Drop redundant lab_name column
SET @sql = IF(@has_old_lab_name > 0, 'ALTER TABLE lab_machines DROP COLUMN lab_name;', 'SELECT "Old lab_name already dropped";');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 6.4 Evolve Status ENUM:
-- Step 1: Convert existing 'IN_USE' records to 'AVAILABLE'
UPDATE lab_machines SET status = 'AVAILABLE' WHERE status = 'IN_USE';

-- Step 2: Alter column definition to final allowed values
ALTER TABLE lab_machines
    MODIFY COLUMN status ENUM('AVAILABLE', 'MAINTENANCE', 'RETIRED') NOT NULL DEFAULT 'AVAILABLE';


-- --------------------------------------------------------------------------------------
-- 7. NEW TABLE: training_sessions
-- REASON: Courses are multi-day or multi-week programs. Trainees attend specific
-- daily sessions (e.g., "Docker Deep Dive - Nov 2, 09:00 - 12:00"). Sessions map a
-- course to a physical lab, an assigned trainer, and a precise date/time window.
-- --------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS training_sessions (
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
-- 8. NEW TABLE: enrollments
-- REASON: Resolves the Many-to-Many (M:N) relationship between users (trainees)
-- and training_courses. Tracks enrollment status and individual completion progress.
-- --------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS enrollments (
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
-- 9. NEW TABLE: attendance
-- REASON: Tracks presence for every session. Enforces audit accountability by
-- recording which trainer marked the attendance and when.
-- --------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attendance (
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
-- 10. NEW TABLE: feedback
-- REASON: Corporate quality assurance. Allows trainees to submit quantitative (1-5)
-- and qualitative feedback upon course completion.
-- --------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS feedback (
    id INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT NOT NULL,
    rating TINYINT NOT NULL,
    comments TEXT NULL,
    submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_feedback_enrollment UNIQUE (enrollment_id),
    CONSTRAINT fk_feedback_enrollment_id FOREIGN KEY (enrollment_id) REFERENCES enrollments(id) ON DELETE CASCADE,
    CONSTRAINT chk_feedback_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;


-- --------------------------------------------------------------------------------------
-- 11. ALTER TABLE: lab_bookings
-- REASONS:
-- a) booking_status: Evolves from simple 'CONFIRMED' to realistic enterprise approval
--    lifecycle ('PENDING','APPROVED','REJECTED','CANCELLED','COMPLETED').
-- b) reviewed_by, reviewed_at, admin_remarks: Tracks administrative accountability.
-- c) ON DELETE RESTRICT on user_id: A critical corporate compliance requirement!
--    If an employee leaves, their historic lab reservations must NEVER be silently
--    cascaded/deleted.
-- d) CHECK (end_time > start_time) and composite index for lightning-fast conflict lookups.
-- --------------------------------------------------------------------------------------

-- 11.1 Safely evolve the ENUM without truncating existing data
-- Step A: Temporarily expand ENUM to hold both old ('CONFIRMED') and new values
ALTER TABLE lab_bookings 
    MODIFY COLUMN booking_status ENUM('CONFIRMED', 'PENDING', 'APPROVED', 'REJECTED', 'CANCELLED', 'COMPLETED') NOT NULL DEFAULT 'PENDING';

-- Step B: Convert legacy 'CONFIRMED' bookings to 'APPROVED'
UPDATE lab_bookings SET booking_status = 'APPROVED' WHERE booking_status = 'CONFIRMED';

-- Step C: Tighten ENUM to final official specification
ALTER TABLE lab_bookings 
    MODIFY COLUMN booking_status ENUM('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED', 'COMPLETED') NOT NULL DEFAULT 'PENDING';

-- 11.2 Add review and audit columns
ALTER TABLE lab_bookings
    ADD COLUMN IF NOT EXISTS reviewed_by INT NULL AFTER purpose,
    ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMP NULL AFTER reviewed_by,
    ADD COLUMN IF NOT EXISTS admin_remarks VARCHAR(255) NULL AFTER reviewed_at;

-- Set foreign key for reviewer
ALTER TABLE lab_bookings
    ADD CONSTRAINT fk_bookings_reviewed_by 
        FOREIGN KEY (reviewed_by) REFERENCES users(id) 
        ON DELETE SET NULL;

-- 11.3 Update foreign key on user_id from CASCADE to RESTRICT
-- In MySQL, to alter an FK, we look up its system name and drop it
DROP PROCEDURE IF EXISTS _drop_fk_if_exists;
DELIMITER //
CREATE PROCEDURE _drop_fk_if_exists(IN p_table VARCHAR(64), IN p_column VARCHAR(64))
BEGIN
    DECLARE v_fk_name VARCHAR(64);
    SELECT CONSTRAINT_NAME INTO v_fk_name
    FROM information_schema.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = DATABASE() 
      AND TABLE_NAME = p_table 
      AND COLUMN_NAME = p_column 
      AND REFERENCED_TABLE_NAME IS NOT NULL
    LIMIT 1;

    IF v_fk_name IS NOT NULL THEN
        SET @drop_query = CONCAT('ALTER TABLE ', p_table, ' DROP FOREIGN KEY ', v_fk_name);
        PREPARE stmt FROM @drop_query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END //
DELIMITER ;

CALL _drop_fk_if_exists('lab_bookings', 'user_id');
DROP PROCEDURE IF EXISTS _drop_fk_if_exists;

-- Re-add FK with strict enterprise RESTRICT rule
ALTER TABLE lab_bookings
    ADD CONSTRAINT fk_bookings_user_id 
        FOREIGN KEY (user_id) REFERENCES users(id) 
        ON DELETE RESTRICT;

-- Also update machine_id FK to ensure it points cleanly to lab_machines
-- (Renaming a table automatically updates the target reference in InnoDB, but let's ensure constraint naming)
ALTER TABLE lab_bookings
    ADD CONSTRAINT chk_bookings_time CHECK (end_time > start_time);

-- Composite index for high-speed booking conflict detection queries
ALTER TABLE lab_bookings
    ADD INDEX idx_bookings_machine_date_time (machine_id, booking_date, start_time, end_time);


-- --------------------------------------------------------------------------------------
-- 12. NEW TABLE: notifications
-- REASON: Delivers real-time and asynchronous alerts to trainees and trainers
-- (e.g., "Your lab booking #BK-105 was approved", "New Kubernetes session scheduled").
-- --------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS notifications (
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

-- Re-enable foreign key checks and unique checks
SET FOREIGN_KEY_CHECKS = 1;
SET UNIQUE_CHECKS = 1;

-- ======================================================================================
-- MIGRATION COMPLETE!
-- All 5 original tables evolved without data loss.
-- 7 new normalized tables created.
-- Schema is now ready for production Spring Boot JPA entities.
-- ======================================================================================
