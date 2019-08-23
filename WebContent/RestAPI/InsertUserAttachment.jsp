<%@ page language="java" contentType="application/json; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.io.BufferedReader" %>
<%@include file="../COMMON.jsp" %>
<%
UserSystemMySQLAPIResponse userSystemResponse = new UserSystemMySQLAPIResponse();
StringBuffer jb = new StringBuffer();
String line = null;
boolean success = false;
try {
		BufferedReader reader = request.getReader();
		while ((line = reader.readLine()) != null){
			jb.append(line);
		}

		UserAttachmentInfo userAttachmentInfo = (UserAttachmentInfo) CommonUtils.convertJsonStringToObject(jb.toString(), UserAttachmentInfo.class);
		
		success = this.insertToAttachment(userAttachmentInfo.userRecId, userAttachmentInfo.attachmentId);
} 
catch (Exception e) 
{
	userSystemResponse.message = e.getMessage();
	e.printStackTrace(); 
}



if(success){
	userSystemResponse.statusCode = 200;
	userSystemResponse.message = "INSERT SUCCESSFULL!";
}
else{
	userSystemResponse.statusCode = 500;
	userSystemResponse.message += ". ERROR IN INSERT.";
}

response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");
response.getWriter().write(CommonUtils.convertObjectToJsonString(userSystemResponse));
%>