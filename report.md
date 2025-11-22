# Lab 5 Report: Servlet & MVC Pattern Implementation

## WHAT: Project Overview

This project implements a **Student Management System** using the **MVC (Model-View-Controller)** architectural pattern. The application allows users to perform CRUD (Create, Read, Update, Delete) operations on student records through a web interface. The system consists of:

- **Model Layer**: `Student.java` - JavaBean representing student data
- **DAO Layer**: `StudentDAO.java` - Data Access Object handling database operations
- **Controller Layer**: `StudentController.java` - Servlet managing request routing and business logic
- **View Layer**: JSP files using JSTL and EL for presentation

## WHY: Purpose and Benefits

### Why MVC Pattern?

1. **Separation of Concerns**: Each layer has a specific responsibility
   - Model: Data structure and business logic
   - View: User interface and presentation
   - Controller: Request handling and coordination

2. **Maintainability**: Changes in one layer don't affect others
   - Database changes only affect DAO
   - UI changes only affect JSP files
   - Business logic changes only affect Controller

3. **Reusability**: Components can be reused across different views
   - Same DAO can serve multiple controllers
   - Same model can be used in different contexts

4. **Testability**: Each component can be tested independently
   - DAO can be tested with unit tests
   - Controller logic can be tested separately

### Why JSTL Instead of Scriptlets?

1. **Cleaner Code**: JSTL provides cleaner, more readable syntax
2. **Security**: Reduces risk of script injection
3. **Maintainability**: Easier for frontend developers to understand
4. **Best Practices**: Follows modern Java web development standards

### Why PreparedStatement?

1. **Security**: Prevents SQL injection attacks
2. **Performance**: Better query optimization by database
3. **Type Safety**: Ensures correct data types are used

## HOW: Implementation Details

### Exercise 1: Model Layer Implementation

#### Student.java (JavaBean)
**What**: A Plain Old Java Object (POJO) representing a student entity.

**How**:
- Declared private attributes: `id`, `studentCode`, `fullName`, `email`, `major`, `createdAt`
- Created no-arg constructor for JavaBean compliance
- Created parameterized constructor (without id) for creating new students
- Implemented getters and setters for all attributes
- Overrode `toString()` method for debugging and logging

**Why**: JavaBeans follow a standard pattern that makes them compatible with frameworks, JSP EL expressions, and serialization.

#### StudentDAO.java (Data Access Object)
**What**: A class responsible for all database interactions.

**How**:
- Defined database connection constants (URL, username, password, driver)
- Implemented `getConnection()` method using JDBC DriverManager
- Used try-with-resources for automatic resource management
- Implemented CRUD methods:
  - `getAllStudents()`: Retrieves all students using SELECT query
  - `getStudentById(int id)`: Retrieves single student by ID
  - `addStudent(Student student)`: Inserts new student using INSERT
  - `updateStudent(Student student)`: Updates existing student using UPDATE
  - `deleteStudent(int id)`: Removes student using DELETE

**Why**: 
- Centralizes database logic in one place
- Makes it easy to change database or add connection pooling later
- Try-with-resources ensures connections are always closed, preventing memory leaks

### Exercise 2: Controller Layer Implementation

#### StudentController.java (Servlet)
**What**: A servlet that acts as the controller, handling all HTTP requests and coordinating between Model and View.

**How**:
- Annotated with `@WebServlet("/student")` for URL mapping
- Initialized `StudentDAO` in `init()` method (called once when servlet loads)
- Implemented `doGet()` method to handle GET requests:
  - Extracts `action` parameter from request
  - Routes to appropriate method based on action (list, new, edit, delete)
- Implemented `doPost()` method to handle POST requests:
  - Routes to insert or update methods
- Created handler methods:
  - `listStudents()`: Gets all students from DAO, sets as request attribute, forwards to list view
  - `showNewForm()`: Forwards to form view for adding new student
  - `showEditForm()`: Gets student by ID, sets as request attribute, forwards to form view
  - `insertStudent()`: Extracts form parameters, creates Student object, calls DAO, redirects with message
  - `updateStudent()`: Gets existing student, updates fields, calls DAO, redirects with message
  - `deleteStudent()`: Extracts ID, calls DAO delete method, redirects with message

**Why**:
- Single servlet handles all student-related operations
- Separation of concerns: Controller doesn't know about database details
- Uses redirect-after-post pattern to prevent duplicate submissions
- Request attributes allow passing data to JSP views

