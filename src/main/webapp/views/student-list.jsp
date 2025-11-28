<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Student List</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f5f5f5;
        }
        .navbar {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .navbar h2 {
            margin: 0;
            font-size: 24px;
        }
        .navbar-right {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        .navbar-right a {
            color: white;
            text-decoration: none;
            padding: 8px 15px;
            border-radius: 4px;
            transition: background 0.3s;
        }
        .navbar-right a:hover {
            background: rgba(255,255,255,0.2);
        }
        .user-info {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .role-badge {
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
            text-transform: uppercase;
        }
        .role-badge.role-admin {
            background-color: #ff6b6b;
        }
        .role-badge.role-user {
            background-color: #4ecdc4;
        }
        .container {
            max-width: 1200px;
            margin: 20px auto;
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            border-bottom: 3px solid #4CAF50;
            padding-bottom: 10px;
        }
        .alert {
            padding: 12px;
            border-radius: 4px;
            margin-bottom: 20px;
            border: 1px solid;
        }
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border-color: #c3e6cb;
        }
        .alert-error {
            background-color: #f8d7da;
            color: #721c24;
            border-color: #f5c6cb;
        }
        .btn {
            display: inline-block;
            padding: 10px 20px;
            background-color: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            border: none;
            cursor: pointer;
        }
        .btn-secondary {
            background-color: #2196F3;
        }
        .btn-light {
            background-color: #e0e0e0;
            color: #333;
        }
        .btn:hover {
            background-color: #45a049;
        }
        .btn-secondary:hover {
            background-color: #0b7dda;
        }
        .btn-light:hover {
            background-color: #cacaca;
        }
        .btn-edit {
            background-color: #2196F3;
            padding: 6px 12px;
            font-size: 14px;
        }
        .btn-edit:hover {
            background-color: #0b7dda;
        }
        .btn-delete {
            background-color: #f44336;
            padding: 6px 12px;
            font-size: 14px;
        }
        .btn-delete:hover {
            background-color: #da190b;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #4CAF50;
            color: white;
            font-weight: bold;
        }
        tr:hover {
            background-color: #f5f5f5;
        }
        .actions {
            white-space: nowrap;
        }
        .actions a {
            margin-right: 8px;
        }
        .empty-message {
            text-align: center;
            padding: 40px;
            color: #666;
            font-style: italic;
        }
        .controls {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            margin-bottom: 20px;
            align-items: flex-end;
        }
        .search-box, .filter-box {
            flex: 1;
            min-width: 280px;
        }
        .search-box form,
        .filter-box form {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            align-items: center;
        }
        .search-box input[type="text"],
        .filter-box select {
            flex: 1;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 16px;
        }
        .info-text {
            margin-top: 8px;
            color: #555;
        }
        th a {
            color: white;
            text-decoration: none;
        }
        .sort-indicator {
            margin-left: 4px;
            font-size: 12px;
        }
    </style>
</head>
<body>
    <!-- Navigation Bar -->
    <div class="navbar">
        <h2>📚 Student Management System</h2>
        <div class="navbar-right">
            <div class="user-info">
                <span>Welcome, ${sessionScope.fullName}</span>
                <span class="role-badge role-${sessionScope.role}">
                    ${sessionScope.role}
                </span>
            </div>
            <a href="dashboard">Dashboard</a>
            <a href="logout">Logout</a>
        </div>
    </div>

    <div class="container">
        <h1>📚 Student List</h1>

        <!-- Display success message -->
        <c:if test="${not empty param.message}">
            <div class="alert alert-success">✅ ${param.message}</div>
        </c:if>

        <!-- Display error message -->
        <c:if test="${not empty param.error}">
            <div class="alert alert-error">❌ ${param.error}</div>
        </c:if>

        <!-- Add new student button - Admin only -->
        <c:if test="${sessionScope.role eq 'admin'}">
            <a href="student?action=new" class="btn">➕ Add New Student</a>
        </c:if>

        <div class="controls">
            <div class="search-box">
                <form action="student" method="get">
                    <input type="hidden" name="action" value="search">
                    <input type="text" name="keyword" placeholder="Search by code, name, or email" value="${keyword}">
                    <button type="submit" class="btn btn-secondary">🔍 Search</button>
                    <c:if test="${not empty keyword}">
                        <a href="student?action=list" class="btn btn-light">Clear</a>
                    </c:if>
                </form>
                <c:if test="${not empty keyword}">
                    <p class="info-text">Search results for: <strong>${keyword}</strong></p>
                </c:if>
            </div>

            <div class="filter-box">
                <form action="student" method="get">
                    <input type="hidden" name="action" value="filter">
                    <label for="majorFilter">Filter by Major:</label>
                    <select id="majorFilter" name="major">
                        <option value="" ${empty selectedMajor ? 'selected="selected"' : ''}>All Majors</option>
                        <option value="Computer Science" ${selectedMajor == 'Computer Science' ? 'selected="selected"' : ''}>Computer Science</option>
                        <option value="Information Technology" ${selectedMajor == 'Information Technology' ? 'selected="selected"' : ''}>Information Technology</option>
                        <option value="Software Engineering" ${selectedMajor == 'Software Engineering' ? 'selected="selected"' : ''}>Software Engineering</option>
                        <option value="Business Administration" ${selectedMajor == 'Business Administration' ? 'selected="selected"' : ''}>Business Administration</option>
                    </select>
                    <button type="submit" class="btn btn-secondary">Filter</button>
                    <c:if test="${not empty selectedMajor}">
                        <a href="student?action=list" class="btn btn-light">Clear Filter</a>
                    </c:if>
                </form>
                <c:if test="${not empty selectedMajor}">
                    <p class="info-text">Showing students majoring in <strong>${selectedMajor}</strong></p>
                </c:if>
            </div>
        </div>

        <table>
            <thead>
                <tr>
                    <th>
                        <c:set var="idOrder" value="${sortBy == 'id' && order == 'asc' ? 'desc' : 'asc'}" />
                        <a href="student?action=sort&sortBy=id&order=${idOrder}">ID
                            <c:if test="${sortBy == 'id'}">
                                <span class="sort-indicator">${order == 'asc' ? '▲' : '▼'}</span>
                            </c:if>
                        </a>
                    </th>
                    <th>
                        <c:set var="codeOrder" value="${sortBy == 'student_code' && order == 'asc' ? 'desc' : 'asc'}" />
                        <a href="student?action=sort&sortBy=student_code&order=${codeOrder}">Code
                            <c:if test="${sortBy == 'student_code'}">
                                <span class="sort-indicator">${order == 'asc' ? '▲' : '▼'}</span>
                            </c:if>
                        </a>
                    </th>
                    <th>
                        <c:set var="nameOrder" value="${sortBy == 'full_name' && order == 'asc' ? 'desc' : 'asc'}" />
                        <a href="student?action=sort&sortBy=full_name&order=${nameOrder}">Name
                            <c:if test="${sortBy == 'full_name'}">
                                <span class="sort-indicator">${order == 'asc' ? '▲' : '▼'}</span>
                            </c:if>
                        </a>
                    </th>
                    <th>
                        <c:set var="emailOrder" value="${sortBy == 'email' && order == 'asc' ? 'desc' : 'asc'}" />
                        <a href="student?action=sort&sortBy=email&order=${emailOrder}">Email
                            <c:if test="${sortBy == 'email'}">
                                <span class="sort-indicator">${order == 'asc' ? '▲' : '▼'}</span>
                            </c:if>
                        </a>
                    </th>
                    <th>
                        <c:set var="majorOrder" value="${sortBy == 'major' && order == 'asc' ? 'desc' : 'asc'}" />
                        <a href="student?action=sort&sortBy=major&order=${majorOrder}">Major
                            <c:if test="${sortBy == 'major'}">
                                <span class="sort-indicator">${order == 'asc' ? '▲' : '▼'}</span>
                            </c:if>
                        </a>
                    </th>
                    <c:if test="${sessionScope.role eq 'admin'}">
                        <th>Actions</th>
                    </c:if>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${not empty students}">
                        <c:forEach var="student" items="${students}">
                            <tr>
                                <td>${student.id}</td>
                                <td>${student.studentCode}</td>
                                <td>${student.fullName}</td>
                                <td>${student.email}</td>
                                <td>${student.major}</td>
                                <c:if test="${sessionScope.role eq 'admin'}">
                                    <td class="actions">
                                        <a href="student?action=edit&id=${student.id}" class="btn btn-edit">✏️ Edit</a>
                                        <a href="student?action=delete&id=${student.id}" 
                                           class="btn btn-delete" 
                                           onclick="return confirm('Are you sure you want to delete this student?')">🗑️ Delete</a>
                                    </td>
                                </c:if>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="${sessionScope.role eq 'admin' ? '6' : '5'}" class="empty-message">
                                No students found. 
                                <c:if test="${sessionScope.role eq 'admin'}">
                                    Click "Add New Student" to get started.
                                </c:if>
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</body>
</html>

