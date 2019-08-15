<%@include file="COMMON.jsp" %>
<%
String userName = CommonUtils.convertNullToString(request.getParameter("userName"));    
String password = CommonUtils.convertNullToString(request.getParameter("password"));

String referer = "Login.jsp";

if(userName.isEmpty()){
	request.setAttribute("error", "User Name is required!");
    request.getRequestDispatcher(referer).forward(request, response);
    return;
}
if(password.isEmpty()){
	request.setAttribute("error", "Password is required!");
    request.getRequestDispatcher(referer).forward(request, response);
    return;
}

password = CommonUtils.convertStringToSha512(password, salt);

UserInfo userInfo = new UserInfo();
try{
	userInfo = this.login(userName, password);
}
catch(Exception ex){
	request.setAttribute("error", ex.toString());
    request.getRequestDispatcher(referer).forward(request, response);
    return;
}

session.setAttribute("userInfo", userInfo);

response.sendRedirect("UserInfo.jsp");
%>