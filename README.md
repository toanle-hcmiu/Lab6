# Student Management System - Lab 6

## Quick Setup

### 1. Prerequisites
- JDK 8+ (not JRE)
- MySQL Database
- Maven

### 2. Database Setup
```bash
mysql -u root -p < database_setup.sql
```

Or use MySQL Workbench to run `database_setup.sql`

### 3. Configure Database (if needed)
If your MySQL password is not empty, edit database credentials in:
- `src/main/java/com/student/dao/StudentDAO.java`
- `src/main/java/com/student/dao/UserDAO.java`

Default settings: username=`root`, password=`""` (empty)

### 4. Run Application
```bash
mvn clean package
mvn jetty:run
```

Access at: **http://localhost:8080**

---

## Features

### Authentication & Session Management
- ✅ User login/logout
- ✅ BCrypt password hashing
- ✅ Session management (30-minute timeout)
- ✅ Role-based access control

### Filters (Homework)
- ✅ **AuthFilter**: Protects all pages, requires login
- ✅ **AdminFilter**: Restricts admin actions to admin users
- ✅ **Role-Based UI**: Shows/hides buttons based on user role

---

## Test Credentials

**Admin** (full access):
- Username: `admin`
- Password: `password123`

**Regular User** (view only):
- Username: `john`
- Password: `password123`

---

## Project Structure
```
src/main/java/com/student/
├── controller/          # Servlets
├── dao/                 # Database access
├── model/               # Java beans
├── filter/              # Auth & Admin filters (NEW)
└── util/                # Utilities

src/main/webapp/views/   # JSP pages
```

---

## Documentation

**Detailed Report**: See `report.md` for complete implementation details and explanations.

---

## Lab Completion

- ✅ In-class exercises (60 pts)
- ✅ Homework exercises (40 pts)
  - Exercise 5: AuthFilter (12 pts)
  - Exercise 6: AdminFilter (10 pts)
  - Exercise 7: Role-Based UI (10 pts)
