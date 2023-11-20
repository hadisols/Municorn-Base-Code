// Use this class when you want a SYS Log to be processed immediately
// Instantiate a log record and call the execute method. Do not call this from a trigger context since outbound will have
// callouts
public without sharing class SYS_IntegrationLogOutboundImmediate{ 
    
    //private List<Id> sysLogIds = new List<Id>();
    List<SYS_IntegrationLog__c> sysLogs;
    private Boolean followUp = false;
    
    public SYS_IntegrationLogOutboundImmediate(List<SYS_IntegrationLog__c> uncommittedLogs){
        this.sysLogs = uncommittedLogs;
    }
    public void execute(){
        
        List<sObject> outboundResultLogs = new List<sObject>();
        /*
        List<SYS_IntegrationLog__c> sysLogs = 
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
        for(SYS_IntegrationLog__c log:sysLogs) {
            
            try{
                SYS_DataCache.log = log;
                if(Limits.getCallouts() < Limits.getLimitCallouts() - 1 && !this.followUp){
                    SYS_DataCacheFactory init = new SYS_DataCacheFactory(log.Account_Id__c,
                    log.Integration_Type__c,
                    log.Integration_Setting__c,
                    log.ObjectSettingId__c);
                    
                    
                    // SYS_DataCache.INT_TYPE = log.Integration_Setting__c;
                    // SYS_DataCache.OBJ_TYPE = log.ObjectSettingId__c;
                    SYS_ApplicationService appService;
                    
                    /*--*/SYS_debug.log('appService Handler:'+log.How_to_process__c+'::'+log.Custom_Apex_Handler__c);

                    if(log.How_to_process__c == 'use_object_setting')
                        appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ApexHandler__c).newInstance();
                    else if(log.How_to_process__c == 'use_custom_apex_handler')
                        appService = (SYS_ApplicationService)Type.forName(log.Custom_Apex_Handler__c).newInstance();
                    else if(log.How_to_process__c == 'ignore_log'){
                        continue;
                    }
                    else{
                        appService = (SYS_ApplicationService)Type.forName('SYS_ApplicationService').newInstance();
                        //EX continue;
                    }
                    SYS_debug.log('SP parentLog id in immediate: '+log.Id);
                    HttpResponse outboundResponse = appService.doOutbound(log);
                    outboundResultLogs.addAll(appService.generatelogForOutboundResultNew(outboundResponse,log));
                    if(outboundResponse.getBody() != NULL && outboundResponse.getBody().length() > SYS_Constants.TEXT_AREA_MAX_SIZE*10) {
                        this.followUp = true;
                    }
                    // outboundResultLogs.add(appService.generatelogForOutboundResult(outboundResponse,log));
                }
                else{
                    pendingProcessLogs.add(log.Id);
                }

                
            }catch(Exception e){
                SYS_DataCache.log.retry__c = true;
                SYS_Helper.logException(log, e.getStackTraceString()+'\n'+e.getMessage());
            }
            
        }// For Loop ends
        
        if(outboundResultLogs.size() > 0){

            //new SYS_ApplicationService().doDML(outboundResultLogs, 'UPSERT','');
            // upsert outboundResultLogs;
            SYS_Helper.upsertLog(outboundResultLogs);
            Map<String, String> uuidMap = new Map<String, String>();
            for(sObject log : outboundResultLogs) {
                if(((SYS_IntegrationLog__c)log).UUID__c != NULL) {
                    uuidMap.put(((SYS_IntegrationLog__c)log).UUID__c, ((SYS_IntegrationLog__c)log).Id);
                }
            }
            SYS_debug.log('SP requestId map : '+ JSON.serializePretty(uuidMap));
            //Update the requestId field
            List<SYS_IntegrationLog__c> logLookUpUpdate = new List<SYS_IntegrationLog__c>();
            for(sObject log : outboundResultLogs) {
                
                if(((SYS_IntegrationLog__c)log).Parent_UUID__c != NULL) {
                    // ((SYS_IntegrationLog__c)log).SYS_RequestId__c = uuidMap.get(((SYS_IntegrationLog__c)log).Parent_UUID__c);
                    SYS_IntegrationLog__c newLog = new SYS_IntegrationLog__c();
                    newLog.Id = ((SYS_IntegrationLog__c)log).Id;
                    newLog.SYS_RequestId__c = uuidMap.get(((SYS_IntegrationLog__c)log).Parent_UUID__c);
                    logLookUpUpdate.add(newLog);
                }
                SYS_debug.log('SP requestId update: '+((SYS_IntegrationLog__c)log).SYS_RequestId__c + ' : ' +((SYS_IntegrationLog__c)log).Parent_UUID__c);
            }

            SYS_Helper.upsertLog(logLookUpUpdate);
        } 
        else if (sysLogs.size() > 0) {
            SYS_Helper.upsertLog(sysLogs);
        }

        /**
         * If there are still some logs pending for process after exhausting the callout limits 
         * then chain the queueable
         **/ 
        if(pendingProcessLogs.size()>0){
            System.enqueueJob(new SYS_IntegrationLogOutboundQueueable(pendingProcessLogs));
        }
        
    }
    
}