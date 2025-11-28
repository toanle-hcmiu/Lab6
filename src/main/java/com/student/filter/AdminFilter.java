package com.student.filter;

import com.student.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebFilter(filterName = "AdminFilter", urlPatterns = {"/student"})
public class AdminFilter implements Filter {
    
    // Admin-only actions
    private static final String[] ADMIN_ACTIONS = {
        "new",
        "insert",
        "edit",
        "update",
        "delete"
    };
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("AdminFilter initialized");
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        // Get action parameter
        String action = httpRequest.getParameter("action");
        
        // Check if action requires admin role
        if (isAdminAction(action)) {
            
            // Get session and user
            HttpSession session = httpRequest.getSession(false);
            User user = null;
            
            if (session != null) {
                user = (User) session.getAttribute("user");
            }
            
            // Check if user is admin
            if (user != null && user.isAdmin()) {
                // Allow access
                chain.doFilter(request, response);
            } else {
                // Deny access - redirect with error message
                String contextPath = httpRequest.getContextPath();
                httpResponse.sendRedirect(contextPath + "/student?action=list&error=You do not have permission to perform this action. Admin access required.");
            }
        } else {
            // Not an admin action, allow
            chain.doFilter(request, response);
        }
    }
    
    @Override
    public void destroy() {
        System.out.println("AdminFilter destroyed");
    }
    
    /**
     * Check if the action requires admin role
     */
    private boolean isAdminAction(String action) {
        if (action == null) {
            return false;
        }
        
        for (String adminAction : ADMIN_ACTIONS) {
            if (adminAction.equalsIgnoreCase(action)) {
                return true;
            }
        }
        
        return false;
    }
}

