package com.common.BoxNetAPI;

import com.common.AbstractOrInterface.RestAPIInfo;
import com.common.RestAPI.RestAPISSL;
import com.common.RestAPI.RestAPISSLJson;
import com.UserSystemMySQLAPI.*;

import org.bouncycastle.pkcs.*;
import org.bouncycastle.asn1.pkcs.PrivateKeyInfo;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.openssl.PEMParser;
import org.bouncycastle.openssl.jcajce.JcaPEMKeyConverter;
import org.bouncycastle.openssl.jcajce.JceOpenSSLPKCS8DecryptorProviderBuilder;
import org.bouncycastle.operator.InputDecryptorProvider;
/*import org.apache.http.HttpEntity;
import org.apache.http.NameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;*/
import org.jose4j.jws.AlgorithmIdentifiers;
import org.jose4j.jws.JsonWebSignature;
import org.jose4j.jwt.JwtClaims;

import java.io.File;
import java.io.StringReader;
import java.security.PrivateKey;
import java.security.Security;
import java.util.ArrayList;

public class BoxNetAPI {

    final String APIBaseURI = "https://api.box.com/2.0/";
    final String APIBaseUploadURI = "https://upload.box.com/api/2.0/files/content";
    final String authenticationUrl = "https://api.box.com/oauth2/token";
    final String credentialBoxNet = "box_net_cred.json";

    final String getItemListURI = APIBaseURI + "folders/%s/items";
    final String getRootList = APIBaseURI + "folders/0";
    final String getFileInfo = APIBaseURI + "files/";
    final String getTrashItems = APIBaseURI + "folders/trash/items";
    final String createFolder = APIBaseURI + "folders";
    final String deleteFolder = APIBaseURI + "folders/";
    final String deleteFile = APIBaseURI + "files/";
    final String deleteFileInTrash = APIBaseURI + "files/%s/trash";
    final String deleteFolderInTrash = APIBaseURI + "folders/%s/trash";
    final String shareFile = APIBaseURI + "files/%s?fields=shared_link";

    final String HTTP_401 = "Unauthorized";

    BoxCredSettings boxCredSettings;
    PrivateKey key;
    String assertion;
    Token token;
    BoxItemSimpleInfo userSystemFolder;

    RestAPISSL restAPISSL;
    RestAPISSLJson RestAPISSLJson;

    public BoxNetAPI(String credFileLocation) throws Exception{

        restAPISSL = new RestAPISSL();
        RestAPISSLJson = new RestAPISSLJson();

        String credContent = CommonUtils.FileToString(credFileLocation);
        boxCredSettings = (BoxCredSettings) CommonUtils.convertJsonStringToObject(credContent, BoxCredSettings.class);

        decriptPrivateKey();
        setJWTClaim();
        getAuthCode();
    }

    private void decriptPrivateKey() throws Exception{
    	Security.addProvider(new BouncyCastleProvider());

        // Using BouncyCastle's PEMParser we convert the
        // encrypted private key into a keypair object
        PEMParser pemParser = new PEMParser(
                new StringReader(boxCredSettings.boxAppSettings.appAuth.privateKey)
        );
        Object keyPair = pemParser.readObject();


        // Finally, we decrypt the key using the passphrase
        char[] passphrase = boxCredSettings.boxAppSettings.appAuth.passphrase.toCharArray();
        JceOpenSSLPKCS8DecryptorProviderBuilder decryptBuilder =
                new JceOpenSSLPKCS8DecryptorProviderBuilder().setProvider("BC");
        InputDecryptorProvider decryptProvider
                = decryptBuilder.build(passphrase);

        PrivateKeyInfo keyInfo
                = ((PKCS8EncryptedPrivateKeyInfo) keyPair).decryptPrivateKeyInfo(decryptProvider);

        // In the end, we will use this key in the next steps
        key = (new JcaPEMKeyConverter()).getPrivateKey(keyInfo);

        pemParser.close();
    }

    private void setJWTClaim() throws Exception{

        // Rather than constructing the JWT assertion manually, we are
        // using the org.jose4j.jwt library.
        JwtClaims claims = new JwtClaims();
        claims.setIssuer(boxCredSettings.boxAppSettings.clientID);
        claims.setAudience(authenticationUrl);
        claims.setSubject(boxCredSettings.enterpriseID);
        claims.setClaim("box_sub_type", "enterprise");
        // This is an identifier that helps protect against
        // replay attacks
        claims.setGeneratedJwtId(64);
        // We give the assertion a lifetime of 45 seconds
        // before it expires
        claims.setExpirationTimeMinutesInTheFuture(0.75f);

        // With the claims in place, it's time to sign the assertion
        JsonWebSignature jws = new JsonWebSignature();
        jws.setPayload(claims.toJson());
        jws.setKey(key);
        // The API support "RS256", "RS384", and "RS512" encryption
        jws.setAlgorithmHeaderValue(AlgorithmIdentifiers.RSA_USING_SHA512);
        jws.setHeader("typ", "JWT");
        jws.setHeader("kid", boxCredSettings.boxAppSettings.appAuth.publicKeyID);
        assertion = jws.getCompactSerialization();
    }

