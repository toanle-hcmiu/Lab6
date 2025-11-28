-- Student Management Database Setup Script
-- Lab 6: Authentication & Session Management
-- Run this script in MySQL to set up the complete database

-- Create database
CREATE DATABASE IF NOT EXISTS student_management;
USE student_management;

-- ========================================
-- 1. Create students table
-- ========================================
CREATE TABLE IF NOT EXISTS students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_code VARCHAR(20) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    major VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample students data
INSERT INTO students (student_code, full_name, email, major) VALUES
('SV001', 'John Doe', 'john.doe@example.com', 'Computer Science'),
('SV002', 'Jane Smith', 'jane.smith@example.com', 'Information Technology'),
('IT001', 'Bob Johnson', 'bob.johnson@example.com', 'Software Engineering'),
('IT002', 'Alice Williams', 'alice.williams@example.com', 'Business Administration'),
('SV003', 'Charlie Brown', 'charlie.brown@example.com', 'Computer Science');

-- ========================================
-- 2. Create users table (Lab 6)
-- ========================================
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role ENUM('admin', 'user') DEFAULT 'user',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL
);

-- ========================================
-- 3. Insert test users with hashed passwords
-- ========================================
-- Note: Passwords are hashed using BCrypt
-- All test accounts use password: password123

-- IMPORTANT: Run PasswordHashGenerator.java first, or use these pre-hashed passwords
-- BCrypt hash for "password123": $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy

INSERT INTO users (username, password, full_name, role) VALUES
('admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Admin User', 'admin'),
('john', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'John Doe', 'user'),
('jane', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Jane Smith', 'user');

-- ========================================
-- 4. Verify setup
-- ========================================
-- Check students table
SELECT '=== Students Table ===' AS '';
SELECT * FROM students;

-- Check users table
SELECT '=== Users Table ===' AS '';
SELECT id, username, full_name, role, is_active, created_at FROM users;

-- Done!
SELECT '=== Setup Complete! ===' AS '';
SELECT 'You can now run the application!' AS '';
