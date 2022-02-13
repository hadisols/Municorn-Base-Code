public class override_SYS_ApplicationService extends SYS_ApplicationService {
    public override_SYS_ApplicationService() {

    }

    public override HttpResponse doOutbound(SYS_IntegrationLog__c log){
        System.debug('\n In override_SYS_ApplicationService');
        return super.doOutbound(log);
    }

    public override SYS_IntegrationLog__c generatelogForOutboundResult(HttpResponse resp,SYS_IntegrationLog__c log){

        SYS_IntegrationLog__c logResp = SYS_Helper.getLogsToInsert(resp.getBody());
        if(resp.getStatusCode() != 201 && resp.getStatusCode() != 200){
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
    
    
            //--EX
            /*
            List<SYS_IntegrationLog__c> exLogs = [Select Id,data0__c from SYS_IntegrationLog__c WHERE Id='a015f00000Juy2nAAB'];
            logResp = exLogs[0].clone(false,true,true,false);
            */
            //EX--
    
            logResp.Resource__c = SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ResourcePath__c;
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Status__c.isCreateable()) {
                //--EX logResp.Status__c = 'DONE';
                logResp.Status__c = 'NEW';
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
                //--EX logResp.How_To_Process__c = 'ignore_log';
                logResp.How_To_Process__c = 'use_object_setting';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                System.debug('MS log.SYS_Operation_Type__c:'+log.Parent__r.SYS_Operation_Type__c);
                if(log.SYS_Operation_Type__c == 'INSERT'){
                    logResp.SYS_Operation_Type__c = 'UPDATE';
                }
                else{
                    logResp.SYS_Operation_Type__c = log.SYS_Operation_Type__c;
                }
            }
    
            //logResp.Custom_Apex_Handler__c = 'SYS_ApplicationService';
            //logResp.Flat_Key_for_Resource__c = 'attributes.type'; //not required if JSON has root
            //logResp.External_Id_Field_API_Name__c = SYS_DataCache.objectSettingsMap.get(SYS_DataCache.OBJ_TYPE).ExternalFieldApi__c;
            logResp.Custom_Field_Value__c = 'false';
        }
    
        return logResp;
    }

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
                SYS_debug.log('header is = '+head.MasterLabel + ''+head.Value__c);
                req.setHeader(String.valueOf(head.MasterLabel), String.valueOf(head.Value__c));
                    
            }
            String resourceUrl = integrationSetting.BaseAPIEndPoint__c+SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ResourcePath__c+'/';
            List<Custom_Parent__c> rec = [SELECT SYS_Key__c FROM Custom_Parent__c WHERE Id = :log.WhatId__c LIMIT 1];
            req.setEndpoint(resourceUrl+'Id'+'/'+rec[0].SYS_Key__c);
            return req;
        }
        
    }

    

}