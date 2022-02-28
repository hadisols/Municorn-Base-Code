public class SYS_Override_ApplicationService extends SYS_ApplicationService{
    public SYS_Override_ApplicationService() {

    }

    public override HttpResponse doOutbound(SYS_IntegrationLog__c log){
        System.debug('\n In SYS_Override_ApplicationService');
        return super.doOutbound(log);
    }

    /*
    public override SYS_IntegrationLog__c generatelogForOutboundResult(HttpResponse resp,SYS_IntegrationLog__c log){

        SYS_IntegrationLog__c logResp = SYS_Helper.getLogsToInsert(resp.getBody());
        
        if(resp.getStatusCode() != 201 && resp.getStatusCode() != 200){
            SYS_debug.log('#### resp status: '+resp.getStatus());
            SYS_debug.log('#### resp code: '+resp.getStatusCode()); 
            SYS_debug.log('#### resp: '+resp.getBody()); 
    
            
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Status__c.isCreateable()) {
                logResp.Status__c = 'ERROR';
                SYS_Helper.flagLogForRetry(logResp.Id);
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Http_Status__c.isCreateable()) {
                logresp.SYS_Http_Status__c = integer.valueOf(resp.getStatusCode());
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_RequestId__c.isCreateable()) {
                SYS_IntegrationLog__c tempLog = new SYS_IntegrationLog__c(UUID__c = log.UUID__c);
                logResp.SYS_RequestId__r = tempLog;
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.WhatId__c.isCreateable()) {
                logResp.WhatId__c = log.WhatId__c;
            }
            
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Type__c.isCreateable()) {
                logResp.Type__c = 'RESPONSE';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                //No operation when there is an HTTP Error logResp.SYS_Operation_Type__c = 'RESPONSE';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.How_To_Process__c.isCreateable()) {
                logResp.How_To_Process__c = 'ignore_log';
                
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                logResp.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
            }
            
        }
        else{
    
            //new SYS_Log().instance.setValue('data0__c','TESTING SYS_LOG');
            

            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Status__c.isCreateable()) {
                
                if(log.SYS_Operation_Type__c == 'INSERT'){
                    logResp.Status__c = 'NEW';
                }
                else{
                    logResp.Status__c = 'DONE';
                }
            }
            
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Http_Status__c.isCreateable()) {
                logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_RequestId__c.isCreateable()) {
                SYS_IntegrationLog__c tempLog = new SYS_IntegrationLog__c(UUID__c = log.UUID__c);
                logResp.SYS_RequestId__r = tempLog;
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.WhatId__c.isCreateable()) {
                logResp.WhatId__c = log.WhatId__c;
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Type__c.isCreateable()) {
                logResp.Type__c = 'RESPONSE';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                logResp.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.How_To_Process__c.isCreateable()) {
                if(log.SYS_Operation_Type__c == 'INSERT'){
                    logResp.How_To_Process__c = 'use_custom_apex_handler';
                    logResp.Custom_Apex_Handler__c = 'SYS_ApplicationService';
                }
                else{
                    logResp.How_To_Process__c = 'ignore_log';
                }
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                if(log.SYS_Operation_Type__c == 'INSERT'){
                    logResp.SYS_Operation_Type__c = 'UPDATE';
                    logResp.Resource__c = SYS_DataCache.fieldSettingMappingUsingObjSetting[0].RestResource__c;
                    //SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ResourcePath__c;
                }
            }
        }
    
        return logResp;
    }
    */

    public override HttpRequest buildOutboundHttpRequest(SYS_IntegrationLog__c log){

        if(log.SYS_Operation_Type__c == 'INSERT'){
            return super.buildOutboundHttpRequest(log);
        }
        else{
            HttpRequest req = new HttpRequest();
            IntegrationSetting__mdt integrationSetting = SYS_DataCache.integrationSetting.get(SYS_Datacache.INT_TYPE);
            String baseEndpoint = integrationSetting.BaseAPIEndPoint__c;
    
            List<HttpHeaders__mdt> httpHeader = SYS_DataCache.headerSetting;
            req.setMethod('PATCH');//req.setMethod(integrationSetting.UpdateMethod__c);
            for(HttpHeaders__mdt head:httpHeader){
                SYS_debug.log('header is = '+head.header_name__c + ''+head.Value__c);
                req.setHeader(String.valueOf(head.header_name__c), String.valueOf(head.Value__c));  
                    
            }
            String resourceUrl = 
            integrationSetting.BaseAPIEndPoint__c+
            SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ResourcePath__c+'/';
            String urlParams='';
            if(SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).url_params__c != NULL)
                urlParams = SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).url_params__c;
            List<sObject> rec = Database.query('SELECT SYS_Key__c FROM '+SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ObjectApiName__c+' WHERE Id = \''+log.WhatId__c+'\' LIMIT 1');
            req.setEndpoint(resourceUrl+'Id'+'/'+rec[0].get('SYS_Key__c')+urlParams);
            return req;
        }
        
    }
}