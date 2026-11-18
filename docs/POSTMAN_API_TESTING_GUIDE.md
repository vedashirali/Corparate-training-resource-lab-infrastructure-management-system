# CorpLab Nexus | Master Postman API Testing & Presentation Guide
## Corporate Training Resource & Lab Infrastructure Management System

**Target Audience:** BCA Students, Faculty Project Guides, Academic Reviewers  
**Technologies Tested:** Java 17/21, Spring Boot 3.2.5, Spring Security, Spring Data JPA, MySQL 8.0  
**Collection File Location:** [`docs/postman/CorpLab_Nexus_API_Collection.postman_collection.json`](file:///c:/Corparate%20training%20resource%20&%20lab%20infrastructure%20management%20system/docs/postman/CorpLab_Nexus_API_Collection.postman_collection.json)  
**Environment File Location:** [`docs/postman/CorpLab_Local_Environment.postman_environment.json`](file:///c:/Corparate%20training%20resource%20&%20lab%20infrastructure%20management%20system/docs/postman/CorpLab_Local_Environment.postman_environment.json)

---

## 1. What is Postman and Why Did Your Guide Ask For It?

In professional enterprise development, web applications follow a **Client-Server 3-Tier Architecture**:
1. **Frontend (Presentation Tier):** HTML, CSS, JavaScript in the browser.
2. **Backend (Application Logic Tier):** Java & Spring Boot REST API service.
3. **Database (Data Persistence Tier):** MySQL.

### Why Your Guide Wants You to Use Postman:
* In industry, software engineers do **not** write frontend code first. They first build the backend REST API and thoroughly test every endpoint in **Postman**.
* **Postman** is an API testing studio that acts like a browser without the graphical user interface. It lets you send raw HTTP requests (`GET`, `POST`, `PUT`, `DELETE`), pass JSON payloads, inspect HTTP status codes (such as `200 OK` or `201 Created`), and verify that records are correctly inserted into and read from the MySQL database.
* By demonstrating your APIs in Postman to your college guide, you demonstrate:
  1. Complete mastery of **RESTful API standards**.
  2. Understanding of **HTTP methods and status codes**.
  3. Knowledge of **JSON data exchange**.
  4. Understanding of **Spring Security authentication and session cookie management**.

---

## 2. Quick 2-Minute Postman Setup

### Step A: Install Postman (If Not Already Installed)
1. Download the free desktop app from: [https://www.postman.com/downloads/](https://www.postman.com/downloads/)
2. Install and launch Postman on your Windows machine. (You can skip signing in by clicking *"Take me to the app"* or sign in with Google).

### Step B: Import the Pre-Configured CorpLab Collection (2 Clicks)
We have already packaged every single endpoint, header, URL, and sample JSON body into an official collection file right inside your project!

1. In Postman, look at the top-left corner and click the **Import** button.
2. Click **Files** (or drag and drop).
3. Browse to your project folder:
   ```text
   C:\Corparate training resource & lab infrastructure management system\docs\postman\
   ```
4. Select both files:
   * 📄 `CorpLab_Nexus_API_Collection.postman_collection.json`
   * 📄 `CorpLab_Local_Environment.postman_environment.json`
5. Click **Import**.
6. On your left sidebar in Postman, you will now see:  
   👉 **`CorpLab Nexus Enterprise REST API`**  
   Inside it are all 10 organized folders containing every API endpoint!

---

## 3. The Master Live Presentation Sequence for Your Guide

Follow this exact step-by-step presentation order when demonstrating to your guide. This sequence is designed to impress academic examiners and prove end-to-end functionality.

```
[1. Negative Security Check] ──► [2. Login & Session Creation] ──► [3. Dashboard Overview]
                                                                           │
                                                                           ▼
[6. System Audit Logs] ◄── [5. Resource Request Workflow] ◄── [4. Employee CRUD in MySQL]
```

---

### Step 1: Prove Security & Protected Route Guard (Negative Test)
*Examiners love seeing that your backend actually blocks unauthorized users!*

1. In Postman, expand folder **`2. Dashboard & Statistics`**.
2. Click on **`2.1 GET Dashboard Overview`**.
3. Click the blue **Send** button.
4. **Result:**  
   * **Status:** `401 Unauthorized`
   * **Response Body:**
     ```json
     {
       "timestamp": "2026-11-15T...",
       "status": 401,
       "error": "Unauthorized",
       "message": "Access Denied. Please log in."
     }
     ```
5. **What to Say to Your Guide:**
   > *"Ma'am/Sir, as you can see, our Spring Boot backend strictly enforces session route guards. When an unauthenticated client attempts to query dashboard metrics without a valid session, the server immediately denies access with HTTP 401 Unauthorized."*

---

### Step 2: Authenticate User via POST Login
1. In Postman, expand folder **`1. Authentication Module`**.
2. Click on **`1.1 Login (Admin)`**.
3. Notice the pre-configured request:
   * **Method:** `POST`
   * **URL:** `http://localhost:8080/api/auth/login`
   * **Body (raw JSON):**
     ```json
     {
       "usernameOrEmail": "admin",
       "password": "Admin@123"
     }
     ```
4. Click **Send**.
5. **Result:**
   * **Status:** `200 OK`
   * **Response Body:**
     ```json
     {
       "success": true,
       "message": "Login successful.",
       "user": {
         "id": 1,
         "username": "admin",
         "email": "admin@corplab.com",
         "fullName": "System Administrator",
         "role": "ADMIN",
         "department": "IT Infrastructure"
       }
     }
     ```
   * Click on the **Cookies** tab in Postman: you will see `JSESSIONID` stored automatically by Postman's built-in cookie jar!
6. **What to Say to Your Guide:**
   > *"Here we execute our login API. The backend retrieves the user from MySQL, verifies the password using the BCrypt hashing algorithm, and generates a stateful HTTP Session Cookie (JSESSIONID). Postman now holds this session cookie for subsequent protected requests."*

---

### Step 3: Verify Active Profile (GET Profile)
1. Click on **`1.2 Get Current Profile (GET Profile)`**.
2. Notice:
   * **Method:** `GET`
   * **URL:** `http://localhost:8080/api/auth/profile`
3. Click **Send**.
4. **Result:**
   * **Status:** `200 OK`
   * Returns the authenticated administrator profile, confirming the session is active.

---

### Step 4: Query Dashboard Overview & Statistics
1. Click on **`2.1 GET Dashboard Overview`**.
2. Click **Send**.
3. **Result:**
   * **Status:** `200 OK`
   * **Response Body:**
     ```json
     {
       "totalEmployees": 4,
       "totalTrainers": 3,
       "totalPrograms": 4,
       "availableLabs": 3,
       "totalResources": 4,
       "pendingRequests": 2,
       "systemStatus": "OPERATIONAL",
       "uptime": "99.98%"
     }
     ```
4. Click on **`2.2 GET Dashboard Statistics (Charts Data)`** &rarr; click **Send**:
   * Returns live numerical arrays (`labels` and `values`) used by the dashboard charts to render enrollment trends and lab utilization rates.

---

### Step 5: Test Employee Management CRUD (Database Mutation)
*This proves your backend writes directly to and reads from MySQL!*

1. Click on **`3.1 GET All Employees`** &rarr; click **Send**:
   * Returns the list of currently registered employees (`Rahul Sharma`, `Priya Patel`, `Vikram Malhotra`, `Neha Deshmukh`).
2. Click on **`3.2 POST Create New Employee`**:
   * Inspect the JSON body:
     ```json
     {
       "fullName": "Karan Johar",
       "username": "karan.j",
       "email": "karan.j@corplab.com",
       "department": "Cloud & DevOps",
       "phone": "+1-555-0145",
       "password": "Employee@123"
     }
     ```
   * Click **Send**.
   * **Status:** `201 Created`
   * Notice the newly generated ID (e.g. `5` or higher).
3. Now re-click **`3.1 GET All Employees`** &rarr; click **Send**:
   * **Boom!** You can show your guide that `"Karan Johar"` is now permanently stored in MySQL and returned by the GET API!
4. Switch to your browser tab of **phpMyAdmin** &rarr; click on `users` table &rarr; click **Refresh**:
   * Show your guide that row `Karan Johar` was physically added to the MySQL database!

---

### Step 6: Test Training Program & Lab Infrastructure APIs
1. In folder **`5. Training Program Management`**:
   * Click **`5.1 GET All Training Programs`** &rarr; click **Send** &rarr; returns course syllabi (`DEV-201`, `AI-301`, `SEC-401`, `FSJ-101`).
   * Click **`5.2 POST Create Training Program`** &rarr; click **Send** &rarr; `201 Created` (new course added).
2. In folder **`6. Lab Infrastructure Management`**:
   * Click **`6.1 GET All Labs`** &rarr; click **Send** &rarr; returns `Cloud Lab A`, `AI Research Lab`, `Dev Lab B`.
   * Click **`6.2 POST Create Laboratory`** &rarr; click **Send** &rarr; `201 Created`.

---

### Step 7: Test Resource Request Allocation Workflow
1. In folder **`8. Resource Request Management`**:
   * Click **`8.1 GET All Resource Requests`** &rarr; click **Send** &rarr; returns pending reservation requests.
   * Click **`8.2 POST Submit Resource Request`** &rarr; click **Send** &rarr; submits a new request with status `PENDING`.
   * Click **`8.3 PUT Approve or Reject Request`**:
     * **Method:** `PUT`
     * **URL:** `http://localhost:8080/api/resource-requests/1/status`
     * **Body:**
       ```json
       {
         "status": "APPROVED",
         "adminRemarks": "Approved by Lab Administrator for AI benchmark cohort"
       }
       ```
     * Click **Send** &rarr; returns `200 OK` with status updated to `APPROVED`.
2. **What to Say to Your Guide:**
   > *"This endpoint demonstrates state machine management and approval workflows in our platform. An administrator can review incoming hardware requests and transition their state from PENDING to APPROVED or REJECTED."*

---

### Step 8: Institutional Reports & Analytics
1. In folder **`9. Reports & Analytics`**:
   * Click **`9.1 GET Training Completion Report`** &rarr; click **Send** &rarr; returns pass rates and cohort breakdown.
   * Click **`9.2 GET Lab Facilities Report`** &rarr; click **Send** &rarr; returns facility utilization hours and peak usage.
   * Click **`9.3 GET Compute Resources Report`** &rarr; click **Send** &rarr; returns hardware health and allocation percentages.

---

### Step 9: Verify Real-Time System Audit Logs
1. In folder **`10. System Audit Logs`**:
   * Click **`10.1 GET System Audit Logs`** &rarr; click **Send**.
2. **Result:**  
   * The response lists every single operation you just performed in Postman with exact timestamps, actors, and descriptions:
     - `USER_LOGIN`
     - `EMPLOYEE_CREATED`
     - `PROGRAM_CREATED`
     - `REQUEST_APPROVED`
3. **What to Say to Your Guide:**
   > *"To ensure regulatory compliance and enterprise governance, every state-modifying action in the system triggers an asynchronous audit event saved to our `activity_logs` table."*

---

## 4. Viva Voce / Presentation Q&A Cheatsheet

Here are the exact questions your guide or examiner may ask you about Postman and your APIs, along with the correct answers:

| Question | Correct Technical Answer |
| :--- | :--- |
| **Q1: What is an API?** | *"An API (Application Programming Interface) is a standardized contract that allows two software systems to communicate. In our project, our Spring Boot REST API allows our HTML/JavaScript frontend to communicate with our MySQL database using JSON."* |
| **Q2: What is the difference between GET, POST, PUT, and DELETE?** | *"They are standard HTTP methods: <br>• **GET** retrieves data without modifying server state.<br>• **POST** creates a new record in the database.<br>• **PUT** updates an existing record.<br>• **DELETE** removes a record."* |
| **Q3: What HTTP status codes does your API return?** | *"• **200 OK**: Request succeeded.<br>• **201 Created**: New entity successfully inserted into MySQL.<br>• **400 Bad Request**: Validation failure (e.g. missing username or duplicate email).<br>• **401 Unauthorized**: User attempted to access protected endpoint without logging in.<br>• **404 Not Found**: Resource ID does not exist."* |
| **Q4: How does Postman authenticate without a username and password on every GET request?** | *"Upon successful login via `POST /api/auth/login`, Spring Boot issues a `Set-Cookie` header containing a `JSESSIONID`. Postman automatically captures and sends this session cookie with every subsequent request, simulating browser behavior."* |
| **Q5: Why is JSON used for API payloads?** | *"JSON (JavaScript Object Notation) is lightweight, language-agnostic, and natively parsed by both Java (via Jackson library) and modern JavaScript in web browsers."* |
| **Q6: Why are passwords not returned in GET responses?** | *"For security, our Data Transfer Objects (`UserResponse`) exclude the `passwordHash` field so that hashed credentials are never exposed over network payloads."* |
