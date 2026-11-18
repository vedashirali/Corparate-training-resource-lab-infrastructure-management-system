# CorpLab Nexus
## Corporate Training Resource & Lab Infrastructure Management Platform
### Comprehensive Project Documentation & Technical Progress Report

**Document Title:** Official Project Documentation & System Progress Report  
**Platform Name:** CorpLab Nexus (Corporate Training Resource & Lab Infrastructure Management Platform)  
**Academic Degree:** Bachelor of Computer Applications (BCA)  
**Academic Year:** 2026  
**Document Stage:** Frontend Operational Prototype & Relational Database Implementation  
**Date of Submission:** 3 November 2026  

---

## 1. Executive Summary

**CorpLab Nexus** is an enterprise-grade digital management platform engineered to unify corporate training curriculum, learning materials, daily classroom schedules, physical and virtual compute lab facilities, hardware reservations, and department attendance compliance into a single centralized operational workspace.

In contemporary technology organizations, training engineering personnel across specialized tracks—such as Cloud Architecture, Kubernetes Administration, Deep Learning, and Cybersecurity—requires coordinated access to both structured technical materials and high-performance physical or virtual compute nodes. Prior to this platform, such activities suffered from fragmented administration: curriculum documents were scattered across disconnected directories and email threads, while expensive compute hardware experienced scheduling collisions and uncoordinated downtime.

The current implementation achieves two major developmental milestones:
1. **Interactive Frontend Portal:** A fully functional, responsive, browser-based management console built with HTML5, modern CSS3, and Vanilla JavaScript. It delivers role-specific perspectives for Trainees, Instructors, and Lab Administrators, featuring real-time compute node status telemetry, hardware RAM allocation bars, simulated SSH diagnostic terminals, curriculum repositories, daily classroom session schedules, multi-criteria filtering, and a conflict-free lab reservation workflow.
2. **Relational Database Architecture:** An enterprise MySQL 8.0 database named `corporate_training_lab_db`, deployed and verified on XAMPP with 10 normalized Third Normal Form (3NF) tables. The database features strict primary and foreign keys (`ON DELETE RESTRICT`), unique indexes, and authentic 60-character Spring Security BCrypt password hashes, seeded with realistic 2026 operational data.

Currently, the frontend prototype operates in client-side demonstration mode, mirroring the 10 database tables with structured demonstration records. This enables full stakeholder evaluation of workflows and user interface ergonomics prior to connecting the forthcoming Java Spring Boot REST API microservice in Phase 2.

---

## 2. Introduction

Modern technology-driven organizations rely heavily on rapid continuous upskilling. However, managing enterprise-scale workforce upskilling involves complex logistics spanning educational content distribution, classroom schedule coordination, and physical infrastructure management.

### 2.1 Problem Statement
In the absence of a unified corporate training and lab resource management system, enterprises encounter critical operational bottlenecks:
* **Curriculum & Schedule Fragmentation:** Training tracks, syllabi, classroom venues, and downloadable laboratory manuals are distributed across disparate communication channels, resulting in version discrepancies and missed sessions.
* **Compute Infrastructure Contention:** Expensive, high-performance compute nodes (such as multi-GPU AI servers, Linux container nodes, and developer workstations) are uncoordinated. Trainees and trainers frequently suffer from schedule collisions, overlapping slot bookings, and unannounced maintenance windows.
* **Lack of Auditability & Compliance:** Tracking trainee attendance, course progress, and administrative booking approvals manually on spreadsheets results in lost audit trails and inaccurate departmental training records.

### 2.2 Proposed Solution
**CorpLab Nexus** solves these challenges by establishing an integrated, three-tier enterprise web portal that centralizes both instructional resources and physical lab compute nodes. The system provides:
* An executive console with role-specific views for **Trainees**, **Trainers**, and **Lab Administrators**.
* Real-time hardware telemetry and status monitoring for all compute machines across physical corporate lab venues.
* An interactive, conflict-free reservation engine allowing users to request and verify compute capacity without double-booking.
* A centralized curriculum repository linking training courses with daily session timetables and downloadable technical guides.
* Departmental attendance and infrastructure utilization analytics for organizational management.

Future implementation will bridge this frontend console to the prepared MySQL database through a Java Spring Boot REST API, enforcing token-based authentication and server-side business logic validation.

---

## 3. Project Objectives

