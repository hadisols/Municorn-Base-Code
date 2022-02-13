public class Plivo_Outbound_SYS_ApplicationService extends SYS_ApplicationService {
    public Plivo_Outbound_SYS_ApplicationService() {

    }
    /* ---------------  Outbound Immediate Response Processing  ----------------------*/
    //Immediate Response Wrapper
    public class PlivoMessage {
        public String message ;
        public List<String> message_uuid ;
        public String api_id ;
    }
    //Add Immediate Outbound Response Syslog to Upsert Using Custom Apex Handler
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
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.How_To_Process__c.isCreateable()) {
                //logResp.How_To_Process__c = 'ignore_log';
                log.How_to_process__c = 'use_custom_apex_handler';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Custom_Apex_Handler__c.isCreateable()) {
                log.Custom_Apex_Handler__c = 'Plivo_Outbound_SYS_ApplicationService';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                logResp.SYS_Operation_Type__c = 'UPSERT';
            }
        }

        return logResp;
    }
    // For Outbound. Called from doInbound() in ApplicationService
     //Upsert Outbound Response using WhattID
    public override List<sObject> transformJsonToSObject(String jsonBody,String resource) {
        //Custom Code to Upsert Outbound Response
        SYS_IntegrationLog__c log = SYS_DataCache.log;
        String recordId = log.WhatId__c;
        PlivoMessage plivoRespObj = (PlivoMessage)System.JSON.deserialize(jsonBody, PlivoMessage.class);
        String messageUUID = String.valueof(plivoRespObj.message_uuid[0]);
        
        List<sObject> sObjectsToDML = new List<sObject>();
        String ObjectName = ((Id)recordId).getsobjecttype() + '';
        sObject record = Schema.getGlobalDescribe().get(ObjectName).newSObject(((Id)recordId)); 
        record.put('Id' , recordId);
        record.put('UUID__c' , messageUUID);
        sObjectsToDML.add(record);

        //List < sObject > sObjectsToDML = SYS_Transformer.getSObjectsToUpsert(new List<String>{jsonBody},resource);
        return sObjectsToDML;
    }

    //Upsert Immediate Response using WhattID
    //User SYS_DataCache.log and transformJsonToSObject() override
    /*
    public override Boolean doInbound(SYS_IntegrationLog__c log) {
        String jsonBody = '';
        String recordId = log.WhatId__c;
        jsonBody =  log.data0__c != null ? log.data0__c : '' +
                    log.data1__c != null ? log.data1__c : '' +
                    log.data2__c != null ? log.data2__c : '' +
                    log.data3__c != null ? log.data3__c : '' +
                    log.data4__c != null ? log.data4__c : '' +
                    log.data5__c != null ? log.data5__c : '' +
                    log.data6__c != null ? log.data6__c : '' +
                    log.data7__c != null ? log.data7__c : '' +
                    log.data8__c != null ? log.data8__c : '' +
                    log.data9__c != null ? log.data9__c : '' ;

        jsonBody = preprocessJSONForInbound(log,jsonBody);
        //Custom Code to Upsert Outbound Response
        PlivoMessage plivoRespObj = (PlivoMessage)System.JSON.deserialize(jsonBody, PlivoMessage.class);
        SYS_debug.log('test RespObj '+ plivoRespObj);
        String messageUUID = String.valueof(plivoRespObj.message_uuid[0]);
        SYS_debug.log('test messageUUID '+messageUUID);
        
        List<sObject> sObjectsToDML = new List<sObject>();
        String ObjectName = ((Id)recordId).getsobjecttype() + '';
        sObject record = Schema.getGlobalDescribe().get(ObjectName).newSObject(((Id)recordId)); 
        record.put('Id' , recordId);
        record.put('UUID__c' , messageUUID);
        sObjectsToDML.add(record);
        
        SYS_debug.log('\n\n ------------------------------- \n\n Application Service sObjects to DML:'+sObjectsToDML);

        String externalIdFieldAPIName = log.External_Id_Field_API_Name__c!=NULL?log.External_Id_Field_API_Name__c:'';
               
        return doDML(sObjectsToDML,log.SYS_Operation_Type__c,externalIdFieldAPIName);
    }
    */
}