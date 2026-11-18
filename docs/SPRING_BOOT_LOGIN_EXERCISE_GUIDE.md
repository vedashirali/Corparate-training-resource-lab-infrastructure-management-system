# Lab Exercise Guide: Spring Boot User Login API & Dashboard Navigation

**Assignment Title:** User Login and Dashboard Navigation  
**Technology Stack:** Java 17+, Spring Boot 3.x, MySQL 8.0 (XAMPP), REST APIs, HTML5, CSS3, JavaScript  
**Target Score:** 100 / 100 Marks  

---

## 🎯 Evaluation Rubric Coverage (100 Marks)

| Evaluation Criteria | Marks | What Was Built in Your Project |
| :--- | :---: | :--- |
| **Database & Entity Creation** | **10** | `db/user_management_setup.sql` + `User.java` with `@Entity`, `@Table`, `@Id`, getters/setters. |
| **Repository & Service Implementation** | **20** | `UserRepository.java` with `findByUsernameOrEmail` + `UserService.java` with BCrypt matching. |
| **Login REST API** | **20** | `AuthController.java` with `POST /api/auth/login` and `DashboardController.java` with `GET /api/dashboard`. |
| **Frontend Login Page** | **15** | `frontend/login.html` with username/email & password inputs, login button, and error container. |
| **Dashboard Navigation** | **15** | `frontend/dashboard.html` with welcome banner, User ID, Email, Role, and Logout navigation. |
| **Error Handling & Validation** | **10** | `@NotBlank` annotations on `LoginRequest` + `@RestControllerAdvice` in `GlobalExceptionHandler.java`. |
| **Code Structure & Best Practices** | **10** | Clean package layering (`entity`, `repository`, `service`, `controller`, `dto`, `exception`, `config`). |
| **TOTAL** | **100** | **Complete Full-Score Implementation** |

---

## 🚀 Step-by-Step Execution Guide

