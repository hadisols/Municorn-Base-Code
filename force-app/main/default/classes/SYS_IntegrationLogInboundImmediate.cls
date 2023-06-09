public without sharing class SYS_IntegrationLogInboundImmediate{ 
    
    private List<Id> sysLogIds = new List<Id>();
    
    public SYS_IntegrationLogInboundImmediate(List<Id> idList){
        this.sysLogIds = idList;
    }

    public void execute(){
        
        List<sObject> inboundResultLogs = new List<sObject>();
        //TODO where clause root == null

        String query = 'SELECT '+SYS_Helper.getAllFieldsFor('SYS_IntegrationLog__c')+', Parent__r.WhatId__c, Parent__r.SYS_Operation_Type__c FROM SYS_IntegrationLog__c';
        String whereClause = ' WHERE Id in (' + '\'' + String.join(sysLogIds,'\',\'') + '\')';
        List<SYS_IntegrationLog__c> sysLogs = Database.query(String.escapeSingleQuotes(query)+whereClause);
/*
                                            [SELECT 
                                                id,
                                                data0__c,
                                                data1__c,
                                                data2__c,
                                                data3__c,
                                                data4__c,
                                                data5__c,
                                                data6__c,
                                                data7__c,
                                                data8__c,
                                                data9__c,
                                                Custom_Field_Value__c,
                                                Parent__r.WhatId__c,
                                                Resource__c,
                                                On_Complete_Handler__c,
                                                Requires_process_on_complete__c,
                                                How_to_process__c,Custom_Apex_Handler__c,SYS_Operation_Type__c,Flat_Key_for_Resource__c,
                                                Type__c,WhatId__c,Parent__c,Order__c,ObjectSettingId__c,Integration_Setting__c
                                            FROM SYS_IntegrationLog__c 
                                            WHERE Id in:sysLogIds];
                                            */
        Map<SYS_IntegrationLog__c, sObject> mapLogrecVsObject = new Map<SYS_IntegrationLog__c, sObject>();
        Map<String, SYS_IntegrationLog__c> sysLogMap = new Map<String, SYS_IntegrationLog__c>();
        List<SYS_IntegrationLog__c> partialSysLogs = new List<SYS_IntegrationLog__c>();

        //TODO 
        List<Id> sysLogsWithChildRecords = new List<Id>(); 
        for(SYS_IntegrationLog__c log:sysLogs) {
            if(log.Has_Child__c) {
                sysLogsWithChildRecords.add(log.Id);
            }
        }
        whereClause = ' WHERE Root_Log__c in (' + '\'' + String.join(sysLogsWithChildRecords,'\',\'') + '\') LIMIT 100';
        List<SYS_IntegrationLog__c> allChildLogs = Database.query(String.escapeSingleQuotes(query)+whereClause);
        
        for(SYS_IntegrationLog__c log:sysLogs) {
            
            try{

                if(log.Account_Id__c != NULL && log.Integration_Type__c != NULL) {
                    SYS_DataCacheFactory init = new SYS_DataCacheFactory(log.Account_Id__c,
                    log.Integration_Type__c,
                    log.Integration_Setting__c,
                    log.ObjectSettingId__c);
                }

                SYS_DataCache.log = log;
                
                SYS_DataCache.INT_TYPE = log.Integration_Setting__c;
                SYS_debug.log('MS SYS_DataCache.log in Inbound queueable:'+SYS_DataCache.log);
                SYS_DataCache.OBJ_TYPE = log.ObjectSettingId__c;
                SYS_ApplicationService appService;

                /*--*/SYS_debug.log('How to process:'+log.How_to_process__c);
                /*--*/SYS_debug.log('SYS_DataCache.OBJ_TYPE:'+SYS_DataCache.OBJ_TYPE);
                
                if(log.How_to_process__c == 'use_object_setting')
                    appService = (SYS_ApplicationService)Type.forName(SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ApexHandler__c).newInstance();
                else if(log.How_to_process__c == 'use_custom_apex_handler')
                    appService = (SYS_ApplicationService)Type.forName(log.Custom_Apex_Handler__c).newInstance();
                else if(log.How_to_process__c == 'ignore_log'){
                    continue;
                }
                else{
                    //Log Message
                    continue;
                }

                //NEW CODE BULKIFIED
                appService.processInboundRecord(log, mapLogrecVsObject, partialSysLogs, allChildLogs);
                sysLogMap.put(log.Id, log);

                /*--*/SYS_debug.log('--MS Log final check #'+log.Id+' has WhatId: '+log.WhatId__c);

            }catch(Exception e){
                /*--*/SYS_debug.log('MS Exception Digest check:'+SYS_DataCache.log.Request_Digest__c+':'+e.getMessage());
                SYS_Helper.logException(log, e.getStackTraceString()+'\n'+e.getMessage());
            }

        }// For loop ends

        /*--*/SYS_debug.log('MS log result size for Log:'+SYS_DataCache.log.Request_Digest__c+':'+inboundResultLogs.size());
        
        if(mapLogrecVsObject?.values() != NULL && mapLogrecVsObject?.values()?.size() > 0){

            //VERIFY :: Assuming the inbound bulk have the same objectsetting

            SYS_IntegrationLog__c log = mapLogrecVsObject.keySet()?.iterator()?.next();
            String dmlType = log?.SYS_Operation_Type__c;
            String externalIdFieldAPIName;
            if(dmlType == 'UPSERT') {  
                String resource = log?.Resource__c;
                String sobjectApiName = String.valueOf(mapLogrecVsObject.values()[0]?.getSObjectType()?.getDescribe()?.getName());
                // externalIdFieldAPIName = SYS_DataCache.externalKeyByResourceMap?.get(resource);
                externalIdFieldAPIName = SYS_DataCacheFactory.externalKeyByObject?.get(sobjectApiName?.toLowerCase());
            }
            SYS_ApplicationService appService = new SYS_ApplicationService();
            appService.doDMLNew(mapLogrecVsObject, dmlType, externalIdFieldAPIName, sysLogMap);
            
        }
        List<SYS_IntegrationLog__c> allLogs = sysLogMap.values();
        if(sysLogMap?.values() != NULL && sysLogMap?.values()?.size() > 0) {

            allLogs.addAll(partialSysLogs);
            SYS_Helper.upsertLog(allLogs);
        } else if (sysLogs.size() > 0) {
            allLogs.addAll(sysLogs);
            SYS_Helper.upsertLog(allLogs);
        }

     

            // for(sObject log2:inboundResultLogs){
            //     SYS_IntegrationLog__c l = (SYS_IntegrationLog__c)log2;
            //     //l.WhatId__c = 'a025f000006QN4FAAW';
            //     /*--*/SYS_debug.log('--MS Log final compilation ###'+l.Id+' has WhatId: '+l.WhatId__c);
            // }
            // //new SYS_ApplicationService().doDML(inboundResultLogs,'UPSERT','');  
            // upsert inboundResultLogs;

            // for(sObject log2:inboundResultLogs){
            //     SYS_IntegrationLog__c l = (SYS_IntegrationLog__c)log2;
            //     /*--*/SYS_debug.log('--MS Log after upsert ==='+l.Id+' has WhatId: '+l.WhatId__c);
            // }
    }
}