/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ims.controller;

/**
 *
 * @author ars3lan
 */

import com.ims.dao.ProductDAO;
import com.ims.model.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "InventoryServlet", urlPatterns = {"/InventoryServlet"})
public class InventoryServlet extends HttpServlet {

    // Handle form submissions (Add / Update / Delete)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        ProductDAO dao = new ProductDAO();

        // ---------------------------------------------------
        // ACTION 1: ADD PRODUCT
        // ---------------------------------------------------
        if ("add".equals(action)) {
            String name = request.getParameter("name");
            String category = request.getParameter("category");
            double price = Double.parseDouble(request.getParameter("price"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            Product p = new Product();
            p.setName(name);
            p.setCategory(category);
            p.setPrice(price);
            p.setQuantity(quantity);

            boolean success = dao.addProduct(p);

            if (success) {
                response.sendRedirect("admin/manage_products.jsp?status=success");
            } else {
                response.sendRedirect("admin/manage_products.jsp?status=error");
            }

        // ---------------------------------------------------
        // ACTION 2: UPDATE PRODUCT (New Code)
        // ---------------------------------------------------
        } else if ("update".equals(action)) {
            // 1. Capture the ID (hidden field) and new data
            int id = Integer.parseInt(request.getParameter("id"));
            String name = request.getParameter("name");
            String category = request.getParameter("category");
            double price = Double.parseDouble(request.getParameter("price"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            // 2. Create object with NEW data but SAME ID
            Product p = new Product();
            p.setId(id);
            p.setName(name);
            p.setCategory(category);
            p.setPrice(price);
            p.setQuantity(quantity);

            // 3. Update in DB
            dao.updateProduct(p);

            // 4. Return to list
            response.sendRedirect("admin/manage_products.jsp?status=updated");

        // ---------------------------------------------------
        // ACTION 3: DELETE PRODUCT
        // ---------------------------------------------------
        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            dao.deleteProduct(id);
            response.sendRedirect("admin/manage_products.jsp");
        }
    }
}