### Exercise 3: View Layer Implementation

#### student-list.jsp
**What**: JSP page displaying a table of all students with action buttons.

**How**:
- Included JSTL taglib directive: `<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>`
- Used `<c:if>` to conditionally display success/error messages from URL parameters
- Used `<c:forEach>` to iterate through students list from request attribute
- Used EL expressions `${student.property}` to display data
- Used `<c:choose>` and `<c:when>` to handle empty list case
- Created links for Edit and Delete actions with confirmation dialog

**Why**:
- No scriptlets means cleaner, more maintainable code
- JSTL provides standard tag library for common operations
- EL expressions are type-safe and null-safe
- Separation: View only displays data, doesn't contain business logic

#### student-form.jsp
**What**: Single JSP form that handles both adding new students and editing existing ones.

**How**:
- Used `<c:choose>` to dynamically set page title (Add vs Edit)
- Used `<c:if>` to conditionally include hidden ID field (only when editing)
- Set form action dynamically: `value="${student != null ? 'update' : 'insert'}"`
- Made student code field readonly when editing: `${student != null ? 'readonly' : 'required'}`
- Pre-filled form fields using EL: `value="${student.fullName}"`
- Dynamic submit button text based on mode

**Why**:
- Single form reduces code duplication
- Conditional logic handles both scenarios elegantly
- Pre-filling values improves user experience
- Readonly student code prevents accidental changes to unique identifier

### Exercise 4: Complete CRUD Integration

**What**: Full integration of all Create, Read, Update, Delete operations.

**How**:
- Completed all DAO methods (getById, add, update, delete)
- Integrated all controller methods with proper error handling
- Added success/error messages via URL parameters
- Implemented redirect-after-post pattern
- Added confirmation dialog for delete operation

**Why**:
- Complete CRUD provides full functionality
- Error handling improves user experience
- Redirect-after-post prevents browser refresh from resubmitting forms
- Confirmation dialogs prevent accidental deletions

## Technical Decisions and Rationale

### 1. URL Parameter Messages vs Request Attributes
**Decision**: Used URL parameters for success/error messages (`?message=...`)

**Why**: 
- Messages persist after redirect
- Can be bookmarked/shared
- Simple to implement

**Trade-off**: Messages visible in URL (but acceptable for this use case)

### 2. Single Form for Add/Edit
**Decision**: One JSP form handles both add and edit operations

**Why**:
- Reduces code duplication
- Easier to maintain (one form to update)
- Consistent UI/UX

### 3. PreparedStatement for All Queries
**Decision**: Used PreparedStatement for all database operations

**Why**:
- Security: Prevents SQL injection
- Performance: Query plans are cached
- Type safety: Database validates types

### 4. Try-With-Resources
**Decision**: Used try-with-resources for all database connections

**Why**:
- Automatic resource management
- Guarantees connection closure even on exceptions
- Cleaner code (no finally blocks needed)

### 5. Redirect After POST
**Decision**: Used `sendRedirect()` after POST operations instead of forward

**Why**:
- Prevents duplicate form submissions on browser refresh
- Follows PRG (Post-Redirect-Get) pattern
- Better user experience

## CRUD Operations: Detailed Code Flow

This section explains the step-by-step code flow for each CRUD operation, tracing the execution from user interaction through the MVC layers to the database and back.

---

### 1. READ Operation: List All Students

**User Action**: Navigates to `/student` or clicks "View Students" link

#### Step-by-Step Flow:

**Step 1: HTTP Request**
```
GET /student?action=list
```
- Browser sends GET request to servlet mapped at `/student`
- URL parameter `action=list` (or defaults to "list" if omitted)

**Step 2: Servlet Container**
- Tomcat receives request
- Routes to `StudentController` servlet (mapped via `@WebServlet("/student")`)
- Calls `doGet()` method

**Step 3: Controller - doGet() Method** (StudentController.java:26-52)
```java
protected void doGet(HttpServletRequest request, HttpServletResponse response) {
    String action = request.getParameter("action");  // Extracts "list"
    if (action == null) action = "list";             // Default to "list"
    
    switch (action) {
        case "list":
            listStudents(request, response);  // Routes here
            break;
        // ... other cases
    }
}
```

