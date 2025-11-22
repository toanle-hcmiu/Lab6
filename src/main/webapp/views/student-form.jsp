<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>
        <c:set var="isEdit" value="${isEditMode == true}" />
        <c:choose>
            <c:when test="${isEdit}">Edit Student</c:when>
            <c:otherwise>Add New Student</c:otherwise>
        </c:choose>
    </title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            border-bottom: 3px solid #4CAF50;
            padding-bottom: 10px;
            margin-bottom: 30px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: bold;
        }
        input[type="text"],
        input[type="email"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 16px;
            box-sizing: border-box;
        }
        input[type="text"]:read-only {
            background-color: #f5f5f5;
            cursor: not-allowed;
        }
        .btn {
            display: inline-block;
            padding: 12px 24px;
            background-color: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            border: none;
            cursor: pointer;
            font-size: 16px;
            margin-right: 10px;
        }
        .btn:hover {
            background-color: #45a049;
        }
        .btn-cancel {
            background-color: #6c757d;
        }
        .btn-cancel:hover {
            background-color: #5a6268;
        }
        .form-actions {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
        }
        .error-text {
            color: #d32f2f;
            font-size: 14px;
            margin-top: 6px;
            display: block;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>
            <c:choose>
                <c:when test="${isEdit}">✏️ Edit Student</c:when>
                <c:otherwise>➕ Add New Student</c:otherwise>
            </c:choose>
        </h1>

        <form action="student" method="POST">
            <!-- Hidden field for action -->
            <input type="hidden" name="action" value="${isEdit ? 'update' : 'insert'}">

            <!-- Hidden field for id if editing -->
            <c:if test="${isEdit}">
                <input type="hidden" name="id" value="${student.id}">
            </c:if>

            <!-- Student code field -->
            <div class="form-group">
                <label for="studentCode">Student Code:</label>
                <input type="text" 
                       id="studentCode" 
                       name="studentCode" 
                       value="${student.studentCode}" 
                       ${isEdit ? 'readonly' : 'required'}
                       placeholder="e.g., SV001">
                <c:if test="${not empty errorCode}">
                    <span class="error-text">${errorCode}</span>
                </c:if>
            </div>

            <!-- Full name field -->
            <div class="form-group">
                <label for="fullName">Full Name:</label>
                <input type="text" 
                       id="fullName" 
                       name="fullName" 
                       value="${student.fullName}" 
                       required
                       placeholder="Enter full name">
                <c:if test="${not empty errorName}">
                    <span class="error-text">${errorName}</span>
                </c:if>
            </div>

            <!-- Email field -->
            <div class="form-group">
                <label for="email">Email:</label>
                <input type="email" 
                       id="email" 
                       name="email" 
                       value="${student.email}" 
                       placeholder="Enter email address">
                <c:if test="${not empty errorEmail}">
                    <span class="error-text">${errorEmail}</span>
                </c:if>
            </div>

            <!-- Major field -->
            <div class="form-group">
                <label for="major">Major:</label>
                <input type="text" 
                       id="major" 
                       name="major" 
                       value="${student.major}" 
                       required
                       placeholder="Enter major">
                <c:if test="${not empty errorMajor}">
                    <span class="error-text">${errorMajor}</span>
                </c:if>
            </div>

            <!-- Submit button -->
            <div class="form-actions">
                <button type="submit" class="btn">
                    ${isEdit ? 'Update Student' : 'Add Student'}
                </button>
                <a href="student?action=list" class="btn btn-cancel">Cancel</a>
            </div>
        </form>
    </div>
</body>
</html>

