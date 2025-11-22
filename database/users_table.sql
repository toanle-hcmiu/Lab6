-- Lab 6: Users Table Setup
-- Authentication & Session Management

USE student_management;

-- Create users table
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

-- Note: Run PasswordHashGenerator.java first to generate hashed passwords
-- Then replace YOUR_HASHED_PASSWORD below with the generated hash

-- Insert test users (replace YOUR_HASHED_PASSWORD with actual BCrypt hash)
-- INSERT INTO users (username, password, full_name, role) VALUES
-- ('admin', 'YOUR_HASHED_PASSWORD', 'Admin User', 'admin'),
-- ('john', 'YOUR_HASHED_PASSWORD', 'John Doe', 'user'),
-- ('jane', 'YOUR_HASHED_PASSWORD', 'Jane Smith', 'user');

-- Verify table structure
DESCRIBE users;

