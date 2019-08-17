<%@ page language="java" contentType="application/json; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.io.BufferedReader" %>
<%@include file="../COMMON.jsp" %>
<%
UserSystemMySQLAPIResponse userSystemResponse = new UserSystemMySQLAPIResponse();
StringBuffer jb = new StringBuffer();
String line = null;
boolean success = false;
UserInfo userInfo = new UserInfo();
try {
		BufferedReader reader = request.getReader();
		while ((line = reader.readLine()) != null){
			jb.append(line);
		}

		userInfo = (UserInfo) CommonUtils.convertJsonStringToObject(jb.toString(), UserInfo.class);
		
		userInfo = this.login(userInfo.userName, userInfo.password);
		
		if(userInfo.firstName != null && !userInfo.firstName.isEmpty()){
			success = true;
		}
} 
catch (Exception e) 
{
	userSystemResponse.message = e.getMessage();
	e.printStackTrace(); 
}

String jsonToSend = "";


if(success){
	response.setStatus(200);
	jsonToSend = CommonUtils.convertObjectToJsonString(userInfo);
}
else{
	response.setStatus(500);
	userSystemResponse.statusCode = 500;
	userSystemResponse.message += ". ERROR IN INSERT.";
	jsonToSend = CommonUtils.convertObjectToJsonString(userSystemResponse);
}

response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");
response.getWriter().write(jsonToSend);
%>