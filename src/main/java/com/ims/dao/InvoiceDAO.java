/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ims.dao;

/**
 *
 * @author ars3lan
 */

import com.ims.model.Invoice;
import com.ims.model.InvoiceItem;
import com.ims.util.DatabaseConnection;
import java.sql.*;
import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.LinkedHashMap; // Important to keep date order

public class InvoiceDAO {

    // ---------------------------------------------------
    // METHOD 1: CREATE SALE (Transaction)
    // ---------------------------------------------------
    public boolean createSale(Invoice invoice, List<InvoiceItem> items) {
        Connection con = null;
        try {
            con = DatabaseConnection.getConnection();
            
            // 1. Turn OFF auto-commit to start a transaction
            con.setAutoCommit(false);

            // 2. Insert the Invoice (Header)
            String sqlInvoice = "INSERT INTO invoices (cashier_id, total_amount) VALUES (?, ?)";
            PreparedStatement pstInvoice = con.prepareStatement(sqlInvoice, Statement.RETURN_GENERATED_KEYS);
            pstInvoice.setInt(1, invoice.getCashierId());
            pstInvoice.setDouble(2, invoice.getTotalAmount());
            pstInvoice.executeUpdate();

            // Get the generated Invoice ID
            ResultSet rs = pstInvoice.getGeneratedKeys();
            int newInvoiceId = 0;
            if (rs.next()) {
                newInvoiceId = rs.getInt(1);
            }

            // 3. Insert Invoice Items & Update Stock
            String sqlItem = "INSERT INTO invoice_items (invoice_id, product_id, quantity, sub_total) VALUES (?, ?, ?, ?)";
            String sqlStock = "UPDATE products SET quantity = quantity - ? WHERE product_id = ?";
            
            PreparedStatement pstItem = con.prepareStatement(sqlItem);
            PreparedStatement pstStock = con.prepareStatement(sqlStock);

            for (InvoiceItem item : items) {
                // Add Item
                pstItem.setInt(1, newInvoiceId);
                pstItem.setInt(2, item.getProductId());
                pstItem.setInt(3, item.getQuantity());
                pstItem.setDouble(4, item.getSubTotal());
                pstItem.addBatch();

                // Deduct Stock
                pstStock.setInt(1, item.getQuantity());
                pstStock.setInt(2, item.getProductId());
                pstStock.addBatch();
            }

            // Execute all updates
            pstItem.executeBatch();
            pstStock.executeBatch();

            // 4. COMMIT EVERYTHING
            con.commit();
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            try {
                if (con != null) con.rollback(); // Undo if error
            } catch (SQLException ex) { ex.printStackTrace(); }
            return false;
        } finally {
            try { if (con != null) con.setAutoCommit(true); } catch (SQLException e) {}
        }
    } // <--- END OF createSale METHOD

    
    // ---------------------------------------------------
    // METHOD 2: GET ALL INVOICES (For Admin Report)
    // ---------------------------------------------------
    public List<Invoice> getAllInvoices() {
        List<Invoice> list = new ArrayList<>();
        
        // Join query to get Cashier Name
        String sql = "SELECT i.invoice_id, i.date, i.total_amount, u.username " +
                     "FROM invoices i " +
                     "JOIN users u ON i.cashier_id = u.user_id " +
                     "ORDER BY i.date DESC";

        try (Connection con = DatabaseConnection.getConnection();
             Statement stmt = con.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Invoice inv = new Invoice();
                inv.setInvoiceId(rs.getInt("invoice_id"));
                inv.setDate(rs.getTimestamp("date"));
                inv.setTotalAmount(rs.getDouble("total_amount"));
                inv.setCashierName(rs.getString("username")); 
                list.add(inv);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    } // <--- END OF getAllInvoices METHOD
    
    // --------------------------------------------------------
    // CHART 1: GET REVENUE BY DATE (Last 7 Entries)
    // --------------------------------------------------------
    public Map<String, Double> getRevenueByDate() {
        Map<String, Double> map = new LinkedHashMap<>();
        String sql = "SELECT date, SUM(total_amount) as total FROM invoices GROUP BY date ORDER BY date ASC LIMIT 7";
        
        try (Connection con = DatabaseConnection.getConnection();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            
            while(rs.next()) {
                map.put(rs.getString("date"), rs.getDouble("total"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return map;
    }

    // --------------------------------------------------------
    // CHART 2: GET SALES BY CATEGORY
    // --------------------------------------------------------
    public Map<String, Integer> getSalesByCategory() {
        Map<String, Integer> map = new HashMap<>();
        // Join products and invoice_items to count quantities per category
        String sql = "SELECT p.category, SUM(ii.quantity) as qty " +
                     "FROM invoice_items ii " +
                     "JOIN products p ON ii.product_id = p.product_id " +
                     "GROUP BY p.category";
                     
        try (Connection con = DatabaseConnection.getConnection();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            
            while(rs.next()) {
                map.put(rs.getString("category"), rs.getInt("qty"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return map;
    }
    // --------------------------------------------------------
    // 3. SAVE INVOICE (Checkout Logic)
    // --------------------------------------------------------
    public boolean saveInvoice(com.ims.model.User cashier, java.util.List<com.ims.model.Product> cart) {
        Connection con = null;
        PreparedStatement pstInvoice = null;
        PreparedStatement pstItem = null;
        PreparedStatement pstStock = null;
        ResultSet rs = null;
        boolean isSuccess = false;
        
        System.out.println("--- CHECKOUT DEBUG START ---");
        System.out.println("Cashier ID: " + cashier.getId());
        System.out.println("Cart Size: " + cart.size());

        try {
            con = DatabaseConnection.getConnection();
            con.setAutoCommit(false); 
            
            // 1. Calculate Total
            double total = 0;
            for(com.ims.model.Product p : cart) { total += (p.getPrice() * p.getQuantity()); }
            
            // 2. Insert Invoice
            // Using NOW() for datetime. Ensure your DB column is DATETIME or TIMESTAMP
            String sqlInv = "INSERT INTO invoices (cashier_id, date, total_amount) VALUES (?, NOW(), ?)";
            
            pstInvoice = con.prepareStatement(sqlInv, Statement.RETURN_GENERATED_KEYS);
            pstInvoice.setInt(1, cashier.getId()); 
            pstInvoice.setDouble(2, total);
            
            int rowsAffected = pstInvoice.executeUpdate();
            System.out.println("Invoice Insert Rows: " + rowsAffected);
            
            rs = pstInvoice.getGeneratedKeys();
            int invoiceId = 0;
            if(rs.next()) { invoiceId = rs.getInt(1); }
            System.out.println("Generated Invoice ID: " + invoiceId);
            
            // 3. Insert Items
            String sqlItem = "INSERT INTO invoice_items (invoice_id, product_id, quantity, price) VALUES (?, ?, ?, ?)";
            String sqlStock = "UPDATE products SET quantity = quantity - ? WHERE product_id = ?";
            
            pstItem = con.prepareStatement(sqlItem);
            pstStock = con.prepareStatement(sqlStock);
            
            for(com.ims.model.Product p : cart) {
                // Add Item
                pstItem.setInt(1, invoiceId);
                pstItem.setInt(2, p.getId());
                pstItem.setInt(3, p.getQuantity());
                pstItem.setDouble(4, p.getPrice());
                pstItem.addBatch();
                
                // Update Stock
                pstStock.setInt(1, p.getQuantity());
                pstStock.setInt(2, p.getId());
                pstStock.addBatch();
            }
            
            pstItem.executeBatch();
            pstStock.executeBatch();
            
            con.commit();
            isSuccess = true;
            System.out.println("--- TRANSACTION COMMITTED SUCCESSFULLY ---");
            
        } catch (SQLException e) {
            e.printStackTrace(); // CHECK YOUR SERVER LOGS FOR THIS
            System.out.println("!!! SQL ERROR: " + e.getMessage());
            try { if(con != null) con.rollback(); } catch(SQLException ex) { ex.printStackTrace(); }
        } finally {
            try { if(rs!=null) rs.close(); if(pstInvoice!=null) pstInvoice.close(); if(pstItem!=null) pstItem.close(); if(pstStock!=null) pstStock.close(); if(con!=null) con.close(); } catch(SQLException e) {}
        }
        return isSuccess;
    }
    // --------------------------------------------------------
    // 4. GET ITEMS FOR RECEIPT
    // --------------------------------------------------------
    public java.util.List<com.ims.model.Product> getInvoiceProducts(int invoiceId) {
        java.util.List<com.ims.model.Product> list = new ArrayList<>();
        String sql = "SELECT p.name, ii.quantity, ii.price " +
                     "FROM invoice_items ii " +
                     "JOIN products p ON ii.product_id = p.product_id " +
                     "WHERE ii.invoice_id = ?";
                     
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setInt(1, invoiceId);
            ResultSet rs = pst.executeQuery();
            
            while(rs.next()) {
                com.ims.model.Product p = new com.ims.model.Product();
                p.setName(rs.getString("name"));
                p.setQuantity(rs.getInt("quantity")); // Sold Qty
                p.setPrice(rs.getDouble("price"));    // Sold Price
                list.add(p);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
}