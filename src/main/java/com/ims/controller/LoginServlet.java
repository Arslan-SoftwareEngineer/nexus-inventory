/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ims.controller;

/**
 *
 * @author ars3lan
 */

import com.ims.dao.UserDAO;
import com.ims.model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

// This annotation maps the URL "/LoginServlet" to this code
@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Retrieve Data from the Form
        String user = request.getParameter("username");
        String pass = request.getParameter("password");
        
        // 2. Check credentials using DAO
        UserDAO dao = new UserDAO();
        User loggedInUser = dao.checkLogin(user, pass);
        
        // 3. Logic Flow
        if (loggedInUser != null) {
            // LOGIN SUCCESS: Start a session
            HttpSession session = request.getSession();
            session.setAttribute("user", loggedInUser);
            
            // Redirect based on Role (Matches your Sequence Diagram logic)
            if ("Admin".equalsIgnoreCase(loggedInUser.getRole())) {
                response.sendRedirect("admin/dashboard.jsp");
            } else if ("Cashier".equalsIgnoreCase(loggedInUser.getRole())) {
                response.sendRedirect("cashier/pos.jsp");
            } else {
                response.sendRedirect("error.jsp"); // Unknown role
            }
            
        } else {
            // LOGIN FAILED: Go back to login page with error flag
            response.sendRedirect("login.jsp?status=failed");
        }
    }
}
