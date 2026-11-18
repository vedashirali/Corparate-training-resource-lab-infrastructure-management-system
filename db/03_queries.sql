-- ======================================================================================
-- Corporate Training Resource & Lab Infrastructure Management System
-- ANALYTICAL & OPERATIONAL QUERIES: 03_queries.sql
-- Architecture: MySQL 8.0+ / InnoDB / utf8mb4
-- Mentor Note: Use these queries in your Spring Boot Repositories (@Query) or phpMyAdmin!
-- ======================================================================================

USE corporate_training_lab_db;

-- ======================================================================================
-- QUERY GROUP A: MACHINE AVAILABILITY FOR A GIVEN DATE & TIME WINDOW
-- Business Problem:
-- When a trainee or trainer asks: "Which computers in Cloud Lab A are free on
-- Nov 06, 2026 between 09:00 and 12:00?", we must return machines that:
--   1. Have hardware status = 'AVAILABLE' (not in maintenance or retired).
--   2. Do NOT have an overlapping APPROVED reservation during that exact time slice.
--
-- Time Overlap Formula in Relational Databases:
-- Two intervals [A_start, A_end] and [B_start, B_end] overlap IF AND ONLY IF:
--   A_start < B_end AND A_end > B_start
-- ======================================================================================

-- Define target evaluation parameters (simulate input arguments from a web form)
SET @target_date  = '2026-11-06';
SET @target_start = '09:00:00';
SET @target_end   = '12:00:00';
SET @target_lab_id = 1; -- 1 = Cloud Lab A (Pass NULL to search across all labs)

SELECT 
    m.id AS machine_id,
    m.machine_name,
    l.lab_name,
    l.location AS lab_location,
    m.os_type,
    m.ram_gb,
    m.cpu_cores,
    m.ip_address,
    m.status AS hardware_status
FROM lab_machines m
JOIN labs l ON m.lab_id = l.id
WHERE m.status = 'AVAILABLE'
  AND l.status = 'ACTIVE'
  AND (@target_lab_id IS NULL OR m.lab_id = @target_lab_id)
  -- Exclude any machine that has an existing APPROVED booking colliding with this slot
  AND m.id NOT IN (
      SELECT b.machine_id
      FROM lab_bookings b
      WHERE b.booking_date = @target_date
        AND b.booking_status = 'APPROVED'
        AND b.start_time < @target_end
        AND b.end_time   > @target_start
  )
ORDER BY m.ram_gb DESC, m.machine_name ASC;


-- ======================================================================================
-- QUERY GROUP B: BOOKING CONFLICT DETECTION (PREVENT DOUBLE-BOOKING)
-- Business Problem:
-- Before inserting a new reservation or approving a pending request, the backend
-- must verify if the target machine already has an overlapping approved booking.
-- Returns count > 0 if a collision exists, plus details of the colliding booking.
-- ======================================================================================

SET @check_machine_id = 1;          -- Target machine: SRV-K8S-MASTER
SET @check_date       = '2026-11-06';
SET @new_start_time   = '09:30:00'; -- Collides with existing 09:00 - 12:00 slot!
SET @new_end_time     = '11:30:00';

SELECT 
    b.id AS conflicting_booking_id,
    m.machine_name,
    u.full_name AS booked_by,
    u.email AS requester_email,
    b.booking_date,
    b.start_time AS existing_start,
    b.end_time   AS existing_end,
    b.purpose,
    b.booking_status,
    CASE 
        WHEN b.id IS NOT NULL THEN 'CONFLICT_DETECTED: Overlapping approved slot exists'
        ELSE 'AVAILABLE: Safe to allocate'
    END AS scheduling_verdict
FROM lab_bookings b
JOIN lab_machines m ON b.machine_id = m.id
JOIN users u ON b.user_id = u.id
WHERE b.machine_id = @check_machine_id
  AND b.booking_date = @check_date
  AND b.booking_status = 'APPROVED'
  AND b.start_time < @new_end_time
  AND b.end_time   > @new_start_time;


-- ======================================================================================
-- QUERY GROUP C: EXECUTIVE DASHBOARD KPIS (SINGLE CONSOLIDATED QUERY)
-- Business Problem:
-- Corporate dashboards require 8 core metric counters rendered simultaneously
-- on page load. Running 8 separate HTTP roundtrips is inefficient.
-- This single query computes all 8 KPIs using fast subqueries and aggregations.
-- ======================================================================================

