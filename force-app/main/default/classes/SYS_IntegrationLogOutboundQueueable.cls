public class SYS_IntegrationLogOutboundQueueable implements Queueable, Database.AllowsCallouts{ 
    
    private List<Id> sysLogIds = new List<Id>();
    
    public SYS_IntegrationLogOutboundQueueable(List<Id> idList){
        this.sysLogIds = idList;
    }
    public void execute(QueueableContext context){
        
        List<sObject> outboundResultLogs = new List<sObject>();
        List<SYS_IntegrationLog__c> sysLogs = 
        Database.query('SELECT '+SYS_Helper.getAllFieldsFor('SYS_IntegrationLog__c')+', Parent__r.WhatId__c, Parent__r.SYS_Operation_Type__c FROM SYS_IntegrationLog__c WHERE Id in (' + '\'' + String.join(sysLogIds,'\',\'') + '\')');
                                            
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
                                                Type__c,WhatId__c,Parent__c,Order__c,ObjectSettingId__c,SYS_IntegrationSettings__c
                                            FROM SYS_IntegrationLog__c WHERE Id in:sysLogIds];
                                            */
        
        List<Id> pendingProcessLogs = new List<Id>();
        for(SYS_IntegrationLog__c log:sysLogs) {
            
            try{
                SYS_DataCache.log = log;
                if(Limits.getCallouts() < Limits.getLimitCallouts() - 1){
                    SYS_DataCache.INT_TYPE = log.SYS_IntegrationSettings__c;
                    SYS_DataCache.OBJ_TYPE = log.ObjectSettingId__c;
                    SYS_ApplicationService appService;
                    

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
                    HttpResponse outboundResponse = appService.doOutbound(log);
                    outboundResultLogs.add(appService.generatelogForOutboundResult(outboundResponse,log));
                }
                else{
                    pendingProcessLogs.add(log.Id);
                }

                /**
                 * If there are still some logs pending for process after exhausting the callout limits 
                 * then chain the queueable
                 **/ 
                if(pendingProcessLogs.size()>0){
                    System.enqueueJob(new SYS_IntegrationLogOutboundQueueable(pendingProcessLogs));
                }
            }catch(Exception e){

                SYS_Helper.logException(log,e.getStackTraceString()+'\n'+e.getMessage());
    
            }
            
        }//For Loop Ends
        
        if(outboundResultLogs.size() > 0){

            new SYS_ApplicationService().doDML(outboundResultLogs, 'UPSERT','');
            
        } 
        
    }
    
}