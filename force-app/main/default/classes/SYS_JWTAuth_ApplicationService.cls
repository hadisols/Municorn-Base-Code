public with sharing class SYS_JWTAuth_ApplicationService extends SYS_ApplicationService {

    public String base64UrlEncode(Blob input){ 
        String output = EncodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')){
            output = output.subString(0,output.length()-1);
        }
        return output;
    }

    public override String preprocessJSONForOutbound(SYS_IntegrationLog__c log, String jsonBody,HttpRequest req){

        // TODO add other supported algos. Handle RSA-SHA256 using Certificate

        List<SYS_OAuthConfig__c> authConfigList = 
            Database.query('SELECT '+SYS_Helper.getAllFieldsFor('SYS_OAuthConfig__c') +' FROM SYS_OAuthConfig__c WHERE Id = \'' + log.WhatId__c + '\'');

        String jwt = '';
    
        JSONGenerator header = JSON.createGenerator(false);
        header.writeStartObject();
        header.writeStringField('alg', authConfigList[0].algo__c);
        header.writeStringField('typ', 'JWT');
        header.writeEndObject();
        
        String encodedHeader = base64UrlEncode(Blob.valueOf(header.getAsString()));

        jwt = encodedHeader + '.' + base64UrlEncode(Blob.valueOf(jsonBody));
        Blob key = EncodingUtil.base64Decode(authConfigList[0].Private_Key__c);
        Blob signature = Crypto.sign('rsa-sha256', Blob.valueOf(jwt), key);
        jwt += '.' + base64UrlEncode(signature); 

        jsonBody = 'grant_type='+EncodingUtil.urlEncode(authConfigList[0].Scope__c,'UTF-8')+'&assertion='+jwt;

        log.data1__c = jsonBody;

        return jsonBody;
    }

    public override String getHttpRequestMethod(SYS_IntegrationLog__c log,String externalId){
        return 'POST';
    }

    public override String getResourceFromJSON(SYS_IntegrationLog__c log,String jsonBody){
        return 'token';
    }

    public override String getHttpRequestEndpoint(HttpRequest req,SYS_IntegrationLog__c log, String externalId){
        String baseEndpoint = SYS_DataCache.integrationSetting.get(SYS_Datacache.INT_TYPE).BaseAPIEndPoint__c;
        String resourceUrl = baseEndpoint + SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ResourcePath__c;
        
        String urlParams='';
        if(SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).url_params__c != NULL)
                urlParams = SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).url_params__c;
        
        if(urlParams!=''){
            resourceUrl+='/'+urlParams;
        }
        
        return resourceUrl;
    }
    
    @AuraEnabled
    public static void invokeTokenFlow(Id oauthConfigId){
        try {
            List<SYS_OAuthConfig__c> authConfigList = 
            Database.query('SELECT '+SYS_Helper.getAllFieldsFor('SYS_OAuthConfig__c') +' FROM SYS_OAuthConfig__c WHERE Id = \'' + oauthConfigId + '\'');


            SYS_DataCache.INT_TYPE = 'SYS_Auth_Integration_Setting';
            SYS_DataCache.OBJ_TYPE = 'SYS_Auth_JWT_Object_Setting';
            SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ApexHandler__c).newInstance();
            Map<Id, String> jsonListForOutbound = appService.transformSObjectToJson(authConfigList);
            
            List<SYS_IntegrationLog__c> insertSysLog = new List<SYS_IntegrationLog__c>();
            
            if(jsonListForOutbound.values().size() > 0){
                for(Id jsonRecordId:jsonListForOutbound.keyset()){ 
                    String finalJsonForOutbound;

                    finalJsonForOutbound = appService.sanitizeJSONForOutbound(jsonListForOutbound.get(jsonRecordId));

                    SYS_IntegrationLog__c  newSysLog = SYS_Helper.getLogsToInsert(finalJsonForOutbound);
                    newSysLog.Status__c = 'NEW';
                    newSysLog.Type__c = 'OUTBOUND';
                    newSysLog.Integration_Setting__c = SYS_DataCache.INT_TYPE;
                    newSysLog.SYS_Operation_Type__c = 'INSERT';
                    newSysLog.whatid__c = jsonRecordId;
                    newSysLog.How_to_process__c = 'use_object_setting';
                    newSysLog.ObjectSettingId__c = SYS_DataCache.OBJ_TYPE;

                    insertSysLog.add(newSysLog);
                }

                if(insertSysLog.size()>0 && SYS_DataCache.enableCheck.get(SYS_DataCache.INT_TYPE.toUpperCase())){
                    new SYS_IntegrationLogOutboundImmediate(insertSysLog).execute();
                    //insert insertSysLog;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

   
}