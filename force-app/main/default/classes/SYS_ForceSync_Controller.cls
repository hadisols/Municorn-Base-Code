global class SYS_ForceSync_Controller extends SYS_ApplicationService {

    private static SYS_IntegrationLog__c log;

    public override String getHttpRequestMethod(){
        return 'GET';
    }

    public override String getHttpRequestEndpoint(){

        String baseEndpoint = SYS_DataCache.integrationSetting.get(SYS_Datacache.INT_TYPE).BaseAPIEndPoint__c;
        String resourceUrl = 
            baseEndpoint+
            SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ResourcePath__c+'/';
        
        List<sObject> recList = 
            Database.query( 'SELECT '+SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ExternalFieldApi__c+
                            ' FROM '+SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ObjectApiName__c+
                            ' WHERE Id = \'' + log.WhatId__c + '\'');
 
        String externalId = String.valueOf(recList[0].get(SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ExternalFieldApi__c));
        resourceUrl+=externalId;
        return resourceUrl;
    }

    @AuraEnabled
    public static SYS_IntegrationLog__c invokeFlow(Id recId,String objSetting,String apexHandler, String direction){
        
        List<SYS_IntegrationLog__c> insertSysLog = new List<SYS_IntegrationLog__c>();
        
        try {

            System.debug('======:'+objSetting);
            System.debug('======:'+recId);
            System.debug('======:'+apexHandler);
            System.debug('======:'+direction);

            SYS_DataCache.OBJ_TYPE = objSetting;
            SYS_DataCache.INT_TYPE = SYS_DataCache.objectSettingMap.get(objSetting).IntegrationType__r.DeveloperName;
            
            SYS_IntegrationLog__c  newSysLog = new SYS_IntegrationLog__c();
            List<sObject> recList = 
                Database.query('SELECT '+SYS_Helper.getAllFieldsFor(String.valueOf(recId.getsobjecttype())) +' FROM '+String.valueOf(recId.getsobjecttype())+' WHERE Id = \'' + recId + '\'');


            if(direction == 'OUT'){
                
                System.debug('=========:'+SYS_DataCache.INT_TYPE+'['+recList+']');

                SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ApexHandler__c).newInstance();
                Map<Id, String> jsonListForOutbound = appService.transformSObjectToJson(recList);

                System.debug('=========:'+jsonListForOutbound);
                
                if(jsonListForOutbound.values().size() > 0){
                    for(Id jsonRecordId:jsonListForOutbound.keyset()){ 
                        String finalJsonForOutbound;

                        finalJsonForOutbound = appService.sanitizeJSONForOutbound(jsonListForOutbound.get(jsonRecordId));

                        newSysLog = SYS_Helper.getLogsToInsert(finalJsonForOutbound);
                        newSysLog.Status__c = 'NEW';
                        newSysLog.Type__c = 'OUTBOUND';
                        newSysLog.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
                        newSysLog.SYS_Operation_Type__c = 'UPSERT';
                        newSysLog.WhatId__c = jsonRecordId;
                        newSysLog.How_to_process__c = 'use_custom_apex_handler';
                        newSysLog.Custom_Apex_Handler__c = apexHandler;
                        newSysLog.ObjectSettingId__c = SYS_DataCache.OBJ_TYPE;
                        newSysLog.Force_Sync__c = true;

                        
                        log = newSysLog;
                        insertSysLog.add(newSysLog);
                    }

                    if(insertSysLog.size()>0 && SYS_DataCache.enableCheck.get(SYS_DataCache.INT_TYPE.toUpperCase())){
                        new SYS_IntegrationLogOutboundImmediate(insertSysLog).execute();
                    }
                }

            }else if(direction == 'IN'){
                
                newSysLog.Status__c = 'NEW';
                newSysLog.Type__c = 'OUTBOUND';
                newSysLog.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
                newSysLog.SYS_Operation_Type__c = 'INSERT';
                newSysLog.WhatId__c = recId;
                newSysLog.How_to_process__c = 'use_custom_apex_handler';
                newSysLog.Custom_Apex_Handler__c = apexHandler;
                newSysLog.ObjectSettingId__c = SYS_DataCache.OBJ_TYPE;
                newSysLog.Force_Sync__c = true;

                log = newSysLog;

                insertSysLog.add(newSysLog);
                if(insertSysLog.size()>0 && SYS_DataCache.enableCheck.get(SYS_DataCache.INT_TYPE.toUpperCase())){
                    new SYS_IntegrationLogOutboundImmediate(insertSysLog).execute();
                }

            }else{
                throw new AuraHandledException('Invalid Direction specified');
            }
            
        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return insertSysLog[0];
    }
}