SELECT 
    -- 1. Total active trainees (corporate employees enrolled in training)
    (SELECT COUNT(*) FROM users WHERE role = 'TRAINEE' AND is_active = TRUE) AS total_employees,

    -- 2. Total active trainers
    (SELECT COUNT(*) FROM users WHERE role = 'TRAINER' AND is_active = TRUE) AS total_trainers,

    -- 3. Currently active training courses (OPEN or ONGOING)
    (SELECT COUNT(*) FROM training_courses WHERE status IN ('OPEN', 'ONGOING')) AS active_courses,

    -- 4. Available compute nodes (hardware ready for allocation)
    (SELECT COUNT(*) FROM lab_machines WHERE status = 'AVAILABLE') AS available_machines,

    -- 5. Sessions scheduled for today (evaluated using '2026-11-06' for demo simulation)
    (SELECT COUNT(*) FROM training_sessions 
     WHERE session_date = '2026-11-06' AND status != 'CANCELLED') AS today_sessions,

    -- 6. Lab reservations scheduled in current calendar month (November 2026)
    (SELECT COUNT(*) FROM lab_bookings 
     WHERE booking_date BETWEEN '2026-11-01' AND '2026-11-30') AS bookings_this_month,

    -- 7. Reservations awaiting administrator review & approval
    (SELECT COUNT(*) FROM lab_bookings WHERE booking_status = 'PENDING') AS pending_approvals,

    -- 8. Overall corporate attendance rate (PRESENT + LATE counts as attended)
    (SELECT ROUND(
        100.0 * COUNT(CASE WHEN status IN ('PRESENT', 'LATE') THEN 1 END) / 
        NULLIF(COUNT(*), 0), 2)
     FROM attendance) AS overall_attendance_pct;


-- ======================================================================================
-- QUERY GROUP D: ANALYTICAL & MANAGEMENT REPORTS
-- ======================================================================================

-- --------------------------------------------------------------------------------------
-- D.1: Course Enrollment Metrics & Seat Utilization
-- Shows how many seats are filled vs course capacity.
-- --------------------------------------------------------------------------------------
SELECT 
    c.course_code,
    c.course_title,
    c.category,
    c.status AS course_status,
    u.full_name AS trainer_name,
    c.capacity,
    COUNT(e.id) AS enrolled_trainees,
    (c.capacity - COUNT(e.id)) AS remaining_seats,
    ROUND(100.0 * COUNT(e.id) / c.capacity, 1) AS seat_utilization_pct,
    CASE 
        WHEN COUNT(e.id) >= c.capacity THEN 'FULL'
        WHEN COUNT(e.id) >= c.capacity * 0.8 THEN 'ALMOST_FULL'
        ELSE 'SEATS_AVAILABLE'
    END AS enrollment_alert
FROM training_courses c
LEFT JOIN users u ON c.trainer_id = u.id
LEFT JOIN enrollments e ON c.id = e.course_id AND e.status != 'DROPPED'
GROUP BY c.id, c.course_code, c.course_title, c.category, c.status, u.full_name, c.capacity
ORDER BY enrolled_trainees DESC;


-- --------------------------------------------------------------------------------------
-- D.2: Monthly Lab Booking Audit Summary (By Status Breakdown)
-- Grouped by calendar month to show demand trends and approval throughput.
-- --------------------------------------------------------------------------------------
SELECT 
    DATE_FORMAT(booking_date, '%Y-%m') AS booking_month,
    COUNT(*) AS total_booking_requests,
    COUNT(CASE WHEN booking_status = 'APPROVED'  THEN 1 END) AS approved_count,
    COUNT(CASE WHEN booking_status = 'PENDING'   THEN 1 END) AS pending_count,
    COUNT(CASE WHEN booking_status = 'REJECTED'  THEN 1 END) AS rejected_count,
    COUNT(CASE WHEN booking_status = 'COMPLETED' THEN 1 END) AS completed_count,
    COUNT(CASE WHEN booking_status = 'CANCELLED' THEN 1 END) AS cancelled_count,
    ROUND(100.0 * COUNT(CASE WHEN booking_status IN ('APPROVED', 'COMPLETED') THEN 1 END) / COUNT(*), 1) AS approval_rate_pct
FROM lab_bookings
GROUP BY DATE_FORMAT(booking_date, '%Y-%m')
ORDER BY booking_month DESC;


-- --------------------------------------------------------------------------------------
-- D.3: Training Attendance Rate by Corporate Department
-- Helps HR identify which departments maintain the highest training compliance.
-- --------------------------------------------------------------------------------------
SELECT 
    d.name AS department_name,
    COUNT(a.id) AS total_session_attendances,
    COUNT(CASE WHEN a.status = 'PRESENT' THEN 1 END) AS present_count,
    COUNT(CASE WHEN a.status = 'LATE'    THEN 1 END) AS late_count,
    COUNT(CASE WHEN a.status = 'ABSENT'  THEN 1 END) AS absent_count,
    COUNT(CASE WHEN a.status = 'EXCUSED' THEN 1 END) AS excused_count,
    ROUND(100.0 * COUNT(CASE WHEN a.status IN ('PRESENT', 'LATE') THEN 1 END) / NULLIF(COUNT(a.id), 0), 1) AS compliance_rate_pct
FROM departments d
JOIN users u ON d.id = u.department_id
JOIN attendance a ON u.id = a.user_id
GROUP BY d.id, d.name
ORDER BY compliance_rate_pct DESC;


