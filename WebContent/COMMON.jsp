<%@ page import="java.sql.*,com.UserSystemMySQLAPI.entity.*,
java.util.*,com.UserSystemMySQLAPI.*" %>
<%!

final String dbHost = "jdbc:mysql://sql12.freesqldatabase.com/";
final String dbDatabaseName = "sql12301091";
final String dbConnectionURL = dbHost + dbDatabaseName;
final String dbUserName = "sql12301091";
final String dbPassword = "7BRse2umyY";
final String salt = "@#$6salt%^*";


private Connection getConnection() throws Exception{
	Class.forName("com.mysql.cj.jdbc.Driver");  
	return DriverManager.getConnection(dbConnectionURL,dbUserName,dbPassword);  
}

private void closeConnection(Connection con, PreparedStatement statement, ResultSet rs) throws Exception{
	if(rs != null){
		rs.close();
	}
	if(statement != null){
		statement.close();
	}
	if(con != null){
		con.close();
	}
}

private String translateColumnNameFromTable(String columnName){
	if(columnName.equals("firstName")){
		return "FirstName";
	}
	return "";
}

public ArrayList<UserInfo> getUserInfo() throws Exception{
	return getUserInfo("", "", "", "");
}

public ArrayList<UserInfo> getUserInfo(String offset, String limit, String sort, String order) throws Exception{
	Connection con = null;
	PreparedStatement statement = null;
	ResultSet rs = null;
	
	ArrayList<UserInfo> userInfos = new ArrayList<UserInfo>();

	try{
		con = getConnection();
		
		String sql = "Select * from UserInfoTable";
		
		if(!sort.isEmpty() && !order.isEmpty()){
			sql += " ORDER BY "+translateColumnNameFromTable(sort)+" " + order;
		}
		
		if(!offset.isEmpty() && !limit.isEmpty()){
			sql += " LIMIT "+limit+" OFFSET " + offset;
		}
		
		statement = con.prepareStatement(sql);
		
		rs = statement.executeQuery();
		
		while(rs.next()){
			UserInfo userInfo = new UserInfo();
			userInfo.recId = rs.getLong("RecId");
			userInfo.firstName = rs.getString("FirstName");
			userInfo.lastName = rs.getString("LastName");
			userInfo.userName = rs.getString("UserName");
			userInfo.password = rs.getString("Password");
			userInfo.profileFolderId = rs.getString("ProfileFolderId");
			userInfo.attachementFolderId = rs.getString("AttachementFolderId");
			userInfo.profileId = rs.getString("ProfileId");
			
			userInfos.add(userInfo);
		}
	}
	finally{
		closeConnection(con, statement, rs);
	}
	return userInfos;
}

public long getTotalUser() throws Exception{
	return getTotalUser("");
}

public long getTotalUser(String where, Object... params) throws Exception{
	long total = 0;
	
	Connection con = null;
	PreparedStatement statement = null;
	ResultSet rs = null;
	
	try{
		con = getConnection();
		
		String sql = "Select count(*) as total from UserInfoTable";
		
		if(!where.isEmpty()){
			sql += " WHERE "+ where;
		}
		
		statement = con.prepareStatement(sql);
		
		if(!where.isEmpty() && params != null){
			int col = 1;
			for(Object param : params){
				statement.setObject(col, param);
			}
		}
		
		rs = statement.executeQuery();
		
		while(rs.next()){
			total = rs.getLong("total");
		}
	}
	finally{
		closeConnection(con, statement, rs);
	}
	
	return total;
}

public UserInfo getUserInfo(String userName) throws Exception{
	Connection con = null;
	PreparedStatement statement = null;
	ResultSet rs = null;
	
	UserInfo userInfo = new UserInfo();

	try{
		con = getConnection();
		
		statement = con.prepareStatement("Select * from UserInfoTable where UserName = ?");
		
		statement.setString(1, userName);
		
		rs = statement.executeQuery();
		
		if(rs.next()){
			userInfo.recId = rs.getLong("RecId");
			userInfo.firstName = rs.getString("FirstName");
			userInfo.lastName = rs.getString("LastName");
			userInfo.userName = rs.getString("UserName");
			userInfo.password = rs.getString("Password");
			userInfo.profileFolderId = rs.getString("ProfileFolderId");
			userInfo.attachementFolderId = rs.getString("AttachementFolderId");
			userInfo.profileId = rs.getString("ProfileId");
		}
	}
	finally{
		closeConnection(con, statement, rs);
	}
	return userInfo;
}

public UserInfo login(String userName, String password) throws Exception{
	Connection con = null;
	PreparedStatement statement = null;
	ResultSet rs = null;
	
	UserInfo userInfo = new UserInfo();

	try{
		con = getConnection();
		
		statement = con.prepareStatement("Select * from UserInfoTable where UserName = ? and Password = ?");
		
		statement.setString(1, userName);
		statement.setString(2, password);
		
		rs = statement.executeQuery();
		
		if(rs.next()){
			userInfo.recId = rs.getLong("RecId");
			userInfo.firstName = rs.getString("FirstName");
			userInfo.lastName = rs.getString("LastName");
			userInfo.userName = rs.getString("UserName");
			userInfo.password = rs.getString("Password");
			userInfo.profileFolderId = rs.getString("ProfileFolderId");
			userInfo.attachementFolderId = rs.getString("AttachementFolderId");
			userInfo.profileId = rs.getString("ProfileId");
		}else{
			throw new Exception("Incorrect User Name or Password!");
		}
	}
	finally{
		closeConnection(con, statement, rs);
	}
	return userInfo;
}

