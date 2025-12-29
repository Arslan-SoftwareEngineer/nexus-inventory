<%-- 
    Document   : dashboard
    Created on : Dec 14, 2025, 10:41:36 PM
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
<!DOCTYPE html>
<html>
<head>
    <title>Dashboard | Nexus Inventory Management</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
        
        :root {
            --primary: #6366f1; --primary-hover: #818cf8;
            --bg-body: #0f172a; --bg-card: #1e293b;
            --text-main: #f8fafc; --text-muted: #94a3b8;
            --border: #334155;
            --success: #10b981; /* Green for Reports */
            --team: #f59e0b;    /* Orange for Team Access */
        }

        body { font-family: 'Inter', sans-serif; background-color: var(--bg-body); color: var(--text-main); margin: 0; }
        a { text-decoration: none; color: inherit; }
        * { box-sizing: border-box; }

        /* Navbar */
        .navbar {
            background: rgba(30, 41, 59, 0.9); backdrop-filter: blur(10px);
            border-bottom: 1px solid var(--border); padding: 1rem 2rem;
            display: flex; justify-content: space-between; align-items: center;
        }
        .brand { font-size: 1.25rem; font-weight: 700; color: var(--primary); display: flex; gap: 10px; align-items: center; }

        .btn-danger { background: rgba(239, 68, 68, 0.2); color: #fca5a5; border: 1px solid rgba(239, 68, 68, 0.5); padding: 0.5rem 1rem; border-radius: 8px; font-weight: 500; display: flex; align-items: center; gap: 8px; }
        .btn-danger:hover { background: rgba(239, 68, 68, 0.3); }

        /* Container & Grid */
        .container { max-width: 1200px; margin: 0 auto; padding: 2rem; }
        .grid-3 { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 1.5rem; margin-top: 2rem; }

        /* Cards */
        .card {
            background: var(--bg-card); border: 1px solid var(--border);
            border-radius: 16px; padding: 2rem; transition: 0.2s;
            display: flex; flex-direction: column; height: 100%;
        }
        .card:hover { transform: translateY(-5px); border-color: var(--primary); }
        
        .icon-box {
            width: 50px; height: 50px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; margin-bottom: 1.5rem;
        }
        
        h3 { margin: 0 0 0.5rem 0; }
        p { color: var(--text-muted); margin: 0; font-size: 0.9rem; line-height: 1.5; }

        /* Button Styles */
        .btn-outline {
             border: 1px solid var(--border); 
             color: var(--text-muted); 
             padding: 0.75rem; 
             border-radius: 8px; 
             text-align: center; 
             margin-top: 2rem; 
             display: block; 
             transition: 0.2s;
             font-weight: 500;
        }
        
        /* HOVER: Purple for Stock Button */
        .btn-stock:hover {
            background-color: var(--primary) !important;
            border-color: var(--primary) !important;
            color: white !important;
        }

        /* HOVER: Green for Reports Button */
        .btn-reports:hover {
            background-color: var(--success) !important;
            border-color: var(--success) !important;
            color: white !important;
        }

        /* HOVER: Orange for Team Button */
        .btn-team:hover {
            background-color: var(--team) !important;
            border-color: var(--team) !important;
            color: white !important;
        }

    </style>
</head>
<body>

    <nav class="navbar">
        <div class="brand"><i class="fa-solid fa-layer-group"></i> Nexus Inventory</div>
        <a href="${pageContext.request.contextPath}/LogoutServlet" class="btn-danger"><i class="fa-solid fa-power-off"></i> Logout</a>
    </nav>

    <div class="container">
        <h2 style="margin-bottom: 5px;">Dashboard Overview</h2>
        <p style="color: var(--text-muted);">Welcome back, Administrator.</p>

        <div class="grid-3">
            <div class="card">
                <div class="icon-box" style="background: rgba(99, 102, 241, 0.2); color: #818cf8;"><i class="fa-solid fa-boxes-stacked"></i></div>
                <h3>Inventory</h3>
                <p>Manage product catalog, update stock, and pricing.</p>
                <a href="manage_products.jsp" class="btn-outline btn-stock">Manage Stock</a>
            </div>

            <div class="card">
                <div class="icon-box" style="background: rgba(16, 185, 129, 0.2); color: #34d399;"><i class="fa-solid fa-chart-pie"></i></div>
                <h3>Analytics</h3>
                <p>View sales performance and revenue history.</p>
                <a href="reports.jsp" class="btn-outline btn-reports">View Reports</a>
            </div>

            <div class="card">
                <div class="icon-box" style="background: rgba(245, 158, 11, 0.2); color: #f59e0b;">
                    <i class="fa-solid fa-users"></i>
                </div>
                <h3>Team Access</h3>
                <p>Manage cashier roles and create new accounts.</p>
                <a href="manage_staff.jsp" class="btn-outline btn-team">Manage Staff</a>
            </div>
        </div>
    </div>
</body>
</html>