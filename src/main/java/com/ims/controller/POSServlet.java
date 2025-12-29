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
import com.ims.dao.InvoiceDAO; // You'll need this for checkout later
import com.ims.model.Invoice;   // And this
import com.ims.model.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "POSServlet", urlPatterns = {"/POSServlet"})
public class POSServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        
        // 1. GET OR CREATE CART
        List<Product> cart = (List<Product>) session.getAttribute("cart");
        if (cart == null) {
            cart = new ArrayList<>();
        }

        // ---------------------------------------------------
        // ACTION: ADD ITEM
        // ---------------------------------------------------
        if ("add".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            int qty = Integer.parseInt(request.getParameter("qty"));
            
            ProductDAO dao = new ProductDAO();
            Product p = dao.getProductById(id);
            
            // Check if product is already in cart, if so, just update qty
            boolean found = false;
            for(Product item : cart) {
                if(item.getId() == id) {
                    item.setQuantity(item.getQuantity() + qty); // Update cart qty (using quantity field temporarily for cart qty)
                    // Note: In a real app, you'd calculate price * qty here
                    found = true;
                    break;
                }
            }
            
            if(!found) {
                p.setQuantity(qty); // Set the cart quantity
                cart.add(p);
            }
            
            session.setAttribute("cart", cart);
            response.sendRedirect("cashier/pos.jsp"); // Redirect back to your file
        }
        
        // ---------------------------------------------------
        // ACTION: CLEAR CART
        // ---------------------------------------------------
        else if ("clear".equals(action)) {
            session.removeAttribute("cart");
            response.sendRedirect("cashier/pos.jsp");
        }
        
        // ---------------------------------------------------
        // ACTION: CHECKOUT (REAL LOGIC)
        // ---------------------------------------------------
        else if ("checkout".equals(action)) {
            // 1. Get Current User (Cashier)
            com.ims.model.User user = (com.ims.model.User) session.getAttribute("user");
            
            if(user == null) {
                response.sendRedirect("../login.jsp");
                return;
            }

            // 2. Save to DB
            if(cart != null && !cart.isEmpty()) {
                InvoiceDAO dao = new InvoiceDAO();
                boolean success = dao.saveInvoice(user, cart);
                
                if(success) {
                    // 3. Clear Cart & Show Success
                    session.removeAttribute("cart");
                    response.sendRedirect("cashier/pos.jsp?status=success");
                } else {
                    response.sendRedirect("cashier/pos.jsp?status=failed");
                }
            } else {
                response.sendRedirect("cashier/pos.jsp?status=empty");
            }
        }
    }
}