The core objectives of the CorpLab Nexus development project are:
1. **Centralize Corporate Training Administration:** Consolidate training programs, syllabi, trainer allocations, and technical course materials into an accessible catalog.
2. **Optimize Lab Infrastructure Allocation:** Provide visibility into physical and virtual compute machines, displaying operating systems, IP addresses, vCPU cores, and dynamic RAM utilization meters.
3. **Prevent Resource Scheduling Collisions:** Formulate an intuitive reservation workflow allowing authorized personnel to schedule machine time slots without overlapping conflicts.
4. **Deliver Distinct Role-Based Experiences:** Provide tailored interfaces for Trainees (curriculum and bookings), Trainers (schedules and materials), and Administrators (infrastructure health and booking approvals).
5. **Enforce Database Normalization & Security:** Implement a robust 10-table relational schema normalized to Third Normal Form (3NF), enforcing referential integrity and industry-standard BCrypt password hashing.
6. **Establish an Extensible 3-Tier Foundation:** Structure the codebase cleanly to support immediate frontend prototyping and seamless migration to a Java Spring Boot middle tier.

---

## 4. Work Completed So Far

The project development has progressed systematically through database architecture, client-side interface engineering, and system documentation.

### 4.1 Executive Dashboard & Global Navigation
The primary interface features a modern dark-slate corporate header and navigation sidebar:
* **Global Header:** Displays the enterprise brand (`CorpLab Nexus`), active platform breadcrumb, live system clock, environment status indicator, and an interactive Role Switcher dropdown.
* **Quick Metric Cards:** Four top-level metric counters summarize key operational indicators: Total Machines (14), Available Nodes (6), Active Trainees (20), and Course Materials (10).
* **Sidebar Utilization Widget:** An aggregate cluster utilization gauge tracks total allocated memory (768 / 1152 GB RAM, 68%) and processor allocation across all data center zones.

### 4.2 Compute Nodes Management & Telemetry
The core infrastructure view provides a detailed operational inventory of all 14 corporate compute nodes across three facilities:
* **Hardware Telemetry:** Displays node identifiers (`SRV-K8S-M01`, `GPU-AI-NODE01`), operating system tags (Ubuntu 22.04 LTS, Rocky Linux 9.3, Windows Server 2022), static IP addresses, vCPU core counts, and dynamic RAM usage bars.
* **Status Badging:** Visual color-coded indicators highlight nodes as `Available` (green), `Maintenance` (amber), or `Retired` (red).
* **Multi-Criteria Filtering & Search:** Instant browser-side filtering by operational status and lab venue, supported by a real-time keyword search bar.
* **View Modes:** Instant toggle between a visual Card Grid layout and a dense, tabular Enterprise Data Grid.
* **Interactive SSH Diagnostic Simulator:** Clicking the **SSH** diagnostic button opens an authentic terminal overlay simulating an SSH handshake, displaying target IP resolution, RSA key fingerprint verification, and live CPU load diagnostics.

### 4.3 Lab Facilities Management
A dedicated physical venue catalog models the enterprise's three primary technical centers:
* **Cloud Lab A** (Tech Tower B, Floor 4): Configured for cloud orchestration, holding 25 physical workstations and 5 dedicated server rack units.
* **AI Research Lab** (Innovation Hub, Room 302): High-density GPU research lab with 15 specialized machine learning workstations and dedicated cooling.
* **Dev Lab B** (Engineering Wing, Floor 2): General software engineering laboratory holding 30 developer terminals.

### 4.4 Course Curriculum & Technical Resources
The training module manages 8 corporate learning tracks (including *Kubernetes Container Orchestration*, *Deep Learning with PyTorch*, *Zero Trust Cyber Defense*, and *Enterprise Spring Boot 3*):
* Displays assigned trainers, scheduled dates, course status badges (`ONGOING`, `OPEN`, `COMPLETED`), and enrolled batch capacities.
* Houses an integrated repository of technical resources, providing downloadable laboratory manuals (PDFs), Jupyter notebook exercises, and Git repository references.

### 4.5 Training Sessions Daily Schedule
A comprehensive calendar schedule displays 27 classroom and laboratory training sessions scheduled across Q4 2026. Each session record maps the parent course track, session topic, assigned trainer, room venue, and precise 24-hour time slots (e.g., 09:00:00 to 13:00:00).