**Step 4: Controller - listStudents() Method** (StudentController.java:73-81)
```java
private void listStudents(...) {
    // 1. Call DAO to get data
    List<Student> students = studentDAO.getAllStudents();
    
    // 2. Store data in request scope for JSP access
    request.setAttribute("students", students);
    
    // 3. Forward to view (server-side redirect, same request)
    RequestDispatcher dispatcher = request.getRequestDispatcher("/views/student-list.jsp");
    dispatcher.forward(request, response);
}
```

**Step 5: DAO - getAllStudents() Method** (StudentDAO.java:23-46)
```java
public List<Student> getAllStudents() {
    List<Student> students = new ArrayList<>();
    String sql = "SELECT * FROM students ORDER BY id DESC";
    
    // Try-with-resources: auto-closes Connection, PreparedStatement, ResultSet
    try (Connection conn = getConnection();           // Opens DB connection
         PreparedStatement pstmt = conn.prepareStatement(sql);
         ResultSet rs = pstmt.executeQuery()) {      // Executes SELECT query
        
        // Iterate through result set
        while (rs.next()) {
            Student student = new Student();          // Create new Student object
            student.setId(rs.getInt("id"));          // Map database columns
            student.setStudentCode(rs.getString("student_code"));
            student.setFullName(rs.getString("full_name"));
            student.setEmail(rs.getString("email"));
            student.setMajor(rs.getString("major"));
            student.setCreatedAt(rs.getTimestamp("created_at"));
            students.add(student);                    // Add to list
        }
    } catch (SQLException | ClassNotFoundException e) {
        e.printStackTrace();
    }
    
    return students;  // Returns List<Student>
}
```

**Step 6: Database Query Execution**
- MySQL executes: `SELECT * FROM students ORDER BY id DESC`
- Returns ResultSet with all student records
- Connection automatically closed by try-with-resources

**Step 7: View - student-list.jsp Rendering**
```jsp
<!-- JSTL iterates through students list -->
<c:forEach var="student" items="${students}">
    <tr>
        <td>${student.id}</td>                    <!-- EL accesses getter methods -->
        <td>${student.studentCode}</td>
        <td>${student.fullName}</td>
        <td>${student.email}</td>
        <td>${student.major}</td>
        <td>
            <a href="student?action=edit&id=${student.id}">Edit</a>
            <a href="student?action=delete&id=${student.id}">Delete</a>
        </td>
    </tr>
</c:forEach>
```

**Step 8: HTTP Response**
- JSP generates HTML
- Response sent to browser
- User sees table of all students

**Key Points:**
- Uses `forward()` (server-side, same request)
- Data passed via `request.setAttribute()`
- DAO returns List, Controller passes to View
- View uses JSTL `<c:forEach>` and EL `${}`

---

### 2. CREATE Operation: Add New Student

**User Action**: Clicks "Add New Student" button, fills form, submits

#### Phase 1: Display Form (GET Request)

**Step 1: HTTP Request**
```
GET /student?action=new
```

**Step 2: Controller - doGet()** (StudentController.java:26-52)
```java
switch (action) {
    case "new":
        showNewForm(request, response);  // Routes here
        break;
}
```

**Step 3: Controller - showNewForm()** (StudentController.java:83-88)
```java
private void showNewForm(...) {
    // No data needed, just forward to form
    RequestDispatcher dispatcher = request.getRequestDispatcher("/views/student-form.jsp");
    dispatcher.forward(request, response);
}
```

**Step 4: View - student-form.jsp (Add Mode)**
```jsp
<!-- Form renders with empty fields -->
<form action="student" method="POST">
    <input type="hidden" name="action" value="insert">  <!-- Action for POST -->
    
    <input type="text" name="studentCode" required>
    <input type="text" name="fullName" required>
    <input type="email" name="email">
    <input type="text" name="major" required>
    
    <button type="submit">Add Student</button>
</form>
```

#### Phase 2: Process Form Submission (POST Request)

**Step 5: HTTP Request (Form Submit)**
```
POST /student
Content-Type: application/x-www-form-urlencoded

action=insert&studentCode=SV001&fullName=John Doe&email=john@example.com&major=CS
```

**Step 6: Controller - doPost()** (StudentController.java:54-71)
```java
protected void doPost(...) {
    String action = request.getParameter("action");  // Extracts "insert"
    
    switch (action) {
        case "insert":
            insertStudent(request, response);  // Routes here
            break;
    }
}
```

