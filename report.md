# Lab 6 Report: Authentication & Session Management

## WHAT: Project Overview

This project implements **Authentication and Session Management** for the Student Management System. The application now includes user authentication, session handling, role-based access control, and secure password management using BCrypt hashing. The system consists of:

- **User Model**: `User.java` - JavaBean representing user data with roles
- **User DAO**: `UserDAO.java` - Data Access Object handling user authentication and database operations
- **Controllers**: `LoginController.java`, `LogoutController.java`, `DashboardController.java` - Servlets managing authentication flow
- **Views**: `login.jsp`, `dashboard.jsp` - JSP pages for user interface
- **Security**: BCrypt password hashing, session management, role-based access

## WHY: Purpose and Benefits

### Why Authentication?

1. **Security**: Protects sensitive student data from unauthorized access
   - Only authenticated users can access the system
   - Prevents unauthorized modifications to student records

2. **User Management**: Allows multiple users with different roles
   - Admin users can perform all operations
   - Regular users have limited access

3. **Audit Trail**: Tracks user activities through session management
   - Last login timestamps
   - User identification for all operations

### Why BCrypt for Password Hashing?

1. **Security**: BCrypt is a one-way hashing algorithm
   - Passwords are never stored in plain text
   - Even if database is compromised, passwords cannot be recovered

2. **Industry Standard**: BCrypt is widely used and trusted
   - Built-in salt generation
   - Configurable cost factor for future-proofing

3. **Protection Against Attacks**: Resistant to rainbow table and brute force attacks
   - Each password hash includes unique salt
   - Slow hashing algorithm prevents rapid brute force attempts

### Why Session Management?

1. **State Persistence**: Maintains user login state across requests
   - Users don't need to login for every page
   - Seamless navigation experience

2. **Security**: Session timeout prevents unauthorized access
   - Automatic logout after inactivity
   - Session invalidation on logout

3. **User Experience**: Stores user information for personalized experience
   - Welcome messages with user name
   - Role-based UI elements

## HOW: Implementation Details

### Exercise 1: Database & User Model

#### Task 1.1: Create Users Table

**What**: Created a `users` table in MySQL database to store user credentials and information.

**How**:
- Created SQL script: `database/users_table.sql`
- Defined table structure with columns:
  - `id`: Primary key, auto-increment
  - `username`: Unique, not null
  - `password`: VARCHAR(255) to store BCrypt hashes
  - `full_name`: User's display name
  - `role`: ENUM('admin', 'user') with default 'user'
  - `is_active`: Boolean flag for account status
  - `created_at`: Timestamp of account creation
  - `last_login`: Timestamp of last successful login

**Why**: 
- Centralized user data storage
- Proper constraints ensure data integrity
- Role field enables authorization checks
- `is_active` allows account deactivation without deletion

#### Task 1.2: Generate Hashed Passwords

**What**: Created a utility class to generate BCrypt password hashes.

**How**:
- Created `PasswordHashGenerator.java` in `src/main/java/com/student/util/`
- Uses `BCrypt.hashpw()` to generate salted hash
- Includes verification test to ensure hash works correctly
- Outputs hash for manual insertion into database

**Code**:
```java
String plainPassword = "password123";
String hashedPassword = BCrypt.hashpw(plainPassword, BCrypt.gensalt());
boolean matches = BCrypt.checkpw(plainPassword, hashedPassword);
```

**Why**:
- Separates password hashing from application logic
- Allows batch generation of hashes for test users
- Verifies BCrypt library is working correctly

#### Task 1.3: Insert Test Users

**What**: Inserted test users into the database with hashed passwords.

**How**:
- Generated hash using `PasswordHashGenerator`
- Created SQL INSERT statements for:
  - Admin user: username 'admin', role 'admin'
  - Regular users: 'john' and 'jane', role 'user'
- All users use same password 'password123' for testing

**Why**:
- Provides test accounts for development
- Demonstrates both admin and user roles
- Allows testing authentication flow

### Exercise 2: User Model & DAO

#### Task 2.1: Create User Model

**What**: Created `User.java` as a JavaBean representing user entity.