### 4.6 Lab Reservations & Booking Workflow
The reservation module provides visibility into 22 compute node booking records tracking through standard enterprise lifecycle states: `APPROVED`, `PENDING`, `REJECTED`, `CANCELLED`, and `COMPLETED`:
* **Interactive Booking Modal:** Clicking **Schedule Reservation** opens a modal form allowing users to select an available compute node, choose a reservation date, specify start/end hours, and state business justification.
* **Client-Side Validation & Feedback:** The reservation workflow validates that requested end times exceed start times, immediately updates the UI counter, and fires a non-intrusive toast notification confirming submission.

### 4.7 Department Compliance & Analytics
The reporting section provides graphical analytics on departmental training compliance across corporate divisions:
* Graduate Engineering: 95.0% compliance
* Cloud & DevOps: 92.5% compliance
* Data Science & AI: 90.0% compliance
* IT Infrastructure: 85.0% compliance
* Finance & Operations: 82.0% compliance

### 4.8 Role-Based Perspective Switching
To demonstrate multi-persona workflows, the header includes an instant role switcher supporting:
* **Rahul Sharma (Trainee):** Focuses on course materials, personal bookings, and node availability.
* **David Kumar (Trainer):** Focuses on session agendas, lab venues, and trainee attendance.
* **Sarah Jenkins (Lab Administrator):** Focuses on node maintenance, approval queues, and utilization metrics.

### 4.9 Database Implementation
The MySQL database `corporate_training_lab_db` has been structured, created, and populated in XAMPP:
* 10 normalized tables established with foreign key constraints (`ON DELETE RESTRICT`) and check constraints.
* Comprehensive seed dataset including 25 users, 8 courses, 3 facilities, 14 machines, 27 sessions, 44 enrollments, 24 attendance records, 11 feedback ratings, 22 bookings, and 16 notifications.
* Standardized 60-character BCrypt password hashing applied to all seed accounts for the credential `Admin@123`.

---

## 5. Technology Stack

| Technology Layer | Tool / Framework | Technical Justification |
| :--- | :--- | :--- |
| **User Interface (Markup)** | **HTML5** | Semantic, accessible layout including modal dialogs, data tables, and input forms without external library overhead. |
| **Styling & Presentation** | **CSS3** | Modern dark-slate corporate aesthetics, responsive CSS Grid and Flexbox layouts, animated RAM meters, and custom typography (*Plus Jakarta Sans* and *JetBrains Mono*). |
| **Client-Side Logic** | **Vanilla JavaScript (ES6+)** | High-performance DOM manipulation, event handling, real-time catalog filtering, state simulation, and terminal rendering without heavyweight runtime dependencies. |
| **Relational Database** | **MySQL 8.0 (InnoDB via XAMPP)** | ACID-compliant storage engine, strict foreign key enforcement, native `CHECK` constraints, and index optimization. |
| **Credential Security** | **Spring Security BCrypt** | 60-character cryptographic hashing (`$2a$10$...`) with internal 128-bit random salt, ensuring zero plaintext password persistence. |
| **Planned Backend Service** | **Java 17 & Spring Boot 3.x** | Enterprise middle tier offering Spring Data JPA, HikariCP connection pooling, RESTful controllers, and Spring Security JWT filters (Phase 2). |

---

## 6. Project Folder Structure

The project repository is organized into distinct functional layers to ensure complete separation between documentation, client assets, database scripts, and future backend source code:

```text
Corporate Training Resource & Lab Infrastructure Management Platform/
├── docs/                                  # Comprehensive technical reports, presentation guides, and requirements
│   ├── guide-presentation-cheatsheet.md  # Viva voce oral defense Q&A preparation script
│   ├── project-overview.md                # System requirements specification & architectural overview
│   ├── PROJECT_DOCUMENTATION.html         # High-resolution, printable HTML documentation report
│   ├── PROJECT_DOCUMENTATION.md           # Master academic project documentation (this document)
│   └── PROJECT_DOCUMENTATION_REPORT.md    # Consolidated submission report
├── frontend/                              # Client-side user interface application
│   ├── css/
│   │   └── style.css                      # Enterprise dark-slate theme, typography, badges, and layout grid
│   ├── js/
│   │   └── app.js                         # Application state, catalog filters, terminal simulator, and reservation logic
│   └── index.html                         # Primary dashboard console containing all 6 functional views
├── db/                                    # Enterprise database migrations, seed data, and analytical scripts
│   ├── complete_database_setup.sql        # All-in-one idempotent schema creation and seed script (10 tables)
│   ├── 01_migration.sql                   # 3NF relational schema migration script
│   ├── 02_seed_data.sql                   # Realistic 2026 enterprise seed data script
│   └── 03_queries.sql                     # Analytical reports, KPI aggregation, and conflict detection queries
├── backend/                               # Java Spring Boot application (Scheduled for Phase 2)
│   └── README.md                          # Backend architecture, JPA entity plan, and REST API specification
└── README.md                              # Root repository overview and setup instructions
```

