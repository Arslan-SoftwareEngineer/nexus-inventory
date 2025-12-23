<%-- 
    Document   : manage_staff
    Created on : Dec 14, 2025, 10:42:00 PM
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
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List"%>
<%@page import="com.ims.dao.UserDAO"%>
<%@page import="com.ims.model.User"%>
<%
    if(session.getAttribute("user") == null) { response.sendRedirect("../login.jsp"); return; }
    UserDAO dao = new UserDAO();
    List<User> userList = dao.getAllUsers();
    
    // Date Formatter
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Team Access | Nexus</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
        :root {
            --primary: #6366f1; --bg-body: #0f172a; --bg-card: #1e293b; --text-main: #f8fafc; --border: #334155; --input-bg: #0f172a;
            --success: #10b981; --success-hover: #34d399;
        }
        body { font-family: 'Inter', sans-serif; background: var(--bg-body); color: var(--text-main); margin: 0; }
        a { text-decoration: none; color: inherit; }
        * { box-sizing: border-box; }

        .navbar { background: rgba(30,41,59,0.9); border-bottom: 1px solid var(--border); padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; }
        .nav-left { display: flex; align-items: center; gap: 25px; }
        .brand { font-weight: 700; color: var(--primary); display: flex; gap: 10px; font-size: 1.1rem; }
        
        .btn-home { color: #94a3b8; font-size: 0.9rem; transition: 0.2s; display: flex; align-items: center; gap: 6px; font-weight: 500; padding: 6px 12px; border-radius: 6px; text-decoration: none !important; } 
        .btn-home:hover { background: rgba(255,255,255,0.05); color: white; }

        .container { max-width: 1200px; margin: 0 auto; padding: 2rem; display: grid; grid-template-columns: 320px 1fr; gap: 2rem; align-items: start; }
        
        .card { background: var(--bg-card); border: 1px solid var(--border); border-radius: 16px; padding: 1.5rem; }
        input, select { width: 100%; padding: 0.7rem; background: var(--input-bg); border: 1px solid var(--border); border-radius: 8px; color: white; margin-bottom: 0.8rem; font-size: 0.9rem; }
        label { display: block; margin-bottom: 0.3rem; font-size: 0.85rem; color: #94a3b8; }
        
        button { width: 100%; padding: 0.8rem; background: var(--success); border: none; border-radius: 8px; color: white; font-weight: 600; cursor: pointer; transition: 0.2s; }
        button:hover { background: var(--success-hover); transform: translateY(-2px); box-shadow: 0 4px 6px -1px rgba(16, 185, 129, 0.4); }

        /* TABLE STYLING FIXED */
        table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
        
        th { 
            text-align: left; 
            color: #94a3b8; 
            padding: 1rem; 
            border-bottom: 1px solid var(--border); 
            font-size: 0.8rem; 
            text-transform: uppercase; 
            letter-spacing: 0.5px;
        }
        
        td { 
            padding: 1rem; 
            border-bottom: 1px solid var(--border); 
            color: white; 
            font-size: 0.9rem; 
            vertical-align: middle; /* Keeps everything centered vertically */
        }
        
        tr:hover td { background: rgba(255,255,255,0.03); }
        
        .badge-role { background: rgba(99, 102, 241, 0.2); color: #818cf8; padding: 4px 8px; border-radius: 6px; font-size: 0.75rem; font-weight: 600; }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="nav-left">
            <div class="brand"><i class="fa-solid fa-layer-group"></i> NexusHR</div>
            <a href="dashboard.jsp" class="btn-home"><i class="fa-solid fa-arrow-left"></i> Dashboard</a>
        </div>
        <div></div>
    </nav>

    <div class="container">
        <div class="card" style="position: sticky; top: 20px;">
            <h3 style="margin-top:0;">Register Employee</h3>
            <form action="${pageContext.request.contextPath}/UserServlet" method="POST">
                <input type="hidden" name="action" value="add">
                
                <label>Full Name</label> <input type="text" name="fullName" required>
                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:10px;">
                    <div><label>Age</label> <input type="number" name="age" required></div>
                    <div>
                        <label>Gender</label> 
                        <select name="gender">
                            <option>Male</option><option>Female</option><option>Other</option>
                        </select>
                    </div>
                </div>
                <label>Monthly Salary ($)</label> <input type="number" name="salary" required>
                <label>Joining Date</label> <input type="date" name="joiningDate" required>
                
                <hr style="border:0; border-top:1px solid var(--border); margin: 15px 0;">
                
                <label>Username</label> <input type="text" name="username" required>
                <label>Password</label> <input type="password" name="password" required>
                <label>Role</label> 
                <select name="role"><option value="cashier">Cashier</option><option value="admin">Administrator</option></select>
                
                <button type="submit">Add Employee</button>
            </form>
        </div>

        <div>
            <h2 style="margin-top:0;">Staff Directory</h2>
            <div class="card" style="padding: 0; overflow: hidden;">
                <table>
                    <thead>
                        <tr>
                            <th style="width: 35%;">Name</th>
                            <th style="width: 15%;">Role</th>
                            <th style="width: 15%;">Salary</th>
                            <th style="width: 20%;">Joined</th>
                            <th style="width: 15%; text-align: right;">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for(User u : userList) { 
                             String joinedDate = (u.getJoiningDate() != null) ? sdf.format(u.getJoiningDate()) : "N/A";
                        %>
                        <tr>
                            <td>
                                <div style="font-weight:600;"><%= u.getFullName() != null ? u.getFullName() : "N/A" %></div>
                                <div style="font-size:0.8rem; color:#94a3b8;">@<%= u.getUsername() %></div>
                            </td>
                            <td><span class="badge-role"><%= u.getRole().toUpperCase() %></span></td>
                            <td>$<%= String.format("%,.0f", u.getSalary()) %></td>
                            <td style="color:#94a3b8;"><%= joinedDate %></td>
                            <td style="text-align: right;">
                                <div style="display:flex; justify-content: flex-end; gap:10px; align-items: center;">
                                    <a href="edit_user.jsp?id=<%= u.getId() %>" style="color:var(--primary);" title="Edit Profile">
                                        <i class="fa-solid fa-pen-to-square"></i>
                                    </a>
                                    
                                    <% if(!"admin".equalsIgnoreCase(u.getUsername())) { %>
                                    <form action="${pageContext.request.contextPath}/UserServlet" method="POST" style="margin:0;">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="<%= u.getId() %>">
                                        <button type="submit" style="background:none; width:auto; padding:0; color:#ef4444; box-shadow:none; font-size: 1rem;" title="Remove User">
                                            <i class="fa-solid fa-trash"></i>
                                        </button>
                                    </form>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>