package com.student.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/logout")
public class LogoutController extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get session (don't create if doesn't exist)
        HttpSession session = request.getSession(false);
        
        // If session exists, invalidate it
        if (session != null) {
            session.invalidate();
        }
        
        // Redirect to login with success message
        response.sendRedirect("login?message=You have been logged out successfully");
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}