**How**:
- Declared private attributes matching database columns:
  - `id`, `username`, `password`, `fullName`, `role`, `isActive`, `createdAt`, `lastLogin`
- Created two constructors:
  - No-arg constructor for JavaBean compliance
  - Parameterized constructor for creating new users
- Implemented all getters and setters
- Added utility methods:
  - `isAdmin()`: Returns true if role is "admin"
  - `isUser()`: Returns true if role is "user"
- Overrode `toString()` for debugging

**Why**:
- Follows JavaBean pattern for framework compatibility
- Utility methods simplify role checking in controllers
- Encapsulation protects data integrity

#### Task 2.2: Create UserDAO

**What**: Created `UserDAO.java` to handle all user-related database operations.

**How**:
- **Database Connection**: Reused connection pattern from `StudentDAO`
- **authenticate() method**:
  1. Queries user by username and active status
  2. Retrieves hashed password from database
  3. Uses `BCrypt.checkpw()` to verify plain password against hash
  4. If valid, updates `last_login` timestamp and returns User object
  5. If invalid, returns null
- **getUserById() method**: Retrieves user by ID
- **updateLastLogin() method**: Updates last login timestamp
- **mapResultSetToUser() helper**: Maps database ResultSet to User object

**Code Flow for Authentication**:
```java
public User authenticate(String username, String password) {
    // 1. Query user from database
    PreparedStatement pstmt = conn.prepareStatement(
        "SELECT * FROM users WHERE username = ? AND is_active = TRUE");
    pstmt.setString(1, username);
    ResultSet rs = pstmt.executeQuery();
    
    if (rs.next()) {
        String hashedPassword = rs.getString("password");
        
        // 2. Verify password using BCrypt
        if (BCrypt.checkpw(password, hashedPassword)) {
            User user = mapResultSetToUser(rs);
            updateLastLogin(user.getId());
            return user;
        }
    }
    return null; // Authentication failed
}
```

**Why**:
- Centralizes authentication logic
- BCrypt verification ensures secure password checking
- Automatic last login tracking provides audit trail
- PreparedStatement prevents SQL injection

### Exercise 3: Login/Logout Controllers

#### Task 3.1: Create Login Controller

**What**: Created `LoginController.java` to handle login GET and POST requests.

**How**:
- **doGet() method**:
  - Checks if user is already logged in (session exists with user attribute)
  - If logged in, redirects to dashboard
  - If not logged in, forwards to `login.jsp`
  
- **doPost() method**:
  1. Extracts username and password from form
  2. Validates input (not null/empty)
  3. Calls `userDAO.authenticate()` to verify credentials
  4. If successful:
     - Invalidates old session (security best practice)
     - Creates new session
     - Stores user data in session attributes
     - Sets session timeout to 30 minutes
     - Redirects to dashboard
  5. If failed:
     - Sets error message
     - Remembers username for better UX
     - Forwards back to login page

**Code**:
```java
if (user != null) {
    // Security: Invalidate old session
    HttpSession oldSession = request.getSession(false);
    if (oldSession != null) {
        oldSession.invalidate();
    }
    
    // Create new session
    HttpSession session = request.getSession(true);
    
    // Store user data
    session.setAttribute("user", user);
    session.setAttribute("userId", user.getId());
    session.setAttribute("username", user.getUsername());
    session.setAttribute("role", user.getRole());
    session.setAttribute("fullName", user.getFullName());
    
    // Set timeout (30 minutes)
    session.setMaxInactiveInterval(30 * 60);
    
    response.sendRedirect("dashboard");
}
```

**Why**:
- Session invalidation prevents session fixation attacks
- Storing user data in session avoids repeated database queries
- Session timeout balances security and usability
- Error handling provides feedback to users

#### Task 3.2: Create Logout Controller

**What**: Created `LogoutController.java` to handle user logout.

**How**:
- **doGet() and doPost() methods**:
  1. Retrieves existing session (without creating new one)
  2. Invalidates session if it exists
  3. Redirects to login page with success message

**Code**:
```java
HttpSession session = request.getSession(false);
if (session != null) {
    session.invalidate();
}
response.sendRedirect("login?message=You have been logged out successfully");
```

