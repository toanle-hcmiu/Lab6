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
            margin: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
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
        .success {
            background-color: #d4edda;
            color: #155724;
            padding: 12px;
            border-radius: 4px;
            margin-bottom: 20px;
            border: 1px solid #c3e6cb;
        }
        .error {
            background-color: #f8d7da;
            color: #721c24;
            padding: 12px;
            border-radius: 4px;
            margin-bottom: 20px;
            border: 1px solid #f5c6cb;
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
    <div class="container">
        <h1>📚 Student Management (MVC)</h1>

        <!-- Display success message -->
        <c:if test="${not empty param.message}">
            <div class="success">${param.message}</div>
        </c:if>

        <!-- Display error message -->
        <c:if test="${not empty param.error}">
            <div class="error">${param.error}</div>
        </c:if>

        <!-- Add new student button -->
        <a href="student?action=new" class="btn">➕ Add New Student</a>

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
                    <th>Actions</th>
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
                                <td class="actions">
                                    <a href="student?action=edit&id=${student.id}" class="btn btn-edit">✏️ Edit</a>
                                    <a href="student?action=delete&id=${student.id}" 
                                       class="btn btn-delete" 
                                       onclick="return confirm('Are you sure you want to delete this student?')">🗑️ Delete</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="6" class="empty-message">No students found. Click "Add New Student" to get started.</td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</body>
</html>