---

## 7. Functional Requirements and Current Status

| Requirement ID | Module / Feature | Detailed Description | Implementation Status |
| :--- | :--- | :--- | :--- |
| **FR-01** | **Executive Dashboard** | Top navigation bar with breadcrumbs, environment status, metric cards, and memory allocation gauge. | **Frontend Created** |
| **FR-02** | **Compute Fleet Monitoring**| Inventory of 14 machines with IP addresses, OS tags, vCPU counts, and dynamic RAM telemetry meters. | **Frontend Created** |
| **FR-03** | **Hardware Status Filtering** | Instant client-side filtering by operational state (`Available`, `Maintenance`, `Retired`). | **Frontend Created** |
| **FR-04** | **Venue Filtering & Search** | Dropdown filtering by physical lab room (`Cloud Lab A`, `AI Lab`) and keyword search. | **Frontend Created** |
| **FR-05** | **Layout Toggle** | Seamless toggling between visual Card Grid View and dense Enterprise Table View. | **Frontend Created** |
| **FR-06** | **SSH Terminal Simulator** | Interactive dark terminal overlay showing IP handshake, RSA key verification, and live diagnostics. | **Frontend Created** |
| **FR-07** | **Lab Facilities Catalog** | Physical venue directory presenting room numbers, seating capacity, and cluster density. | **Frontend Created** |
| **FR-08** | **Course Curriculum Module** | 8 enterprise training tracks with instructor assignments, timelines, and downloadable lab assets. | **Frontend Created** |
| **FR-09** | **Daily Session Schedule** | Daily timetable mapping 27 classroom slots across courses, instructors, rooms, and time windows. | **Frontend Created** |
| **FR-10** | **Lab Reservation Engine** | Interactive modal to book available compute machines with start/end time validation. | **Frontend Created** |
| **FR-11** | **Reservation Status Audit** | Booking ledger tracking 22 reservations across `APPROVED`, `PENDING`, `REJECTED`, etc. | **Frontend Created** |
| **FR-12** | **Department Compliance** | Visual progress analytics displaying attendance compliance rates across 5 corporate divisions. | **Frontend Created** |
| **FR-13** | **Multi-Role Switcher** | Header switcher allowing instant demonstration of Trainee, Trainer, and Admin perspectives. | **Prototype Demo** |
| **FR-14** | **Relational Schema** | 10 normalized 3NF tables with foreign keys and check constraints deployed in XAMPP MySQL. | **Database Prepared** |
| **FR-15** | **Spring Boot REST API** | Middle-tier service exposing endpoints (`/api/machines`, `/api/bookings`) via Spring Data JPA. | **Pending Phase 2** |
| **FR-16** | **Server-Side Security** | Spring Security 6.x implementation with stateless JWT authentication and role-based permissions. | **Pending Phase 2** |

---

## 8. Database Status

**Database Identifier:** `corporate_training_lab_db`  
**Host Environment:** MySQL 8.0+ running under XAMPP on `localhost:3306`  
**Storage Engine & Encoding:** InnoDB / `utf8mb4_unicode_ci`  

