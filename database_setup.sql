-- Student Management Database Setup Script
-- Run this script in MySQL to set up the database and table

-- Create database
CREATE DATABASE IF NOT EXISTS student_management;
USE student_management;

-- Create students table
CREATE TABLE IF NOT EXISTS students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_code VARCHAR(20) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    major VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO students (student_code, full_name, email, major) VALUES
('SV001', 'John Doe', 'john.doe@example.com', 'Computer Science'),
('SV002', 'Jane Smith', 'jane.smith@example.com', 'Information Technology'),
('IT001', 'Bob Johnson', 'bob.johnson@example.com', 'Software Engineering'),
('IT002', 'Alice Williams', 'alice.williams@example.com', 'Business Administration'),
('SV003', 'Charlie Brown', 'charlie.brown@example.com', 'Computer Science');

-- Verify data
SELECT * FROM students;

