# Student Management System - Setup Instructions

## Prerequisites

1. **JDK 8 or higher** (required for compilation) ⚠️ **CURRENTLY MISSING**
   - **You have JRE but need JDK!** See [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed installation instructions
   - Quick install: Download from https://adoptium.net/ (Temurin 8 or 11)
   - Make sure `JAVA_HOME` is set to your JDK installation (not JRE)
   - Verify with: `javac -version` (this command will fail if you only have JRE)

2. **MySQL Database** (currently not detected)
   - **Option A: Install MySQL Server**
     - Download: https://dev.mysql.com/downloads/mysql/
     - Or use MySQL Installer for Windows: https://dev.mysql.com/downloads/installer/
     - During installation, remember the root password you set
   - **Option B: Use XAMPP/WAMP** (easier for development)
     - XAMPP: https://www.apachefriends.org/ (includes MySQL)
     - WAMP: https://www.wampserver.com/ (includes MySQL)
   - After installation, add MySQL to PATH or use full path to mysql.exe

3. **Maven** (already installed ✓)

## Setup Steps

### 1. Set up the Database

**If MySQL is in your PATH:**
```bash
# Connect to MySQL and run:
mysql -u root -p < database_setup.sql

# Or manually:
mysql -u root -p
# Then copy and paste the contents of database_setup.sql
```

**If using XAMPP:**
```bash
# Use full path:
C:\xampp\mysql\bin\mysql.exe -u root -p < database_setup.sql
```

**If using MySQL installed separately:**
```bash
# Find MySQL installation (usually in Program Files):
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p < database_setup.sql
```

**Alternative: Use MySQL Workbench or phpMyAdmin**
- Open MySQL Workbench or phpMyAdmin
- Connect to your MySQL server
- Open and execute the `database_setup.sql` file

### 2. Configure Database Connection

Edit `src/main/java/com/student/dao/StudentDAO.java` and update the database credentials if needed:
- `JDBC_USER`: Default is "root"
- `JDBC_PASSWORD`: Update with your MySQL password (currently empty)

### 3. Build and Run

**Option 1: Using Jetty Maven Plugin (Recommended)**
```bash
# Build the project
mvn clean package

# Run with Jetty (supports Jakarta EE)
mvn jetty:run
```

**Option 2: Deploy to External Tomcat Server**
```bash
# Build the WAR file
mvn clean package

# Copy the WAR file to Tomcat webapps directory
# Copy: target/student-management-mvc.war
# To: [TOMCAT_HOME]/webapps/
# Then start Tomcat server
```

**Option 3: Using IDE (Eclipse/IntelliJ)**
1. Import as Maven project
2. Add Tomcat 10+ server (for Jakarta EE support)
3. Deploy the project
4. Run on server

The application will be available at: **http://localhost:8080**

## Alternative: Using an IDE

If you have Eclipse or IntelliJ IDEA:
1. Import as Maven project
2. Configure Tomcat server
3. Deploy and run