The database has been fully structured, normalized to **Third Normal Form (3NF)**, and populated using [`db/complete_database_setup.sql`](file:///c:/Corparate%20training%20resource%20&%20lab%20infrastructure%20management%20system/db/complete_database_setup.sql).

### Table Schema Summary

| Table Name | Primary Key | Foreign Keys & References | Records Seeded | Primary Purpose |
| :--- | :--- | :--- | :---: | :--- |
| **`departments`** | `id` | None | 6 | Corporate organizational divisions (IT, Cloud, AI, Engineering, HR, Finance). |
| **`users`** | `id` | `department_id` &rarr; `departments(id)` | 25 | Enterprise accounts (1 Admin, 4 Trainers, 20 Trainees) with BCrypt hashes. |
| **`labs`** | `id` | None | 3 | Physical corporate facility locations, room numbers, and workstation capacities. |
| **`lab_machines`** | `id` | `lab_id` &rarr; `labs(id)` | 14 | Physical & virtual compute nodes with RAM, vCPU, OS, IP, and status flags. |
| **`training_courses`** | `id` | `trainer_id` &rarr; `users(id)` | 8 | Corporate training curricula, course codes, duration, and status. |
| **`course_materials`** | `id` | `course_id` &rarr; `training_courses(id)` | 10 | Technical reference resources (PDF lab guides, notebooks, code repos). |
| **`training_sessions`**| `id` | `course_id`, `trainer_id`, `lab_id` | 27 | Daily classroom lectures with `CHECK (end_time > start_time)` constraints. |
| **`enrollments`** | `id` | `user_id` &rarr; `users(id)`, `course_id` | 44 | Trainee registrations tracking progress percentages ($0-100\%$). |
| **`attendance`** | `id` | `session_id`, `user_id`, `marked_by` | 24 | Classroom presence audit logs (`PRESENT`, `ABSENT`, `LATE`, `EXCUSED`). |
| **`feedback`** | `id` | `course_id`, `user_id` &rarr; `users(id)` | 11 | Post-training trainee evaluations and ratings ($1-5$). |
| **`lab_bookings`** | `id` | `user_id`, `machine_id`, `approved_by` | 22 | Compute reservation records with audit timestamps and review remarks. |
| **`notifications`** | `id` | `user_id` &rarr; `users(id)` | 16 | System dispatch notifications and booking status alert messages. |

### Security & Password Storage
All user credentials in the database are hashed using the **Spring Security BCrypt Password Encoder** algorithm with a work factor of 10 (`$2a$10$...`). Plaintext passwords are never recorded in schema scripts or table rows.

* **Sample Seed Password:** `Admin@123`
* **Stored Ciphertext Digest:** `$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy` (verified 60 characters)

---

## 9. Current Limitations

1. **Client-Side Simulation:** The frontend currently utilizes an in-memory JavaScript state model mirroring the database schema. Client interactions (such as submitting reservations) update local browser state and toast alerts, but do not directly persist to MySQL without a backend server.
2. **Stateless Authentication:** The role selector provides multi-persona demonstration without cryptographic session management, JWT tokens, or HTTP-only cookies.
3. **Database Connectivity:** Direct browser-to-MySQL communication is intentionally excluded due to standard enterprise security policies prohibiting direct database exposure to client browsers.
4. **Mocked Terminal Diagnostics:** The interactive SSH console simulates server handshakes and diagnostic telemetry in JavaScript rather than executing live network sockets against physical hardware.
5. **Simulated File Downloads:** Resource download links initiate simulated browser download actions rather than streaming binary objects from a cloud storage service (e.g., AWS S3).

---

## 10. Future Enhancements (Phase 2 Development)

1. **Java Spring Boot 3 Backend Microservice:**
   * Develop a lightweight, high-performance REST API backend using Java 17 and Spring Boot 3.x.
   * Implement Spring Data JPA repositories with Hibernate ORM to automatically map Java objects to the 10 MySQL tables.
2. **Spring Security & Stateless JWT Authentication:**
   * Replace client-side role toggling with a secure `/api/auth/login` endpoint issuing signed JSON Web Tokens (JWT).
   * Enforce Role-Based Access Control (RBAC) across API routes using `@PreAuthorize("hasRole('ADMIN')")`.
3. **Automated Conflict-Detection Engine:**
   * Implement a backend scheduling validator utilizing the standard interval overlap formula:
     $$\text{Conflict} \iff (\text{ExistingStart} < \text{RequestedEnd}) \land (\text{ExistingEnd} > \text{RequestedStart})$$
   * Automatically reject overlapping reservation requests at the API layer before database write attempts.
4. **Asynchronous REST Integration:**
   * Upgrade frontend `app.js` methods to replace mock records with asynchronous `fetch()` API calls against backend REST endpoints.
5. **Automated Notification Dispatch:**
   * Implement email alerts (via Spring Mail / SMTP) notifying trainees when administrators approve or reject lab reservations.
6. **Automated Testing Suite:**
   * Implement automated unit and integration tests using JUnit 5 and Mockito, targeting $\ge 85\%$ code coverage across all controller and service classes.

---

## 11. System Testing Plan

The following test suite verifies user interface interactions, data validation, and database integrity.

| Test Case ID | Test Objective | Procedure / Input Action | Expected Operational Result | Verification Status |
| :--- | :--- | :--- | :--- | :---: |
| **TC-01** | **Interface Initialization** | Open `frontend/index.html` in Chrome/Edge. | Application loads cleanly with corporate styling, active metric cards, and zero console errors. | **Pass** |
| **TC-02** | **Status Filter Validation** | Click the **Available** filter button on the Compute Nodes tab. | The grid updates instantly to display only the 6 nodes currently in `AVAILABLE` state. | **Pass** |
| **TC-03** | **Venue Filter Validation** | Select **AI Research Lab** from the lab facility dropdown. | The grid updates to display only the GPU nodes located in Room 302. | **Pass** |
| **TC-04** | **Layout Switching** | Click the **Table View** icon in the action bar. | Machine display transforms from card layout to dense tabular view without data loss. | **Pass** |
| **TC-05** | **SSH Terminal Handshake** | Click the **SSH** diagnostic button on node `SRV-K8S-M01`. | Dark diagnostic terminal overlay launches, displays IP resolution, RSA handshake, and CPU metrics. | **Pass** |
| **TC-06** | **Reservation Modal Submission**| Click **Schedule Reservation**, select an available machine, specify hours, and submit. | Modal validates time interval, updates available machine count, and triggers green toast notification. | **Pass** |
| **TC-07** | **Multi-Role Switching** | Change the top header role selector from Trainee to Admin. | System switches active user to `Sarah Jenkins`, displays administrator perspective, and fires alert. | **Pass** |
| **TC-08** | **Live Search Functionality** | Enter `"Ubuntu"` into the search bar. | Node catalog filters in real time to show only machines executing the Ubuntu OS. | **Pass** |
| **TC-09** | **Database Schema Integrity** | Inspect `corporate_training_lab_db` in phpMyAdmin. | All 10 tables exist with correct foreign keys, indexes, and InnoDB engine specifications. | **Pass** |
| **TC-10** | **Seed Data Verification** | Execute `SELECT COUNT(*) FROM lab_machines;` in MySQL. | Query returns exactly 14 records matching the operational hardware fleet. | **Pass** |
| **TC-11** | **Backend REST Connection** | Dispatch `GET /api/machines` from client application. | Server responds with JSON payload of live machines from MySQL database. | *Pending Phase 2* |

---

## 12. Conclusion

The **CorpLab Nexus** project has successfully fulfilled all foundational requirements for Phase 1. 

The client-side operational console provides an executive, highly polished user experience tailored to the distinct operational needs of Trainees, Instructors, and System Administrators. Hardware telemetry, status filtering, diagnostic simulation, curriculum indexing, daily session tracking, and reservation workflows are fully demonstrated. Concurrently, the persistence tier has been designed and realized as a 10-table, Third Normal Form (3NF) relational database in MySQL 8.0, complete with referential integrity, check constraints, realistic seed data, and cryptographic BCrypt security.

With the presentation layer and data layer fully established and verified, the project is architecturally poised for Phase 2: the implementation of the Java Spring Boot REST microservice to bridge client-side interactions directly with persistent enterprise database storage.

---

### Appendix A — Academic Note on 3-Tier Enterprise Separation

In enterprise web engineering, web browsers are strictly isolated from direct database interaction. Client-side web browsers execute code in an untrusted end-user environment. Connecting a browser directly to a database server would expose database credentials, bypass business validation logic, and expose the persistence tier to unauthorized data tampering and SQL injection vulnerabilities.

Therefore, CorpLab Nexus adheres strictly to the **3-Tier Enterprise Architecture**:
1. **Tier 1 (Presentation):** HTML5 / CSS3 / Vanilla JavaScript running securely in the client browser.
2. **Tier 2 (Application / Business Logic):** Java Spring Boot REST API executing on the application server (Phase 2).
3. **Tier 3 (Data Persistence):** MySQL 8.0 relational database operating behind a secure internal firewall.

The current implementation successfully validates Tier 1 and Tier 3 in parallel, establishing a clean foundation for final full-stack integration.