    private void getAuthCode() throws Exception{
        ArrayList<RestAPIInfo> restAPIInfoArrayList = new ArrayList<>();

        RestAPIInfo restAPIInfo = new RestAPIInfo();
        restAPIInfo.fieldName = "grant_type";
        restAPIInfo.fieldData = "urn:ietf:params:oauth:grant-type:jwt-bearer";
        restAPIInfo.doEncode = false;
        restAPIInfoArrayList.add(restAPIInfo);

        restAPIInfo = new RestAPIInfo();
        restAPIInfo.fieldName = "client_id";
        restAPIInfo.fieldData = boxCredSettings.boxAppSettings.clientID;
        restAPIInfo.doEncode = false;
        restAPIInfoArrayList.add(restAPIInfo);

        restAPIInfo = new RestAPIInfo();
        restAPIInfo.fieldName = "client_secret";
        restAPIInfo.fieldData = boxCredSettings.boxAppSettings.clientSecret;
        restAPIInfo.doEncode = false;
        restAPIInfoArrayList.add(restAPIInfo);

        restAPIInfo = new RestAPIInfo();
        restAPIInfo.fieldName = "assertion";
        restAPIInfo.fieldData = assertion;
        restAPIInfo.doEncode = false;
        restAPIInfoArrayList.add(restAPIInfo);

        String reqResponseString = restAPISSL.POST(authenticationUrl, restAPIInfoArrayList);

        if(reqResponseString.startsWith("ERROR:")){
            throw new Exception(reqResponseString);
        }

        /* do not use from apache if can still able to manage using own custom code
        // Create the params for the request
        List<NameValuePair> params = new ArrayList<NameValuePair>();
        // This specifies that we are using a JWT assertion
        // to authenticate
        params.add(new BasicNameValuePair(
                "grant_type", "urn:ietf:params:oauth:grant-type:jwt-bearer"));
        // Our JWT assertion
        params.add(new BasicNameValuePair(
                "assertion", assertion));
        // The OAuth 2 client ID and secret
        params.add(new BasicNameValuePair(
                "client_id", boxCredSettings.boxAppSettings.clientID));
        params.add(new BasicNameValuePair(
                "client_secret", boxCredSettings.boxAppSettings.clientSecret));

        // Make the POST call to the authentication endpoint
        CloseableHttpClient httpClient =
                HttpClientBuilder.create().disableCookieManagement().build();
        HttpPost request = new HttpPost(authenticationUrl);
        request.setEntity(new UrlEncodedFormEntity(params));
        CloseableHttpResponse httpResponse = httpClient.execute(request);
        HttpEntity entity = httpResponse.getEntity();
        String reqResponseString = EntityUtils.toString(entity);
        httpClient.close();*/

        token = (Token) CommonUtils.convertJsonStringToObject(reqResponseString, Token.class);

        ArrayList<RestAPIInfo> restAPIInfoHeaderArrayList = new ArrayList<>();

        restAPIInfo = new RestAPIInfo();
        restAPIInfo.fieldName = "Authorization";
        restAPIInfo.fieldData = "Bearer " + token.access_token;
        restAPIInfoHeaderArrayList.add(restAPIInfo);

        restAPISSL.setHeaders(restAPIInfoHeaderArrayList);
        RestAPISSLJson.setHeaders(restAPIInfoHeaderArrayList);
    }

    private BoxItemInfo getRootList() throws Exception{
        String reqResponseString = restAPISSL.GET(String.format(getRootList), null);

        if(reqResponseString.startsWith("ERROR:")){
            throw new Exception(reqResponseString);
        }else if(reqResponseString.equals(HTTP_401)){
            getAuthCode();
            getRootList();
        }

        return (BoxItemInfo) CommonUtils.convertJsonStringToObject(reqResponseString, BoxItemInfo.class);
    }

    public BoxItemInfo getItemInfo(String itemID) throws Exception{
        String reqResponseString = restAPISSL.GET( getFileInfo + itemID, null);

        if(reqResponseString.startsWith("ERROR:")){
            throw new Exception(reqResponseString);
        }else if(reqResponseString.equals(HTTP_401)){
            getAuthCode();
            getItemInfo(itemID);
        }

        return (BoxItemInfo) CommonUtils.convertJsonStringToObject(reqResponseString, BoxItemInfo.class);
    }

