<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="com.UserSystemMySQLAPI.*" %>
<!doctype html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="PLUGINS/bootstrap.min.css">
<script src="PLUGINS/bootstrap.min.js"></script>
<title>Login</title>
</head>
<body>
<% if(request.getAttribute("error") != null){ %>
<%= request.getAttribute("error") %>
<% } %>
<%
String userName = CommonUtils.convertNullToString(request.getParameter("userName"));    
String password = CommonUtils.convertNullToString(request.getParameter("password"));
%>
<form method="post" action="<%= "LoginServer.jsp" %>">
    <center>
    <table  cellpadding="3">
        <thead>
            <tr>
                <th colspan="2">Login Here</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>User Name</td>
                <td><input type="text" name="userName" value="<%= userName %>" /></td>
            </tr>
            <tr>
                <td>Password</td>
                <td><input type="password" name="password" value="<%= password %>" /></td>
            </tr>
            <tr>
                <td><input type="submit" value="Login" /></td>
                <td><a href="RegisterUser.jsp">Register</a></td>
            </tr>
        </tbody>
    </table>
    </center>
</form>
</body>
</html>