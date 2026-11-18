package com.corplab.platform.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * ====================================================================
 * CorpLab Nexus | Pure JDBC Connectivity & Query Verification Engine
 * ====================================================================
 * Demonstrates low-level Java Database Connectivity (JDBC) using:
 * 1. MySQL JDBC Driver (com.mysql.cj.jdbc.Driver)
 * 2. java.sql.DriverManager for connection establishment
 * 3. java.sql.PreparedStatement for SQL injection defense
 * 4. java.sql.ResultSet for tabular cursor processing
 *
 * Can be run standalone inside IntelliJ IDEA (Right-click -> Run 'main()')
 * to verify XAMPP MySQL connection on port 3306 or 3307.
 */
public class JdbcConnectionTester {

    // Default connection parameters (XAMPP MySQL)
    private static final String DB_URL_3307 = "jdbc:mysql://localhost:3307/corplab_enterprise_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String DB_URL_3306 = "jdbc:mysql://localhost:3306/corplab_enterprise_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";

    public static void main(String[] args) {
        System.out.println("====================================================================");
        System.out.println("  CorpLab Nexus | Native JDBC Architecture Verification Engine       ");
        System.out.println("====================================================================");

        // 1. Try port 3307 (Custom XAMPP port)
        boolean connected = testConnection(DB_URL_3307, "Port 3307");

        // 2. Fallback to standard port 3306 if 3307 is not open
        if (!connected) {
            System.out.println("\n[INFO] Attempting standard XAMPP MySQL port 3306...");
            testConnection(DB_URL_3306, "Port 3306");
        }
    }

    public static boolean testConnection(String jdbcUrl, String portLabel) {
        System.out.println("\n[JDBC] Connecting via Driver: com.mysql.cj.jdbc.Driver");
        System.out.println("[JDBC] Target URL: " + jdbcUrl);

        try {
            // Step 1: Explicitly load MySQL JDBC Driver class
            Class.forName("com.mysql.cj.jdbc.Driver");

            // Step 2: Establish raw socket connection using DriverManager
            try (Connection connection = DriverManager.getConnection(jdbcUrl, DB_USER, DB_PASSWORD)) {
                System.out.println("[SUCCESS] JDBC Connection established on " + portLabel + "!");
                System.out.println("[INFO] Connected Database Product: " + connection.getMetaData().getDatabaseProductName());
                System.out.println("[INFO] Database Product Version: " + connection.getMetaData().getDatabaseProductVersion());

                // Step 3: Execute a parameterized PreparedStatement query
                String sql = "SELECT id, username, email, role, department FROM users WHERE role = ? LIMIT 5";
                try (PreparedStatement stmt = connection.prepareStatement(sql)) {
                    stmt.setString(1, "ADMIN");

                    // Step 4: Process the tabular ResultSet
                    try (ResultSet rs = stmt.executeQuery()) {
                        System.out.println("\n--- Query Execution: " + sql + " ---");
                        while (rs.next()) {
                            long id = rs.getLong("id");
                            String username = rs.getString("username");
                            String email = rs.getString("email");
                            String role = rs.getString("role");
                            String dept = rs.getString("department");
                            System.out.printf("  -> User [ID=%d, Username=%s, Email=%s, Role=%s, Dept=%s]%n", id, username, email, role, dept);
                        }
                    }
                }
                return true;
            }
        } catch (ClassNotFoundException e) {
            System.err.println("[ERROR] MySQL JDBC Driver not found on classpath: " + e.getMessage());
            return false;
        } catch (SQLException e) {
            System.err.println("[WARNING] JDBC Connection failed on " + portLabel + ": " + e.getMessage());
            return false;
        }
    }
}