    public BoxItemCollectionInfo getItemList(String folderID) throws Exception{
        String reqResponseString = restAPISSL.GET(String.format(getItemListURI, folderID), null);

        if(reqResponseString.startsWith("ERROR:")){
            throw new Exception(reqResponseString);
        }else if(reqResponseString.equals(HTTP_401)){
            getAuthCode();
            getItemList(folderID);
        }

        return (BoxItemCollectionInfo) CommonUtils.convertJsonStringToObject(reqResponseString, BoxItemCollectionInfo.class);
    }

    public void getUserSystemFolder() throws Exception{
        BoxItemInfo rootFolder = getRootList();

        for(BoxItemSimpleInfo boxItemInfo : rootFolder.item_collection.entries){
            if(boxItemInfo.name.equals("UserSystemFolder")){
                userSystemFolder = boxItemInfo;
                break;
            }
        }
    }

    public BoxUploadedFileInfo updloadFile(File fileToUpload) throws Exception{
        return updloadFile(fileToUpload, null);
    }

    public BoxUploadedFileInfo updloadFile(File fileToUpload, String userPrivateFolderId) throws Exception{

        BoxUploadCreateItemInfo BoxUploadCreateItemInfo = new BoxUploadCreateItemInfo();
        BoxUploadCreateItemInfo.name = fileToUpload.getName();

        BoxUploadCreateItemInfo.parent = new BoxUploadCreateItemParentInfo();
        if(userPrivateFolderId != null && !userPrivateFolderId.isEmpty()){
            BoxUploadCreateItemInfo.parent.id = userPrivateFolderId;
        }else {
            BoxUploadCreateItemInfo.parent.id = userSystemFolder.id;
        }

        ArrayList<RestAPIInfo> restAPIInfoArrayList = new ArrayList<>();

        RestAPIInfo restAPIInfo = new RestAPIInfo();
        restAPIInfo.fieldName = "attributes";
        restAPIInfo.fieldData = CommonUtils.convertObjectToJsonString(BoxUploadCreateItemInfo);
        restAPIInfo.doEncode = false;
        restAPIInfoArrayList.add(restAPIInfo);

        restAPIInfo = new RestAPIInfo();
        restAPIInfo.fieldName = "file";
        restAPIInfo.isFile = true;
        restAPIInfo.fieldData = fileToUpload.getAbsolutePath();
        restAPIInfoArrayList.add(restAPIInfo);

        String reqResponseString = restAPISSL.POST(APIBaseUploadURI, restAPIInfoArrayList);

        if(reqResponseString.startsWith("ERROR:")){
            throw new Exception(reqResponseString);
        }else if(reqResponseString.equals(HTTP_401)){
            getAuthCode();
            updloadFile(fileToUpload, userPrivateFolderId);
        }

        return(BoxUploadedFileInfo) CommonUtils.convertJsonStringToObject(reqResponseString, BoxUploadedFileInfo.class);
    }

    public BoxItemSimpleInfo getUserPrivateFolder(String userPrivateFolder) throws Exception{
        BoxItemCollectionInfo BoxItemCollectionInfo = getItemList(userSystemFolder.id);

        for(BoxItemSimpleInfo boxItemInfo : BoxItemCollectionInfo.entries){
            if(boxItemInfo.name.equals(userPrivateFolder)){
                return boxItemInfo;
            }
        }

        return null;
    }

    public BoxItemInfo createUserPrivateFolder(String userPrivateFolderName) throws Exception{
        return createUserPrivateFolder(userPrivateFolderName, userSystemFolder.id);
    }

    public BoxItemInfo createUserPrivateFolder(String userPrivateFolderName, String parentFolderId) throws Exception{
        BoxUploadCreateItemInfo BoxUploadCreateItemInfo = new BoxUploadCreateItemInfo();
        BoxUploadCreateItemInfo.name = userPrivateFolderName;

        BoxUploadCreateItemInfo.parent = new BoxUploadCreateItemParentInfo();
        BoxUploadCreateItemInfo.parent.id = parentFolderId;

        ArrayList<RestAPIInfo> restAPIInfoArrayList = new ArrayList<>();

        RestAPIInfo restAPIInfo = new RestAPIInfo();
        restAPIInfo.fieldName = "jsonData";
        restAPIInfo.fieldData = CommonUtils.convertObjectToJsonString(BoxUploadCreateItemInfo);
        restAPIInfo.doEncode = false;
        restAPIInfoArrayList.add(restAPIInfo);

        String reqResponseString = RestAPISSLJson.POST(createFolder, restAPIInfoArrayList);

        if(reqResponseString.startsWith("ERROR:")){
            throw new Exception(reqResponseString);
        }else if(reqResponseString.equals(HTTP_401)){
            getAuthCode();
            createUserPrivateFolder(userPrivateFolderName, parentFolderId);
        }

        return (BoxItemInfo) CommonUtils.convertJsonStringToObject(reqResponseString, BoxItemInfo.class);
    }