**Step 7: Controller - insertStudent()** (StudentController.java:101-116)
```java
private void insertStudent(...) {
    // 1. Extract form parameters from request
    String studentCode = request.getParameter("studentCode");
    String fullName = request.getParameter("fullName");
    String email = request.getParameter("email");
    String major = request.getParameter("major");
    
    // 2. Create Student object (using parameterized constructor)
    Student student = new Student(studentCode, fullName, email, major);
    
    // 3. Call DAO to persist to database
    if (studentDAO.addStudent(student)) {
        // Success: Redirect with message (PRG pattern)
        response.sendRedirect("student?action=list&message=Student added successfully");
    } else {
        // Failure: Redirect with error
        response.sendRedirect("student?action=list&error=Failed to add student");
    }
}
```

**Step 8: DAO - addStudent()** (StudentDAO.java:76-93)
```java
public boolean addStudent(Student student) {
    String sql = "INSERT INTO students (student_code, full_name, email, major) VALUES (?, ?, ?, ?)";
    
    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {
        
        // Set parameters (prevents SQL injection)
        pstmt.setString(1, student.getStudentCode());
        pstmt.setString(2, student.getFullName());
        pstmt.setString(3, student.getEmail());
        pstmt.setString(4, student.getMajor());
        
        // Execute INSERT
        int rowsAffected = pstmt.executeUpdate();  // Returns number of rows inserted
        
        return rowsAffected > 0;  // true if insert successful
    } catch (SQLException | ClassNotFoundException e) {
        e.printStackTrace();
        return false;
    }
}
```

**Step 9: Database INSERT**
- MySQL executes: `INSERT INTO students (student_code, full_name, email, major) VALUES ('SV001', 'John Doe', 'john@example.com', 'CS')`
- Returns number of affected rows (should be 1)
- Auto-increment assigns `id` and `created_at` timestamp

**Step 10: Redirect Response**
- `sendRedirect()` sends HTTP 302 redirect
- Browser makes new GET request to: `/student?action=list&message=Student added successfully`
- This triggers the READ operation (listStudents) again
- User sees updated list with success message

**Key Points:**
- Two-phase: GET to show form, POST to process
- Uses `sendRedirect()` after POST (PRG pattern)
- Prevents duplicate submissions on refresh
- Message passed via URL parameter

---

### 3. UPDATE Operation: Edit Existing Student

**User Action**: Clicks "Edit" button on a student row, modifies form, submits

#### Phase 1: Display Form with Data (GET Request)

**Step 1: HTTP Request**
```
GET /student?action=edit&id=1
```

**Step 2: Controller - doGet()** (StudentController.java:26-52)
```java
switch (action) {
    case "edit":
        showEditForm(request, response);  // Routes here
        break;
}
```

**Step 3: Controller - showEditForm()** (StudentController.java:90-99)
```java
private void showEditForm(...) {
    // 1. Extract student ID from request
    int id = Integer.parseInt(request.getParameter("id"));
    
    // 2. Fetch student data from database
    Student student = studentDAO.getStudentById(id);
    
    // 3. Store student in request scope for JSP
    request.setAttribute("student", student);
    
    // 4. Forward to form (same form as add, but with data)
    RequestDispatcher dispatcher = request.getRequestDispatcher("/views/student-form.jsp");
    dispatcher.forward(request, response);
}
```

**Step 4: DAO - getStudentById()** (StudentDAO.java:49-73)
```java
public Student getStudentById(int id) {
    Student student = null;
    String sql = "SELECT * FROM students WHERE id = ?";
    
    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {
        
        pstmt.setInt(1, id);  // Set ID parameter
        
        try (ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {  // If record found
                student = new Student();
                student.setId(rs.getInt("id"));
                student.setStudentCode(rs.getString("student_code"));
                student.setFullName(rs.getString("full_name"));
                student.setEmail(rs.getString("email"));
                student.setMajor(rs.getString("major"));
                student.setCreatedAt(rs.getTimestamp("created_at"));
            }
        }
    } catch (SQLException | ClassNotFoundException e) {
        e.printStackTrace();
    }
    
    return student;  // Returns Student object or null
}
```

