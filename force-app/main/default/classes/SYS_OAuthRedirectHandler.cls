@RestResource(urlMapping='/v1/callback/*')
global class SYS_OAuthRedirectHandler extends SYS_ApplicationService{

    private static String authCode;
    private static String calloutUrl;

    global override String getHttpRequestEndpoint(HttpRequest req,SYS_IntegrationLog__c log, String externalId){
        if(SYS_DataCache.INT_TYPE !=NULL && SYS_DataCache.OBJ_TYPE !=NULL){
            String baseEndpoint = SYS_DataCache.integrationSetting.get(SYS_Datacache.INT_TYPE).BaseAPIEndPoint__c;
            String resourceUrl = baseEndpoint + SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ResourcePath__c;
            
            String urlParams='';
            if(SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).url_params__c != NULL)
                        urlParams = SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).url_params__c;
                
            if(urlParams!=''){
                resourceUrl+='/'+urlParams;
            }
            

            log.Callout_URL__c = resourceUrl;
            
            return resourceUrl;
        }else{
            return super.getHttpRequestEndpoint(req, log, externalId);
        }
    }


    global override sObject processFieldMapping(FieldSetting__mdt mapping,sObject sObj,Object value, String sObjectApiName){
        sObj.put(mapping.FieldApiName__c,SYS_Helper.secondsToDatetime(String.valueOf(value)));
        return sObj;
    }

    global override String preprocessJSONForOutbound(SYS_IntegrationLog__c log,String jsonBody,HttpRequest req) {
        
        String formUrlEncodedBody='';
        Map<String,Object> jsonobj = SYS_Helper.getFlatKeys(jsonBody, 'A[B]');//(Map<String,Object>)JSON.deserializeUntyped(flatJSON);
        List<String> reqkeymap = new List<String>(jsonobj.keySet());
        List<String> keyValueList = new List<String>();
        reqkeymap.sort();

        for (String key: reqkeymap) {
            if (!String.isBlank(key)){
                keyValueList.add(key.toLowerCase() + '=' + EncodingUtil.urlEncode(String.valueOf(jsonobj.get(key)!=NULL?jsonobj.get(key):''),'UTF-8'));
            }
        }
        if(authCode!=NULL)
        keyValueList.add('code' + '=' + EncodingUtil.urlEncode(authCode,'UTF-8'));

        formUrlEncodedBody = String.join(keyValueList,'&');
        log.data1__c = formUrlEncodedBody; 

        jsonBody = formUrlEncodedBody;
        
        return jsonBody;
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

        upsert log;
        logResp.SYS_RequestId__c = log.Id;

        return logResp;
    }

	@HttpGet
    global static void doGet(){
        System.debug('RestContext:'+RestContext.response);
        if(RestContext.response!=NULL){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.addHeader('Access-Control-Allow-Origin', '*');
        }
        String code= RestContext.request.params.get('code');
        String state = RestContext.request.params.get('state');
        
        System.debug('Code:'+code);
        authCode = code;
        
        List<SYS_OAuthConfig__c> configs = 

        Database.query('SELECT '+SYS_Helper.getAllFieldsFor('SYS_OAuthConfig__c')+' FROM SYS_OAuthConfig__c WHERE Id =\''+state+'\'');
        
        if(configs.size()>0){
            calloutUrl = configs[0].Token_Endpoint__c;
            try{

                SYS_DataCache.OBJ_TYPE = configs[0].Object_Setting__c;
                SYS_DataCache.INT_TYPE = SYS_DataCache.objectSettingMap.get(configs[0].Object_Setting__c).IntegrationType__r.DeveloperName;
                SYS_IntegrationLog__c  newSysLog = new SYS_IntegrationLog__c();
                List<SYS_IntegrationLog__c> insertSysLog = new List<SYS_IntegrationLog__c>();
                
                SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ApexHandler__c).newInstance();
                Map<Id, String> jsonListForOutbound = appService.transformSObjectToJson(configs);
                
                if(jsonListForOutbound.values().size() > 0){
                    for(Id jsonRecordId:jsonListForOutbound.keyset()){ 
                        String finalJsonForOutbound;

                        finalJsonForOutbound = appService.sanitizeJSONForOutbound(jsonListForOutbound.get(jsonRecordId));

                        newSysLog = SYS_Helper.getLogsToInsert(finalJsonForOutbound);
                        newSysLog.Status__c = 'NEW';
                        newSysLog.HTTP_Method__c = 'POST';
                        newSysLog.Type__c = 'OUTBOUND';
                        newSysLog.Integration_Setting__c = SYS_DataCache.INT_TYPE;
                        newSysLog.How_to_process__c = 'use_object_setting';
                        newSysLog.ObjectSettingId__c = SYS_DataCache.OBJ_TYPE;
                        newSysLog.SYS_Operation_Type__c = 'INSERT';
                        //newSysLog.Callout_URL__c = configs[0].Token_Endpoint__c;
                        newSysLog.Custom_Field_Value__c = code;
                        newSysLog.WhatId__c = state;
                        
                        newSysLog.retry__c = false;
                        insertSysLog.add(newSysLog);
                    }

                    if(insertSysLog.size()>0 && SYS_DataCache.enableCheck.get(SYS_DataCache.INT_TYPE.toUpperCase())){
                        new SYS_IntegrationLogOutboundImmediate(insertSysLog).execute();
                    }
                    if(RestContext.response!=null)
                    RestContext.response.responseBody = 
                    Blob.valueOf('Token Generated succesfully.');
                    
                }
            }catch(Exception e){
                if(RestContext.response!=null)
                RestContext.response.responseBody = 
                    Blob.valueOf('Something went wrong while trying to call token url \n'+e.getMessage() + '\n' +e.getStackTraceString());
            }
            
            /*
            Http h = new Http();
    
            HttpRequest req = new HttpRequest();
            req.setEndpoint(configs[0].Token_Endpoint__c);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            
            String clientId = configs[0].Client_Id__c;
            String clientSecret = configs[0].Client_Secret__c;
            String redirect_uri = configs[0].Redirect_URL__c;
            String payload =    'client_id='+EncodingUtil.urlEncode(clientId,'UTF-8')+
                                '&client_secret='+EncodingUtil.urlEncode(clientSecret,'UTF-8')+
                                '&code='+EncodingUtil.urlEncode(code,'UTF-8')+
                                '&state='+EncodingUtil.urlEncode(state,'UTF-8')+
                                '&grant_type=authorization_code'+
                                '&redirect_uri='+EncodingUtil.urlEncode(redirect_uri ,'UTF-8');
            
            req.setBody(payload);
            System.debug('----- Token Request Body:'+req.getBody());
            

            // Send the request, and return a response
            HttpResponse res = h.send(req);

            //TODO - Check status code and process success/error
            
            JSONParser parser = JSON.createParser(res.getBody());
            String access_token='';
            String refresh_token=''; 
            String expiry;
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'access_token')) {
                    
                    parser.nextToken();
                    access_token= parser.getText();
                }

                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'refresh_token')) {
                    
                    parser.nextToken();
                    refresh_token= parser.getText();
                }

                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'expires_in')) {
                    
                    parser.nextToken();
                    expiry = parser.getText();
                }
            }

            configs[0].Access_Token__c =access_token;
            configs[0].Refresh_Token__c = refresh_token;
            configs[0].Token_Expiry_Time__c = expiry;

            Integer day = 86400;
            Integer hour = 3600;
            Integer minute = 60;
            if(expiry=='' || expiry==null){expiry = '36544015';}
            Integer totalSeconds = Integer.valueOf(expiry);
            Integer daysout = Integer.valueOf(Math.floor(totalseconds / day));
            Integer hoursout = Integer.valueOf(Math.floor((totalseconds - daysout * day)/hour));
            Integer minutesout = Integer.valueOf(Math.floor((totalseconds - daysout * day - hoursout * hour)/minute));
            Integer secondsout = Integer.valueOf(totalseconds - daysout * day - hoursout * hour - minutesout * minute);
            String inpputString = System.now().yearGmt()+'-'+System.now().monthGmt()+'-'+(System.now().dayGmt()+daysout)+'T'+(System.now().hourGmt()+hoursout)+':'+(System.now().minuteGmt()+minutesout)+':'+(System.now().secondGmt()+secondsout)+'.'+'000Z';
            System.debug('MS Date time:'+inpputString);
            DateTime resultDateTime = DateTime.valueof(inpputString.replace('T', ' ')); 

            configs[0].Token_Expiry_Date__c = resultDateTime;
            configs[0].Schedule_Refresh_Token__c = true;

            update configs;

            RestContext.response.responseBody = Blob.valueOf('{"data":'+res.getBody()+'}');
            
            */

        }else{
            RestContext.response.responseBody = Blob.valueOf('{"error":'+'Invalid Config Id. Authentication Failed'+'}');
        }
        
    }
}