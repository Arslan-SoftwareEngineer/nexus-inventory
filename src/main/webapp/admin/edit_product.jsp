<%-- 
    Document   : edit_product
    Created on : Dec 15, 2025, 6:42:56 PM
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
<%@page import="com.ims.dao.ProductDAO"%>
<%@page import="com.ims.model.Product"%>
<%
    if(session.getAttribute("user") == null) { response.sendRedirect("../login.jsp"); return; }
    
    // Fetch the product to edit
    String idParam = request.getParameter("id");
    if(idParam == null || idParam.isEmpty()) { response.sendRedirect("manage_products.jsp"); return; }
    
    int id = Integer.parseInt(idParam);
    ProductDAO dao = new ProductDAO();
    Product p = dao.getProductById(id);
%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Product | Nexus</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
        
        :root { 
            --primary: #6366f1; 
            --success: #10b981;       /* Green */
            --success-hover: #34d399; /* Brighter Green */
            --bg-body: #0f172a; --bg-card: #1e293b; 
            --text-main: #f8fafc; --border: #334155; --input-bg: #0f172a; 
        }
        
        body { 
            font-family: 'Inter', sans-serif; 
            background: var(--bg-body); 
            color: var(--text-main); 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            height: 100vh; 
            margin: 0; 
        }
        
        /* Centered Card - Reduced width for better proportion */
        .card { 
            background: var(--bg-card); 
            border: 1px solid var(--border); 
            border-radius: 16px; 
            padding: 2rem; 
            width: 400px; /* Reduced from 450px to make fields look less 'long' */
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        
        /* Unified Input Styling */
        input, select { 
            width: 100%; 
            padding: 0.8rem; 
            background: var(--input-bg); 
            border: 1px solid var(--border); 
            border-radius: 8px; 
            color: white; 
            margin-bottom: 1rem; 
            font-family: inherit;
            box-sizing: border-box; /* CRITICAL: Ensures padding doesn't add to width */
            display: block; /* Forces them to behave identically */
        }
        
        /* Focus state for inputs */
        input:focus, select:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 2px rgba(99, 102, 241, 0.2);
        }
        
        label { 
            display: block; 
            margin-bottom: 0.5rem; 
            color: #94a3b8; 
            font-size: 0.9rem; 
            font-weight: 500;
        }
        
        /* SAVE BUTTON (Green) */
        button[type="submit"] { 
            width: 100%; 
            padding: 1rem; 
            background: var(--success); 
            border: none; 
            border-radius: 8px; 
            color: white; 
            font-weight: 600; 
            cursor: pointer; 
            font-size: 1rem;
            transition: all 0.2s ease-in-out;
            margin-top: 0.5rem;
        }
        
        button[type="submit"]:hover {
            background: var(--success-hover); 
            transform: translateY(-2px); 
            box-shadow: 0 4px 6px -1px rgba(16, 185, 129, 0.4); 
        }
        
        /* Cancel Button */
        .btn-cancel { 
            width: 100%;
            padding: 1rem;
            background: transparent; 
            border: 1px solid var(--border); 
            color: #94a3b8; 
            margin-top: 10px; 
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .btn-cancel:hover {
            border-color: #ef4444;
            color: #ef4444;
            background: rgba(239, 68, 68, 0.1); 
        }
    </style>
</head>
<body>
    <div class="card">
        <h2 style="margin-top:0; text-align: center; margin-bottom: 1.5rem;">Edit Item #<%= p.getId() %></h2>
        
        <form action="${pageContext.request.contextPath}/InventoryServlet" method="POST">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" value="<%= p.getId() %>">
            
            <label>Product Name</label>
            <input type="text" name="name" value="<%= p.getName() %>" required>
            
            <label>Category</label>
            <select name="category">
                <option value="Electronics" <%= p.getCategory().equals("Electronics") ? "selected" : "" %>>Electronics</option>
                <option value="Grocery" <%= p.getCategory().equals("Grocery") ? "selected" : "" %>>Grocery</option>
                <option value="Clothing" <%= p.getCategory().equals("Clothing") ? "selected" : "" %>>Clothing</option>
                <option value="Other" <%= p.getCategory().equals("Other") ? "selected" : "" %>>Other</option>
            </select>
            
            <label>Price ($)</label>
            <input type="number" step="0.01" name="price" value="<%= p.getPrice() %>" required>
            
            <label>Quantity</label>
            <input type="number" name="quantity" value="<%= p.getQuantity() %>" required>
            
            <button type="submit">Save Changes</button>
            
            <a href="manage_products.jsp" style="text-decoration: none;">
                <button type="button" class="btn-cancel">Cancel</button>
            </a>
        </form>
    </div>
</body>
</html>