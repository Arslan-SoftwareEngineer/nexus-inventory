<%-- 
    Document   : pos
    Created on : Dec 14, 2025, 10:42:55 PM
    Author     : ars3lan
--%>

<%
    // PREVENT BROWSER CACHING
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies

    // SECURITY CHECK
    if(session.getAttribute("user") == null) { 
        response.sendRedirect("../login.jsp"); 
        return; 
    }
%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="com.ims.dao.ProductDAO"%>
<%@page import="com.ims.model.Product"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if(session.getAttribute("user") == null) { response.sendRedirect("../login.jsp"); return; }

    ProductDAO dao = new ProductDAO();
    List<Product> productList = dao.getAllProducts();
    
    List<Product> cart = (List<Product>) session.getAttribute("cart");
    if(cart == null) cart = new ArrayList<>();
    
    double totalBill = 0;
    for(Product p : cart) { totalBill += (p.getPrice() * p.getQuantity()); }
%>
<!DOCTYPE html>
<html>
<head>
    <title>POS Terminal | Nexus</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
        :root {
            --bg-body: #0f172a; --bg-card: #1e293b; --text-main: #f8fafc; --border: #334155; --input-bg: #0f172a;
            --primary: #6366f1; --success: #10b981; --success-hover: #34d399;
        }
        body { font-family: 'Inter', sans-serif; background: var(--bg-body); color: var(--text-main); margin: 0; display: flex; height: 100vh; overflow: hidden; }
        * { box-sizing: border-box; }
        a { text-decoration: none; }

        .layout { display: grid; grid-template-columns: 1fr 400px; width: 100%; height: 100%; }
        
        .catalog-section { padding: 2rem; overflow-y: auto; position: relative; } /* Added relative for absolute positioning if needed */
        
        .catalog-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; }

        .product-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 1.5rem; }

        .card {
            background: var(--bg-card); border: 1px solid var(--border); border-radius: 16px; padding: 1.5rem;
            display: flex; flex-direction: column; height: 100%; transition: 0.2s;
        }
        .card:hover { border-color: var(--primary); transform: translateY(-3px); }

        .icon-box { font-size: 2rem; color: #94a3b8; margin-bottom: 1rem; text-align: center; }
        h3 { margin: 0 0 0.5rem 0; font-size: 1.1rem; text-align: center; }
        .qty-text { color: #94a3b8; font-size: 0.9rem; text-align: center; margin: 0; }
        .price-text { color: var(--primary); font-size: 1.2rem; font-weight: 700; text-align: center; margin: 0.5rem 0 1.5rem 0; }

        .add-form { margin-top: auto; display: flex; gap: 10px; }
        input[type="number"] { width: 60px; padding: 0.5rem; background: var(--input-bg); border: 1px solid var(--border); border-radius: 8px; color: white; text-align: center; }
        .btn-add { flex: 1; padding: 0.5rem; background: var(--primary); border: none; border-radius: 8px; color: white; font-weight: 600; cursor: pointer; transition: 0.2s; }
        .btn-add:hover { background: #818cf8; }

        .bill-section { background: rgba(30,41,59,0.5); border-left: 1px solid var(--border); padding: 2rem; display: flex; flex-direction: column; }
        .bill-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; }
        .btn-clear { color: #ef4444; background: none; border: none; font-weight: 600; cursor: pointer; }

        .bill-items { flex: 1; overflow-y: auto; margin-bottom: 1rem; padding-right: 5px; }
        .cart-item { display: flex; justify-content: space-between; align-items: center; padding: 10px; border-bottom: 1px solid var(--border); font-size: 0.95rem; }
        .cart-item:last-child { border-bottom: none; }
        
        .total-section { margin-top: auto; border-top: 2px dashed var(--border); padding-top: 1rem; }
        .btn-checkout { width: 100%; padding: 1rem; background: var(--success); border: none; border-radius: 8px; color: white; font-weight: 700; font-size: 1.1rem; cursor: pointer; }
        .btn-checkout:hover { background: var(--success-hover); }

        .btn-logout { background: rgba(239, 68, 68, 0.1); color: #fca5a5; border: 1px solid rgba(239, 68, 68, 0.5); padding: 0.5rem 1rem; border-radius: 8px; font-weight: 500; display: flex; align-items: center; gap: 8px; font-size: 0.9rem; transition: 0.2s; }
        .btn-logout:hover { background: rgba(239, 68, 68, 0.2); color: #ef4444; border-color: #ef4444; }

        /* --- NEW NOTIFICATION STYLES --- */
        .notification {
            position: fixed;
            top: -100px; /* Hidden initially */
            left: 50%;
            transform: translateX(-50%);
            padding: 1rem 2rem;
            border-radius: 12px;
            color: white;
            font-weight: 600;
            box-shadow: 0 10px 25px rgba(0,0,0,0.5);
            z-index: 1000;
            transition: top 0.5s ease-in-out;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .notif-success { background: #10b981; border: 1px solid #059669; }
        .notif-error { background: #ef4444; border: 1px solid #b91c1c; }
        .notif-warning { background: #f59e0b; border: 1px solid #d97706; }
    </style>
</head>
<body>

    <div id="notificationBanner" class="notification">
        <i id="notifIcon" class="fa-solid"></i>
        <span id="notifMessage">Message goes here</span>
    </div>

    <div class="layout">
        <div class="catalog-section">
            <div class="catalog-header">
                <h1 style="margin:0;">Catalog</h1>
                <a href="${pageContext.request.contextPath}/LogoutServlet" class="btn-logout"><i class="fa-solid fa-power-off"></i> Logout</a>
            </div>
            
            <div class="product-grid">
                <% for(Product p : productList) { %>
                <div class="card">
                    <div class="icon-box"><i class="fa-solid fa-box-open"></i></div>
                    <h3><%= p.getName() %></h3>
                    <p class="qty-text">In Stock: <%= p.getQuantity() %></p>
                    <p class="price-text">$<%= p.getPrice() %></p>
                    <form class="add-form" action="${pageContext.request.contextPath}/POSServlet" method="POST">
                        <input type="hidden" name="action" value="add">
                        <input type="hidden" name="id" value="<%= p.getId() %>">
                        <input type="number" name="qty" value="1" min="1" max="<%= p.getQuantity() %>">
                        <button type="submit" class="btn-add">Add</button>
                    </form>
                </div>
                <% } %>
            </div>
        </div>

        <div class="bill-section">
            <div class="bill-header">
                <h2>Current Bill</h2>
                <form action="${pageContext.request.contextPath}/POSServlet" method="POST">
                    <input type="hidden" name="action" value="clear">
                    <button type="submit" class="btn-clear">Clear All</button>
                </form>
            </div>
            
            <div class="bill-items">
                <% if(cart.isEmpty()) { %>
                    <div style="text-align:center; color:#94a3b8; margin-top: 50px;">Cart is empty</div>
                <% } else { %>
                    <% for(Product item : cart) { %>
                    <div class="cart-item">
                        <div>
                            <div style="font-weight:600;"><%= item.getName() %></div>
                            <div style="font-size:0.85rem; color:#94a3b8;"><%= item.getQuantity() %> x $<%= item.getPrice() %></div>
                        </div>
                        <div style="font-weight:600;">$<%= item.getPrice() * item.getQuantity() %></div>
                    </div>
                    <% } %>
                <% } %>
            </div>
            
            <div class="total-section">
                <div style="display:flex; justify-content:space-between; margin-bottom: 1rem; font-size: 1.2rem; font-weight: 700;">
                    <span>Total</span>
                    <span>$<%= String.format("%,.2f", totalBill) %></span>
                </div>
                <form action="${pageContext.request.contextPath}/POSServlet" method="POST">
                    <input type="hidden" name="action" value="checkout">
                    <button type="submit" class="btn-checkout">Checkout</button>
                </form>
            </div>
        </div>
    </div>

    <script>
        const urlParams = new URLSearchParams(window.location.search);
        const status = urlParams.get('status');
        const banner = document.getElementById('notificationBanner');
        const msg = document.getElementById('notifMessage');
        const icon = document.getElementById('notifIcon');

        function showNotification(text, type) {
            msg.innerText = text;
            banner.className = 'notification ' + type; // Apply color class
            
            // Set Icon
            if(type === 'notif-success') icon.className = 'fa-solid fa-circle-check';
            else if(type === 'notif-error') icon.className = 'fa-solid fa-circle-xmark';
            else icon.className = 'fa-solid fa-triangle-exclamation';

            // Slide Down
            banner.style.top = '30px';

            // Hide after 3.5 seconds
            setTimeout(() => {
                banner.style.top = '-100px';
            }, 3500);
            
            // Clean URL
            window.history.replaceState(null, null, window.location.pathname);
        }

        if (status === 'success') {
            // Updated Notification with PRINT Button
            msg.innerHTML = `
                Transaction Successful! 
                <% 
                   // Get the LAST invoice ID created (Quick fetch for the link)
                   com.ims.dao.InvoiceDAO linkDao = new com.ims.dao.InvoiceDAO();
                   // NOTE: We need a helper to get Max ID, or we can just link to 'Reports'
                %>
                <a href="../admin/reports.jsp" style="color:white; text-decoration:underline; margin-left:10px;">View in Reports</a>
            `;
            
            showNotification("Transaction Successful! Stock updated.", "notif-success");
        } else if (status === 'failed') {
            showNotification("Transaction Failed. Check Database.", "notif-error");
        } else if (status === 'empty') {
            showNotification("Cart is empty! Add items first.", "notif-warning");
        }
    </script>
</body>
</html>