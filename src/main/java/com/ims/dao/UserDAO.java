/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ims.dao;

/**
 *
 * @author ars3lan
 */

import com.ims.model.User;
import com.ims.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    // 1. CHECK LOGIN (Fixed to capture ID)
    public User checkLogin(String username, String password) {
        User user = null;
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement pst = con.prepareStatement("SELECT * FROM users WHERE username=? AND password=?")) {
            pst.setString(1, username);
            pst.setString(2, password);
            ResultSet rs = pst.executeQuery();
            
            if (rs.next()) {
                user = new User();
                user.setId(rs.getInt("user_id")); // CRITICAL FIX
                user.setUsername(rs.getString("username"));
                user.setRole(rs.getString("role"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return user;
    }

    // 2. GET ALL USERS
    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        try (Connection con = DatabaseConnection.getConnection();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery("SELECT * FROM users")) {
            while (rs.next()) {
                User u = new User();
                u.setId(rs.getInt("user_id"));
                u.setUsername(rs.getString("username"));
                u.setRole(rs.getString("role"));
                u.setFullName(rs.getString("full_name"));
                u.setSalary(rs.getDouble("salary"));
                u.setJoiningDate(rs.getDate("joining_date"));
                list.add(u);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // 3. GET USER BY ID
    public User getUserById(int id) {
        User u = null;
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement pst = con.prepareStatement("SELECT * FROM users WHERE user_id=?")) {
            pst.setInt(1, id);
            ResultSet rs = pst.executeQuery();
            if (rs.next()) {
                u = new User();
                u.setId(rs.getInt("user_id"));
                u.setUsername(rs.getString("username"));
                u.setPassword(rs.getString("password"));
                u.setRole(rs.getString("role"));
                u.setFullName(rs.getString("full_name"));
                u.setAge(rs.getInt("age"));
                u.setGender(rs.getString("gender"));
                u.setSalary(rs.getDouble("salary"));
                u.setJoiningDate(rs.getDate("joining_date"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return u;
    }

    // 4. ADD USER
    public boolean addUser(User u) {
        String sql = "INSERT INTO users (username, password, role, full_name, age, gender, salary, joining_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, u.getUsername());
            pst.setString(2, u.getPassword());
            pst.setString(3, u.getRole());
            pst.setString(4, u.getFullName());
            pst.setInt(5, u.getAge());
            pst.setString(6, u.getGender());
            pst.setDouble(7, u.getSalary());
            pst.setDate(8, u.getJoiningDate());
            return pst.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // 5. UPDATE USER
    public boolean updateUser(User u) {
        String sql = "UPDATE users SET username=?, password=?, role=?, full_name=?, age=?, gender=?, salary=?, joining_date=? WHERE user_id=?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, u.getUsername());
            pst.setString(2, u.getPassword());
            pst.setString(3, u.getRole());
            pst.setString(4, u.getFullName());
            pst.setInt(5, u.getAge());
            pst.setString(6, u.getGender());
            pst.setDouble(7, u.getSalary());
            pst.setDate(8, u.getJoiningDate());
            pst.setInt(9, u.getId());
            return pst.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // 6. DELETE USER
    public void deleteUser(int id) {
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement pst = con.prepareStatement("DELETE FROM users WHERE user_id = ?")) {
            pst.setInt(1, id);
            pst.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }
}