**Step 5: View - student-form.jsp (Edit Mode)**
```jsp
<!-- Form renders with pre-filled values -->
<form action="student" method="POST">
    <input type="hidden" name="action" value="update">  <!-- Different action -->
    <input type="hidden" name="id" value="${student.id}">  <!-- Include ID -->
    
    <!-- Student code is readonly in edit mode -->
    <input type="text" name="studentCode" 
           value="${student.studentCode}" readonly>
    
    <!-- Other fields pre-filled with existing values -->
    <input type="text" name="fullName" 
           value="${student.fullName}" required>
    <input type="email" name="email" 
           value="${student.email}">
    <input type="text" name="major" 
           value="${student.major}" required>
    
    <button type="submit">Update Student</button>
</form>
```

#### Phase 2: Process Update (POST Request)

**Step 6: HTTP Request (Form Submit)**
```
POST /student
Content-Type: application/x-www-form-urlencoded

action=update&id=1&studentCode=SV001&fullName=John Smith&email=john.smith@example.com&major=IT
```

**Step 7: Controller - doPost()** (StudentController.java:54-71)
```java
switch (action) {
    case "update":
        updateStudent(request, response);  // Routes here
        break;
}
```

**Step 8: Controller - updateStudent()** (StudentController.java:118-140)
```java
private void updateStudent(...) {
    // 1. Extract parameters
    int id = Integer.parseInt(request.getParameter("id"));
    String fullName = request.getParameter("fullName");
    String email = request.getParameter("email");
    String major = request.getParameter("major");
    
    // 2. Fetch existing student from database
    Student student = studentDAO.getStudentById(id);
    
    if (student != null) {
        // 3. Update only mutable fields (not studentCode)
        student.setFullName(fullName);
        student.setEmail(email);
        student.setMajor(major);
        
        // 4. Persist changes
        if (studentDAO.updateStudent(student)) {
            response.sendRedirect("student?action=list&message=Student updated successfully");
        } else {
            response.sendRedirect("student?action=list&error=Failed to update student");
        }
    } else {
        response.sendRedirect("student?action=list&error=Student not found");
    }
}
```

**Step 9: DAO - updateStudent()** (StudentDAO.java:96-113)
```java
public boolean updateStudent(Student student) {
    String sql = "UPDATE students SET full_name = ?, email = ?, major = ? WHERE id = ?";
    
    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {
        
        // Set parameters (note: studentCode NOT updated)
        pstmt.setString(1, student.getFullName());
        pstmt.setString(2, student.getEmail());
        pstmt.setString(3, student.getMajor());
        pstmt.setInt(4, student.getId());  // WHERE clause
        
        int rowsAffected = pstmt.executeUpdate();  // Returns number of rows updated
        
        return rowsAffected > 0;
    } catch (SQLException | ClassNotFoundException e) {
        e.printStackTrace();
        return false;
    }
}
```

**Step 10: Database UPDATE**
- MySQL executes: `UPDATE students SET full_name = 'John Smith', email = 'john.smith@example.com', major = 'IT' WHERE id = 1`
- Returns number of affected rows (should be 1)

**Step 11: Redirect Response**
- Redirects to list with success message
- User sees updated student in the list

**Key Points:**
- Fetches existing data before showing form
- Student code is readonly (not updated)
- Only updates mutable fields
- Uses same form JSP as add operation

---

### 4. DELETE Operation: Remove Student

**User Action**: Clicks "Delete" button, confirms deletion

#### Step-by-Step Flow:

**Step 1: HTTP Request**
```
GET /student?action=delete&id=1
```
- Link includes confirmation dialog: `onclick="return confirm('Are you sure?')"`

**Step 2: Controller - doGet()** (StudentController.java:26-52)
```java
switch (action) {
    case "delete":
        deleteStudent(request, response);  // Routes here
        break;
}
```

**Step 3: Controller - deleteStudent()** (StudentController.java:142-152)
```java
private void deleteStudent(...) {
    // 1. Extract student ID
    int id = Integer.parseInt(request.getParameter("id"));
    
    // 2. Call DAO to delete
    if (studentDAO.deleteStudent(id)) {
        response.sendRedirect("student?action=list&message=Student deleted successfully");
    } else {
        response.sendRedirect("student?action=list&error=Failed to delete student");
    }
}
```

