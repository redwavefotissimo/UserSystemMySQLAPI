<%
session.setAttribute("userInfo", null);
session.invalidate();
response.sendRedirect("Login.jsp");
%>