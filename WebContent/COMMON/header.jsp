<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@include file="../COMMON.jsp" %>
<%
String uri = request.getRequestURI();

String fileName = uri.substring(uri.lastIndexOf("/")+1);

String pageName = fileName.split("\\.")[0];

UserInfo userInfo = (UserInfo) session.getAttribute("userInfo");

if(userInfo == null){
	response.sendRedirect("Login.jsp");
}

%>
<!doctype html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="PLUGINS/bootstrap.min.css">
<link rel="stylesheet" href="PLUGINS/bootstrap-table.min.css">

<script src="PLUGINS/jquery-3.4.1.min.js"></script>
<script src="PLUGINS/jquery-migrate-3.0.1.min.js"></script>
<script src="PLUGINS/popper.min.js"></script>
<script src="PLUGINS/bootstrap.min.js"></script>
<script src="PLUGINS/bootstrap-table.min.js"></script>

<title><%= pageName %></title>
</head>
<body>
<a href="Logout.jsp">Log out</a><br/>