**Step 4: DAO - deleteStudent()** (StudentDAO.java:116-129)
```java
public boolean deleteStudent(int id) {
    String sql = "DELETE FROM students WHERE id = ?";
    
    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {
        
        pstmt.setInt(1, id);  // Set ID parameter
        
        int rowsAffected = pstmt.executeUpdate();  // Returns number of rows deleted
        
        return rowsAffected > 0;  // true if delete successful
    } catch (SQLException | ClassNotFoundException e) {
        e.printStackTrace();
        return false;
    }
}
```

**Step 5: Database DELETE**
- MySQL executes: `DELETE FROM students WHERE id = 1`
- Returns number of affected rows (should be 1)
- Record permanently removed from database

**Step 6: Redirect Response**
- Redirects to list with success message
- User sees updated list without deleted student

**Key Points:**
- Simple operation: just ID needed
- No form required
- Confirmation dialog prevents accidental deletion
- Permanent operation (no undo)

---

## Architecture Flow Summary

### Request Flow Example: Adding a Student

1. **User Action**: Clicks "Add New Student" button
2. **HTTP Request**: GET `/student?action=new`
3. **Controller**: `doGet()` receives request, routes to `showNewForm()`
4. **Controller**: Forwards to `student-form.jsp`
5. **View**: JSP renders empty form
6. **User Action**: Fills form and submits
7. **HTTP Request**: POST `/student` with form data and `action=insert`
8. **Controller**: `doPost()` receives request, routes to `insertStudent()`
9. **Controller**: Extracts parameters, creates Student object
10. **DAO**: `addStudent()` executes INSERT query
11. **Controller**: Redirects to `/student?action=list&message=Success`
12. **Controller**: `listStudents()` gets all students from DAO
13. **View**: `student-list.jsp` displays updated list with success message

## Key Learning Outcomes

1. **MVC Pattern Understanding**: Clear separation between data (Model), presentation (View), and logic (Controller)

2. **Servlet Lifecycle**: Understanding of `init()`, `doGet()`, `doPost()` methods

3. **JSTL Mastery**: Replaced all scriptlets with JSTL tags and EL expressions

4. **Database Best Practices**: PreparedStatement, try-with-resources, proper connection management

5. **Web Application Architecture**: Request/response cycle, forwarding vs redirecting, request attributes

## Homework Enhancements (Part B)

### Exercise 5: Search Capability
- Added `searchStudents(String keyword)` in `StudentDAO` to query student code, name, and email columns with wildcard `LIKE` matches and prepared statements.
- Introduced `searchStudents()` handler in `StudentController` that trims keywords, falls back to the default list when empty, and forwards results together with the current keyword so the JSP can show context.
- Extended `student-list.jsp` with a GET search form, persistent keyword input, contextual “Search results for …” text, and a Clear button to return to the full list.

### Exercise 6: Server-Side Validation
- Added `validateStudent(Student student, HttpServletRequest request)` to the controller for reusable validation logic (code pattern, name length, optional email format, required major).
- Integrated validation into both `insertStudent()` and `updateStudent()` so invalid submissions forward back to the form with the user-entered data and specific error attributes.
- Updated `student-form.jsp` to display per-field error messages in red just beneath the corresponding inputs for clear guidance.

### Exercise 7: Sorting & Filtering
- Implemented reusable DAO helpers: `getStudentsSorted`, `getStudentsByMajor`, and `getStudentsFiltered` (search + filter + sort) with whitelist validation for column/order inputs.
- Added controller routes/actions for `sort` and `filter`, along with sanitizers to prevent invalid parameters and ensure consistent state passed to the view.
- Upgraded `student-list.jsp` with UI controls:
  - Sortable table headers showing ascending/descending indicators and toggling order links.
  - A filter dropdown for common majors that preserves the selected option and offers a “Clear Filter” action.
  - Shared state indicators so users always know which filters or sorts are active.

### Exercise 8 (Optional): Pagination
- Not implemented; current focus remained on fully delivering Exercises 5-7 per requirements.

## Conclusion

This project now delivers both the in-class MVC foundation and the Part B homework enhancements. Core CRUD flows remain robust, while search, validation, and sorting/filtering significantly improve usability and data integrity. The separation of concerns keeps the codebase maintainable, JSTL-based views stay free of scriptlets, and validation plus sanitization guard against malformed input. Together these updates demonstrate solid command of:
- MVC architectural pattern
- Servlet programming
- JSP with JSTL and EL
- JDBC database operations
- Web application security practices (validation, prepared statements, sanitized parameters)