### Step 1: Set Up the Database in XAMPP (Takes 1 Minute)
1. Open **XAMPP Control Panel** and ensure **Apache** and **MySQL** are both running (green).
2. Open your browser and go to: `http://localhost/phpmyadmin`
3. Click the **SQL** tab at the top.
4. Open the script file:  
   👉 [`db/user_management_setup.sql`](file:///c:/Corparate%20training%20resource%20&%20lab%20infrastructure%20management%20system/db/user_management_setup.sql)
5. Copy all contents (`Ctrl + A`, `Ctrl + C`), paste into phpMyAdmin, and click **Go**.
6. **Result:** The `user_management` database and `users` table are created with 5 sample users:
   * `john_doe` (Admin, `john.doe@example.com`)
   * `david_kumar` (Trainer, `david.kumar@example.com`)
   * `elena_rostova` (Trainer, `elena.rostova@example.com`)
   * `rahul_sharma` (Trainee, `rahul.sharma@example.com`)
   * `priya_patel` (Trainee, `priya.patel@example.com`)
   * *Password for all 5 accounts:* **`Admin@123`** (hashed via BCrypt)

---

### Step 2: Run the Spring Boot Backend

#### Option A: Running in VS Code
1. In VS Code, open the folder: `backend/`.
2. Navigate to:  
   👉 `src/main/java/com/corplab/usermanagement/UserManagementApplication.java`
3. Click **"Run"** or press **`F5`** (or right-click &rarr; **Run Java**).
4. The console will display:
   ```text
   ============================================================
     User Management Spring Boot Backend Started Successfully! 
     Port: 8080 | Database: MySQL user_management               
     Login API: POST http://localhost:8080/api/auth/login       
   ============================================================
   ```

#### Option B: Running with Maven Terminal Command
In your PowerShell or Command Prompt, run:
```powershell
cd "c:\Corparate training resource & lab infrastructure management system\backend"
mvn spring-boot:run
```

---

### Step 3: Test Frontend in Your Browser

#### Testing Scenario 1: Successful Login
1. Open [`frontend/login.html`](file:///c:/Corparate%20training%20resource%20&%20lab%20infrastructure%20management%20system/frontend/login.html) in Chrome or Edge.
2. Enter:
   * **Username or Email:** `john_doe` (or `john.doe@example.com`)
   * **Password:** `Admin@123`
3. Click **Login**.
4. **Expected Output:**
   * Backend validates credentials using BCrypt.
   * Browser navigates to `dashboard.html`.
   * Dashboard displays:
     * **Welcome, John Doe!**
     * **User ID :** `101`
     * **Email :** `john.doe@example.com`
     * **Role :** `Admin`
     * Blue **Logout** button.

#### Testing Scenario 2: Invalid Login
1. Return to `login.html`.
2. Enter:
   * **Username or Email:** `john_doe`
   * **Password:** `WrongPassword999`
3. Click **Login**.
4. **Expected Output:**
   * Backend responds with HTTP 401 Unauthorized.
   * User remains on the login page.
   * Red error message displays: `"Invalid username/email or password."`

#### Testing Scenario 3: Unauthorized Access Protection (Challenge 4.6)
1. Close your browser tab.
2. Try opening [`frontend/dashboard.html`](file:///c:/Corparate%20training%20resource%20&%20lab%20infrastructure%20management%20system/frontend/dashboard.html) directly without logging in.
3. **Expected Output:**
   * Alert pops up: *"Access Denied! Please log in first to view the dashboard."*
   * Browser immediately redirects to `login.html`.

---

## 📬 Postman API Testing (For Your Lab Deliverables)

Your assignment asks for **"API testing screenshots from Postman"**. Here are the exact requests to test in Postman:

### 1. Successful Login Test
* **Method:** `POST`
* **URL:** `http://localhost:8080/api/auth/login`
* **Headers:** `Content-Type: application/json`
* **Body (raw JSON):**
  ```json
  {
    "usernameOrEmail": "john_doe",
    "password": "Admin@123"
  }
  ```
* **Response (HTTP 200 OK):**
  ```json
  {
    "success": true,
    "message": "Login successful! Redirecting to dashboard...",
    "user": {
      "id": 101,
      "username": "john_doe",
      "email": "john.doe@example.com",
      "role": "Admin"
    }
  }
  ```

### 2. Invalid Login Test
* **Method:** `POST`
* **URL:** `http://localhost:8080/api/auth/login`
* **Headers:** `Content-Type: application/json`
* **Body (raw JSON):**
  ```json
  {
    "usernameOrEmail": "john_doe",
    "password": "wrong_password"
  }
  ```
* **Response (HTTP 401 Unauthorized):**
  ```json
  {
    "status": 401,
    "error": "Unauthorized",
    "message": "Invalid username/email or password.",
    "success": false
  }
  ```

### 3. Protected Dashboard API Test
* **Method:** `GET`
* **URL:** `http://localhost:8080/api/dashboard`
* **Response (HTTP 200 OK when session active, or 403 Forbidden if unauthenticated)**

---

## 📸 Screenshots Checklist for Submission

| Screenshot # | What to Capture | Where to Capture |
| :---: | :--- | :--- |
| **1** | **MySQL `users` table** | phpMyAdmin &rarr; `user_management` &rarr; `users` table showing 5 rows. |
| **2** | **Successful Login Scenario** | Browser on `dashboard.html` showing "Welcome, John Doe!", ID 101, Role: Admin. |
| **3** | **Unsuccessful Login Scenario**| Browser on `login.html` showing red error "Invalid username/email or password." |
| **4** | **Postman 200 OK Response** | Postman window testing `POST /api/auth/login` with success JSON. |
| **5** | **Postman 401 Error Response** | Postman window testing `POST /api/auth/login` with 401 Unauthorized JSON. |

---

## 🎓 Viva Voce Q&A (What to Say to Your Ma'am)

### Q1: "Where is the password stored, and is it secure?"
> **Answer:** *"Ma'am, passwords are never stored in plain text. We use Spring Security's **BCryptPasswordEncoder** with 10 log rounds. In the database, the password is encrypted into a 60-character hash (`$2a$10$...`) containing a cryptographically secure random 128-bit salt."*

### Q2: "How does the backend validate that a user can login with either username or email?"
> **Answer:** *"In our `UserRepository`, we defined a JPQL query:  
> `SELECT u FROM User u WHERE u.username = :identifier OR u.email = :identifier`.  
> The service layer searches for the matching user by whichever identifier they typed, and then verifies the password against the stored BCrypt hash."*

### Q3: "How does your frontend communicate with the backend?"
> **Answer:** *"In `login.html`, our JavaScript `fetch()` sends an asynchronous `POST` request with JSON payload to `http://localhost:8080/api/auth/login`. When the backend returns HTTP 200 with `success: true`, the user profile is stored in `sessionStorage` and the browser navigates to `dashboard.html`."*

### Q4: "How do you protect the dashboard from unauthorized access?"
> **Answer:** *"We protect it on both tiers:  
> 1. On the frontend, `dashboard.html` verifies that the authentication session exists; if not, it alerts the user and redirects to `login.html`.  
> 2. On the backend, `GET /api/dashboard` checks the HTTP session; if unauthenticated, it throws `UnauthorizedException` returning HTTP 403 Forbidden via `@ControllerAdvice`."*
