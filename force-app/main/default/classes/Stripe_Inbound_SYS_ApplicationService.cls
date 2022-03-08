public with sharing class Stripe_Inbound_SYS_ApplicationService extends SYS_ApplicationService {
    public Stripe_Inbound_SYS_ApplicationService() {

    }
    /**
     * This hook is called from each of the hook for Http Verb processing
     * Arguement: Http Verb - POST,GET,PATCH,DELETE,PUT
     * Relies on Integration Setting in DataCache and RestContext
     * Override if custom log generation is required
     */
    //Process Webhook Responses for Stripe Integration
    public override SYS_IntegrationLog__c generateLogForWebhookReq(String method) {
        String requestBody = RestContext.request.requestBody.toString();
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

    // For Outbound. Called from doInbound() in ApplicationService
    //Upsert Webhook Response using externalid and preprocess values in sobject
    public override List<sObject> transformJsonToSObject(String jsonBody,String resource) {
        List < sObject > sObjectsToDML = SYS_Transformer.getSObjectsToUpsert(new List<String>{jsonBody},resource);
        if (sObjectsToDML.size() > 0) {
            for (sObject currentObj: sObjectsToDML) {
                if (currentObj instanceOf Transaction__c) {
                    String contactId = (String) currentObj.get('Contact__c');
                    String paymentRequestId = (String) currentObj.get('PaymentRequestId__c');
                    String txstatus = (String) currentObj.get('Status__c');
                    Double amount = (Double) currentObj.get('Amount__c');
                    Double amountCaptured = (Double) currentObj.get('Amount_Captured__c');
                    Double amountRefunded = (Double) currentObj.get('AmountRefunded__c');
                    currentObj.put('Amount__c', amount / 100);
                    currentObj.put('Amount_Captured__c', amountCaptured / 100);
                    currentObj.put('AmountRefunded__c', amountRefunded / 100);
                    if (contactId != '') {
                        List < Sobject > contactRecords = PMA_ExternalSiteFormsUtility.getRecord(contactId);
                        Contact contactRecord = (contactRecords.size() > 0) ? (Contact)contactRecords[0] : new Contact();
                        String paymentName = 'Payment For ' + contactRecord.Name;
                        currentObj.put('Name', paymentName);
                    }
                }
                if (currentObj instanceOf Payment_Method__c) {
                    String cardToken = (String) currentObj.get('Payment_Method_Id__c');
                    currentObj.put('Card_Id__c', cardToken);
                }
            }
        }
        return sObjectsToDML;
    }

}