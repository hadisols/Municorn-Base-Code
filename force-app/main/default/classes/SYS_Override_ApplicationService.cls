public class SYS_Override_ApplicationService extends SYS_ApplicationService{
    public SYS_Override_ApplicationService() {

    }

    public override HttpResponse doOutbound(SYS_IntegrationLog__c log){
        System.debug('\n In SYS_Override_ApplicationService');
        return super.doOutbound(log);
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