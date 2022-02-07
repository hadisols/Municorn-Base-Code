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
        String keyForResource = 'data.object.object';
        String requestBody = RestContext.request.requestBody.toString();
        SYS_IntegrationLog__c log = SYS_ApplicationService.getLogsToInsert(requestBody);
        //To Identify the ExternalId Field and add it to syslog 
        Map < String, Object > flatKeyMap = SYS_Transformer.makeJsonIntoKeyValuePairs(requestBody);
        System.debug('-- MS flatKeyMap in generateLogForWebhookReq:' + flatKeyMap);
        String objectName = (String) flatKeyMap.get(keyForResource);
        switch on objectName.toLowerCase() {
            when 'customer' {
                log.External_Id_Field_API_Name__c = 'StripeCustomerId__c';
            }
            when 'card' {
                log.External_Id_Field_API_Name__c = 'Payment_Method_Id__c';
            }
            when 'charge' {
                log.External_Id_Field_API_Name__c = 'StripeChargeId__c';
            }
            when
            else {
                SYS_debug.log('Not found any external Id based on Webhook JSON: ' + objectName);
            }

        }

        String algo = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Hashing_Algo__c;
        if (algo != NULL && algo != '')
            log.Request_Digest__c = generateHash(requestBody, algo);
        log.Type__c = 'INBOUND';
        log.SYS_Operation_Type__c = getOperationTypeFor('PUT');
        log.Flat_Key_for_Resource__c = keyForResource;
        log.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
        log.Status__c = 'NEW';
        log.How_to_process__c = 'use_custom_apex_handler';
        log.Custom_Apex_Handler__c = 'Stripe_Inbound_SYS_ApplicationService';

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