    public void deleteAllItemInFolder(String folderId) throws Exception{
        ArrayList<RestAPIInfo> restAPIInfoArrayList = new ArrayList<>();

        RestAPIInfo restAPIInfo = new RestAPIInfo();
        restAPIInfo.fieldName = "recursive";
        restAPIInfo.fieldData = "true";
        restAPIInfoArrayList.add(restAPIInfo);

        String reqResponseString = restAPISSL.DELETE(deleteFolder + folderId, restAPIInfoArrayList);

        if(reqResponseString.startsWith("ERROR:")){
            reqResponseString = reqResponseString.replaceFirst("ERROR:", "");

            BoxErrorInfo boxErrorInfo = (BoxErrorInfo) CommonUtils.convertJsonStringToObject(reqResponseString, BoxErrorInfo.class);

            if(!boxErrorInfo.message.equals("Not Found")){
                throw new Exception(boxErrorInfo.code + "-" + boxErrorInfo.message);
            }
        }else if(reqResponseString.equals(HTTP_401)){
            getAuthCode();
            deleteAllItemInFolder(folderId);
        }
    }

    public void deleteItem(BoxItemSimpleInfo fileForRemoval) throws Exception{

        restAPISSL.addHeaders("If-Match", fileForRemoval.etag);
        String reqResponseString = restAPISSL.DELETE(deleteFile + fileForRemoval.id, null);
        restAPISSL.deleteHeader("If-Match");

        if(reqResponseString.startsWith("ERROR:")){
            reqResponseString = reqResponseString.replaceFirst("ERROR:", "");

            BoxErrorInfo boxErrorInfo = (BoxErrorInfo) CommonUtils.convertJsonStringToObject(reqResponseString, BoxErrorInfo.class);

            if(!boxErrorInfo.message.equals("Not Found")){
                throw new Exception(boxErrorInfo.code + "-" + boxErrorInfo.message);
            }
        }else if(reqResponseString.equals(HTTP_401)){
            getAuthCode();
            deleteItem(fileForRemoval);
        }
    }

    private void deleteItemInTrash(String type, String id) throws Exception{
        String reqResponseString = "";

        if(type.equals("file")){
            reqResponseString = restAPISSL.DELETE(String.format(deleteFileInTrash, id), null);
        }else if (type.equals("folder")){
            reqResponseString = restAPISSL.DELETE(String.format(deleteFolderInTrash, id), null);
        }

        if(reqResponseString.startsWith("ERROR:")){
            reqResponseString = reqResponseString.replaceFirst("ERROR:", "");

            BoxErrorInfo boxErrorInfo = (BoxErrorInfo) CommonUtils.convertJsonStringToObject(reqResponseString, BoxErrorInfo.class);

            if(!boxErrorInfo.message.equals("Not Found")){
                throw new Exception(boxErrorInfo.code + "-" + boxErrorInfo.message);
            }
        }else if(reqResponseString.equals(HTTP_401)){
            getAuthCode();
            deleteItemInTrash(type, id);
        }
    }

    public BoxItemCollectionInfo getAllItemInTrash() throws Exception{
        String reqResponseString = restAPISSL.GET(getTrashItems, null);

        if(reqResponseString.startsWith("ERROR:")){
            throw new Exception(reqResponseString);
        }else if(reqResponseString.equals(HTTP_401)){
            getAuthCode();
            getAllItemInTrash();
        }

        return (BoxItemCollectionInfo) CommonUtils.convertJsonStringToObject(reqResponseString, BoxItemCollectionInfo.class);
    }

    public void deleteAllItemInTrash() throws Exception{
        BoxItemCollectionInfo BoxItemCollectionInfo = getAllItemInTrash();

        for(BoxItemSimpleInfo boxItemSimpleInfo : BoxItemCollectionInfo.entries){
            deleteItemInTrash(boxItemSimpleInfo.type, boxItemSimpleInfo.id);
        }
    }

    public void setFileItemAsSharable(String itemID) throws Exception{

        ArrayList<RestAPIInfo> restAPIInfoArrayList = new ArrayList<>();

        RestAPIInfo restAPIInfo = new RestAPIInfo();
        restAPIInfo.fieldName = "jsonData";
        restAPIInfo.fieldData = "{\"shared_link\": {\"access\": \"open\", \"password\" : null}}";
        restAPIInfo.doEncode = false;
        restAPIInfoArrayList.add(restAPIInfo);

        String reqResponseString = RestAPISSLJson.PUT( String.format(shareFile, itemID), restAPIInfoArrayList);

        if(reqResponseString.startsWith("ERROR:")){
            throw new Exception(reqResponseString);
        }else if(reqResponseString.equals(HTTP_401)){
            getAuthCode();
            setFileItemAsSharable(itemID);
        }

    }
}
