# CorpLab Nexus | Corporate Training Resource & Lab Infrastructure Management Platform

[![Java 17](https://img.shields.io/badge/Java-17-orange.svg?logo=openjdk&logoColor=white)](https://openjdk.org/)
[![Spring Boot](https://img.shields.io/badge/Spring_Boot-3.2.5-brightgreen.svg?logo=springboot&logoColor=white)](https://spring.io/projects/spring-boot)
[![Spring Security](https://img.shields.io/badge/Spring_Security-6.2.4-green.svg?logo=springsecurity&logoColor=white)](https://spring.io/projects/spring-security)
[![MySQL 8.0](https://img.shields.io/badge/MySQL-8.0_(XAMPP)-blue.svg?logo=mysql&logoColor=white)](https://www.mysql.com/)
[![REST API](https://img.shields.io/badge/Architecture-RESTful_APIs-blueviolet.svg)](#api-endpoints)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Build-Passing-success.svg)](#)

> **CorpLab Nexus** is an enterprise-grade full-stack platform engineered to orchestrate corporate workforce upskilling, track cohort syllabi, manage physical/cloud computer laboratories, and schedule high-demand compute resources (GPU clusters, Kubernetes nodes, database instances) with real-time institutional oversight.

---

## 🌟 Key Platform Capabilities

### 1. Multi-Role Enterprise Portals
- 🏢 **Company Executive / System Administrator Portal:**
  - Complete operational authority over employees, certified trainers, course catalogs, and laboratory facilities.
  - Dedicated request approval matrix with automated conflict detection.
  - Institutional analytics: cohort completion velocity, lab utilization rates, hardware asset health.
- 👨‍🏫 **Trainer & Faculty Management Console:**
  - Curriculum orchestration and dynamic syllabus module updates.
  - Active cohort assignment tracking and student lab grading roster.
  - Real-time audit telemetry emitted to the Company Executive console upon every syllabus modification.
- 🎓 **Student & Trainee Learning Hub:**
  - Enrolled course catalog with dynamic progress bars and instant syllabus specification (PDF) downloads.
  - Self-service compute slot booking for hands-on assignments (NVIDIA RTX 4090 Rigs, Kubernetes nodes).
  - One-click slot release and lab access telemetry.

### 2. Modern Authentication & Google OAuth2 Integration
- **Google Identity Services (Gmail):** One-click authenticated sign-in with pre-configured student, faculty, and executive profiles or custom `@gmail.com` accounts.
- **Enterprise RBAC:** Role-Based Access Control enforcing strict separation between `ADMIN`, `TRAINER`, and `EMPLOYEE` privileges.
- **Dynamic Security Recovery:** Integrated password recovery generator producing cryptographically simulated reset tokens.

### 3. Real-Time Institutional Oversight & Telemetry Engine
- **Live Notification Bell & Unread Counter:** Displays categorized platform events (`[STUDENT]`, `[TEACHER]`, `[COMPANY]`).
- **Animated Toast Cards:** Instant visual alerts on the top-right corner whenever a trainee reserves hardware or a teacher updates a curriculum track.
- **Audit Logging Stream:** Chronological event history logging actor identities, action types, and execution timestamps.

### 4. Dual-Engine Architecture (Viva-Safe Guarantee)
- **Engine 1 (Live Spring Boot + MySQL):** Full RESTful API integration against Spring Boot running on port `8085` and MySQL running in XAMPP on port `3307`.
- **Engine 2 (Reactive Client Store):** Seamless offline fail-safe store in `localStorage`/`sessionStorage` ensuring that the UI, filters, modals, and telemetry continue executing smoothly during demonstrations even if backend services are offline.

---

## 🏗️ Architectural Topology

```text
+-----------------------------------------------------------------------------------+
|                        PRESENTATION LAYER (FRONTEND)                              |
|  HTML5  •  CSS3 (Midnight Slate Design System)  •  Vanilla ES6+ Reactive Client   |
|  • Student Learning Hub    • Trainer Syllabus Console   • Executive Dashboard     |
+-----------------------------------------+-----------------------------------------+
                                          |
                                          | JSON over HTTP / REST (Fetch API)
                                          v
+-----------------------------------------------------------------------------------+
|                        APPLICATION LAYER (SPRING BOOT)                            |
|  Java 17  •  Spring Boot 3.2.5  •  Spring Data JPA  •  Spring Security 6          |
|  • Port: 8085 (Configured in application.properties)                              |
|  • Controllers: Auth, Employee, Trainer, Program, Lab, Resource, Request, Reports  |
+-----------------------------------------+-----------------------------------------+
                                          |
                                          | JDBC Driver / HikariCP Pool
                                          v
+-----------------------------------------------------------------------------------+
|                        PERSISTENCE LAYER (DATABASE)                               |
|  MySQL 8.0 running inside XAMPP (Port 3307)                                       |
|  • Database: corplab_enterprise_db                                                |
|  • Tables: users, employees, trainers, training_programs, labs, resources, ...    |
+-----------------------------------------------------------------------------------+
```

---

## 🚀 Quick Start Guide

### Prerequisites
- **Java Development Kit (JDK 17 or higher)**
- **Apache Maven 3.8+**
- **XAMPP Control Panel** (Apache + MySQL running on port `3307`)
- Modern web browser (Chrome, Edge, Firefox, Brave)

---

### Step 1: Initialize Database in XAMPP
1. Open **XAMPP Control Panel** and start **MySQL** (listening on port `3307`).
2. Open your web browser and navigate to:
   ```text
   http://localhost/phpmyadmin
   ```
3. Create a new database named:
   ```sql
   CREATE DATABASE corplab_enterprise_db;
   ```
4. Import the provided schema files located in the `db/` folder:
   - `01_migration.sql` (Schema and tables)
   - `02_seed_data.sql` (Default users, employees, trainers, and resources)

---

### Step 2: Run Spring Boot Backend
1. Open the project in your IDE (IntelliJ IDEA, Eclipse, or VS Code).
2. Verify [`backend/src/main/resources/application.properties`](backend/src/main/resources/application.properties):
   ```properties
   server.port=8085
   spring.datasource.url=jdbc:mysql://localhost:3307/corplab_enterprise_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
   spring.datasource.username=root
   spring.datasource.password=
   spring.jpa.hibernate.ddl-auto=update
   ```
3. Run `PlatformApplication.java` or execute Maven from terminal:
   ```bash
   cd backend
   mvn clean spring-boot:run
   ```
4. Verify the backend is active at:
   ```text
   http://localhost:8085/
   ```

---

### Step 3: Launch Frontend Console
Open your browser and navigate to either:
- **Via Spring Boot Server:** `http://localhost:8085/login.html`
- **Or Direct Client:** Double-click [`frontend/login.html`](frontend/login.html) in your file explorer.

---

## 🔑 Pre-Configured Demo Credentials

| Role | Username / Corporate Email | Password | Google One-Click Profile |
| :--- | :--- | :--- | :--- |
| **Company Administrator** | `admin` / `admin@corplab.com` | `Admin@123` *(or `veda`)* | Operations Lead (`admin@corplab.com`) |
| **Faculty / Trainer** | `david.k` / `david.kumar@corplab.com` | `Trainer@123` *(or `veda`)* | Prof. David Kumar (`david.kumar@gmail.com`) |
| **Student / Trainee** | `rahul.s` / `rahul.sharma@corplab.com` | `Employee@123` *(or `veda`)* | Rahul Sharma (`rahul.sharma@gmail.com`) |

> 💡 **Presentation Tip:** You can also use the **Role Perspective Selector** located at the top-right navbar inside the dashboard to switch perspectives instantly during an evaluation!

---

## 📡 REST API Specifications

The backend exposes a comprehensive set of RESTful endpoints:

### Authentication & Sessions
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/api/auth/login` | Authenticate user credentials and issue session |
| `POST` | `/api/auth/register` | Register new corporate account with RBAC role |
| `POST` | `/api/auth/logout` | Invalidate authenticated session |
| `GET` | `/api/auth/me` | Fetch active session profile |

### Core Infrastructure & Learning Resources
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET`, `POST` | `/api/employees` | Trainee directory and cohort onboarding |
| `GET`, `POST` | `/api/trainers` | Certified instructor records and domain tags |
| `GET`, `POST` | `/api/training-programs` | Corporate curriculum catalog and track schedules |
| `GET`, `POST` | `/api/labs` | Physical & virtual computer laboratories |
| `GET`, `POST` | `/api/resources` | Compute hardware assets (GPUs, servers, clusters) |
| `GET`, `POST` | `/api/resource-requests` | Self-service trainee hardware reservations |
| `PUT` | `/api/resource-requests/{id}/status` | Administrative approval or rejection (`APPROVED`, `REJECTED`) |

### Telemetry & Analytics
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/api/dashboard/overview` | Platform metric counters and live activity stream |
| `GET` | `/api/dashboard/statistics` | Monthly enrollment curve and lab load percentages |
| `GET` | `/api/reports/training` | Cohort completion velocity and attendance audit |
| `GET` | `/api/settings/logs` | Security audit trail and chronological history |

---

## 📂 Repository Directory Layout

```text
CorpLab-Nexus/
├── backend/                                # Spring Boot 3.2.5 Java 17 Application
│   ├── src/main/java/com/corplab/platform/
│   │   ├── config/                        # SecurityConfig, WebMvcConfig, PasswordEncoder
│   │   ├── controller/                    # REST API Controllers (Auth, Resource, Lab, etc.)
│   │   ├── dto/                           # Data Transfer Objects & Requests
│   │   ├── model/                         # JPA Entities (User, Employee, LabResource, etc.)
│   │   ├── repository/                    # Spring Data JPA Repositories
│   │   ├── service/                       # Business Logic Layer
│   │   └── PlatformApplication.java       # Main Spring Boot Runner
│   └── src/main/resources/
│       ├── application.properties         # MySQL connection (Port 3307), Server Port (8085)
│       └── static/                        # Synchronized production web assets
├── frontend/                               # Interactive Web Client
│   ├── css/
│   │   └── app.css                        # Midnight Slate Enterprise Design System
│   ├── js/
│   │   ├── auth.js                        # Authentication, Google OAuth modal, dual-engine logic
│   │   └── dashboard.js                   # Master dashboard logic, telemetry, role switching
│   ├── login.html                         # Unified login & registration interface
│   └── dashboard.html                     # Multi-role executive console
├── db/                                     # Database DDL & Seed Scripts
│   ├── 01_migration.sql                   # 10 normalized relational tables
│   ├── 02_seed_data.sql                   # Comprehensive 2026 enterprise seed data
│   └── user_management_setup.sql          # Dedicated user authentication schema
├── docs/                                   # Architectural defense guides & presentations
│   └── PROJECT_PRESENTATION_MASTER_GUIDE.md # Viva defense script & technical Q&A
├── .gitignore                             # Standard Java, Maven, IDE, and OS ignore rules
├── pom.xml                                # Project Object Model configuration
└── README.md                              # Repository overview and documentation
```

---

## 🛡️ License & Academic Declaration

Developed as an academic and enterprise corporate training management project. Distributed under the **MIT License**. Free for educational, evaluation, and commercial exploration.
