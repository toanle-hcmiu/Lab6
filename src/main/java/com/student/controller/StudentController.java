package com.student.controller;

import com.student.dao.StudentDAO;
import com.student.model.Student;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/student")
public class StudentController extends HttpServlet {

    private StudentDAO studentDAO;

    @Override
    public void init() {
        studentDAO = new StudentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "list":
                listStudents(request, response);
                break;
            case "new":
                showNewForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteStudent(request, response);
                break;
            case "search":
                searchStudents(request, response);
                break;
            case "sort":
                sortStudents(request, response);
                break;
            case "filter":
                filterStudents(request, response);
                break;
            default:
                listStudents(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        switch (action) {
            case "insert":
                insertStudent(request, response);
                break;
            case "update":
                updateStudent(request, response);
                break;
            default:
                listStudents(request, response);
                break;
        }
    }

    private void listStudents(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Student> students = studentDAO.getAllStudents();
        request.setAttribute("students", students);
        request.setAttribute("keyword", "");
        request.setAttribute("selectedMajor", "");
        request.setAttribute("sortBy", "id");
        request.setAttribute("order", "desc");

        forwardToList(request, response);
    }

    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("isEditMode", false);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/views/student-form.jsp");
        dispatcher.forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));
        Student student = studentDAO.getStudentById(id);
        request.setAttribute("student", student);
        request.setAttribute("isEditMode", true);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/views/student-form.jsp");
        dispatcher.forward(request, response);
    }

    private void insertStudent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String studentCode = request.getParameter("studentCode");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String major = request.getParameter("major");

        Student student = new Student(studentCode, fullName, email, major);

        if (!validateStudent(student, request)) {
            request.setAttribute("student", student);
            request.setAttribute("isEditMode", false);
            forwardToForm(request, response);
            return;
        }

        if (studentDAO.addStudent(student)) {
            response.sendRedirect("student?action=list&message=Student added successfully");
        } else {
            response.sendRedirect("student?action=list&error=Failed to add student");
        }
    }

    private void updateStudent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));
        String studentCode = request.getParameter("studentCode");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String major = request.getParameter("major");

        Student student = new Student(studentCode, fullName, email, major);
        student.setId(id);

        if (!validateStudent(student, request)) {
            request.setAttribute("student", student);
            request.setAttribute("isEditMode", true);
            forwardToForm(request, response);
            return;
        }

        if (studentDAO.updateStudent(student)) {
            response.sendRedirect("student?action=list&message=Student updated successfully");
        } else {
            response.sendRedirect("student?action=list&error=Failed to update student");
        }
    }

    private void deleteStudent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));

        if (studentDAO.deleteStudent(id)) {
            response.sendRedirect("student?action=list&message=Student deleted successfully");
        } else {
            response.sendRedirect("student?action=list&error=Failed to delete student");
        }
    }

    private void searchStudents(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        List<Student> students = studentDAO.searchStudents(keyword);

        request.setAttribute("students", students);
        request.setAttribute("keyword", keyword != null ? keyword.trim() : "");

        forwardToList(request, response);
    }

    private void sortStudents(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String sortBy = sanitizeSortBy(request.getParameter("sortBy"));
        String order = sanitizeOrder(request.getParameter("order"));

        List<Student> students = studentDAO.getStudentsSorted(sortBy, order);

        request.setAttribute("students", students);
        request.setAttribute("sortBy", sortBy);
        request.setAttribute("order", order);

        forwardToList(request, response);
    }

    private void filterStudents(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String major = request.getParameter("major");
        List<Student> students = studentDAO.getStudentsByMajor(major);

        request.setAttribute("students", students);
        request.setAttribute("selectedMajor", major);

        forwardToList(request, response);
    }

    private boolean validateStudent(Student student, HttpServletRequest request) {
        boolean isValid = true;

        // Validate student code
        String code = student.getStudentCode();
        if (code == null || code.trim().isEmpty()) {
            request.setAttribute("errorCode", "Student code is required");
            isValid = false;
        } else if (!code.matches("[A-Z]{2}[0-9]{3,}")) {
            request.setAttribute("errorCode", "Use format: 2 uppercase letters + 3 digits (e.g., SV001)");
            isValid = false;
        }

        // Validate full name
        String fullName = student.getFullName();
        if (fullName == null || fullName.trim().length() < 2) {
            request.setAttribute("errorName", "Full name must be at least 2 characters");
            isValid = false;
        }

        // Validate email (optional)
        String email = student.getEmail();
        if (email != null && !email.trim().isEmpty()) {
            String emailPattern = "^[A-Za-z0-9+_.-]+@(.+)$";
            if (!email.matches(emailPattern)) {
                request.setAttribute("errorEmail", "Please provide a valid email address");
                isValid = false;
            }
        }

        // Validate major
        String major = student.getMajor();
        if (major == null || major.trim().isEmpty()) {
            request.setAttribute("errorMajor", "Major is required");
            isValid = false;
        }

        return isValid;
    }

    private void forwardToList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (request.getAttribute("sortBy") == null) {
            request.setAttribute("sortBy", "id");
        }
        if (request.getAttribute("order") == null) {
            request.setAttribute("order", "desc");
        }
        if (request.getAttribute("selectedMajor") == null) {
            request.setAttribute("selectedMajor", "");
        }
        if (request.getAttribute("keyword") == null) {
            request.setAttribute("keyword", "");
        }
        RequestDispatcher dispatcher = request.getRequestDispatcher("/views/student-list.jsp");
        dispatcher.forward(request, response);
    }

    private void forwardToForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RequestDispatcher dispatcher = request.getRequestDispatcher("/views/student-form.jsp");
        dispatcher.forward(request, response);
    }

    private String sanitizeSortBy(String sortBy) {
        if (sortBy == null) {
            return "id";
        }
        String normalized = sortBy.toLowerCase();
        switch (normalized) {
            case "student_code":
            case "full_name":
            case "email":
            case "major":
            case "created_at":
            case "id":
                return normalized;
            default:
                return "id";
        }
    }

    private String sanitizeOrder(String order) {
        return "desc".equalsIgnoreCase(order) ? "desc" : "asc";
    }
}