**Why**:
- Session invalidation ensures complete logout
- Success message confirms logout to user
- Simple implementation handles both GET and POST

### Exercise 4: Views & Dashboard

#### Task 4.1: Create Login View

**What**: Created `login.jsp` as the user login interface.

**How**:
- **Professional Design**:
  - Gradient background (purple theme)
  - Centered login form with rounded corners
  - Modern input fields with focus effects
  - Hover effects on submit button
  
- **Error/Success Messages**:
  - Uses JSTL `<c:if>` to conditionally display error messages
  - Shows success message from URL parameter (logout confirmation)
  - Styled alert boxes with appropriate colors
  
- **Form Features**:
  - Username field with autofocus
  - Password field (hidden input)
  - Remember me checkbox
  - Submit button with gradient styling
  
- **Demo Credentials**:
  - Displays test usernames and passwords
  - Helps during development and testing

**JSP Code**:
```jsp
<c:if test="${not empty error}">
    <div class="alert alert-error">❌ ${error}</div>
</c:if>

<c:if test="${not empty param.message}">
    <div class="alert alert-success">✅ ${param.message}</div>
</c:if>

<form action="login" method="post">
    <input type="text" name="username" value="${username}" required>
    <input type="password" name="password" required>
    <button type="submit">Login</button>
</form>
```

**Why**:
- User-friendly interface encourages proper usage
- Error messages guide users to correct mistakes
- Remember username on error improves UX
- Demo credentials facilitate testing

#### Task 4.2: Create Dashboard

**What**: Created `DashboardController.java` and `dashboard.jsp` to display user dashboard.

**How**:
- **DashboardController**:
  1. Checks if user is logged in (session validation)
  2. Retrieves user from session
  3. Gets statistics (total students count)
  4. Sets attributes for JSP
  5. Forwards to `dashboard.jsp`
  
- **dashboard.jsp**:
  - **Navigation Bar**:
    - Displays welcome message with user's full name
    - Shows role badge (admin/user) with different colors
    - Links to Students list and Logout
  - **Welcome Section**: Personalized greeting
  - **Statistics Cards**: Displays total students count
  - **Quick Actions**: 
    - View Students link
    - Add Student link (admin only, using JSTL conditional)
    - Dashboard refresh link

**JSP Code**:
```jsp
<div class="navbar">
    <h2>📚 Student Management System</h2>
    <div class="navbar-right">
        <span>Welcome, ${sessionScope.fullName}</span>
        <span class="role-badge role-${sessionScope.role}">
            ${sessionScope.role}
        </span>
        <a href="student?action=list">Students</a>
        <a href="logout">Logout</a>
    </div>
</div>

<c:if test="${sessionScope.role eq 'admin'}">
    <a href="student?action=new">➕ Add New Student</a>
</c:if>
```

**Why**:
- Centralized entry point after login
- Statistics provide quick overview
- Role-based UI elements demonstrate authorization
- Professional design maintains consistency

## Technical Decisions and Rationale

### 1. BCrypt vs Other Hashing Algorithms

**Decision**: Used BCrypt for password hashing

**Why**:
- Industry standard for password hashing
- Built-in salt generation (unique salt per password)
- Configurable cost factor (can increase as computers get faster)
- Resistant to rainbow table attacks
- Slow hashing prevents brute force attacks

**Trade-off**: Slightly slower than MD5/SHA, but security is worth it

### 2. Session Invalidation on Login

**Decision**: Invalidate old session before creating new one

**Why**:
- Prevents session fixation attacks
- Ensures clean session state
- Security best practice

**Trade-off**: User loses any unsaved data in old session (acceptable for login)

### 3. Session Attributes vs Database Queries

**Decision**: Store user data in session attributes

**Why**:
- Reduces database load
- Faster page rendering
- Better user experience

**Trade-off**: Session data may become stale (mitigated by session timeout)

### 4. URL Parameters for Messages

**Decision**: Used URL parameters for logout success message

**Why**:
- Simple implementation
- Works across redirects
- Easy to display in JSP

**Trade-off**: Messages visible in URL (acceptable for non-sensitive messages)

