package com.student.dao;

import com.student.model.Student;

import java.sql.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

public class StudentDAO {
    // Database configuration constants
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/student_management";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "admin"; // Update with your MySQL password
    private static final String JDBC_DRIVER = "com.mysql.cj.jdbc.Driver";

    // Get database connection
    private Connection getConnection() throws SQLException, ClassNotFoundException {
        Class.forName(JDBC_DRIVER);
        return DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
    }

    // Map a ResultSet row to Student object
    private Student mapStudent(ResultSet rs) throws SQLException {
        Student student = new Student();
        student.setId(rs.getInt("id"));
        student.setStudentCode(rs.getString("student_code"));
        student.setFullName(rs.getString("full_name"));
        student.setEmail(rs.getString("email"));
        student.setMajor(rs.getString("major"));
        student.setCreatedAt(rs.getTimestamp("created_at"));
        return student;
    }

    // Get all students
    public List<Student> getAllStudents() {
        String sql = "SELECT * FROM students ORDER BY id DESC";
        return executeStudentQuery(sql, Collections.emptyList());
    }

    // Get student by ID
    public Student getStudentById(int id) {
        Student student = null;
        String sql = "SELECT * FROM students WHERE id = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    student = mapStudent(rs);
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }

        return student;
    }

    // Add new student
    public boolean addStudent(Student student) {
        String sql = "INSERT INTO students (student_code, full_name, email, major) VALUES (?, ?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, student.getStudentCode());
            pstmt.setString(2, student.getFullName());
            pstmt.setString(3, student.getEmail());
            pstmt.setString(4, student.getMajor());

            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Update student
    public boolean updateStudent(Student student) {
        String sql = "UPDATE students SET full_name = ?, email = ?, major = ? WHERE id = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, student.getFullName());
            pstmt.setString(2, student.getEmail());
            pstmt.setString(3, student.getMajor());
            pstmt.setInt(4, student.getId());

            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Delete student
    public boolean deleteStudent(int id) {
        String sql = "DELETE FROM students WHERE id = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Search students by keyword (code, name, email)
    public List<Student> searchStudents(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return getAllStudents();
        }

        String sql = "SELECT * FROM students " +
                "WHERE student_code LIKE ? OR full_name LIKE ? OR email LIKE ? " +
                "ORDER BY id DESC";
        String pattern = "%" + keyword.trim() + "%";

        return executeStudentQuery(sql, Arrays.asList(pattern, pattern, pattern));
    }

    // Get students by major
    public List<Student> getStudentsByMajor(String major) {
        if (major == null || major.trim().isEmpty()) {
            return getAllStudents();
        }

        String sql = "SELECT * FROM students WHERE major = ? ORDER BY id DESC";
        return executeStudentQuery(sql, Collections.singletonList(major.trim()));
    }

    // Get students sorted by column/order
    public List<Student> getStudentsSorted(String sortBy, String order) {
        String validatedColumn = validateSortBy(sortBy);
        String validatedOrder = validateOrder(order);

        String sql = "SELECT * FROM students ORDER BY " + validatedColumn + " " + validatedOrder;
        return executeStudentQuery(sql, Collections.emptyList());
    }

    // Combined filter method (search + filter + sort)
    public List<Student> getStudentsFiltered(String keyword, String major, String sortBy, String order) {
        StringBuilder sql = new StringBuilder("SELECT * FROM students WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (student_code LIKE ? OR full_name LIKE ? OR email LIKE ?)");
            String pattern = "%" + keyword.trim() + "%";
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
        }

        if (major != null && !major.trim().isEmpty()) {
            sql.append(" AND major = ?");
            params.add(major.trim());
        }

        sql.append(" ORDER BY ")
                .append(validateSortBy(sortBy))
                .append(" ")
                .append(validateOrder(order));

        return executeStudentQuery(sql.toString(), params);
    }

    // Helper to execute SELECT queries and map to Student list
    private List<Student> executeStudentQuery(String sql, List<Object> params) {
        List<Student> students = new ArrayList<>();

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    students.add(mapStudent(rs));
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }

        return students;
    }

    private String validateSortBy(String sortBy) {
        String defaultColumn = "id";
        if (sortBy == null) {
            return defaultColumn;
        }

        List<String> allowedColumns = Arrays.asList(
                "id", "student_code", "full_name", "email", "major", "created_at"
        );

        String normalized = sortBy.toLowerCase();
        return allowedColumns.contains(normalized) ? normalized : defaultColumn;
    }

    private String validateOrder(String order) {
        if ("desc".equalsIgnoreCase(order)) {
            return "DESC";
        }
        return "ASC";
    }

    // Test method (remove after testing)
    public static void main(String[] args) {
        StudentDAO dao = new StudentDAO();
        List<Student> students = dao.getAllStudents();
        System.out.println("Total students: " + students.size());
        for (Student s : students) {
            System.out.println(s);
        }
    }
}

