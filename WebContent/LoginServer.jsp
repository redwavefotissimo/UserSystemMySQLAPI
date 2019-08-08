<%@include file="COMMON.jsp" %>
<%
String userName = CommonUtils.convertNullToString(request.getParameter("userName"));    
String password = CommonUtils.convertNullToString(request.getParameter("password"));


if(userName.isEmpty()){
	request.setAttribute("error", "User Name is required!");
    request.getRequestDispatcher("Login.jsp").forward(request, response);
    return;
}
if(password.isEmpty()){
	request.setAttribute("error", "Password is required!");
    request.getRequestDispatcher("Login.jsp").forward(request, response);
    return;
}

password = CommonUtils.convertStringToSha512(password, salt);

UserInfo userInfo = this.login(userName, password);

session.setAttribute("userInfo", userInfo);

response.sendRedirect("UserInfo.jsp");
%>