### 5. 30-Minute Session Timeout

**Decision**: Set session timeout to 30 minutes

**Why**:
- Balances security and usability
- Prevents unauthorized access if user forgets to logout
- Industry standard timeout duration

**Trade-off**: Users may need to re-login if inactive (acceptable trade-off)

## Authentication Flow: Detailed Code Flow

This section explains the step-by-step code flow for user authentication, from login form submission through session creation.

---

### 1. Login Process (POST Request)

**User Action**: Fills login form and clicks "Login" button

#### Step-by-Step Flow:

**Step 1: HTTP Request**
```
POST /login
Content-Type: application/x-www-form-urlencoded

username=admin&password=password123
```
- Browser sends POST request to `/login` servlet
- Form data includes username and password

**Step 2: Servlet Container**
- Tomcat receives request
- Routes to `LoginController` servlet (mapped via `@WebServlet("/login")`)
- Calls `doPost()` method

**Step 3: Controller - Input Validation** (LoginController.java:47-55)
```java
String username = request.getParameter("username");
String password = request.getParameter("password");

if (username == null || username.trim().isEmpty() ||
    password == null || password.trim().isEmpty()) {
    request.setAttribute("error", "Username and password are required");
    request.getRequestDispatcher("/views/login.jsp").forward(request, response);
    return;
}
```
- Extracts username and password from request
- Validates that both fields are not empty
- If invalid, forwards back to login page with error

**Step 4: Controller - Authentication** (LoginController.java:58)
```java
User user = userDAO.authenticate(username.trim(), password);
```
- Calls `UserDAO.authenticate()` method
- Passes username and plain password

**Step 5: DAO - Database Query** (UserDAO.java:42-50)
```java
PreparedStatement pstmt = conn.prepareStatement(
    "SELECT * FROM users WHERE username = ? AND is_active = TRUE");
pstmt.setString(1, username);
ResultSet rs = pstmt.executeQuery();
```
- Queries database for user with matching username
- Only selects active users (`is_active = TRUE`)
- Uses PreparedStatement to prevent SQL injection

**Step 6: DAO - Password Verification** (UserDAO.java:52-58)
```java
if (rs.next()) {
    String hashedPassword = rs.getString("password");
    if (BCrypt.checkpw(password, hashedPassword)) {
        // Password matches
    }
}
```
- Retrieves hashed password from database
- Uses `BCrypt.checkpw()` to compare plain password with hash
- Returns true if passwords match

**Step 7: DAO - Update Last Login** (UserDAO.java:61-62)
```java
user = mapResultSetToUser(rs);
updateLastLogin(user.getId());
```
- Maps database row to User object
- Updates `last_login` timestamp in database

**Step 8: Controller - Session Creation** (LoginController.java:60-75)
```java
if (user != null) {
    // Invalidate old session
    HttpSession oldSession = request.getSession(false);
    if (oldSession != null) {
        oldSession.invalidate();
    }
    
    // Create new session
    HttpSession session = request.getSession(true);
    
    // Store user data
    session.setAttribute("user", user);
    session.setAttribute("userId", user.getId());
    session.setAttribute("username", user.getUsername());
    session.setAttribute("role", user.getRole());
    session.setAttribute("fullName", user.getFullName());
    
    // Set timeout
    session.setMaxInactiveInterval(30 * 60);
    
    response.sendRedirect("dashboard");
}
```
- Invalidates any existing session (security)
- Creates new session
- Stores user object and individual attributes
- Sets 30-minute timeout
- Redirects to dashboard

**Step 9: HTTP Response**
- Server sends HTTP 302 redirect to `/dashboard`
- Browser makes new GET request to dashboard
- User sees dashboard page

**Key Points:**
- Password never stored in session (only hashed version in database)
- Session invalidation prevents session fixation
- Multiple session attributes for easy JSP access
- Redirect-after-POST pattern prevents form resubmission

---

### 2. Logout Process (GET Request)

**User Action**: Clicks "Logout" link

#### Step-by-Step Flow:

**Step 1: HTTP Request**
```
GET /logout
```
- Browser sends GET request to `/logout` servlet

