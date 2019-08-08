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

public ArrayList<UserInfo> getUserInfo() throws Exception{
	return getUserInfo("", "");
}

public ArrayList<UserInfo> getUserInfo(String offset, String limit) throws Exception{
	Connection con = null;
	PreparedStatement statement = null;
	ResultSet rs = null;
	
	ArrayList<UserInfo> userInfos = new ArrayList<UserInfo>();

	try{
		con = getConnection();
		
		String sql = "Select * from UserInfoTable";
		
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
%>