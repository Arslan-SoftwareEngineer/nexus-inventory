<%-- 
    Document   : edit_user
    Created on : Dec 15, 2025, 7:32:09 PM
    Author     : ars3lan
--%>
<%@page import="com.ims.model.User"%> <%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // 1. PREVENT BROWSER CACHING
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // 2. GET USER
    User user = (User) session.getAttribute("user");

    // 3. SECURITY CHECK: Is user logged in?
    if(user == null) { 
        response.sendRedirect("../login.jsp"); 
        return; 
    }
    
    // 4. ROLE CHECK: Is user an Admin? (The Bouncer)
    if(!"admin".equalsIgnoreCase(user.getRole())) {
        // If you are a Cashier trying to be sneaky, go back to work!
        response.sendRedirect("../cashier/pos.jsp");
        return;
    }
%>
<%@page import="com.ims.dao.UserDAO"%>
<%@page import="com.ims.model.User"%>
<%
    if(session.getAttribute("user") == null) { response.sendRedirect("../login.jsp"); return; }
    int id = Integer.parseInt(request.getParameter("id"));
    UserDAO dao = new UserDAO();
    User u = dao.getUserById(id);
%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit User | Nexus</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
        :root { --primary: #6366f1; --success: #10b981; --success-hover: #34d399; --bg-body: #0f172a; --bg-card: #1e293b; --text-main: #f8fafc; --border: #334155; --input-bg: #0f172a; }
        body { font-family: 'Inter', sans-serif; background: var(--bg-body); color: var(--text-main); display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; }
        
        .card { background: var(--bg-card); border: 1px solid var(--border); border-radius: 16px; padding: 2rem; width: 450px; }
        input, select { width: 100%; padding: 0.8rem; background: var(--input-bg); border: 1px solid var(--border); border-radius: 8px; color: white; margin-bottom: 1rem; box-sizing: border-box; display: block; }
        label { display: block; margin-bottom: 0.5rem; color: #94a3b8; font-size: 0.9rem; }
        
        button[type="submit"] { width: 100%; padding: 1rem; background: var(--success); border: none; border-radius: 8px; color: white; font-weight: 600; cursor: pointer; transition: 0.2s; }
        button[type="submit"]:hover { background: var(--success-hover); transform: translateY(-2px); box-shadow: 0 4px 6px -1px rgba(16, 185, 129, 0.4); }
        
        .btn-cancel { width: 100%; padding: 1rem; background: transparent; border: 1px solid var(--border); color: #94a3b8; margin-top: 10px; border-radius: 8px; font-weight: 600; cursor: pointer; transition: 0.2s; }
        .btn-cancel:hover { border-color: #ef4444; color: #ef4444; background: rgba(239, 68, 68, 0.1); }
    </style>
</head>
<body>
    <div class="card">
        <h2 style="margin-top:0; text-align: center; margin-bottom: 1.5rem;">Edit Employee</h2>
        
        <form action="${pageContext.request.contextPath}/UserServlet" method="POST">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" value="<%= u.getId() %>">
            
            <label>Full Name</label> <input type="text" name="fullName" value="<%= u.getFullName() %>" required>
            
            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:10px;">
                <div><label>Age</label> <input type="number" name="age" value="<%= u.getAge() %>" required></div>
                <div>
                    <label>Gender</label> 
                    <select name="gender">
                        <option <%= "Male".equals(u.getGender()) ? "selected" : "" %>>Male</option>
                        <option <%= "Female".equals(u.getGender()) ? "selected" : "" %>>Female</option>
                        <option <%= "Other".equals(u.getGender()) ? "selected" : "" %>>Other</option>
                    </select>
                </div>
            </div>

            <label>Salary</label> <input type="number" name="salary" value="<%= u.getSalary() %>" required>
            <label>Joining Date</label> <input type="date" name="joiningDate" value="<%= u.getJoiningDate() %>" required>
            
            <hr style="border:0; border-top:1px solid var(--border); margin: 15px 0;">

            <label>Username</label> <input type="text" name="username" value="<%= u.getUsername() %>" required>
            <label>Password</label> <input type="text" name="password" value="<%= u.getPassword() %>" required>
            <label>Role</label> 
            <select name="role">
                <option value="cashier" <%= "cashier".equals(u.getRole()) ? "selected" : "" %>>Cashier</option>
                <option value="admin" <%= "admin".equals(u.getRole()) ? "selected" : "" %>>Administrator</option>
            </select>
            
            <button type="submit">Save Changes</button>
            <a href="manage_staff.jsp" style="text-decoration:none;"><button type="button" class="btn-cancel">Cancel</button></a>
        </form>
    </div>
</body>
</html>