/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

package com.ims.util;

/**
 *
 * @author ars3lan
 */

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {

    // 1. Database Configuration
    // Ensure "inventory_db" matches the database name you created in SQL
    private static final String URL = "jdbc:mysql://localhost:3306/inventory_db"; 
    
    // 2. Credentials
    // CHANGE THESE to match your local MySQL settings
    private static final String USER = "root";      // Default for XAMPP/WAMP is often "root"
    private static final String PASSWORD = "";      // Default is often empty or "root" or "1234"

    // 3. The Connection Method
    public static Connection getConnection() {
        Connection con = null;
        try {
            // Load the MySQL JDBC Driver
            // This line is often required in Web Apps to ensure the driver is found
            Class.forName("com.mysql.cj.jdbc.Driver");

            // Attempt to establish the connection
            con = DriverManager.getConnection(URL, USER, PASSWORD);
            
        } catch (ClassNotFoundException | SQLException e) {
            System.out.println(">>> Error: Database Connection Failed! <<<");
            e.printStackTrace(); // Prints the error to your NetBeans Output window
        }
        return con;
    }
    
    // 4. Quick Test (Optional)
    // You can right-click this file and choose "Run File" to test the connection immediately.
    public static void main(String[] args) {
        Connection con = getConnection();
        if (con != null) {
            System.out.println(">>> Success: Connection Established! <<<");
        } else {
            System.out.println(">>> Failed: Could not connect. Check console for errors. <<<");
        }
    }
}