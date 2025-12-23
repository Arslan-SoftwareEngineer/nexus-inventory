/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ims.dao;

/**
 *
 * @author ars3lan
 */

import com.ims.model.Product;
import com.ims.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    // 1. ADD a new product
    public boolean addProduct(Product p) {
        String sql = "INSERT INTO products (name, category, price, quantity, supplier_id) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            
            pst.setString(1, p.getName());
            pst.setString(2, p.getCategory());
            pst.setDouble(3, p.getPrice());
            pst.setInt(4, p.getQuantity());
            // For now, we default supplier to 1 (since you have a dummy supplier)
            pst.setInt(5, 1); 

            int rows = pst.executeUpdate();
            return rows > 0; // Returns true if saved successfully
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 2. GET ALL products (to show in the table)
    public List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM products";

        try (Connection con = DatabaseConnection.getConnection();
             Statement stmt = con.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("product_id"));
                p.setName(rs.getString("name"));
                p.setCategory(rs.getString("category"));
                p.setPrice(rs.getDouble("price"));
                p.setQuantity(rs.getInt("quantity"));
                list.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // 3. DELETE a product
    public void deleteProduct(int id) {
        String sql = "DELETE FROM products WHERE product_id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setInt(1, id);
            pst.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    // 4. GET SINGLE PRODUCT (For Editing)
    public Product getProductById(int id) {
        Product p = null;
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement pst = con.prepareStatement("SELECT * FROM products WHERE product_id = ?")) {
            pst.setInt(1, id);
            ResultSet rs = pst.executeQuery();
            if (rs.next()) {
                p = new Product();
                p.setId(rs.getInt("product_id"));
                p.setName(rs.getString("name"));
                p.setCategory(rs.getString("category"));
                p.setPrice(rs.getDouble("price"));
                p.setQuantity(rs.getInt("quantity"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return p;
    }

    // 5. UPDATE PRODUCT
    public boolean updateProduct(Product p) {
        String sql = "UPDATE products SET name=?, category=?, price=?, quantity=? WHERE product_id=?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, p.getName());
            pst.setString(2, p.getCategory());
            pst.setDouble(3, p.getPrice());
            pst.setInt(4, p.getQuantity());
            pst.setInt(5, p.getId());
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}