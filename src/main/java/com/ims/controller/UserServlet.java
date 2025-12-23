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
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;

@WebServlet(name = "UserServlet", urlPatterns = {"/UserServlet"})
public class UserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        UserDAO dao = new UserDAO();

        if ("add".equals(action) || "update".equals(action)) {
            // Capture all fields
            User u = new User();
            u.setUsername(request.getParameter("username"));
            u.setPassword(request.getParameter("password"));
            u.setRole(request.getParameter("role"));
            u.setFullName(request.getParameter("fullName"));
            u.setAge(Integer.parseInt(request.getParameter("age")));
            u.setGender(request.getParameter("gender"));
            u.setSalary(Double.parseDouble(request.getParameter("salary")));
            u.setJoiningDate(Date.valueOf(request.getParameter("joiningDate")));

            if ("add".equals(action)) {
                dao.addUser(u);
                response.sendRedirect("admin/manage_staff.jsp?status=added");
            } else {
                // Update requires ID
                u.setId(Integer.parseInt(request.getParameter("id")));
                dao.updateUser(u);
                response.sendRedirect("admin/manage_staff.jsp?status=updated");
            }

        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            dao.deleteUser(id);
            response.sendRedirect("admin/manage_staff.jsp?status=deleted");
        }
    }
}