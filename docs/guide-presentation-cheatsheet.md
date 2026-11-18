# Guide Presentation Cheatsheet
**Project:** Corporate Training Resource & Lab Infrastructure Management Platform

---

## 🎯 1. The 30-Second Opening Pitch
When your guide asks: *"Show me what you have done and explain your project."*

> "Ma'am/Sir, I am building the **Corporate Training Resource & Lab Infrastructure Management Platform**. 
> 
> In enterprise environments, companies face two key challenges:
> 1. Managing technical training courses, study materials, and daily classroom sessions across departments.
> 2. Managing expensive physical and virtual lab compute resources (like GPU servers and Linux nodes) so trainees can schedule and reserve machines without schedule conflicts.
> 
> As of today, I have built:
> 1. The **relational database schema in MySQL using XAMPP**, with normalized tables for users, departments, courses, course materials, lab facilities, compute nodes, and reservations.
> 2. The **Frontend UI/UX portal using HTML5, CSS3, and JavaScript**, featuring real-time infrastructure monitoring, search filtering, and reservation workflows."

---

## 🗄️ 2. Explaining the Database (MySQL in XAMPP)

### Q: "How did you create the database?"
> "I used **XAMPP**'s MySQL service and managed it through **phpMyAdmin**:
> 1. In the XAMPP Control Panel, I started the **Apache** and **MySQL** services.
> 2. I opened `http://localhost/phpmyadmin` in my browser.
> 3. I selected the database `corporate_training_lab_db`.
> 4. I executed our SQL scripts (`01_migration.sql` and `02_seed_data.sql`), which created normalized tables with primary keys, foreign keys, and realistic seed data."

---

### Q: "Explain your tables and their relationships."

Open **phpMyAdmin** and point to the tables:

1. **`users` Table:** Stores user profiles (Trainees, Trainers, Admins) linked to `departments`.
2. **`departments` Table:** Corporate divisions (Cloud & DevOps, Data Science, HR, Finance).
3. **`training_courses` Table:** Training tracks (Kubernetes, Deep Learning, Zero Trust Security).
4. **`course_materials` Table:** PDFs, Lab Manuals, and Repositories attached to courses.
5. **`labs` Table:** Physical venues and facilities (Cloud Lab A, AI Research Lab, Dev Lab B).
6. **`lab_machines` Table:** Hardware nodes, IP addresses, OS, RAM, vCPU, and status (`AVAILABLE`, `MAINTENANCE`, `RETIRED`).
7. **`training_sessions` Table:** Daily scheduled classes with assigned trainer, lab venue, and time window.
8. **`enrollments` Table:** Trainee registrations with progress tracking.
9. **`attendance` Table:** Daily presence tracking (`PRESENT`, `ABSENT`, `LATE`, `EXCUSED`).
10. **`lab_bookings` Table:** Machine reservations with approval workflow (`PENDING`, `APPROVED`, `REJECTED`).

---

### Q: "What is a Primary Key and Foreign Key in your schema?"
> - "A **Primary Key (PK)** uniquely identifies each individual record in a table. For example, `id` in `lab_machines`.
> - A **Foreign Key (FK)** creates a relational link between two tables. For example, in `lab_machines`, `lab_id` connects each machine to its physical room in `labs`."

---

## 💻 3. Explaining How the Database Links to Frontend and Backend

### Q: "How is the frontend linked to the database? Does HTML talk to MySQL?"
> "No, ma'am/sir. In industry-standard web engineering, frontend HTML/JavaScript should **never connect directly** to a database because that would expose database passwords and create major security vulnerabilities.
> 
> We follow the **3-Tier Architecture**:
> 
> 1. **Tier 1 - Presentation Layer (Frontend):** HTML, CSS, and JavaScript run in the user's browser. When a user clicks 'Reserve Node', JavaScript makes an asynchronous `fetch()` API request sending JSON data.
> 2. **Tier 2 - Application / Logic Layer (Backend - Java Spring Boot):** 
>    - Spring Boot exposes REST API controllers (e.g., `@PostMapping("/api/bookings")`).
>    - It verifies if the requested machine is free.
>    - It uses Spring Data JPA / JDBC to communicate securely with the database.
> 3. **Tier 3 - Data Layer (MySQL Database):** MySQL in XAMPP executes the SQL queries and stores the data securely."

---

## 🖥️ 4. Demonstrating the Frontend UI/UX

1. Open `frontend/index.html` in Google Chrome or Microsoft Edge.
2. Show the **Header & Metric Cards**: Total Nodes (14), Available (11), Enrolled Trainees (20), Sessions (27).
3. Demonstrate **Live Search & Filter**:
   - Filter by status (`Available`, `Maintenance`, `Retired`).
   - Filter by Lab Location (`Cloud Lab A`, `AI Research Lab`, `Dev Lab B`).
   - Toggle between **Grid View** and **Table View**.
4. Click the **"SSH"** button on any compute card to show the live diagnostics terminal simulator.
5. Demonstrate the **Booking Workflow**:
   - Click **"Reserve Node"**, fill in a purpose, and click **"Confirm & Submit Request"**.
   - Show the toast notification and the new reservation in the **Lab Reservations** table.
6. Show the **Lab Facilities** and **Training Sessions** schedule tabs.
7. Show the **Analytics & Metrics** tab displaying department compliance rates.
