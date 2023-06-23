public without sharing class SYS_IntegrationLogOutboundQueueable implements Queueable, Database.AllowsCallouts{ 
    
    private List<Id> sysLogIds = new List<Id>();
    private Boolean followUp = false;
    
    public SYS_IntegrationLogOutboundQueueable(List<Id> idList){
        this.sysLogIds = idList;
    }
    public void execute(QueueableContext context){
        
        List<sObject> outboundResultLogs = new List<sObject>();

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
                                                Requires_process_on_complete__c,
                                                How_to_process__c,Custom_Apex_Handler__c,
                                                Type__c,WhatId__c,Parent__c,Order__c,ObjectSettingId__c,Integration_Setting__c
                                            FROM SYS_IntegrationLog__c WHERE Id in:sysLogIds];
                                            */
        
        List<Id> pendingProcessLogs = new List<Id>();
        System.debug('Chunk Size '+this.sysLogIds.size());

        Map<String, String> logIdvsWhatIdMap = new Map<String, String>();
        List<sObject> records = new List<sObject>();
        String objectSettingName, objectApiName, objectQuery;
        Integer maxRecordCount = SYS_DataCacheFactory.MAX_CALLOUT_COUNT, i = 0; // TODO This value will come from objest setting, and default value is 50

        for(SYS_IntegrationLog__c log:sysLogs) {
            try {
                if (log.ObjectSettingId__c == NULL) continue;
                if (objectSettingName == NULL ) {
                    objectSettingName = log.ObjectSettingId__c;
                    
                    SYS_DataCacheFactory init = new SYS_DataCacheFactory(log.Account_Id__c,
                    log.Integration_Type__c,
                    log.Integration_Setting__c,
                    log.ObjectSettingId__c);
    
                    objectApiName = SYS_DataCacheFactory.objectSettingMap?.get(SYS_DataCacheFactory.OBJ_TYPE)?.ObjectApiName__c;
                    maxRecordCount = SYS_DataCacheFactory.MAX_CALLOUT_COUNT;
    
                }
                
                if (log.whatid__c != NULL && objectSettingName == log.ObjectSettingId__c && i < maxRecordCount) {
                    logIdvsWhatIdMap.put(log.Id, log.whatid__c);
                    i++;
                }
                else {
                    pendingProcessLogs.add(log.Id);
                }
            } catch (Exception e) {
                SYS_Helper.logException(log,e.getStackTraceString()+'\n'+e.getMessage());
            }
        }

        SYS_ApplicationService appService;
        
        if(objectApiName != NULL || logIdvsWhatIdMap.values()?.size() > 0) {
            objectQuery = 'SELECT Id FROM ' +objectApiName +' WHERE Id in (' + '\'' + String.join(logIdvsWhatIdMap.values(),'\',\'') + '\')';
            records = Database.query(objectQuery);
            
            appService = (SYS_ApplicationService)Type.forName(SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).ApexHandler__c).newInstance();
            Map<Id, String> jsonListForOutbound = appService.transformSObjectToJson(records);

            for(SYS_IntegrationLog__c log:sysLogs) {
                if(!logIdvsWhatIdMap?.containsKey(log.Id) || log.Status__c == 'FAIL' ) {
                    continue;
                }
                try {
                    String finalJsonForOutbound;
                    finalJsonForOutbound = appService.sanitizeJSONForOutbound(jsonListForOutbound?.get(log.whatid__c));
                    
                    if(log.Additional_Param__c != NULL ) {
                        finalJsonForOutbound = appService.sanitizeJSONForOutbound(finalJsonForOutbound, log.Additional_Param__c);
                    }
                    SYS_Helper.generateRequestBody(log, finalJsonForOutbound);
    
                } catch(Exception e) {
                    SYS_Helper.logException(log,e.getStackTraceString()+'\n'+e.getMessage());
                }
            }
        }
        

        

        for(SYS_IntegrationLog__c log:sysLogs) {
            if(pendingProcessLogs.contains(log.Id) || log.Status__c == 'FAIL' ) {
                continue;
            }
            try{
                SYS_DataCache.log = log;
                if(Limits.getCallouts() < Limits.getLimitCallouts() - 1 && !this.followUp){
                    SYS_DataCacheFactory init = new SYS_DataCacheFactory(log.Account_Id__c,
                    log.Integration_Type__c,
                    log.Integration_Setting__c,
                    log.ObjectSettingId__c);
                    
                    // SYS_DataCache.INT_TYPE = log.Integration_Setting__c;
                    // SYS_DataCache.OBJ_TYPE = log.ObjectSettingId__c;
                    // SYS_ApplicationService appService;
                    

                    if(log.How_to_process__c == 'use_object_setting')
                        appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ApexHandler__c).newInstance();
                    else if(log.How_to_process__c == 'use_custom_apex_handler')
                        appService = (SYS_ApplicationService)Type.forName(log.Custom_Apex_Handler__c).newInstance();
                    else if(log.How_to_process__c == 'ignore_log'){
                        continue;
                    }
                    else{
                        //Log Message
                        continue;
                    }
                    SYS_debug.log('SP parentLog id in queueable: '+log.Id);
                    HttpResponse outboundResponse = appService.doOutbound(log); //no dml here
                    outboundResultLogs.addAll(appService.generatelogForOutboundResultNew(outboundResponse,log));
                    if(outboundResponse.getBody() != NULL && outboundResponse.getBody().length() > SYS_Constants.TEXT_AREA_MAX_SIZE*10) {
                        this.followUp = true;
                    }
                    // outboundResultLogs.add(appService.generatelogForOutboundResult(outboundResponse,log));
                }
                else{
                    pendingProcessLogs.add(log.Id);
                } 

                // /**
                //  * If there are still some logs pending for process after exhausting the callout limits 
                //  * then chain the queueable
                //  **/ 
                // if(pendingProcessLogs.size()>0){
                //     System.enqueueJob(new SYS_IntegrationLogOutboundQueueable(pendingProcessLogs));
                // }
            } catch(Exception e) {
                SYS_Helper.logException(log,e.getStackTraceString()+'\n'+e.getMessage());
            }
            
        }//For Loop Ends
        
        if(outboundResultLogs.size() > 0){

            //new SYS_ApplicationService().doDML(outboundResultLogs, 'UPSERT','');
            SYS_Helper.upsertLog(outboundResultLogs); 
            // upsert outboundResultLogs;
        } else if(sysLogs.size() > 0) {
            SYS_Helper.upsertLog(sysLogs);
        }
        System.debug('SP Limits :: dml '+Limits.getDMLStatements()+' queries '+Limits.getQueries() +' heap '+Limits.getHeapSize());
        /**
         * If there are still some logs pending for process after exhausting the callout limits 
         * then chain the queueable
         **/ 
        if(pendingProcessLogs.size()>0 && (Limits.getQueueableJobs() < Limits.getLimitQueueableJobs() - 1)){
            System.enqueueJob(new SYS_IntegrationLogOutboundQueueable(pendingProcessLogs));
        } else if (pendingProcessLogs.size()>0) {

            List<SYS_IntegrationLog__c> syslogPending = new List<SYS_IntegrationLog__c>();
            for(Id logId:pendingProcessLogs) {
                SYS_IntegrationLog__c log = new SYS_IntegrationLog__c(Id = logId, retry__c = true);
                syslogPending.add(log);
            }
            SYS_Helper.upsertLog(syslogPending);
        }
        
    }
    
}