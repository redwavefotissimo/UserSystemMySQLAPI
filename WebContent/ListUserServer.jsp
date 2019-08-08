<%@include file="COMMON.jsp" %>
<%@ page import="com.UserSystemMySQLAPI.DataTables.*" %>
<%


String draw = CommonUtils.convertNullToString(request.getParameter("draw"));
String start = CommonUtils.convertNullToString(request.getParameter("start"));
String length = CommonUtils.convertNullToString(request.getParameter("length"));
String search = CommonUtils.convertNullToString(request.getParameter("search"));
String[] order = request.getParameterValues("order");

DataTablesInfo dataTablesInfo = new DataTablesInfo();

dataTablesInfo.draw = 1;
dataTablesInfo.recordsFiltered = 3;
dataTablesInfo.recordsTotal = 3;
dataTablesInfo.data = new String[5][6];

dataTablesInfo.data[0][0] = "col 1";
dataTablesInfo.data[0][1] = "col 2";
dataTablesInfo.data[0][2] = "col 3";
dataTablesInfo.data[0][3] = "col 4";
dataTablesInfo.data[0][4] = "col 5";
dataTablesInfo.data[0][5] = "col 6";

dataTablesInfo.data[1][0] = "col 1.1";
dataTablesInfo.data[1][1] = "col 2.1";
dataTablesInfo.data[1][2] = "col 3.1";
dataTablesInfo.data[1][3] = "col 4.1";
dataTablesInfo.data[1][4] = "col 5.1";
dataTablesInfo.data[1][5] = "col 6.1";

dataTablesInfo.data[2][0] = "col 1.2";
dataTablesInfo.data[2][1] = "col 2.2";
dataTablesInfo.data[2][2] = "col 3.2";
dataTablesInfo.data[2][3] = "col 4.2";
dataTablesInfo.data[2][4] = "col 5.2";
dataTablesInfo.data[2][5] = "col 6.2";


response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");
response.getWriter().write(CommonUtils.convertObjectToJsonString(dataTablesInfo));
%>