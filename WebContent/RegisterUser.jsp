<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<script src="https://www.google.com/recaptcha/api.js?onload=onloadCallback&render=explicit" async defer></script>
<%@include file="COMMON.jsp" %>
<%
String firstName = CommonUtils.convertNullToString(request.getParameter("firstName"));
String lastName = CommonUtils.convertNullToString(request.getParameter("lastName"));
String pass = CommonUtils.convertNullToString(request.getParameter("pass"));
String retypePass = CommonUtils.convertNullToString(request.getParameter("retypePass"));
String userName = CommonUtils.convertNullToString(request.getParameter("userName"));

if(request.getAttribute("error") != null){%>
<%= request.getAttribute("error") %>
<%}
if(request.getAttribute("success") != null){ %>
<%= request.getAttribute("success") %>
<% } %>
<!doctype html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<script src="PLUGINS/jquery-3.4.1.min.js"></script>
<script src="PLUGINS/jquery-migrate-3.0.1.min.js"></script>
<link rel="stylesheet" href="PLUGINS/bootstrap.min.css">
<script src="PLUGINS/bootstrap.min.js"></script>
<title>Register</title>
</head>
<body>

<form method="post" action="RegisterUserServer.jsp"  onsubmit="finalizeBeforePost();">
<input type="hidden" id="captchaResponse" name="captchaResponse" value="" />
<table>
	<tr>
		<td>First Name:</td>
		<td><input name="firstName" type="text" value="<%= firstName %>" length="20" size="20" /></td>
	
		<td>Last Name:</td>
		<td><input name="lastName" type="text" value="<%= lastName %>" length="20" size="20" /></td>
	</tr>
	<tr>
		<td>User Name:</td>
		<td><input name="userName" type="text" value="<%= userName %>" length="20" size="20" /></td>
	</tr>
	<tr>
		<td>Password:</td>
		<td><input name=pass type="password" value="<%= pass %>" length="20" size="20" /></td>
	</tr>
	<tr>
		<td>retype Password:</td>
		<td><input name="retypePass" type="password" value="<%= retypePass %>" length="20" size="20" /></td>
	</tr>
	<tr>
		<td colspan="4">
		<div>
	 	<input id="imgData" name="imgData" type="hidden" value="">
		<video id="video" width="640" height="480" autoplay></video>
		<input type="button" id="snap" value="Snap Photo" />
		<canvas id="canvas" width="640" height="480"></canvas>
		</div>
		</td>
	</tr>
	<tr>
		<td>
		<div id="recaptcha" ></div>
		</td>
	</tr>
	<tr>
	<td><input id="submitBTN" type="submit" value="Register" autofocus  /></td>
	</tr>
</table>
</form>
<script type="text/javascript">

$(document).ready(function() {
	var video = document.getElementById('video');
	
	// Get access to the camera!
	if(navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
	    // Not adding `{ audio: true }` since we only want video now
	    navigator.mediaDevices.getUserMedia({ video: true }).then(function(stream) {
	        //video.src = window.URL.createObjectURL(stream);
	        video.srcObject = stream;
	        video.play();
	    });
	}
	
	// Elements for taking the snapshot
	var canvas = document.getElementById('canvas');
	var context = canvas.getContext('2d');
	var video = document.getElementById('video');

	// Trigger photo take
	document.getElementById("snap").addEventListener("click", function() {
		context.drawImage(video, 0, 0, 640, 480);
	});
	
} );

var verifyCallback = function(response) {
    document.getElementById('captchaResponse').value = response;
    document.getElementById('submitBTN').disabled = false;
  };

var onloadCallback = function() {
    grecaptcha.render('recaptcha', {
      'sitekey' : '6LdSLbIUAAAAALnj4SkxwUtkiRjqA-11bIasXC4s',
      'callback' : verifyCallback,
    });
  };
  
function finalizeBeforePost(){
	var canvas = document.getElementById('canvas');
	document.getElementById('imgData').value = canvas.toDataURL();
}
</script>
</body>
</html>