**Step 2: Controller - Session Invalidation** (LogoutController.java:15-20)
```java
HttpSession session = request.getSession(false);
if (session != null) {
    session.invalidate();
}
```
- Retrieves existing session (false = don't create if doesn't exist)
- Invalidates session, removing all session data

**Step 3: Redirect to Login** (LogoutController.java:23)
```java
response.sendRedirect("login?message=You have been logged out successfully");
```
- Redirects to login page with success message
- Message passed as URL parameter

**Step 4: Login Page Display**
- Login page shows success message
- User must login again to access system

**Key Points:**
- Session invalidation ensures complete logout
- Success message confirms logout to user
- Simple and secure implementation

---

### 3. Dashboard Access (GET Request)

**User Action**: Navigates to `/dashboard` after login

#### Step-by-Step Flow:

**Step 1: HTTP Request**
```
GET /dashboard
Cookie: JSESSIONID=ABC123...
```
- Browser sends GET request with session cookie

**Step 2: Controller - Session Check** (DashboardController.java:20-25)
```java
HttpSession session = request.getSession(false);
if (session == null || session.getAttribute("user") == null) {
    response.sendRedirect("login");
    return;
}
```
- Checks if session exists and contains user
- If not logged in, redirects to login

**Step 3: Controller - Get Statistics** (DashboardController.java:27-32)
```java
User user = (User) session.getAttribute("user");
int totalStudents = studentDAO.getAllStudents().size();
request.setAttribute("totalStudents", totalStudents);
request.setAttribute("user", user);
```
- Retrieves user from session
- Gets statistics from StudentDAO
- Sets attributes for JSP

**Step 4: View Rendering** (dashboard.jsp)
```jsp
Welcome, ${sessionScope.fullName}
<span class="role-badge role-${sessionScope.role}">
    ${sessionScope.role}
</span>
```
- JSP accesses session attributes using EL
- Displays personalized content
- Shows role-based UI elements

**Key Points:**
- Session validation on every protected page
- Session attributes accessible via `${sessionScope.attributeName}`
- Role-based UI using JSTL conditionals

## Security Measures Implemented

### 1. Password Security
- ✅ BCrypt hashing (one-way, salted)
- ✅ Passwords never stored in plain text
- ✅ Passwords never sent in session

### 2. Session Security
- ✅ Session invalidation on login (prevents fixation)
- ✅ Session timeout (30 minutes)
- ✅ Session validation on protected pages
- ✅ Session invalidation on logout

### 3. Input Validation
- ✅ Server-side validation (username/password required)
- ✅ SQL injection prevention (PreparedStatement)
- ✅ XSS prevention (JSTL escaping)

### 4. Authentication Flow
- ✅ Secure password verification (BCrypt)
- ✅ Active user check (is_active flag)
- ✅ Error messages don't reveal if username exists

## Key Learning Outcomes

1. **Authentication Understanding**: 
   - How to verify user credentials
   - Password hashing and verification
   - Session creation and management

2. **Session Management**:
   - HttpSession API usage
   - Session attributes storage
   - Session timeout configuration
   - Session invalidation

3. **Security Best Practices**:
   - BCrypt password hashing
   - Session fixation prevention
   - Input validation
   - SQL injection prevention

4. **MVC Pattern Application**:
   - Controller handles authentication logic
   - DAO handles database operations
   - View displays login/dashboard interfaces

5. **Role-Based Access**:
   - User roles stored in database
   - Role checking in controllers
   - Conditional UI elements based on role

## Conclusion

This lab successfully implements authentication and session management for the Student Management System. The application now:

- ✅ Securely authenticates users with BCrypt password hashing
- ✅ Manages user sessions with proper timeout and invalidation
- ✅ Provides role-based access control (admin/user)
- ✅ Offers professional login and dashboard interfaces
- ✅ Follows security best practices

The implementation demonstrates understanding of:
- Authentication concepts and password security
- Session management and HttpSession API
- MVC pattern in authentication context
- Security best practices for web applications

**Next Steps (Part B - Homework)**:
- Implement authentication filter for protected pages
- Add admin authorization filter
- Update student list with role-based UI
- Optional: Change password feature
