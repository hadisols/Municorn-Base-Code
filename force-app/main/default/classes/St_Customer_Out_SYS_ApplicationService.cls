public with sharing class St_Customer_Out_SYS_ApplicationService  extends SYS_ApplicationService {
    public St_Customer_Out_SYS_ApplicationService() {

    }
    //Generate Request params from JSON for Outbound
    public override String sanitizeJSONForOutbound(String jsonRecord) {
        String finalJSON = jsonRecord.replace('\n', ' ');
        String newrequestParams=''; 
        Map < String, Object > jsonobj = (Map < String, Object > ) JSON.deserializeUntyped(finalJSON);
        List < String > reqkeymap = new List < String > (jsonobj.keySet());
        reqkeymap.sort();
        Integer i=0;
        for (String key: reqkeymap) {
            if (!String.isBlank(key) && jsonobj.get(key) != '' && (jsonobj.get(key)) instanceOf String)
            if(i==0){
                newrequestParams += '?' + key.toLowerCase() + '=' + jsonobj.get(key);
            } else {
                newrequestParams += '&' + key.toLowerCase() + '=' + jsonobj.get(key);
            }
            i++;
        }
        finalJSON = newrequestParams;
        System.debug('newrequestParams: ' + newrequestParams);
        return finalJSON;
    }

    //TO DO a Callout if customer is not created - pending 
    public override HttpRequest buildOutboundHttpRequest(SYS_IntegrationLog__c log){
        HttpRequest req = new HttpRequest();

        List<sObject> recList = 
            Database.query( 'SELECT '+SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ExternalFieldApi__c+
                            ' FROM '+SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ObjectApiName__c+
                            ' WHERE Id = \'' + log.WhatId__c + '\'');
 
        String externalId = String.valueOf(recList[0].get(SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ExternalFieldApi__c));
        
        req.setMethod(getHttpRequestMethod(log,externalId));
        req.setEndpoint(getHttpRequestEndpoint(req,log,externalId));
        setHttpRequestHeaders(req,log);
 
        return req;
    }

    /* ------------------------------------------------------------------------ */
    // To do midify outbound creteria based on insert and update
    public override HttpResponse doOutbound(SYS_IntegrationLog__c log){
        Http http = new Http();
        HttpRequest req = buildOutboundHttpRequest(log);

        if(req.getMethod()!='GET'){
            String body = SYS_Helper.getDataFrom(log); 
            body = preprocessJSONForOutbound(log,body,req);
            req.setBody(body);
            SYS_debug.log('body:'+body);
        }
 
        HttpResponse response = http.send(req);
        SYS_debug.log('Outbound Request:'+req);
        SYS_debug.log('Outbound Response:'+response.getBody());
        return response;

    }
    //Add Immediate Outbound Response Syslog to Upsert Using Custom Apex Handler
    // Added Custom Apex handler and resource path identifier
    public override SYS_IntegrationLog__c generatelogForOutboundResult(HttpResponse resp,SYS_IntegrationLog__c log){

        SYS_IntegrationLog__c logResp = SYS_Helper.getLogsToInsert(resp.getBody());

        String algo = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Hashing_Algo__c;
        if(algo!=NULL && algo!='')
            logResp.Request_Digest__c = generateHash(resp.getBody(),algo);

        if(resp.getStatusCode() != 201 && resp.getStatusCode() != 200){

            SYS_debug.log('#### resp status: '+resp.getStatus());
            SYS_debug.log('#### resp code: '+resp.getStatusCode()); 
            SYS_debug.log('#### resp: '+resp.getBody());

            log.Status__c = 'FAIL';
            log.retry__c = true;

            logResp.Status__c = 'ERROR';
            //SYS_Helper.flagLogForRetry(log.Id);
            
            logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
            logResp.WhatId__c = log.WhatId__c;
            logResp.Type__c = 'RESPONSE';
            logResp.How_To_Process__c = 'ignore_log';
            logResp.Integration_Setting__c = SYS_DataCache.INT_TYPE;
            
        }
        else{
            log.Status__c = 'DONE';
            
            if(log.SYS_Operation_Type__c == 'INSERT' || log.Force_Sync__c){
                logResp.Status__c = 'NEW';
                logResp.SYS_Operation_Type__c = 'UPDATE';
                //logResp.Flat_Key_for_Resource__c = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Flat_Key_for_Resource__c;
                logResp.Flat_Key_for_Resource__c = 'object';   
                //logResp.Resource__c = SYS_DataCache.FieldMappingOutbound[0].RestResource__c;
                logResp.How_To_Process__c = 'use_custom_apex_handler';
                //logResp.Custom_Apex_Handler__c = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).ApexHandler__c;
                logResp.Custom_Apex_Handler__c = 'St_Customer_Out_SYS_ApplicationService';
            }
            else{
                logResp.Status__c = 'DONE';
                logResp.How_To_Process__c = 'ignore_log';

            }
        
            logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
            logResp.WhatId__c = log.WhatId__c;
            logResp.Type__c = 'RESPONSE';
            logResp.Integration_Setting__c = SYS_DataCache.INT_TYPE;
            logResp.ObjectSettingId__c = log.ObjectSettingId__c;
               
            
        }

        //doDML(new List<SYS_IntegrationLog__c>{log}, 'UPSERT', '') ;
        upsert log;
        logResp.SYS_RequestId__c = log.Id;

        return logResp;
    }
}