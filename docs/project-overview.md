# Project Overview & Requirements Specification

## 1. Problem Statement
In corporate organizations, continuous training is essential to upskill engineering and data science teams. However, organizations struggle with two major logistical bottlenecks:
1. **Resource Disorganization:** Study materials, lab exercises, architecture diagrams, and repositories are scattered across different emails, drives, and wikis.
2. **Infrastructure Contention:** High-performance lab environments (GPU nodes for Deep Learning, Kubernetes clusters, Windows development servers) are scarce and expensive. Multiple teams schedule sessions simultaneously, causing conflicting bookings and uncoordinated downtime.

## 2. System Objectives
* Provide a single, centralized web dashboard for trainees, trainers, and administrators.
* Maintain a real-time catalog of compute machines, their hardware specs, IP addresses, and current status (`AVAILABLE`, `IN_USE`, `MAINTENANCE`).
* Provide conflict-free scheduling and slot reservations for lab infrastructure.
* Organize training course syllabi and link downloadable lab guides and starter repositories.

## 3. User Roles & Permissions
* **Admin:** Adds new lab hardware, assigns trainers to courses, monitors maintenance schedules.
* **Trainer:** Creates courses, uploads training documents/manuals, views enrolled trainees and lab schedules.
* **Trainee:** Browses active training courses, accesses study resources, and reserves available lab machines for practice sessions.

## 4. Technical Architecture
* **Frontend:** HTML5, CSS3, JavaScript (DOM Manipulation, Responsive Design).
* **Database:** MySQL on XAMPP (Relational schema, 3rd Normal Form, Foreign Key constraints).
* **Backend (Future Phase):** Java & Spring Boot (REST API microservice architecture).
