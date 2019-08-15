<%@include file="COMMON.jsp" %>
<%@ page import="com.common.AbstractOrInterface.*,com.common.RestAPI.*,com.common.BoxNetAPI.*,java.io.File" %>
<%
String firstName = CommonUtils.convertNullToString(request.getParameter("firstName"));
String lastName = CommonUtils.convertNullToString(request.getParameter("lastName"));
String oldPass = CommonUtils.convertNullToString(request.getParameter("oldPass"));
String newPass = CommonUtils.convertNullToString(request.getParameter("newPass"));
String retypePass = CommonUtils.convertNullToString(request.getParameter("retypePass"));
String userName = CommonUtils.convertNullToString(request.getParameter("userName"));
String captchaResponse = CommonUtils.convertNullToString(request.getParameter("captchaResponse"));
String imgData = CommonUtils.convertNullToString(request.getParameter("imgData")).replace("data:image/png;base64,", "");

String referer = "UserInfo.jsp";

if(captchaResponse.isEmpty()){
	request.setAttribute("error", "reCaptcha is Required!");
    request.getRequestDispatcher(referer).forward(request, response);
    return;
}
else{
	RestAPISSL RestAPISSL = new RestAPISSL();
	
	ArrayList<RestAPIInfo> RestAPIInfoList = new ArrayList<RestAPIInfo>();

    RestAPIInfo RestAPIInfo = new RestAPIInfo();
    RestAPIInfo.fieldName = "secret";
    RestAPIInfo.fieldData = "6LdSLbIUAAAAAGtHUQvAgGRn62FnXdjB7uioUjAJ";
    RestAPIInfoList.add(RestAPIInfo);

    RestAPIInfo = new RestAPIInfo();
    RestAPIInfo.fieldName = "response";
    RestAPIInfo.fieldData = captchaResponse;
    RestAPIInfoList.add(RestAPIInfo);

    String reqResponseString = RestAPISSL.POST("https://www.google.com/recaptcha/api/siteverify", RestAPIInfoList);

    if(reqResponseString.startsWith("ERROR:")){
        throw new Exception(reqResponseString);
    }

    ReCaptchaResponseInfo reCaptchaResponseInfo = (ReCaptchaResponseInfo) CommonUtils.convertJsonStringToObject(reqResponseString, ReCaptchaResponseInfo.class);

    if(!reCaptchaResponseInfo.success){
    	request.setAttribute("error", "Invalid Recaptcha!");
        request.getRequestDispatcher(referer).forward(request, response);
        return;
    }
}


if(firstName.isEmpty()){
	request.setAttribute("error", "First Name is required!");
    request.getRequestDispatcher(referer).forward(request, response);
    return;
}
if(lastName.isEmpty()){
	request.setAttribute("error", "Last Name is required!");
    request.getRequestDispatcher(referer).forward(request, response);
    return;
}
if(!newPass.equals(retypePass)){
	request.setAttribute("error", "New Password and retype Password not the same!");
    request.getRequestDispatcher(referer).forward(request, response);
    return;
}

UserInfo userInfo = new UserInfo();
if(!oldPass.isEmpty()){
	try{
		userInfo = this.login(userName, CommonUtils.convertStringToSha512(oldPass, salt));
		userInfo.password = CommonUtils.convertStringToSha512(newPass, salt);
	}
	catch(Exception ex){
		request.setAttribute("error", ex.toString());
	    request.getRequestDispatcher(referer).forward(request, response);
	    return;
	}
}else{
	userInfo = this.getUserInfo(userName);
}

userInfo.firstName = firstName;
userInfo.lastName = lastName;

try{
	
	BoxNetAPI boxNetApi = new BoxNetAPI(this.getServletContext().getRealPath("ASSETS").concat(System.getProperty("file.separator").concat("box_net_cred.json")));
	
	BoxItemInfo itemInfo = boxNetApi.getItemInfo(userInfo.profileId);
	
	BoxItemSimpleInfo fileForRemoval = new BoxItemSimpleInfo();
	fileForRemoval.etag = itemInfo.etag;
	fileForRemoval.id = itemInfo.id;
	
	boxNetApi.deleteItem(fileForRemoval);
	
	byte[] decoded = CommonUtils.convertBase64ToBytes(imgData);

	String fileTempLoc = this.getServletContext().getRealPath("ASSETS").concat(System.getProperty("file.separator").concat(userName + ".png"));

	CommonUtils.saveBytesToFile(decoded, fileTempLoc);
	
	userInfo.profileId = boxNetApi.updloadFile(new File(fileTempLoc), userInfo.profileFolderId).entries[0].id;
    
    Thread.sleep(1000);
    
    boxNetApi.setFileItemAsSharable(userInfo.profileId);
    
    CommonUtils.deleteLocalTempFile(fileTempLoc);
	
	this.updateUser(userInfo);
}catch(Exception ex){
	request.setAttribute("error", ex.toString());
    request.getRequestDispatcher(referer).forward(request, response);
    return;
}

session.setAttribute("userInfo", userInfo);

request.setAttribute("success", "Update Successful!");
request.getRequestDispatcher("UserInfo.jsp").forward(request, response);
%>