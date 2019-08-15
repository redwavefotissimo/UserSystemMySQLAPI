<%@include file="COMMON/header.jsp" %>
<%@ page import="com.common.BoxNetAPI.*" %>

<script src="https://www.google.com/recaptcha/api.js?onload=onloadCallback&render=explicit" async defer></script>
<a href="ListUser.jsp">User List</a>
<% if(userInfo != null){ %>

<%
String firstName = CommonUtils.convertNullToString(request.getParameter("firstName"));
String lastName = CommonUtils.convertNullToString(request.getParameter("lastName"));
String oldPass = CommonUtils.convertNullToString(request.getParameter("oldPass"));
String newPass = CommonUtils.convertNullToString(request.getParameter("newPass"));
String retypePass = CommonUtils.convertNullToString(request.getParameter("retypePass"));

BoxNetAPI boxNetAPI = new BoxNetAPI(this.getServletContext().getRealPath("ASSETS").concat(System.getProperty("file.separator").concat("box_net_cred.json")));

BoxItemInfo info = boxNetAPI.getItemInfo(userInfo.profileId);

String profilePicLink = "";

if(info.shared_link != null){
	profilePicLink = info.shared_link.download_url;
}

if(request.getAttribute("error") == null){
	firstName = userInfo.firstName;
	lastName = userInfo.lastName;
}else{%>
<%= request.getAttribute("error") %>
<%}
if(request.getAttribute("success") != null){ %>
<%= request.getAttribute("success") %>
<% } %>
<form method="post" action="UserInfoServer.jsp" onsubmit="finalizeBeforePost();">
<input type="hidden" name="userName" value="<%= userInfo.userName %>"/>
<input type="hidden" id="captchaResponse" name="captchaResponse" value="" />
<table>
	<tr>
		<td>First Name:</td>
		<td><input name="firstName" type="text" value="<%= firstName %>" length="20" size="20" /></td>
	
		<td>Last Name:</td>
		<td><input name="lastName" type="text" value="<%= lastName %>" length="20" size="20" /></td>
		
		<td rowspan="6">
		<img src="<%= profilePicLink %>" alt="profilePic" width="340" height="240" />
		</td>
	</tr>
	<tr>
		<td>User Name:</td>
		<td><%= userInfo.userName %></td>
	</tr>
	<tr>
		<td>old Password:</td>
		<td><input name="oldPass" type="password" value="<%= oldPass %>" length="20" size="20" /></td>
	</tr>
	<tr>
		<td>new Password:</td>
		<td><input name=newPass type="password" value="<%= newPass %>" length="20" size="20" /></td>
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
	<td><input id="submitBTN" type="submit" value="update" autofocus disabled /></td>
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
<%} %>
<%@include file="COMMON/footer.jsp" %>