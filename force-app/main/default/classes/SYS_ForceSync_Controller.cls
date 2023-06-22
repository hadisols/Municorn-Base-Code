global without sharing class SYS_ForceSync_Controller extends SYS_ApplicationService {

    private static SYS_IntegrationLog__c log;
    private static String syncDirection;
    private static List<sObject> recList = new List<sObject>();
    private static SYS_DataCacheFactory init;

    @AuraEnabled
    public static String invokeAccountFlow(Id recId,String objSetting,String apexHandler, String direction, 
    String accountMergeField) {
        String status = '';
        if(!String.isBlank(accountMergeField)) {
            try {
                String query = 'SELECT ' + /* accountMergeField */ removeDuplicateFields(accountMergeField, recId) + ' FROM '+String.valueOf(recId.getsobjecttype());
                String whereClause = ' WHERE Id = \'' + String.escapeSingleQuotes(recId) + '\'';
                recList = Database.query(String.escapeSingleQuotes(query)+whereClause);

                if(recList.size() > 0) {
                    String int_setting = ObjectSetting__mdt.getInstance(objSetting)?.IntegrationType__r?.developername;
                    String int_type = IntegrationSetting__mdt.getInstance(int_setting)?.Integration_Type__c;
                    init = new SYS_DataCacheFactory(
                        (String)recList[0].get(accountMergeField),
                        int_type, 
                        int_setting,
                        objSetting
                    );
                }
            } catch(Exception e) {
                System.debug(e.getStackTraceString());
                throw new AuraHandledException(e.getMessage());
            }
            status = invokeFlow(recId, objSetting, apexHandler, direction);
        }
        return status;
    }

    @AuraEnabled
    public static String invokeFlow(Id recId,String objSetting,String apexHandler, String direction){
        
        List<SYS_IntegrationLog__c> insertSysLog = new List<SYS_IntegrationLog__c>();
        
        try {

            syncDirection = direction;

            //TODO - update the first two parameters with accountId and Integration type after the new implementation
            if(init == NULL) {
                SYS_DataCacheFactory init = new SYS_DataCacheFactory(
                    SYS_DataCacheFactory.objectSettingMap.get(objSetting).IntegrationType__r.DeveloperName,
                    objSetting
                );
            }
            
            // SYS_DataCacheFactory.OBJ_TYPE = objSetting;
            // SYS_DataCacheFactory.INT_TYPE = SYS_DataCacheFactory.objectSettingMap.get(objSetting).IntegrationType__r.DeveloperName;
            
            SYS_IntegrationLog__c  newSysLog = new SYS_IntegrationLog__c();
            
            if(recList?.size() == 0) {
                String query = 'SELECT '+SYS_Helper.getAllFieldsFor(String.valueOf(recId.getsobjecttype())) +' FROM '+String.valueOf(recId.getsobjecttype());
                String whereClause = ' WHERE Id = \'' + String.escapeSingleQuotes(recId) + '\'';
                recList = Database.query(String.escapeSingleQuotes(query)+whereClause);
            }
                

            if(direction == 'OUT'){
                
                /*--*/SYS_debug.log('=========:'+SYS_DataCacheFactory.INT_TYPE+'['+recList+']');

                System.debug('SP handler '+ SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).ApexHandler__c);
                SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).ApexHandler__c).newInstance();
                Map<Id, String> jsonListForOutbound = appService.transformSObjectToJson(recList);

                /*--*/SYS_debug.log('=========:'+jsonListForOutbound);
                
                if(jsonListForOutbound.values().size() > 0){
                    for(Id jsonRecordId:jsonListForOutbound.keyset()){ 
                        String finalJsonForOutbound;
                        /*--*/SYS_debug.log('MS jsonRecordId =========:'+jsonRecordId);

                        finalJsonForOutbound = appService.sanitizeJSONForOutbound(jsonListForOutbound.get(jsonRecordId));

                        newSysLog = SYS_Helper.getLogsToInsert(finalJsonForOutbound);
                        newSysLog.Status__c = 'NEW';
                        //newSysLog.HTTP_Method__c = 'POST';
                        newSysLog.Type__c = 'OUTBOUND';
                        newSysLog.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
                        newSysLog.SYS_Operation_Type__c = 'UPSERT';
                        newSysLog.WhatId__c = jsonRecordId;
                        newSysLog.How_to_process__c = 'use_object_setting';
                        // newSysLog.Custom_Apex_Handler__c = apexHandler;
                        newSysLog.ObjectSettingId__c = SYS_DataCacheFactory.OBJ_TYPE;
                        newSysLog.Force_Sync__c = true;
                        newSysLog.Account_Id__c = SYS_DataCacheFactory.accountId;
                        newSysLog.Integration_Type__c = SYS_DataCacheFactory.integrationType;
                        
                        log = newSysLog;
                        insertSysLog.add(newSysLog);
                    }

                    if(insertSysLog.size()>0 && SYS_DataCacheFactory.enableCheck){
                        new SYS_IntegrationLogOutboundImmediate(insertSysLog).execute();
                    }
                    else if(insertSysLog.size()>0 && !SYS_DataCacheFactory.enableCheck) {
                        // SYS_Helper.updateIntegrationSettingDisableMessage(insertSysLog);
                        // SYS_Helper.upsertLog(insertSysLog);
                        throw new AuraHandledException(Label.IS_disabled + ' : ' + SYS_DataCacheFactory.INT_TYPE);
                    }
                }

            }else if(direction == 'IN'){
                
                newSysLog.Callout_URL__c = SYS_Helper.urlFromPattern('GET',recList[0]);
                newSysLog.Status__c = 'NEW';
                newSysLog.HTTP_Method__c = 'GET';
                newSysLog.Type__c = 'OUTBOUND';
                newSysLog.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
                newSysLog.SYS_Operation_Type__c = 'UPSERT';
                newSysLog.WhatId__c = recId;
                newSysLog.How_to_process__c = 'use_custom_apex_handler';
                newSysLog.Custom_Apex_Handler__c = apexHandler;
                newSysLog.ObjectSettingId__c = SYS_DataCacheFactory.OBJ_TYPE;
                newSysLog.Force_Sync__c = true;
                newSysLog.Account_Id__c = SYS_DataCacheFactory.accountId;
                newSysLog.Integration_Type__c = SYS_DataCacheFactory.integrationType;

                log = newSysLog;

                insertSysLog.add(newSysLog);
                if(insertSysLog.size()>0 && SYS_DataCacheFactory.enableCheck){
                    new SYS_IntegrationLogOutboundImmediate(insertSysLog).execute();
                } 
                else if(insertSysLog.size()>0 && !SYS_DataCacheFactory.enableCheck) {
                    // SYS_Helper.updateIntegrationSettingDisableMessage(insertSysLog);
                    // SYS_Helper.upsertLog(insertSysLog);
                    throw new AuraHandledException(Label.IS_disabled + ' : ' + SYS_DataCacheFactory.INT_TYPE);
                }

            }else{
                throw new AuraHandledException('Invalid Direction specified');
            }
            
        }catch(Exception e) {
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }

        return insertSysLog[0].Status__c;
    }

    //This method is not required as Id field is enough for the framework.
    private static String removeDuplicateFields(String accountMergeField, Id recId) {
        String res = '';
        List<String> allFields = SYS_Helper.getAllFields(String.valueOf(recId.getsobjecttype()));
        for(String f:allFields) {
            if(f?.toLowerCase().equals(accountMergeField?.toLowerCase())) {
                continue;
            }
            res += f?.toLowerCase() +',';
        }
        res +=  accountMergeField?.toLowerCase();
        return res;
    }
}