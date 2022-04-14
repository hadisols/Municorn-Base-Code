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

        String query = 'SELECT '+SYS_Helper.getAllFieldsFor('SYS_OAuthConfig__c') +' FROM SYS_OAuthConfig__c';
        String whereClause = ' WHERE Id = \'' + String.escapeSingleQuotes(log.WhatId__c) + '\'';
        List<SYS_OAuthConfig__c> authConfigList = Database.query(String.escapeSingleQuotes(query)+whereClause);

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

    public override SYS_IntegrationLog__c generatelogForOutboundResult(HttpResponse resp,SYS_IntegrationLog__c log){

        SYS_IntegrationLog__c logResp = SYS_Helper.getLogsToInsert(resp.getBody());

        String algo = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Hashing_Algo__c;
        if(algo!=NULL && algo!='')
            logResp.Request_Digest__c = generateHash(resp.getBody(),algo);

        if(resp.getStatusCode() != 201 && resp.getStatusCode() != 200){

            log.Status__c = 'FAIL';

            logResp.Status__c = 'ERROR';
            
            logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
            logResp.WhatId__c = log.WhatId__c;
            logResp.Type__c = 'RESPONSE';
            logResp.How_To_Process__c = 'ignore_log';
            logResp.Integration_Setting__c = SYS_DataCache.INT_TYPE;
            
        }
        else{
            log.Status__c = 'DONE';

            logResp.Status__c = 'NEW';
            logResp.SYS_Operation_Type__c = 'UPDATE';

            logResp.Resource__c = SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).Resource_Name__c;
            logResp.How_To_Process__c = 'use_custom_apex_handler';
            logResp.Custom_Apex_Handler__c = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).ApexHandler__c;
            
            logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
            logResp.WhatId__c = log.WhatId__c;
            logResp.Type__c = 'RESPONSE';
            logResp.Integration_Setting__c = SYS_DataCache.INT_TYPE;
            logResp.ObjectSettingId__c = log.ObjectSettingId__c;

            logResp.retry__c = false; 
            
        }

        //doDML(new List<SYS_IntegrationLog__c>{log}, 'UPSERT', '') ;
        SYS_Helper.upsertLog(log);
        logResp.SYS_RequestId__c = log.Id;

        return logResp;
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

            SYS_DataCache.INT_TYPE = 'SYS_Auth_Integration_Setting';
            SYS_DataCache.OBJ_TYPE = 'SYS_Auth_JWT_Object_Setting';

            String query = 'SELECT '+SYS_Helper.getAllFieldsFor('SYS_OAuthConfig__c') +' FROM '+ SYS_DataCache.namespacePrefix +'SYS_OAuthConfig__c';
            String whereClause = ' WHERE Id = \'' + String.escapeSingleQuotes(oauthConfigId) + '\'';
            List<SYS_OAuthConfig__c> authConfigList = Database.query(String.escapeSingleQuotes(query)+whereClause);

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
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

   
}