public class ProcessTransactionWebhook implements Queueable, Database.AllowsCallouts{
    
    private List<Id> sysLogIds = new List<Id>();
    
    public ProcessTransactionWebhook(List<Id> idList){
        this.sysLogIds = idList;
    }
    
    public void execute(QueueableContext context){

        List<Id> sysLogResponse = new List<Id>(); //user to trigger the async class to update SyncToken from response.

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String paymentRequestId;
        String accountId;
        // String transactionId;
        SYS_IntegrationLog__c logTrans = new SYS_IntegrationLog__c();
        SYS_IntegrationLog__c logAccount = new SYS_IntegrationLog__c();
        List<SYS_IntegrationLog__c> insertResponse = new List<SYS_IntegrationLog__c>();
        List<SYS_IntegrationLog__c> sysLog = [SELECT id,
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
                                              Type__c,WhatId__c,Parent__c,Order__c
                                              FROM SYS_IntegrationLog__c WHERE Id in:sysLogIds];

        /* for(SYS_IntegrationLog__c log : sysLog) {
            String body = log.data0__c+log.data1__c+log.data2__c+log.data3__c+
                    log.data4__c+log.data5__c+log.data6__c+log.data7__c+
                    log.data8__c+log.data9__c;
            transactionWebhook obj = (transactionWebhook)JSON.deserialize(body, transactionWebhook.class);
            String transactionId;
            if(obj.payload != null) {
                if(obj.payload.entityName == 'transaction'){
                    transactionId = obj.payload.id;
                }
            }
            if(transactionId != null) {
                String reqbody =  getTransactionRequest(transactionId);
                
                req.setEndpoint('https://apitest.authorize.net/xml/v1/request.api');
                req.setMethod('GET');
                req.setBody(reqbody);

                HttpResponse resp = http.send(req);
                System.debug('#### resp status: '+resp.getStatus());
                System.debug('#### resp code: '+resp.getStatusCode());
                System.debug('#### resp: '+resp.getBody());

                if(resp.getStatusCode() == 200) {
                    List<sObject> upsertTrans = new List<sObject>{Schema.getGlobalDescribe().get('Account').newSObject()};//SYS_ApexHandler.getSingleSobjectsToUpsert_QB(resp.getBody().replace('\uFEFF', ''), 'transaction');
                    paymentRequestId = (String)upsertTrans[0].get('PaymentRequestId__c');
                    

                    // upsert upsertTrans;
                    // List<Database.UpsertResult> results = Database.upsert(upsertTrans, Schema.getGlobalDescribe().get('Transaction__c').getDescribe().fields.getMap().get('Transaction_Id__c'), false);
                    // for(Database.UpsertResult result : results){ 
                    //     if(result.isSuccess()){
                    //         SYS_debug.log('Transaction update success'+result.getId());
                    //     } else {
                    //         SYS_debug.log('Insertion error Transaction occured.');
                    //         for(Database.Error err : result.getErrors()) {
                    //             SYS_debug.log('The following error has occurred.');                    
                    //             SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
                    //             SYS_debug.log('Fields affected are: ' + err.getFields());
                    //         }
                    //     }
                    // }
                    //update the satus of payment request
                    PaymentRequest__c paymentReq = new PaymentRequest__c(
                        Id = paymentRequestId,
                        Status__c = 'payment_done'
                    );
                    
                    List<sObject> upsertMethod = new List<sObject>{Schema.getGlobalDescribe().get('Account').newSObject()};//SYS_ApexHandler.getSingleSobjectsToUpsert_QB(resp.getBody().replace('\uFEFF', ''), 'paymentMethod');
                    upsertMethod[0].put('Account__c', getAccountId(paymentRequestId));
                    // List<Database.UpsertResult> resultsUpsert = Database.upsert(upsertMethod, Schema.getGlobalDescribe().get('Payment_Method__c').getDescribe().fields.getMap().get('Profile_Id__c'), false);
                    // for(Database.UpsertResult result : resultsUpsert){ 
                    //     if(result.isSuccess()){
                    //         SYS_debug.log('Payment Method update success'+result.getId());
                    //     } else {
                    //         SYS_debug.log('Insertion error Payment Method occured.');
                    //         for(Database.Error err : result.getErrors()) {
                    //             SYS_debug.log('The following error has occurred.');                    
                    //             SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
                    //             SYS_debug.log('Fields affected are: ' + err.getFields());
                    //         }
                    //     }
                    // }

                    //New changes 
                    List<PaymentRequest__c> paymentrequest = [SELECT Id, Account__c FROM PaymentRequest__c WHERE Id = :paymentRequestId ];
                    accountId = paymentrequest.size() > 0 ? paymentrequest[0].Account__c :'';
                    upsertTrans[0].put('PaymentRequestId__c', paymentRequestId);

                    
                    reqbody =  getTransactionRequest(transactionId);
                            
                    req.setEndpoint('https://apitest.authorize.net/xml/v1/request.api');
                    req.setMethod('GET');
                    req.setBody(reqbody);

                    HttpResponse resp0 = http.send(req);
                    System.debug('#### resp0 status: '+resp0.getStatus());
                    System.debug('#### resp0 code: '+resp0.getStatusCode());
                    System.debug('#### resp0: '+resp0.getBody());
                    if(resp0.getStatusCode() == 200) {
                        logTrans = SYS_integrationLogHandler.getLogsToInsert(resp0.getBody().replace('\uFEFF', '')); // TODO - Integartionlog handler SYS_integrationLogHandler
                        logTrans.Type__c = 'INBOUND';
                        logTrans.SYS_Operation_Type__c = 'INSERT';
                        logTrans.Status__c = 'DONE';
                        logTrans.SYS_IntegrationSettings__c = 'Authorize';
                        logTrans.Entity_Name__c = 'Transaction__c';
                    }
                    reqbody = SYS_integrationLogHandler.getProfileFromTransaction(transactionId);
                    req.setMethod('POST');
                    req.setBody(reqbody);

                    HttpResponse resp2 = http.send(req);
                    System.debug('#### resp2 status: '+resp2.getStatus());
                    System.debug('#### resp2 code: '+resp2.getStatusCode());
                    System.debug('#### resp2: '+resp2.getBody());

                    Map<String, Object> profileMap = (Map<String, Object>)JSON.deserializeUntyped(resp2.getBody().replace('\uFEFF', ''));
                    String profileId = (String)profileMap.get('customerProfileId');

                    reqbody = SYS_integrationLogHandler.getProfileDetails(profileId, accountId);
                    req.setMethod('GET');
                    req.setBody(reqbody);

                    HttpResponse resp3 = http.send(req);
                    System.debug('#### resp3 status: '+resp3.getStatus());
                    System.debug('#### resp3 code: '+resp3.getStatusCode());
                    System.debug('#### resp3: '+resp3.getBody());

                    if(resp.getStatusCode() == 200) {
                        logAccount = SYS_integrationLogHandler.getLogsToInsert(resp3.getBody().replace('\uFEFF', '')); // TODO - Integartionlog handler SYS_integrationLogHandler
                        logAccount.Type__c = 'INBOUND';
                        logAccount.SYS_Operation_Type__c = 'INSERT';
                        logAccount.Status__c = 'DONE';
                        logAccount.SYS_IntegrationSettings__c = 'Authorize';
                        logAccount.Entity_Name__c = 'Account';
                    }

                    List<Database.UpsertResult> results = Database.upsert(upsertTrans, Schema.getGlobalDescribe().get('Transaction__c').getDescribe().fields.getMap().get('Transaction_Id__c'), false);
                    for(Database.UpsertResult result : results){ 
                        if(result.isSuccess()){
                            SYS_debug.log('Transaction update success'+result.getId());
                        } else {
                            SYS_debug.log('Insertion error Transaction occured.');
                            for(Database.Error err : result.getErrors()) {
                                SYS_debug.log('The following error has occurred.');                    
                                SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
                                SYS_debug.log('Fields affected are: ' + err.getFields());
                            }
                        }
                    }

                    List<Database.UpsertResult> resultsUpsert = Database.upsert(upsertMethod, Schema.getGlobalDescribe().get('Payment_Method__c').getDescribe().fields.getMap().get('Profile_Id__c'), false);
                    for(Database.UpsertResult result : resultsUpsert){ 
                        if(result.isSuccess()){
                            SYS_debug.log('Payment Method update success'+result.getId());
                        } else {
                            SYS_debug.log('Insertion error Payment Method occured.');
                            for(Database.Error err : result.getErrors()) {
                                SYS_debug.log('The following error has occurred.');                    
                                SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
                                SYS_debug.log('Fields affected are: ' + err.getFields());
                            }
                        }
                    }

                    update paymentReq;
                    insert logTrans;
                    // insert integrationLog;
                    insert logAccount;

                }

            }
        } */
    }

    public class transactionWebhook {
        public cls_payload payload;
    }
    class cls_payload {
		public String entityName;	//transaction
		public String id;	//40080814409
	}

    public static String getAccountId(String paymentId) {
        List<PaymentRequest__c> payment = [SELECT Id, Account__c FROM PaymentRequest__c WHERE id = :paymentId];
        String result;
        if(payment.size() > 0) {
            result = payment[0].Account__c;
        }

        return result;
    }

    public static String getTransactionRequest(String transId) {

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('getTransactionDetailsRequest'); gen.writeStartObject();
        gen.writeFieldName('merchantAuthentication'); gen.writeStartObject();
        gen.writeStringField('name', '84vMVmF6jP');
        gen.writeStringField('transactionKey', '42Xr3CAw9k83jzu6');
        gen.writeEndObject();
        // gen.writeStringField('refId', );
        gen.writeStringField('transId', transId);
        gen.writeEndObject();
        gen.writeEndObject();

        return gen.getAsString();
    }
}