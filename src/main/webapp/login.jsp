<%-- 
    Document   : login
    Created on : Dec 14, 2025, 10:39:53 PM
    Author     : ars3lan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sign In | Nexus Inventory</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');

        /* DARK MODE PALETTE */
        :root {
            --primary: #6366f1;       /* Brighter Indigo for Dark Mode */
            --primary-hover: #818cf8; 
            --bg-body: #0f172a;       /* Deepest Slate */
            --bg-card: #1e293b;       /* Dark Slate */
            --text-main: #f8fafc;     /* White/Off-White */
            --text-muted: #94a3b8;    /* Muted Gray */
            --border: #334155;        /* Dark Border */
            --input-bg: #0f172a;      /* Input Background */
        }

        * { box-sizing: border-box; }
        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--bg-body);
            height: 100vh;
            margin: 0;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .login-card {
            background: var(--bg-card); /* Dark Card */
            padding: 3rem;
            width: 100%;
            max-width: 400px;
            border-radius: 16px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5); 
            border: 1px solid var(--border);
            text-align: center;
        }

        .brand-logo { font-size: 3rem; margin-bottom: 0.5rem; display: block; }
        
        h2 { margin: 0 0 0.5rem 0; font-weight: 700; color: var(--text-main); }
        p { color: var(--text-muted); margin: 0 0 2rem 0; font-size: 0.9rem; }

        .form-group { margin-bottom: 1.25rem; text-align: left; }
        label { display: block; font-size: 0.875rem; font-weight: 500; margin-bottom: 0.5rem; color: var(--text-muted); }

        input {
            width: 100%; 
            padding: 0.75rem 1rem; 
            border-radius: 8px;
            border: 1px solid var(--border); 
            background-color: var(--input-bg); /* Dark Input */
            font-size: 0.95rem; 
            color: white; 
            outline: none; 
            transition: 0.2s;
        }
        input:focus { 
            border-color: var(--primary); 
            box-shadow: 0 0 0 2px rgba(99, 102, 241, 0.2); 
        }

        button {
            width: 100%; padding: 0.875rem; border-radius: 8px; border: none;
            background-color: var(--primary); color: white; font-weight: 600;
            cursor: pointer; transition: 0.2s; font-size: 1rem; margin-top: 1rem;
        }
        button:hover { background-color: var(--primary-hover); transform: translateY(-1px); }

        .error-msg {
            background: rgba(220, 38, 38, 0.2); /* Red with transparency */
            color: #fca5a5; 
            padding: 0.75rem;
            border-radius: 8px; margin-bottom: 1.5rem; font-size: 0.85rem;
            border: 1px solid rgba(220, 38, 38, 0.5); 
            text-align: left;
        }
    </style>
</head>
<body>
    <div class="login-card">
        <div class="brand-logo">📦</div>
        <h2>Welcome Back</h2>
        <p>Sign in to your dashboard</p>

        <% if ("failed".equals(request.getParameter("status"))) { %>
            <div class="error-msg">⚠️ Invalid Username or Password</div>
        <% } %>

        <form action="LoginServlet" method="POST">
            <div class="form-group">
                <label>Username</label>
                <input type="text" name="username" required placeholder="admin" autocomplete="off">
            </div>
            <div class="form-group">
                <label>Password</label>
                <input type="password" name="password" required placeholder="••••••••">
            </div>
            <button type="submit">Sign In</button>
        </form>
    </div>
</body>
</html>