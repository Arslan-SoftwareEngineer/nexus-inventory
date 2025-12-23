<%-- 
    Document   : reports
    Created on : Dec 14, 2025, 10:42:27 PM
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
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="com.ims.dao.InvoiceDAO"%>
<%@page import="com.ims.model.Invoice"%>
<%
    if(session.getAttribute("user") == null) { response.sendRedirect("../login.jsp"); return; }
    
    InvoiceDAO dao = new InvoiceDAO();
    List<Invoice> invoiceList = dao.getAllInvoices();
    
    // FETCH CHART DATA
    Map<String, Double> revenueMap = dao.getRevenueByDate();
    Map<String, Integer> categoryMap = dao.getSalesByCategory();
    
    // Calculate Total Revenue for Card
    double totalRevenue = 0;
    for(Invoice inv : invoiceList) { totalRevenue += inv.getTotalAmount(); }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Analytics | Nexus</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
        :root {
            --primary: #6366f1; --bg-body: #0f172a; --bg-card: #1e293b; --text-main: #f8fafc; --border: #334155;
            --success: #10b981;
        }
        body { font-family: 'Inter', sans-serif; background: var(--bg-body); color: var(--text-main); margin: 0; }
        
        /* Navbar */
        .navbar { background: rgba(30,41,59,0.9); border-bottom: 1px solid var(--border); padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; }
        .nav-left { display: flex; align-items: center; gap: 25px; }
        .btn-home { color: #94a3b8; font-size: 0.9rem; display: flex; align-items: center; gap: 6px; font-weight: 500; padding: 6px 12px; border-radius: 6px; text-decoration: none; } 
        .btn-home:hover { background: rgba(255,255,255,0.05); color: white; }

        .container { max-width: 1200px; margin: 0 auto; padding: 2rem; }
        
        /* CHART GRID */
        .chart-grid { 
            display: grid; 
            grid-template-columns: 2fr 1fr; /* Revenue chart takes more space */
            gap: 1.5rem; 
            margin-bottom: 2rem; 
        }
        
        /* Cards */
        .card { background: var(--bg-card); border: 1px solid var(--border); border-radius: 16px; padding: 1.5rem; }
        
        /* KPI Cards */
        .kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; margin-bottom: 1.5rem; }

        /* Table */
        table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
        th { text-align: left; color: #94a3b8; padding: 1rem; border-bottom: 1px solid var(--border); }
        td { padding: 1rem; border-bottom: 1px solid var(--border); }
        .badge-done { background: rgba(16, 185, 129, 0.2); color: #6ee7b7; padding: 4px 8px; border-radius: 6px; font-size: 0.8rem; }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="nav-left">
            <div style="color:var(--primary); font-weight:700;"><i class="fa-solid fa-layer-group"></i> NexusAnalytics</div>
            <a href="dashboard.jsp" class="btn-home"><i class="fa-solid fa-arrow-left"></i> Dashboard</a>
        </div>
        <div></div>
    </nav>

    <div class="container">
        
        <div class="kpi-grid">
            <div class="card" style="background: linear-gradient(135deg, #6366f1 0%, #4f46e5 100%); border:none;">
                <p style="color: #e0e7ff; margin:0;">Total Revenue</p>
                <h1 style="color: white; font-size: 2.2rem; margin: 5px 0;">$<%= String.format("%,.2f", totalRevenue) %></h1>
            </div>
            <div class="card">
                <p style="color: #94a3b8; margin:0;">Total Transactions</p>
                <h1 style="font-size: 2.2rem; margin: 5px 0;"><%= invoiceList.size() %></h1>
            </div>
        </div>

        <div class="chart-grid">
            <div class="card">
                <h3 style="margin-top:0; margin-bottom: 15px;">Revenue Trend (Last 7 Days)</h3>
                <div style="height: 300px;">
                    <canvas id="revenueChart"></canvas>
                </div>
            </div>
            
            <div class="card">
                <h3 style="margin-top:0; margin-bottom: 15px;">Sales by Category</h3>
                <div style="height: 300px; display:flex; justify-content:center;">
                    <canvas id="categoryChart"></canvas>
                </div>
            </div>
        </div>

        <h3>Recent Transactions</h3>
        <div class="card" style="padding:0; overflow:hidden;">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Date</th>
                        <th>Cashier</th>
                        <th>Status</th>
                        <th>Receipt</th> <th style="text-align:right;">Amount</th>
                    </tr>
                </thead>
                <tbody>
                    <% for(Invoice inv : invoiceList) { %>
                    <tr>
                        <td style="font-family:monospace; color:#94a3b8;">#<%= inv.getInvoiceId() %></td>
                        <td><%= inv.getDate() %></td>
                        <td><i class="fa-solid fa-user" style="color:var(--primary);"></i> <%= inv.getCashierName() %></td>
                        <td><span class="badge-done">Completed</span></td>
                        
                        <td>
                            <a href="${pageContext.request.contextPath}/ReceiptServlet?id=<%= inv.getInvoiceId() %>&total=<%= inv.getTotalAmount() %>&date=<%= inv.getDate() %>" target="_blank" style="color:#ef4444; font-weight:600; text-decoration:none;">
                                <i class="fa-solid fa-file-pdf"></i> PDF
                            </a>
                        </td>

                        <td style="text-align:right; font-weight:bold;">$<%= inv.getTotalAmount() %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <script>
        // 1. PREPARE DATA FROM JAVA
        // Revenue Data
        const dates = [<% for(String d : revenueMap.keySet()) { %>'<%= d %>',<% } %>];
        const revenues = [<% for(Double val : revenueMap.values()) { %><%= val %>,<% } %>];

        // Category Data
        const categories = [<% for(String c : categoryMap.keySet()) { %>'<%= c %>',<% } %>];
        const catCounts = [<% for(Integer val : categoryMap.values()) { %><%= val %>,<% } %>];

        // 2. RENDER REVENUE CHART (Line)
        new Chart(document.getElementById('revenueChart'), {
            type: 'line',
            data: {
                labels: dates,
                datasets: [{
                    label: 'Revenue ($)',
                    data: revenues,
                    borderColor: '#6366f1',
                    backgroundColor: 'rgba(99, 102, 241, 0.1)',
                    borderWidth: 3,
                    tension: 0.4, // Curvy lines
                    fill: true
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    y: { grid: { color: '#334155' }, ticks: { color: '#94a3b8' } },
                    x: { grid: { display: false }, ticks: { color: '#94a3b8' } }
                }
            }
        });

        // 3. RENDER CATEGORY CHART (Doughnut)
        new Chart(document.getElementById('categoryChart'), {
            type: 'doughnut',
            data: {
                labels: categories,
                datasets: [{
                    data: catCounts,
                    backgroundColor: [
                        '#6366f1', // Indigo
                        '#10b981', // Green
                        '#f59e0b', // Orange
                        '#ef4444', // Red
                        '#ec4899'  // Pink
                    ],
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { 
                    legend: { position: 'bottom', labels: { color: '#94a3b8' } } 
                }
            }
        });
    </script>
</body>
</html>