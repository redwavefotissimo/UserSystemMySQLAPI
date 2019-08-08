package com.UserSystemMySQLAPI;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

import com.google.gson.Gson;

public class CommonUtils {
	
	public static String convertObjectToJsonString(Object data){
		Gson gson = new Gson();
		
		return gson.toJson(data);
	}
	
	public static Object convertJsonStringToObject(String jsonData, Class objectClass){
		Gson gson = new Gson();
		
		return gson.fromJson(jsonData, objectClass);
	}
	
	public static String convertStringToSha512(String value, String salt) throws Exception{
		MessageDigest md = MessageDigest.getInstance("SHA-512");
        md.update(salt.getBytes(StandardCharsets.UTF_8));
        byte[] bytes = md.digest(value.getBytes(StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder();
        for(int i=0; i< bytes.length ;i++){
           sb.append(Integer.toString((bytes[i] & 0xff) + 0x100, 16).substring(1));
        }
        return sb.toString();
	}
	
	public static String convertNullToString(String value){
		if(value == null){
			return "";
		}
		return value;
	}
}
