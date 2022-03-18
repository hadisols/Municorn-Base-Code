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
    
    /**
     * This hook is called from each of the hook for Http Verb processing
     * Arguement: Http Verb - POST,GET,PATCH,DELETE,PUT
     * Relies on Integration Setting in DataCache and RestContext
     * Override if custom log generation is required
     */
    public override SYS_IntegrationLog__c generateLogForWebhookReq(String method) {
        String requestBody = RestContext.request.requestBody.toString();
        Map<String, String> requestParams = RestContext.request.params;
        if(requestBody=='' && !requestParams.isEmpty()){
            requestBody = convertRequestParamsJSON(requestParams);
        }
        SYS_IntegrationLog__c log = SYS_Helper.getLogsToInsert(requestBody);

        String algo = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Hashing_Algo__c;
        if(algo!=NULL && algo!='')
        log.Request_Digest__c = generateHash(requestBody,algo);

        log.Type__c = 'INBOUND';
        log.SYS_Operation_Type__c = getOperationTypeFor(method);
        log.Flat_Key_for_Resource__c = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Flat_Key_for_Resource__c;
        log.Integration_Setting__c = SYS_DataCache.INT_TYPE;
        log.Status__c = 'NEW';
        log.How_to_process__c = 'use_custom_apex_handler';
        log.Custom_Apex_Handler__c = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).ApexHandler__c;

        return log;
    }
}