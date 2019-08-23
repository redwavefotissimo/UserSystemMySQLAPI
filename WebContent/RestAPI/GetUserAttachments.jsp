<%@ page language="java" contentType="application/json; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.io.BufferedReader" %>
<%@include file="../COMMON.jsp" %>
<%
UserSystemMySQLAPIResponse userSystemResponse = new UserSystemMySQLAPIResponse();
StringBuffer jb = new StringBuffer();
String line = null;
boolean success = false;
UserAttachmentListInfo userAttachmentListInfo = new UserAttachmentListInfo();
try {
		BufferedReader reader = request.getReader();
		while ((line = reader.readLine()) != null){
			jb.append(line);
		}

		UserAttachmentInfo userAttachmentInfo = (UserAttachmentInfo) CommonUtils.convertJsonStringToObject(jb.toString(), UserAttachmentInfo.class);
		
		userAttachmentListInfo = this.getUserAttachments(userAttachmentInfo.userRecId, "", "", "", "");
		
		if(userAttachmentListInfo.UserAttachmentInfo != null){
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
	jsonToSend = CommonUtils.convertObjectToJsonString(userAttachmentListInfo);
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