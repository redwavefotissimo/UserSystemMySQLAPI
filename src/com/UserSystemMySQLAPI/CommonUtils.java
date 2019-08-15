package com.UserSystemMySQLAPI;

import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.io.File;
import org.bouncycastle.util.encoders.Base64;

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
	
	public static String FileToString(String fileLoc) throws Exception{
		BufferedReader reader = new BufferedReader(new FileReader(fileLoc));
        StringBuilder sb = new StringBuilder();
        String line;

        while((line = reader.readLine())!= null){
            sb.append(line+"\n");
        }
        return sb.toString();
	}
	
	public static void saveBytesToFile(byte[] rawData, String fileLoc) throws Exception{
		OutputStream out1 = null;
		
		try {
		    out1 = new BufferedOutputStream(new FileOutputStream(fileLoc));
		    out1.write(rawData);            
		} finally {
		    if (out1 != null) {
		        out1.close();
		    }
		}
	}
	
	public static byte[] convertBase64ToBytes(String base64Data) throws Exception{
		return Base64.decode(base64Data);
	}
	
	public static void deleteLocalTempFile(String fileLoc){
		(new File(fileLoc)).delete();
	}
}