-- --------------------------------------------------------------------------------------
-- D.4: Lab Machine Infrastructure Inventory & Status Breakdown
-- Detailed hardware inventory grouped by lab facility and operational state.
-- --------------------------------------------------------------------------------------
SELECT 
    l.lab_name,
    l.location,
    COUNT(m.id) AS total_machines_configured,
    COUNT(CASE WHEN m.status = 'AVAILABLE'   THEN 1 END) AS available_nodes,
    COUNT(CASE WHEN m.status = 'MAINTENANCE' THEN 1 END) AS maintenance_nodes,
    COUNT(CASE WHEN m.status = 'RETIRED'     THEN 1 END) AS retired_nodes,
    SUM(CASE WHEN m.status = 'AVAILABLE' THEN m.ram_gb ELSE 0 END) AS available_ram_gb,
    SUM(CASE WHEN m.status = 'AVAILABLE' THEN m.cpu_cores ELSE 0 END) AS available_cpu_cores
FROM labs l
LEFT JOIN lab_machines m ON l.id = m.lab_id
GROUP BY l.id, l.lab_name, l.location
ORDER BY total_machines_configured DESC;


-- ======================================================================================
-- QUERY GROUP E: USER-SPECIFIC SCHEDULES & CAPACITY VIEWS
-- ======================================================================================

-- --------------------------------------------------------------------------------------
-- E.1: Trainee's Upcoming Schedule (Sessions + Approved Lab Bookings)
-- Query for: Rahul Sharma (User ID: 4)
-- Unions upcoming training sessions with approved hands-on lab bookings.
-- --------------------------------------------------------------------------------------
SET @trainee_id = 4;

(
    -- Part 1: Upcoming Course Sessions
    SELECT 
        'TRAINING_SESSION' AS event_type,
        c.course_code,
        s.session_title AS event_title,
        l.lab_name AS venue,
        s.session_date AS event_date,
        s.start_time,
        s.end_time,
        s.status AS event_status
    FROM enrollments e
    JOIN training_courses c ON e.course_id = c.id
    JOIN training_sessions s ON c.id = s.course_id
    LEFT JOIN labs l ON s.lab_id = l.id
    WHERE e.user_id = @trainee_id
      AND e.status = 'ENROLLED'
      AND s.session_date >= '2026-11-06'
      AND s.status = 'SCHEDULED'
)
UNION ALL
(
    -- Part 2: Trainee's Approved Lab Machine Reservations
    SELECT 
        'LAB_RESERVATION' AS event_type,
        m.machine_name AS course_code,
        b.purpose AS event_title,
        CONCAT(l.lab_name, ' (', m.ip_address, ')') AS venue,
        b.booking_date AS event_date,
        b.start_time,
        b.end_time,
        b.booking_status AS event_status
    FROM lab_bookings b
    JOIN lab_machines m ON b.machine_id = m.id
    JOIN labs l ON m.lab_id = l.id
    WHERE b.user_id = @trainee_id
      AND b.booking_status = 'APPROVED'
      AND b.booking_date >= '2026-11-06'
)
ORDER BY event_date ASC, start_time ASC;


-- --------------------------------------------------------------------------------------
-- E.2: Trainer's Upcoming Teaching Schedule
-- Query for: David Kumar (Trainer User ID: 2)
-- Shows all upcoming sessions assigned to this trainer with venue & class size.
-- --------------------------------------------------------------------------------------
SET @trainer_id = 2;

SELECT 
    s.id AS session_id,
    c.course_code,
    c.course_title,
    s.session_title,
    s.session_date,
    s.start_time,
    s.end_time,
    l.lab_name AS assigned_lab,
    l.location AS lab_location,
    s.status AS session_status,
    (SELECT COUNT(*) FROM enrollments e WHERE e.course_id = c.id AND e.status = 'ENROLLED') AS enrolled_students
FROM training_sessions s
JOIN training_courses c ON s.course_id = c.id
LEFT JOIN labs l ON s.lab_id = l.id
WHERE s.trainer_id = @trainer_id
  AND s.session_date >= '2026-11-06'
ORDER BY s.session_date ASC, s.start_time ASC;


-- --------------------------------------------------------------------------------------
-- E.3: Real-Time Course Seat Availability & Waiting Room Status
-- Used on course enrollment catalog pages so trainees see live available seats.
-- --------------------------------------------------------------------------------------
SELECT 
    c.id AS course_id,
    c.course_code,
    c.course_title,
    c.category,
    c.start_date,
    c.end_date,
    c.capacity AS maximum_seats,
    COUNT(e.id) AS currently_enrolled,
    (c.capacity - COUNT(e.id)) AS seats_remaining,
    CASE 
        WHEN c.status != 'OPEN' THEN 'REGISTRATION_CLOSED'
        WHEN COUNT(e.id) >= c.capacity THEN 'BATCH_FULL'
        ELSE 'OPEN_FOR_REGISTRATION'
    END AS registration_status
FROM training_courses c
LEFT JOIN enrollments e ON c.id = e.course_id AND e.status = 'ENROLLED'
WHERE c.status IN ('OPEN', 'ONGOING')
GROUP BY c.id, c.course_code, c.course_title, c.category, c.start_date, c.end_date, c.capacity, c.status
ORDER BY c.start_date ASC;