public boolean insertUser(UserInfo userForInsert) throws Exception{
	Connection con = null;
	PreparedStatement statement = null;
	ResultSet rs = null;
	boolean success = false;

	try{
		con = getConnection();
		
		UserInfo existingUser = getUserInfo(userForInsert.userName);
		
		if(existingUser.recId > 0){
			throw new Exception("User Name already taken!");
		}
		
		statement = con.prepareStatement("insert into UserInfoTable (FirstName, LastName, UserName, Password, ProfileFolderId, AttachementFolderId, ProfileId) "+
		" values (?, ?, ?, ?, ?, ?, ?)");
		
		int column = 1;
		statement.setString(column++, userForInsert.firstName);
		statement.setString(column++, userForInsert.lastName);
		statement.setString(column++, userForInsert.userName);
		statement.setString(column++, userForInsert.password);
		statement.setString(column++, userForInsert.profileFolderId);
		statement.setString(column++, userForInsert.attachementFolderId);
		statement.setString(column++, userForInsert.profileId);
		
		statement.execute();
		
		success = true;
	}
	finally{
		closeConnection(con, statement, rs);
	}
	return success;
}

public boolean updateUser(UserInfo userForUpdate) throws Exception{
	Connection con = null;
	PreparedStatement statement = null;
	ResultSet rs = null;
	boolean success = false;
	
	try{
		con = getConnection();
		
		statement = con.prepareStatement("update UserInfoTable set FirstName = ?, LastName = ?, UserName = ?, Password = ?, ProfileId = ? where RecId = ?");
		
		int column = 1;
		statement.setString(column++, userForUpdate.firstName);
		statement.setString(column++, userForUpdate.lastName);
		statement.setString(column++, userForUpdate.userName);
		statement.setString(column++, userForUpdate.password);
		statement.setString(column++, userForUpdate.profileId);
		statement.setLong(column++, userForUpdate.recId);
		
		statement.executeUpdate();
		
		success = true;
	}
	finally{
		closeConnection(con, statement, rs);
	}
	
	return success;
}

public boolean insertToAttachment(long userRecId, String AtachmentId) throws Exception{
	
	Connection con = null;
	PreparedStatement statement = null;
	ResultSet rs = null;
	boolean success = false;

	try{
		con = getConnection();
		
		statement = con.prepareStatement("insert into AttachmentTable (UserRecId, AttachmentId, createDate) "+
		" values (?, ?, NOW())");
		
		int column = 1;
		statement.setLong(column++, userRecId);
		statement.setString(column++, AtachmentId);
		
		statement.execute();
		
		success = true;
	}
	finally{
		closeConnection(con, statement, rs);
	}
	return success;
}

public UserAttachmentListInfo getUserAttachments(long userId, String offset, String limit, String sort, String order) throws Exception{
	
	Connection con = null;
	PreparedStatement statement = null;
	ResultSet rs = null;
	
	UserAttachmentListInfo userAttachments = new UserAttachmentListInfo();
	userAttachments.UserAttachmentInfo = new ArrayList<UserAttachmentInfo>();

	try{
		con = getConnection();
		
		String sql = "Select * from AttachmentTable where UserRecId = ? ";
		
		if(!sort.isEmpty() && !order.isEmpty()){
			sql += " ORDER BY "+translateColumnNameFromTable(sort)+" " + order;
		}
		
		if(!offset.isEmpty() && !limit.isEmpty()){
			sql += " LIMIT "+limit+" OFFSET " + offset;
		}
		
		statement = con.prepareStatement(sql);
		
		statement.setLong(1, userId);
		
		rs = statement.executeQuery();
		
		while(rs.next()){
			UserAttachmentInfo userAttachmentInfo = new UserAttachmentInfo();
			userAttachmentInfo.userRecId = rs.getLong("UserRecId");
			userAttachmentInfo.attachmentId = rs.getString("AttachmentId");
			
			userAttachments.UserAttachmentInfo.add(userAttachmentInfo);
		}
	}
	finally{
		closeConnection(con, statement, rs);
	}	
	
	return userAttachments;
}

public long getTotalUser(String userId) throws Exception{
	long total = 0;
	
	Connection con = null;
	PreparedStatement statement = null;
	ResultSet rs = null;
	
	try{
		con = getConnection();
		
		String sql = "Select count(*) as total from AttachmentTable where UserRecId = ?";
		
		statement = con.prepareStatement(sql);
		
		statement.setString(1, userId);
		
		rs = statement.executeQuery();
		
		while(rs.next()){
			total = rs.getLong("total");
		}
	}
	finally{
		closeConnection(con, statement, rs);
	}
	
	return total;
}
%>