public class Plivo_Outbound_SYS_ApplicationService extends SYS_ApplicationService {
    public Plivo_Outbound_SYS_ApplicationService() {

    }
    /* ---------------  Outbound Immediate Response Processing  ----------------------*/
    //Immediate Response Wrapper
    public class PlivoMessage {
        public String message ;
        public List<String> message_uuid ;
        public String api_id ;
    }
    //Add Immediate Outbound Response Syslog to Upsert Using Custom Apex Handler
    public override SYS_IntegrationLog__c generatelogForOutboundResult(HttpResponse resp,SYS_IntegrationLog__c log){
        SYS_IntegrationLog__c logResp = SYS_Helper.getLogsToInsert(resp.getBody());

        String algo = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Hashing_Algo__c;
        if(algo!=NULL && algo!='')
            logResp.Request_Digest__c = generateHash(resp.getBody(),algo);
        //Added Status 202 - Accepted in Creteria
        if(resp.getStatusCode() != 202 && resp.getStatusCode() != 201 && resp.getStatusCode() != 200){
            SYS_debug.log('#### resp status: '+resp.getStatus());
            SYS_debug.log('#### resp code: '+resp.getStatusCode()); 
            SYS_debug.log('#### resp: '+resp.getBody());

            log.Status__c = 'FAIL';
            log.retry__c = true;

            logResp.Status__c = 'ERROR';
            //SYS_Helper.flagLogForRetry(log.Id);
            
            logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
            logResp.WhatId__c = log.WhatId__c;
            logResp.Type__c = 'RESPONSE';
            logResp.How_To_Process__c = 'ignore_log';
            logResp.Integration_Setting__c = SYS_DataCache.INT_TYPE;
        }
        else{

            log.Status__c = 'DONE';

            if(log.SYS_Operation_Type__c == 'INSERT' || log.Force_Sync__c){
                logResp.Status__c = 'NEW';
                logResp.SYS_Operation_Type__c = 'UPDATE';
                logResp.Flat_Key_for_Resource__c = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Flat_Key_for_Resource__c;

                logResp.How_To_Process__c = 'use_custom_apex_handler';
                logResp.Custom_Apex_Handler__c = 'Plivo_Outbound_SYS_ApplicationService';
            }
            else{
                logResp.Status__c = 'DONE';
                logResp.How_To_Process__c = 'ignore_log';

            }
            logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
            logResp.WhatId__c = log.WhatId__c;
            logResp.Type__c = 'RESPONSE';
            logResp.Integration_Setting__c = SYS_DataCache.INT_TYPE;
            logResp.ObjectSettingId__c = log.ObjectSettingId__c;
        }

        upsert log;
        logResp.SYS_RequestId__c = log.Id;

        return logResp;     
    }
    /* ------------------------------------------------------------------------ */
    /**
     * This method sets the id to records in sObjectsToDML if its missing
     * Scenario: Record insert in SF triggers Outbound followed by Response Inbound to be processed
     * Since the newly created SF records won't have the external Id, we cannot do an upsert
     * on external key in the JSON (it will create duplicates). Hence we need to get the Id i.e.
     * the WhatId on the log record.
     */

    public override List<sObject> getMissingIdForUpdate(List<sObject> sObjectsToDML,SYS_IntegrationLog__c logResp) {
        String jsonBody = '';
        jsonBody =  logResp.data0__c != null ? logResp.data0__c : '' +
                    logResp.data1__c != null ? logResp.data1__c : '' +
                    logResp.data2__c != null ? logResp.data2__c : '' +
                    logResp.data3__c != null ? logResp.data3__c : '' +
                    logResp.data4__c != null ? logResp.data4__c : '' +
                    logResp.data5__c != null ? logResp.data5__c : '' +
                    logResp.data6__c != null ? logResp.data6__c : '' +
                    logResp.data7__c != null ? logResp.data7__c : '' +
                    logResp.data8__c != null ? logResp.data8__c : '' +
                    logResp.data9__c != null ? logResp.data9__c : '' ;
        for(sObject s:sObjectsToDML){
            if(s.Id == NULL){
                s.Id = logResp.WhatId__c;
                PlivoMessage plivoRespObj = (PlivoMessage)System.JSON.deserialize(jsonBody, PlivoMessage.class);
                String messageUUID = String.valueof(plivoRespObj.message_uuid[0]);
                s.put(Activity__c.UUID__c, messageUUID);
            }
        }
        return sObjectsToDML;
    }
}