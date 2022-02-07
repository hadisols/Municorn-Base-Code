public class Plivo_Inbound_SYS_ApplicationService extends SYS_ApplicationService {
    public Plivo_Inbound_SYS_ApplicationService() {

    }

    /* ---------------  Inbound Webhook Processing  ----------------------*/
    //Convert Request Params Map Keys to Lowercase
    public static String convertRequestParamsJSON(Map<String,String> reqParams){
        String requestBody='';
        Map<String, String> newrequestParams = new Map<String, String>(); 
        for(String key : reqParams.keySet()){
            newrequestParams.put(key.toLowerCase(), reqParams.get(key));
        }
        requestBody=JSON.serialize(newrequestParams);
        SYS_debug.log('body== from Params' + requestBody);  
        return requestBody;
    }
    
    //Process Webhook Response
    public override SYS_IntegrationLog__c generateLogForWebhookReq(String method) {
        Map<String, String> requestParams = RestContext.request.params;
        String requestBody = RestContext.request.requestBody.toString();
        if(requestBody=='' && !requestParams.isEmpty()){
            requestBody = convertRequestParamsJSON(requestParams);
        }
        SYS_IntegrationLog__c log = SYS_ApplicationService.getLogsToInsert(requestBody);

        String algo = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Hashing_Algo__c;
        if(algo!=NULL && algo!='')
        log.Request_Digest__c = generateHash(requestBody,algo);

        log.Type__c = 'INBOUND';
        log.SYS_Operation_Type__c = getOperationTypeFor('PUT');
        log.Flat_Key_for_Resource__c = 'type';
        log.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
        log.Status__c = 'NEW';
        log.External_Id_Field_API_Name__c = 'UUID__c';
        log.How_to_process__c = 'use_custom_apex_handler';
        log.Custom_Apex_Handler__c = 'Plivo_Inbound_SYS_ApplicationService';

        return log;
    }
}