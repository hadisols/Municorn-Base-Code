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
        IntegrationSetting__mdt integrationSetting = SYS_DataCache.integrationSetting.get(SYS_Datacache.INT_TYPE);
        String baseEndpoint = integrationSetting.BaseAPIEndPoint__c;

        List<HttpHeaders__mdt> httpHeader = SYS_DataCache.headerSetting;
        req.setMethod(integrationSetting.UpdateMethod__c);
        for(HttpHeaders__mdt head:httpHeader){
            SYS_debug.log('header is = '+head.MasterLabel + ''+head.Value__c);
            req.setHeader(String.valueOf(head.MasterLabel), String.valueOf(head.Value__c));
        }
        Boolean createCustomer = true;
        String resourceUrl = integrationSetting.BaseAPIEndPoint__c+SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ResourcePath__c;
        List<Contact> rec = [SELECT StripeCustomerId__c FROM Contact WHERE Id = :log.WhatId__c LIMIT 1];
        if( rec.size() >0 ){
            resourceUrl = resourceUrl +'/'+rec[0].StripeCustomerId__c;
            createCustomer = false;
        }
        req.setEndpoint(resourceUrl);
        if(createCustomer){
          //  HttpResponse createResponse = http.send(req);
            //Log Customer Create JSON into Syslog
          //  SYS_IntegrationLog__c createsyslog = generatelogForOutboundResult(createResponse,log);
        }
        return req;
    }

    /* ------------------------------------------------------------------------ */
    // To do midify outbound creteria based on insert and update
    public override HttpResponse doOutbound(SYS_IntegrationLog__c log){

        Http http = new Http();
        HttpRequest req = buildOutboundHttpRequest(log);
        
        String body = log.data0__c != null ? log.data0__c : '' +
                            log.data1__c != null ? log.data1__c : '' +
                            log.data2__c != null ? log.data2__c : '' +
                            log.data3__c != null ? log.data3__c : '' +
                            log.data4__c != null ? log.data4__c : '' +
                            log.data5__c != null ? log.data5__c : '' +
                            log.data6__c != null ? log.data6__c : '' +
                            log.data7__c != null ? log.data7__c : '' + 
                            log.data8__c != null ? log.data8__c : '' +
                            log.data9__c != null ? log.data9__c : '' ; 
        
        //Log Customer Create JSON into Syslog
       // SYS_IntegrationLog__c createsyslog = generatelogForOutboundResult(createResponse,log);
        //Build Customer Update Request
        body = preprocessJSONForOutbound(log,body);
        req.setBody(body);
        SYS_debug.log('body:'+body);
        HttpResponse response = http.send(req);

        return response;
        
    }
    //Add Immediate Outbound Response Syslog to Upsert Using Custom Apex Handler
    // Added Custom Apex handler and resource path identifier
    public override SYS_IntegrationLog__c generatelogForOutboundResult(HttpResponse resp,SYS_IntegrationLog__c log){
        SYS_IntegrationLog__c logResp = getLogsToInsert(resp.getBody());
        //Added Status 202 - Accepted in Creteria
        if(resp.getStatusCode() != 202 && resp.getStatusCode() != 201 && resp.getStatusCode() != 200){
            SYS_debug.log('#### resp status: '+resp.getStatus());
            SYS_debug.log('#### resp code: '+resp.getStatusCode()); 
            SYS_debug.log('#### resp: '+resp.getBody());

            
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Status__c.isCreateable()) {
                logResp.Status__c = 'ERROR';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Http_Status__c.isCreateable()) {
                logresp.SYS_Http_Status__c = integer.valueOf(resp.getStatusCode());
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_RequestId__c.isCreateable()) {
                logResp.SYS_RequestId__c = log.Id;
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.WhatId__c.isCreateable()) {
                logResp.WhatId__c = log.WhatId__c;
            }
            
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Type__c.isCreateable()) {
                logResp.Type__c = 'INBOUND';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                logResp.SYS_Operation_Type__c = 'RESPONSE';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.How_To_Process__c.isCreateable()) {
                logResp.How_To_Process__c = 'ignore_log';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                logResp.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
            }
        }
        else{

            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Status__c.isCreateable()) {
                logResp.Status__c = 'DONE';
            }
            
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Http_Status__c.isCreateable()) {
                logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_RequestId__c.isCreateable()) {
                logResp.SYS_RequestId__c = log.Id;
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.WhatId__c.isCreateable()) {
                logResp.WhatId__c = log.WhatId__c;
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Type__c.isCreateable()) {
                logResp.Type__c = 'INBOUND';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                logResp.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Flat_Key_for_Resource__c.isCreateable()) {
                logResp.Flat_Key_for_Resource__c = 'object';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.How_To_Process__c.isCreateable()) {
                log.How_to_process__c = 'use_custom_apex_handler';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Custom_Apex_Handler__c.isCreateable()) {
                log.Custom_Apex_Handler__c = 'St_Customer_Out_SYS_ApplicationService';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                logResp.SYS_Operation_Type__c = 'UPSERT';
            }
        }

        return logResp;
    }
    // For Outbound. Called from doInbound() in ApplicationService
    //Upsert Immediate Response using WhattID
    public override List<sObject> transformJsonToSObject(String jsonBody,String resource) {
        List < sObject > sObjectsToDML = SYS_Transformer.getSObjectsToUpsert(new List<String>{jsonBody},resource);
        SYS_IntegrationLog__c log = SYS_DataCache.log;
        String recordId = log.WhatId__c;
        if (sObjectsToDML.size() > 0) {
            for (sObject currentObj: sObjectsToDML) {
                if (currentObj instanceOf Contact) {
                    currentObj.put('Id' , recordId);
                }
            }
        }
        return sObjectsToDML;
    }
    
}