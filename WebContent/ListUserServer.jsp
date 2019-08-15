<%@include file="COMMON.jsp" %>
<%

String search = CommonUtils.convertNullToString(request.getParameter("search"));    
String offset = CommonUtils.convertNullToString(request.getParameter("offset"));
String limit = CommonUtils.convertNullToString(request.getParameter("limit"));    
String sort = CommonUtils.convertNullToString(request.getParameter("sort"));
String order = CommonUtils.convertNullToString(request.getParameter("order"));


UserInfosBootstrap UserInfosBootstrap = new UserInfosBootstrap();
UserInfosBootstrap.total = this.getTotalUser();
UserInfosBootstrap.rows = this.getUserInfo(offset, limit, sort, order).toArray(new UserInfo[0]);


response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");
response.getWriter().write(CommonUtils.convertObjectToJsonString(UserInfosBootstrap));
%>