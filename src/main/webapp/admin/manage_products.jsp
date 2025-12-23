<%-- 
    Document   : manage-products
    Created on : Dec 14, 2025, 10:41:52 PM
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
<%@page import="java.util.List"%>
<%@page import="com.ims.dao.ProductDAO"%>
<%@page import="com.ims.model.Product"%>
<%
    if(session.getAttribute("user") == null) { response.sendRedirect("../login.jsp"); return; }
    ProductDAO dao = new ProductDAO();
    List<Product> productList = dao.getAllProducts();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Inventory | Nexus</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
        :root {
            --primary: #6366f1; --bg-body: #0f172a; --bg-card: #1e293b; --text-main: #f8fafc; --border: #334155; --input-bg: #0f172a;
        }
        body { font-family: 'Inter', sans-serif; background: var(--bg-body); color: var(--text-main); margin: 0; }
        
        /* Global link reset to prevent underlines */
        a { text-decoration: none; color: inherit; }
        * { box-sizing: border-box; }

        /* Navbar Layout */
        .navbar { background: rgba(30,41,59,0.9); border-bottom: 1px solid var(--border); padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; }
        
        /* Left Section: Brand + Home Button */
        .nav-left { display: flex; align-items: center; gap: 25px; }
        .brand { font-weight: 700; color: var(--primary); display: flex; gap: 10px; font-size: 1.1rem; }
        
        /* Dashboard Button (No Underline) */
        .btn-home { 
            color: #94a3b8; 
            font-size: 0.9rem; 
            transition: 0.2s; 
            display: flex; 
            align-items: center; 
            gap: 6px; 
            font-weight: 500;
            padding: 6px 12px; 
            border-radius: 6px;
            text-decoration: none !important; /* Forces no underline */
        } 
        .btn-home:hover { background: rgba(255,255,255,0.05); color: white; }

        .container { max-width: 1200px; margin: 0 auto; padding: 2rem; display: grid; grid-template-columns: 350px 1fr; gap: 2rem; align-items: start; }
        
        /* Card & Form */
        .card { background: var(--bg-card); border: 1px solid var(--border); border-radius: 16px; padding: 1.5rem; }
        input, select { width: 100%; padding: 0.8rem; background: var(--input-bg); border: 1px solid var(--border); border-radius: 8px; color: white; margin-bottom: 1rem; }
        label { display: block; margin-bottom: 0.5rem; font-size: 0.9rem; color: #94a3b8; }
        button { 
            width: 100%; 
            padding: 0.8rem; 
            background: #10b981; /* CHANGED FROM var(--primary) TO #10b981 */
            border: none; 
            border-radius: 8px; 
            color: white; 
            font-weight: 600; 
            cursor: pointer; 
            transition: 0.2s; /* Add transition for smooth effect */
        }

        /* Add this NEW rule for hover effect */
        button:hover {
            background: #34d399; 
            transform: translateY(-2px);
            box-shadow: 0 4px 6px -1px rgba(16, 185, 129, 0.4);
        }

        /* Table */
        table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
        th { text-align: left; color: #94a3b8; padding: 1rem; border-bottom: 1px solid var(--border); font-size: 0.85rem; text-transform: uppercase; }
        td { padding: 1rem; border-bottom: 1px solid var(--border); color: white; }
        tr:hover td { background: rgba(255,255,255,0.03); }
        
        .badge-low { background: rgba(239, 68, 68, 0.2); color: #fca5a5; padding: 4px 8px; border-radius: 6px; font-size: 0.8rem; }
        .badge-ok { background: rgba(16, 185, 129, 0.2); color: #6ee7b7; padding: 4px 8px; border-radius: 6px; font-size: 0.8rem; }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="nav-left">
            <div class="brand"><i class="fa-solid fa-layer-group"></i> NexusInventory</div>
            <a href="dashboard.jsp" class="btn-home"><i class="fa-solid fa-arrow-left"></i> Dashboard</a>
        </div>
        
        <div></div>
    </nav>

    <div class="container">
        <div class="card" style="position: sticky; top: 20px;">
            <h3 style="margin-top:0;">Add Product</h3>
            <form action="${pageContext.request.contextPath}/InventoryServlet" method="POST">
                <input type="hidden" name="action" value="add">
                <label>Name</label> <input type="text" name="name" required>
                <label>Category</label> 
                <select name="category"><option>Electronics</option><option>Grocery</option><option>Clothing</option><option>Other</option></select>
                <label>Price</label> <input type="number" step="0.01" name="price" required>
                <label>Quantity</label> <input type="number" name="quantity" required>
                <button type="submit">Save Item</button>
            </form>
        </div>

        <div>
            <h2 style="margin-top:0;">Current Stock</h2>
            <div class="card" style="padding: 0; overflow: hidden;">
                <table>
                    <thead><tr><th>Name</th><th>Category</th><th>Price</th><th>Status</th><th>Action</th></tr></thead>
                    <tbody>
                        <% for(Product p : productList) { %>
                        <tr>
                            <td><%= p.getName() %></td>
                            <td style="color:#94a3b8"><%= p.getCategory() %></td>
                            <td>$<%= p.getPrice() %></td>
                            <td><% if(p.getQuantity() < 10) { %><span class="badge-low">Low (<%= p.getQuantity() %>)</span><% } else { %><span class="badge-ok">OK (<%= p.getQuantity() %>)</span><% } %></td>
                            <td>
                                <div style="display: flex; gap: 10px; justify-content: flex-end;">
                                    <a href="edit_product.jsp?id=<%= p.getId() %>" 
                                       style="color: #6366f1; font-size: 1.1rem; padding: 5px;" title="Edit">
                                        <i class="fa-solid fa-pen-to-square"></i>
                                    </a>

                                    <form action="${pageContext.request.contextPath}/InventoryServlet" method="POST" style="margin:0;">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="<%= p.getId() %>">
                                        <button type="submit" style="background:transparent; color:#ef4444; width:auto; padding:5px; font-size: 1.1rem;" title="Delete" onclick="return confirm('Are you sure?');">
                                            <i class="fa-solid fa-trash"></i>
                                        </button>
                                    </form>
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