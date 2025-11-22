# BCrypt Library Setup

## Option 1: Maven Dependency (Recommended)

The `pom.xml` already includes the BCrypt dependency:

```xml
<dependency>
    <groupId>org.mindrot</groupId>
    <artifactId>jbcrypt</artifactId>
    <version>0.4</version>
</dependency>
```

If Maven can't find this dependency, use Option 2.

## Option 2: Manual JAR Installation

1. Download `jbcrypt-0.4.jar` from:
   - https://mvnrepository.com/artifact/org.mindrot/jbcrypt/0.4
   - Or search for "jbcrypt 0.4 jar download"

2. Place the JAR file in: `src/main/webapp/WEB-INF/lib/jbcrypt-0.4.jar`

3. The application will automatically include it in the classpath when deployed.

## Verify Installation

Run `PasswordHashGenerator.java` to verify BCrypt is working:

```bash
# From project root
mvn compile exec:java -Dexec.mainClass="com.student.util.PasswordHashGenerator"
```

You should see output like:
```
Plain Password: password123
Hashed Password: $2a$10$...
Verification test: true
```

## Generate Password Hashes

1. Run `PasswordHashGenerator.java`
2. Copy the generated hash
3. Use it in `database/users_table.sql` INSERT statements

Example:
```sql
INSERT INTO users (username, password, full_name, role) VALUES
('admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Admin User', 'admin');
```

