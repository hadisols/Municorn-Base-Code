public inherited sharing class SYS_IntegrationUtility extends SYS_ApplicationService{
    // public SYS_IntegrationUtility() {

    // }

    // public class SYS_IntegrationUtilityException extends Exception{}

    // public void processInboundRecord(SYS_IntegrationLog__c log) {
    //     Map<SYS_IntegrationLog__c, sObject> mapLogrecVsObject
    // }

    // public void doDMLNew(Map<SYS_IntegrationLog__c, sObject> records,String dmlType,String additionalSetting, Map<String, SYS_IntegrationLog__c> sysLogMap ) {
        
        
    //     switch on dmlType.toUpperCase() {
    //         when 'INSERT'{
    //             doInsertNew(records, sysLogMap);
    //         }
    //         when 'UPSERT'{
    //             doUpsertNew(records, additionalSetting, sysLogMap);
    //         }
    //         when 'UPDATE'{
    //             doUpdateNew(records, sysLogMap);
    //         }
    //         when 'DELETE'{
    //             doDeleteNew(records, sysLogMap);
    //         }
    //         when else {
    //             SYS_debug.log('Invalid DML Operation specified in log record:'+dmlType);
    //             return ;
    //         }
            
    //     }

    // }

    // public void doInsertNew(Map<SYS_IntegrationLog__c, sObject> records, Map<String, SYS_IntegrationLog__c> sysLogMap){
    //     Database.SaveResult[] results;
    //     Boolean success = true;
    //     results = Database.insert(records?.values(), false);

    //     for(integer i=0; i < records?.values()?.size() ; i++) {
    //         String syslogId = (String)records?.values()[i]?.get('Last_Processed_SYSLog__c');
    //         generatelogForInboundResult(results[i].isSuccess(), sysLogMap.get(syslogId));

    //         if( !results[i].isSuccess() ) { // Update the error in sysLog
    //             SYS_Helper.handleFailureDml(sysLogMap.get(syslogId), results[i]?.getErrors());
    //         } else {
                
    //             SYS_Helper.handleSuccessDml(sysLogMap.get(syslogId), results[i]?.getId());
    //         }
    //     }
    //     // if(!results[0].isSuccess()){
    //     //     success = false;
    //     //     handleDMLErrors(results[0].getErrors(),log);
    //     // }
    //     // else{
    //     //     log.WhatId__c = results[0].getId();
    //     // }

    //     return ;
    // }

    // public void doUpdateNew(Map<SYS_IntegrationLog__c, sObject> records, Map<String, SYS_IntegrationLog__c> sysLogMap){
    //     Database.SaveResult[] results;
    //     Boolean success = true;
    //     results = Database.update(records?.values(), false);

    //     for(integer i=0; i < records?.values()?.size() ; i++) {
    //         String syslogId = (String)records?.values()[i]?.get('Last_Processed_SYSLog__c');
    //         generatelogForInboundResult(results[i].isSuccess(), sysLogMap.get(syslogId));
            
    //         if( !results[i].isSuccess() ) { // Update the error in sysLog
    //             SYS_Helper.handleFailureDml(sysLogMap.get(syslogId), results[i]?.getErrors());
    //         } else {
    //             SYS_Helper.handleSuccessDml(sysLogMap.get(syslogId), results[i]?.getId());
    //         }
    //     }
    //     // if(!results[0].isSuccess()){
    //     //     success = false;
    //     //     handleDMLErrors(results[0].getErrors(),log);
    //     // }
    //     // else{
    //     //     log.WhatId__c = results[0].getId();
    //     // }

    //     return ;
    // }

    // public void doDeleteNew(Map<SYS_IntegrationLog__c, sObject> records, Map<String, SYS_IntegrationLog__c> sysLogMap){
    //     Database.DeleteResult[] results;
    //     Boolean success = true;
    //     results = SYS_Helper.deleteWithFLSCheck(records?.values());


    //     for(integer i=0; i < records?.values()?.size() ; i++) {
    //         String syslogId = (String)records?.values()[i]?.get('Last_Processed_SYSLog__c');
    //         generatelogForInboundResult(results[i].isSuccess(), sysLogMap.get(syslogId));
            
    //         if( !results[i].isSuccess() ) { // Update the error in sysLog
    //             SYS_Helper.handleFailureDml(sysLogMap.get(syslogId), results[i]?.getErrors());
    //         } else {
                
    //             SYS_Helper.handleSuccessDml(sysLogMap.get(syslogId), results[i]?.getId());
    //         }
    //     }

    //     // if(!results[0].isSuccess()){
    //     //     success = false;
    //     //     handleDMLErrors(results[0].getErrors(),log);
    //     // }
    //     // else{
    //     //     log.WhatId__c = results[0].getId();
    //     // }

    //     return ;
    // }

    // public void doUpsertNew(Map<SYS_IntegrationLog__c, sObject> records,String additionalSetting,Map<String, SYS_IntegrationLog__c> sysLogMap){
    //     Database.UpsertResult[] results;
    //     Boolean success = true;
    //     if(String.isBlank(additionalSetting))
    //         results = Database.upsert(records?.values(), false);
    //     else{
    //         /*--*/SYS_debug.log('--MS externalIdField for:'+records?.values()[0]+' : '+additionalSetting);
    //         //Schema.SObjectField externalIdField = Schema.getGlobalDescribe().get(SYS_DataCache.sObjectApiName).getDescribe().fields.getMap().get(additionalSetting); 
            
    //         Schema.SObjectField externalIdField = records?.values()[0].getSObjectType().getDescribe().fields.getMap().get(additionalSetting); 
    //         /*--*/SYS_debug.log('--MS externalIdField in doUpsert:'+externalIdField);
            
    //         results = Database.upsert(records?.values(), externalIdField, false);
    //     }

    //     for(integer i=0; i < records?.values()?.size() ; i++) {
    //         String syslogId = (String)records?.values()[i]?.get('Last_Processed_SYSLog__c');
    //         generatelogForInboundResult(results[i].isSuccess(), sysLogMap.get(syslogId));
            
    //         System.debug('record ifsuccess '+records?.values()[i]?.Id);
    //         if(!results[i].isSuccess()) { // Update the error in sysLog
    //             SYS_Helper.handleFailureDml(sysLogMap.get(syslogId), results[i]?.getErrors());
    //         } else {
                
    //             SYS_Helper.handleSuccessDml(sysLogMap.get(syslogId), results[i]?.getId());
    //         }
    //     }
        
    //     // /*--*/SYS_debug.log('--MS Log check # '+log.Id+' has WhatId: '+results[0].getId());

    //     // if(!results[0].isSuccess()){
    //     //     success = false;
    //     //     handleDMLErrors(results[0].getErrors(),log);
    //     // }
    //     // else{
    //     //     log.WhatId__c = results[0].getId();
    //     // }
    //     // /*--*/SYS_debug.log('--MS Log re-check # '+log.Id+' has WhatId: '+log.WhatId__c);

    //     return ;
    // }


    //NO OVERRIDES----######
    // public override SYS_IntegrationLog__c generatelogForInboundResult(Boolean result,SYS_IntegrationLog__c log){

    //     SYS_IntegrationLog__c logResp = new SYS_IntegrationLog__c();
        
    //     /*--*/SYS_debug.log('Beginning. Log status for:'+logResp.Request_Digest__c+'='+logResp.Status__c);


    //     if(!result){
            
    //         //-- Error message is set in handleDmlErrors
    //         //String errorMessage = 'Error while processing inbound';

    //         logResp.Status__c = 'FAIL';
    //         logResp.retry__c = true;
    //         //## SYS_Helper.flagLogForRetry(logResp.Id);
            

    //         /*
    //         if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Message__c.isCreateable()) {
    //             logResp.Message__c = errorMessage;
    //         }
    //         */
            
    //         logResp.Id = log.Id;
            
    //     }
    //     else{
            
    //         //ID jobID = System.enqueueJob(new SYS_ParentChildRecordsQueueable(log,SYS_DataCache.INT_TYPE));
    //         logResp = log;
    //         logResp.ObjectSettingId__c = SYS_DataCache.OBJ_TYPE;

    //         //logResp.Status__c = 'DONE';

    //         /**
    //          * Check if there are other siblings. Call parenting queueable only if all are done
    //          */

    //         /*--*/SYS_debug.log('MS totalChildRecords B4:'+SYS_QueueableForInboundChild.totalChildRecords);
    //         SYS_QueueableForInboundChild.totalChildRecords--;
    //         /*--*/SYS_debug.log('MS totalChildRecords After:'+SYS_QueueableForInboundChild.totalChildRecords);
           
    //         /*--*/SYS_debug.log('MS Condition chck for Parenting:'+log.Requires_process_on_complete__c);
    //         /*--*/SYS_debug.log('MS Condition chck for Parenting:'+(SYS_QueueableForInboundChild.totalChildRecords==0));
    //         /*--*/SYS_debug.log('MS Condition chck for Parenting:'+log.Status__c);


    //         /**
    //          * If the log is for either a parent or the LAST sibling of n children or a child
    //          * being processed as part of retry. Therefore in  else we again need to make checks for parent vs. child
    //          * and set the Status accordingly.
    //          */
    //         if(log.Requires_process_on_complete__c 
    //             && (SYS_QueueableForInboundChild.totalChildRecords==0 || log.Status__c==SYS_Constants.READY_FOR_PROCESSING))
    //         {
    //             /*--*/SYS_debug.log('MS Queueable Jobs in queue:'+Limits.getQueueableJobs());
    //             /*--*/SYS_debug.log('MS Queueable Allowed:'+Limits.getLimitQueueableJobs());

    //             logResp.Status__c = 'PENDING_PARENT';
    //             logResp.retry__c = true;
    //             //## SYS_Helper.flagLogForRetry(logResp.Id);

    //             if(!(Limits.getQueueableJobs() + 1 > Limits.getLimitQueueableJobs())){
    //                 System.enqueueJob(new SYS_ParentingQueueable(String.valueOf(log.Parent__c),SYS_DataCache.INT_TYPE,log));

    //             }
    //         }
    //         else{

    //             //One of the sibling of n children. Save as pending parent
    //             if(log.Requires_process_on_complete__c){
    //                 logResp.Status__c = 'PENDING_PARENT';
    //             }
    //             else{
    //                 logResp.Message__c = 'Record created/updated successfully';
    //                 logResp.Status__c = 'DONE';
                    
    //             }

    //         }
            
    //     }

    //     return logResp;
    // }


    // public override processInboundRecord(SYS_IntegrationLog__c log, Map<SYS_IntegrationLog__c, sObject> mapLogrecVsObject) {
        
    //     String jsonBody = '';
    //     jsonBody =  SYS_Helper.getDataFrom(log); 
    //     jsonBody = preprocessJSONForInbound(log,jsonBody);

    //     if(SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Notifications_are_partial__c && 
    //         log.Is_Notification_Only__c
    //         ){
    //         //String baseEndpoint = SYS_DataCache.integrationSetting.get(SYS_Datacache.INT_TYPE).BaseAPIEndPoint__c;
    //         String getURLPattern = SYS_DataCache.integrationSetting.get(SYS_Datacache.INT_TYPE).GET_URL_Pattern__c;
            
    //         SYS_NotificationInterface it = 
    //         (SYS_NotificationInterface)Type.forName(SYS_DataCache.integrationSetting.get(SYS_Datacache.INT_TYPE).Notification_Wrapper__c).newInstance();
            
    //         List<SYS_IntegrationLog__c> insertSysLog = new List<SYS_IntegrationLog__c>();

    //         for(Map<String,String> rMap:it.getIterator(jsonBody)){
    //             String getURL = getURLPattern;
    //             SYS_IntegrationLog__c  newSysLog = new SYS_IntegrationLog__c();
    //             for(String key:rMap.keySet()){
    //                 getURL = getURL.replaceAll('\\{'+key+'\\}',rMap.get(key));
  
    //             }
    //             /*--*/SYS_debug.log('=============== '+ getURL);

    //             newSysLog.Status__c = SYS_Constants.NEW_STATUS;
    //             newSysLog.HTTP_Method__c = 'GET';
    //             newSysLog.Callout_URL__c = getURL;
    //             newSysLog.Type__c = SYS_Constants.OUTBOUND;
    //             newSysLog.WhatId__c = log.Id;
    //             newSysLog.Integration_Setting__c = SYS_DataCache.INT_TYPE;
    //             newSysLog.SYS_Operation_Type__c = 'UPSERT';
    //             newSysLog.How_to_process__c = 'use_custom_apex_handler';
    //             newSysLog.Custom_Apex_Handler__c = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).ApexHandler__c;
    //             insertSysLog.add(newSysLog);
    //         }

            
    //         if(insertSysLog.size()>0 && SYS_DataCache.enableCheck.get(SYS_DataCache.INT_TYPE.toUpperCase())){
    //             SYS_Helper.insertLog(insertSysLog);
    //         }

    //         // return true;

    //     }
    //     else{
    //         String resource = getResourceFromJSON(log,jsonBody);
    //         log.Resource__c = resource;
    //         SYS_debug.log('\n\n ------------------------------- \n\n Application Service resource:'+resource);

    //         List<sObject> sObjectsToDML = transformJsonToSObject(jsonBody, resource, log);

    //         SYS_debug.log('\n\n ------------------------------- \n\n Application Service sObjects to DML:'+sObjectsToDML);
    //         SYS_debug.log('\n\n ------------------------------- \n\n Application Service externalKeyByResourceMap:'+SYS_DataCache.externalKeyByResourceMap);

    //         String externalIdFieldAPIName = SYS_DataCache.externalKeyByResourceMap.get(resource);
    //         //String externalIdFieldAPIName = log.External_Id_Field_API_Name__c!=NULL?log.External_Id_Field_API_Name__c:'';
            
    //         for(sObject item: sObjectsToDML) {
    //             try {
    //                 item.put('Last_Processed_SYSLog__c', log.Id);
    //             } catch(Exception e) {
    //                 throw new SYS_IntegrationUtilityException('Last Processed SYSLog field is not implemented : \n '+e.getMessage());
    //             }
    //             if(log.WhatId__c != NULL) {
    //                 item.put('Id', log.WhatId__c);
    //             }
    //         }
    //         if(sObjectsToDML.size() > 0)
    //             mapLogrecVsObject.put(log, sObjectsToDML[0]);
    //     }
    //     return ;
    // }

    // ############## OUTBOUND #######################

    // public List<SYS_IntegrationLog__c> generatelogForOutboundResultNew(HttpResponse resp,SYS_IntegrationLog__c log ){

    //     SYS_IntegrationLog__c logResp = SYS_Helper.getLogsToInsert(resp.getBody());

    //     String algo = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Hashing_Algo__c;
    //     if(algo!=NULL && algo!='')
    //         logResp.Request_Digest__c = generateHash(resp.getBody(),algo);

    //     logResp.Force_Sync__c = log.Force_Sync__c;

    //     if(resp.getStatusCode() != 201 && resp.getStatusCode() != 200){

    //         SYS_debug.log('#### resp status: '+resp.getStatus());
    //         SYS_debug.log('#### resp code: '+resp.getStatusCode()); 
    //         SYS_debug.log('#### resp: '+resp.getBody());

    //         log.Status__c = 'FAIL';
    //         if(!log.Force_Sync__c)
    //             log.retry__c = true;

    //         logResp.Status__c = 'ERROR';
            
    //         logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
    //         logResp.WhatId__c = log.WhatId__c;
    //         logResp.Type__c = SYS_Constants.RESPONSE;
    //         logResp.How_To_Process__c = 'ignore_log';
    //         logResp.Integration_Setting__c = SYS_DataCache.INT_TYPE;
            
    //     }
    //     else{
    //         log.Status__c = 'DONE';

    //         if(log.SYS_Operation_Type__c == 'INSERT' || log.Force_Sync__c){
    //             logResp.Status__c = SYS_Constants.NEW_STATUS;
    //             logResp.SYS_Operation_Type__c = 'UPDATE';
    //             logResp.Flat_Key_for_Resource__c = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Flat_Key_for_Resource_Response__c;

    //             if(SYS_DataCache.OBJ_TYPE!=NULL)
    //                 logResp.Resource__c = SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).Resource_Name__c;
                
    //             logResp.How_To_Process__c = 'use_custom_apex_handler';
    //             logResp.Custom_Apex_Handler__c = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).ApexHandler__c;
            
    //         }
    //         else{

                
    //             if(SYS_DataCache.OBJ_TYPE != NULL && SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).Always_Ignore_Response__c){
    //                     logResp.How_To_Process__c = 'ignore_log';
    //                     logResp.Status__c = 'DONE';
    //             }
    //             else{
    //                 logResp.SYS_Operation_Type__c = 'UPSERT';
    //                 logResp.How_To_Process__c = 'use_custom_apex_handler';
    //                 logResp.Custom_Apex_Handler__c = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).ApexHandler__c;
    //             }
    //             //logResp.Status__c = 'DONE';
    //             //logResp.How_To_Process__c = 'ignore_log';

    //         }
        
    //         logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
    //         logResp.WhatId__c = log.WhatId__c;
    //         logResp.Type__c = SYS_Constants.RESPONSE;
    //         logResp.Integration_Setting__c = SYS_DataCache.INT_TYPE;
    //         logResp.ObjectSettingId__c = log.ObjectSettingId__c;
            
    //     }

    //     //doDML(new List<SYS_IntegrationLog__c>{log}, 'UPSERT', '') ;
    //     // ##SYS_Helper.upsertLog(new List<SYS_IntegrationLog__c>{log});
        
    //     logResp.SYS_RequestId__c = log.Id;

    //     return new List<SYS_IntegrationLog__c> {log, logResp};
    // }

}