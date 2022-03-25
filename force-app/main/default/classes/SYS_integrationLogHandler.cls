public class SYS_integrationLogHandler {

   /*  public static boolean filterWebSericeToken(String token) { 
        
        String tokenMeta = SYS_DataCache.webhookToken;
        SYS_debug.log('token is=='+tokenMeta+'--url--'+token);
        if(Test.isRunningTest())    return true;
        if (tokenMeta == null) {
            return true;
        } 
        return (token.equals(tokenMeta) );  
    } */

    public static string getProfileDetails(String profileId, String accountId) {
        String result;

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('getCustomerProfileRequest'); gen.writeStartObject();
        gen.writeFieldName('merchantAuthentication'); gen.writeStartObject();
        gen.writeStringField('name', '84vMVmF6jP');
        gen.writeStringField('transactionKey', '42Xr3CAw9k83jzu6');
        gen.writeEndObject();
        gen.writeStringField('refId', accountId);
        gen.writeStringField('customerProfileId', profileId);
        gen.writeStringField('includeIssuerInfo', 'true');
        gen.writeEndObject();
        gen.writeEndObject();

        result = gen.getAsString();
        System.debug('test'+result);

        return result;
    }

    public static string getProfileFromTransaction(String transactionId) {
        String result;

        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
        gen.writeFieldName('createCustomerProfileFromTransactionRequest'); gen.writeStartObject();
        gen.writeFieldName('merchantAuthentication'); gen.writeStartObject();
        gen.writeStringField('name', '84vMVmF6jP');
        gen.writeStringField('transactionKey', '42Xr3CAw9k83jzu6');
        gen.writeEndObject();
        gen.writeStringField('transId', transactionId);
        gen.writeEndObject();
        gen.writeEndObject();

        result = gen.getAsString();
        System.debug('test'+result);

        return result;
    }

    // public static void processAuthorizeResp(String body, String entity) {
    //     if(entity == 'Transaction__c') {
    //         List<sObject> upsertTransaction = SYS_ApexHandler.getSingleSobjectsToUpsert_QB(body, 'transaction');
            
    //         List<Database.UpsertResult> results = Database.upsert(upsertTransaction, Schema.getGlobalDescribe().get('Transaction__c').getDescribe().fields.getMap().get('Transaction_Id__c'), false);
    //         for(Database.UpsertResult result : results){ 
    //             if(result.isSuccess()){
    //                 SYS_debug.log('Transaction update success'+result.getId());
    //             } else {
    //                 SYS_debug.log('Insertion error Transaction occured.');
    //                 for(Database.Error err : result.getErrors()) {
    //                     SYS_debug.log('The following error has occurred.');                    
    //                     SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
    //                     SYS_debug.log('Fields affected are: ' + err.getFields());
    //                 }
    //             }
    //         }
    //     } else if (entity == 'PaymentRequest__c') {
    //         List<sObject> upsertPaymentReq = SYS_ApexHandler.getSingleSobjectsToUpsert_QB(body, 'paymentReq');
    //         upsertPaymentReq[0].put('Status__c', 'payment_done');

    //         List<Database.SaveResult> results = Database.update(upsertPaymentReq, false);
    //         for(Database.SaveResult result : results){ 
    //             if(result.isSuccess()){
    //                 SYS_debug.log('Payment Method update success'+result.getId());
    //             } else {
    //                 SYS_debug.log('Insertion error Payment Method occured.');
    //                 for(Database.Error err : result.getErrors()) {
    //                     SYS_debug.log('The following error has occurred.');                    
    //                     SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
    //                     SYS_debug.log('Fields affected are: ' + err.getFields());
    //                 }
    //             }
    //         }
    //     } else if (entity == 'Account') {
    //         List<sObject> upsertAccount = SYS_ApexHandler.getSingleSobjectsToUpsert_QB(body, 'customer');
    //         List<Database.SaveResult> results = Database.update(upsertAccount, false);

    //         String accountId;
    //         for(Database.SaveResult result : results){ 
    //             if(result.isSuccess()){
    //                 SYS_debug.log('Account update success'+result.getId());
    //                 accountId = result.getId();
    //             } else {
    //                 SYS_debug.log('Insertion error Account occured.');
    //                 for(Database.Error err : result.getErrors()) {
    //                     SYS_debug.log('The following error has occurred.');                    
    //                     SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
    //                     SYS_debug.log('Fields affected are: ' + err.getFields());
    //                 }
    //             }
    //         }

    //         if(accountId != null) {
    //             Map<String, Object> paymentMethods = (Map<String, Object>)JSON.deserializeUntyped(body);
    //             Object profile = paymentMethods.get('profile');
    //             List<Object> payments = (List<Object>)((Map<String, Object>)profile).get('paymentProfiles');
    //             List<String> paymentMethod = new List<String>();
    //             List<sObject> upsertMethods = new List<sObject>();

    //             for(Object obj : payments) {
    //                 paymentMethod.add(JSON.serialize(obj));
    //                 List<sObject> item = SYS_ApexHandler.getSingleSobjectsToUpsert_QB(JSON.serialize(obj), 'paymentMethod1');
    //                 upsertMethods.addAll(item);
    //             }
                
    //             for(sObject itr : upsertMethods) {   
    //                 itr.put('Account__c', accountId);
    //             }
    //             List<Database.UpsertResult> resultMethod = Database.upsert(upsertMethods, Schema.getGlobalDescribe().get('Payment_Method__c').getDescribe().fields.getMap().get('Profile_Id__c'), false);
    //             for(Database.UpsertResult result : resultMethod){ 
    //                 if(result.isSuccess()){
    //                     SYS_debug.log('Methods update success'+result.getId());
    //                     accountId = result.getId();
    //                 } else {
    //                     SYS_debug.log('Insertion error Methods occured.');
    //                     for(Database.Error err : result.getErrors()) {
    //                         SYS_debug.log('The following error has occurred.');                    
    //                         SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
    //                         SYS_debug.log('Fields affected are: ' + err.getFields());
    //                     }
    //                 }
    //             }
    //         }
    //     }
    // }

    // public static sObject transformGETResponse(String getResponse, String whatId) { 
        
    //     String objectApiName = ((Id)whatId).getsobjecttype() + '';
    //     sObject recordObj = Schema.getGlobalDescribe().get(objectApiName).newSObject(whatId) ;
    //     String recordString = JSON.Serialize(((Map<String , Object>)JSON.deserializeUntyped(getResponse)).get(SYS_Constants.metaDataMap.get(objectApiName)));
    //     SYS_debug.log('json is=='+recordString);
    //     String resourcepath = SYS_Constants.mapEntityPath.get(SYS_Constants.metaDataMap.get(objectApiName));
    //     SYS_debug.log('psth=='+resourcepath);
    //     recordObj = SYS_ApexHandler.getSobjectsToUpsert_QB(new List<String>{recordString}, resourcepath) != null ?
    //                 SYS_ApexHandler.getSobjectsToUpsert_QB(new List<String>{recordString}, resourcepath)[0] :
    //                 recordObj ;

    //     return recordObj;
    // }

    // public static String getExternalFieldName(String objectApiName) {
    //     if(SYS_DataCache.getExtId.values().size() > 0) {
    //         return SYS_DataCache.getExtId.get(SYS_Constants.INT_TYPE).values().size() > 0 ? SYS_DataCache.getExtId.get(SYS_Constants.INT_TYPE).get(objectApiName) : '';
    //     }
    //     return ''; 
    // }

    // public static void transformJIRArequest(String response) {
    //     List<sObject> upsertOpp = SYS_ApexHandler.getSingleSobjectsToUpsert_QB(response, 'issue');
    //     String objectApiName = SYS_DataCache.sObjectApiName;
    //     if(upsertOpp.size() > 0) {
    //         upsertOpp[0].put('CloseDate', Date.today());
    //         Database.UpsertResult[] results = Database.upsert(upsertOpp, Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get('SYS_Key1__c'), false);
    //         for(Database.UpsertResult result : results){
    //             if(result.isSuccess()){
    //                 SYS_debug.log('sObject update success');
    //             } else {
    //                 SYS_debug.log('Insertion error has occured.');
    //                 for(Database.Error err : result.getErrors()) {
    //                     SYS_debug.log('The following error has occurred.');                    
    //                     SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
    //                     SYS_debug.log('Fields affected are: ' + err.getFields());
    //                 }
    //             }
    //         }
    //     }
    // }

    

    // public static void updateQuickbooksId(List<SYS_IntegrationLog__c> newList) {
    //     String jsonBody = '';
    //     List<sObject> recordList = new List<sObject>();
    //     for(SYS_IntegrationLog__c log : newList) {
    //         jsonBody = log.data0__c != null ? log.data0__c : '' +
    //                         log.data1__c != null ? log.data1__c : '' +
    //                         log.data2__c != null ? log.data2__c : '' +
    //                         log.data3__c != null ? log.data3__c : '' +
    //                         log.data4__c != null ? log.data4__c : '' +
    //                         log.data5__c != null ? log.data5__c : '' +
    //                         log.data6__c != null ? log.data6__c : '' +
    //                         log.data7__c != null ? log.data7__c : '' + 
    //                         log.data8__c != null ? log.data8__c : '' +
    //                         log.data9__c != null ? log.data9__c : '' ; 
            
    //         sObject obj =  SYS_integrationLogHandler.updateIdAndToken( jsonBody , log.WhatId__c);  
    //         recordList.add(obj);
    //         SYS_debug.log('object=='+obj);
    //     }
    //     Database.update(recordList);
    // } 

    // public static sobject updateIdAndToken(String body, String recId) {
    //     // String objectApiName = ((Id)recId).getSobjectType() + '';
    //     // String query = 'SELECT Id, Quickbooks_Id__c, QB_SyncToken__c FROM '+ objectApiName + ' WHERE Id in :recId';
    //     List<sObject> recordList = new List<sObject>();
    //     Map<String, Object> flatKeyMap = SYS_Transformer.makeJsonIntoKeyValuePairs(body);
    //     String ObjectName = ((Id)recId).getsobjecttype() + '';
    //     String constructKey = SYS_Constants.metaDataMap.get(ObjectName) + '.' + 'Id';
    //     String constructToken = SYS_Constants.metaDataMap.get(ObjectName) + '.' + 'SyncToken'; 
    //     String externalId = String.valueof(flatKeyMap.get(constructKey));
    //     String syncToken = String.valueof(flatKeyMap.get(constructToken));
    //     sObject record = Schema.getGlobalDescribe().get(ObjectName).newSObject(((Id)recId));
    //     record.put('Quickbooks_Id__c' , externalId); 
    //     record.put('QB_SyncToken__c', syncToken);

    //     return record;
    // }

    // public static void transformGETResponseAndUpsertQB(String response , String whatId) { //Specific to Quickbooks.
    //     sObject recordObj;
    //     Object responseType = JSON.deserializeUntyped(response);
    //     if(responseType instanceof Map<String , Object>) {
    //         String rootKey = new List<String>(((Map<String, Object>)responseType).keySet())[0];
    //         if(SYS_Constants.entityNameToObjapiName.containsKey(rootKey)) {
    //             String objectApiName = SYS_Constants.entityNameToObjapiName.get(rootKey);
    //             String recordString = JSON.Serialize(((Map<String, Object>)responseType).get(rootKey));
    //             SYS_debug.log('json is=='+recordString);
    //             String resourcepath = SYS_Constants.mapEntityPath.get(SYS_Constants.metaDataMap.get(objectApiName));
    //             SYS_debug.log('psth=='+resourcepath);
    //             String externalFieldApiName = SYS_DataCache.getExtId.get(SYS_Constants.INT_TYPE) != null ? SYS_DataCache.getExtId.get(SYS_Constants.INT_TYPE).get(objectApiName) : null;
    //             SYS_debug.log('External FIeldApiName=='+externalFieldApiName);
    //             if(rootKey.equalsIgnoreCase('Customer') ) {
    //                 List<sObject> upsertAcc = SYS_ApexHandler.getSingleSobjectsToUpsert_QB(recordString, resourcepath);
    //                 if(upsertAcc.size() > 0) {
    //                     if(whatId != null) {
    //                         upsertAcc[0].put('Id', whatId);
    //                         List<Database.UpsertResult> results = Database.upsert(upsertAcc, Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get('Id'), false);
    //                         for(Database.UpsertResult result : results){
    //                             if(result.isSuccess()){
    //                                 SYS_debug.log('Account update success'+result.getId());
    //                             } else {
    //                                 SYS_debug.log('Insertion error Account occured.');
    //                                 for(Database.Error err : result.getErrors()) {
    //                                     SYS_debug.log('The following error has occurred.');                    
    //                                     SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
    //                                     SYS_debug.log('Fields affected are: ' + err.getFields());
    //                                 }
    //                             }
    //                         }
    //                         checkDatabaseResults(results);  
    //                     } else if (upsertAcc[0].get('Quickbooks_Id__c') != null) {
    //                         List<Database.UpsertResult> resultsUpsert = Database.upsert(upsertAcc, Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(externalFieldApiName), false);
    //                         for(Database.UpsertResult result : resultsUpsert){ 
    //                             if(result.isSuccess()){
    //                                 SYS_debug.log('Account update success'+result.getId());
    //                             } else {
    //                                 SYS_debug.log('Insertion error Account occured.');
    //                                 for(Database.Error err : result.getErrors()) {
    //                                     SYS_debug.log('The following error has occurred.');                    
    //                                     SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
    //                                     SYS_debug.log('Fields affected are: ' + err.getFields());
    //                                 }
    //                             }
    //                         }
    //                     }
    //                 }
                    
    //             } else if(rootKey.equalsIgnoreCase('Invoice') ) {
    //                 SYS_debug.log('resource path=='+resourcepath);
    //                 List<sObject> upsertRecord = SYS_ApexHandler.getSingleSobjectsToUpsert_QB(recordString, resourcepath);
    //                 SYS_debug.log('@@upsert check');
    //                 if(!upsertRecord.isEmpty()) {
    //                     upsertRecord[0].put('Id', whatId);
    //                 }
                    
    //                 List<Database.UpsertResult> results = Database.upsert(upsertRecord, Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get('Id'), false);
    //                 // String recordId = '';
    //                 // String externalId = String.valueof(upsertRecord.size() > 0 ? upsertRecord[0].get('Quickbooks_Id__c') : '');
                    
    //                 for(Database.UpsertResult result : results){
    //                     if(result.isSuccess()){
    //                         SYS_debug.log('sObject update success');
    //                         // recordId = result.getId(); 
    //                     } else {
    //                         SYS_debug.log('Insertion error has occured.');
    //                         for(Database.Error err : result.getErrors()) {
    //                             SYS_debug.log('The following error has occurred.');                    
    //                             SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
    //                             SYS_debug.log('Fields affected are: ' + err.getFields());
    //                         }
    //                     } 
    //                 } 
    //                 // if(recordId != '') {
    //                 //     // if()
    //                 //     Object recordDetails = ((Map<String, Object>)responseType).get(rootKey);
    //                 //     Object lineItem = ((Map<String, Object>)recordDetails).get('Line');
    //                 //     List<sObject> lineItemList = SYS_ApexHandler.getSObjectsToUpsertChildQB(new List<String>{recordString}, resourcepath);
    //                 //     lineItemList.remove(lineItemList.size() - 1);
    //                 //     List<sObject> lineItemsUpdate = new List<sObject>();
                        
    //                 //     for(sObject lineIter : lineItemList) { 
    //                 //         if(lineIter.get('Quickbooks_Invoice_Line_Number__c') != null) {
    //                 //             String qbId = lineIter.get('SYS_Parent__c') + '';
    //                 //             lineIter.put('SBQQ__Quote__c', recordId);   
    //                 //             lineIter.put('Product2Id', SYS_DataCache.PRODMAP.get(qbId));
    //                 //             lineIter.put('PricebookEntryId', SYS_DataCache.PRICEMAP.get(qbId)); 
    //                 //             System.debug('product=='+SYS_DataCache.PRODMAP.get(qbId)+' key=='+qbId);

    //                 //             // String oppId = lineIter.get('OpportunityId') != null ? lineIter.get('OpportunityId') + '' : '';
    //                 //             // String ext = externalId != null ? externalId : '';
    //                 //             // String unitPrice = lineIter.get('UnitPrice') != null ? lineIter.get('UnitPrice') + '' : '';
    //                 //             // String prodName =  lineIter.get('Name') != null ? lineIter.get('Name') + '' : ''; 
                                
    //                 //             String prodKey = lineIter.get('SYS_Parent__c') != null ? String.valueof(lineIter.get('SYS_Parent__c')) : '';   
    //                 //             String quantity = String.valueof(lineIter.get('Quantity') != null ? Integer.valueof(lineIter.get('Quantity')) + '' : '1'); 
    //                 //             String toHash = externalId + prodKey + quantity;    
    //                 //             lineIter.put('SYS_Hash__c' , getHashOfRecord(toHash));
    //                 //             // lineIter.put('PricebookEntryId', SYS_DataCache.mapPriceBookEntry.get(prodKey)); 
    //                 //             lineItemsUpdate.add(lineIter); 
    //                 //             SYS_debug.log('line--'+lineIter); 
    //                 //         } 
    //                 //     } 
                        
    //                 //     List<Database.UpsertResult> lineItems = Database.upsert(lineItemsUpdate, Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fields.getMap().get('SYS_Hash__c'), false);
    //                 //     // List<Database.SaveResult> lineItems = Database.insert(lineItemList);
    //                 //     // checkDatabaseResults(lineItems);
    //                 //     for(Database.UpsertResult result : lineItems){  
    //                 //         if(result.isSuccess()){
    //                 //             SYS_debug.log('LineItem update success');
    //                 //         } else {
    //                 //             SYS_debug.log('LineItem error has occured.');
    //                 //             for(Database.Error err : result.getErrors()) {
    //                 //                 SYS_debug.log('The following error has occurred.');                    
    //                 //                 SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
    //                 //                 SYS_debug.log('Fields affected are: ' + err.getFields());
    //                 //             }
    //                 //         }
    //                 //     }
    //                 // }
    //             } else if(rootKey.equalsIgnoreCase('item') ) { 
    //                 SYS_debug.log('inside item');
    //                 List<sObject> upsertProduct = SYS_ApexHandler.getSingleSobjectsToUpsert_QB(recordString, resourcepath);
    //                 List<Database.UpsertResult> results = new List<Database.UpsertResult>();
    //                 Boolean isActive = false;
    //                 String sysKeyProd;
    //                 if(upsertProduct.size() > 0) { 
    //                     sysKeyProd = String.valueOf(upsertProduct[0].get('Quickbooks_Id__c'));
    //                     isActive = Boolean.valueOf(upsertProduct[0].get('IsActive'));
    //                     if(whatId != null) {
    //                         upsertProduct[0].put('Id', whatId);
    //                         results = Database.upsert(upsertProduct, Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get('Id'), false);
    //                         checkDatabaseResults(results);
    //                     } else if (upsertProduct[0].get('Quickbooks_Id__c') != null)
    //                         results = Database.upsert(upsertProduct, Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(externalFieldApiName), false);
    //                 }
    //                 SYS_debug.log('results size=='+upsertProduct);
    //                 String productId;
    //                 for(Database.UpsertResult result : results){
    //                     if(result.isSuccess()){
    //                         SYS_debug.log('Product update successful');
    //                         productId = result.getId();
    //                     } else {
    //                         SYS_debug.log('Insertion product error has occured.');
    //                         for(Database.Error err : result.getErrors()) {
    //                             SYS_debug.log('The following error has occurred.');                    
    //                             SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
    //                             SYS_debug.log('Fields affected are: ' + err.getFields());
    //                         }
    //                     }
    //                 }
    //                 // if(!String.isBlank(productId)) {
    //                 //     List<sObject> upsertPriceBookEntry = SYS_ApexHandler.getSingleSobjectsToUpsert_QB(recordString, 'itemPrice');
    //                 //     System.debug('price entry=='+SYS_DataCache.mapPriceBookEntry);
    //                 //     if(upsertPriceBookEntry.size() > 0 && isActive) {
    //                 //         if(SYS_DataCache.mapPriceBookEntry.get(sysKeyProd) != null) {
    //                 //             upsertPriceBookEntry[0].put('Id', SYS_DataCache.mapPriceBookEntry.get(sysKeyProd));
    //                 //         } else {
    //                 //             upsertPriceBookEntry[0].put('Product2Id', productId);
    //                 //             upsertPriceBookEntry[0].put('Pricebook2Id', SYS_DataCache.priceBookId);
    //                 //         }
    //                 //         SYS_debug.log('entry=='+upsertPriceBookEntry);
    //                 //         Database.UpsertResult[] priceResults;
    //                 //         priceResults = Database.upsert(upsertPriceBookEntry, Schema.getGlobalDescribe().get('PricebookEntry').getDescribe().fields.getMap().get('Id'), false);
    //                 //         for(Database.UpsertResult result : priceResults){
    //                 //             if(result.isSuccess()){
    //                 //                 SYS_debug.log('ProductPrice update successful');
    //                 //                 productId = result.getId();
    //                 //             } else {
    //                 //                 SYS_debug.log('Insertion productPrice error has occured.');
    //                 //                 for(Database.Error err : result.getErrors()) {
    //                 //                     SYS_debug.log('The following error has occurred.');                    
    //                 //                     SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
    //                 //                     SYS_debug.log('Fields affected are: ' + err.getFields());
    //                 //                 }
    //                 //             }
    //                 //         }
    //                 //     }
    //                 // }
    //             } else if (rootKey.equalsIgnoreCase('Payment')){
    //                 List<sObject> upsertAcc = SYS_ApexHandler.getSingleSobjectsToUpsert_QB(recordString, resourcepath);
    //                 if(upsertAcc.size() > 0) {
    //                     if(whatId != null) {
    //                         upsertAcc[0].put('Id', whatId);
    //                         List<Database.UpsertResult> results = Database.upsert(upsertAcc, Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get('Id'), false);
    //                         for(Database.UpsertResult result : results){
    //                             if(result.isSuccess()){
    //                                 SYS_debug.log('Payment update success');
    //                             } else {
    //                                 SYS_debug.log('Insertion error Account occured.');
    //                                 for(Database.Error err : result.getErrors()) {
    //                                     SYS_debug.log('The following error has occurred.');                    
    //                                     SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
    //                                     SYS_debug.log('Fields affected are: ' + err.getFields());
    //                                 }
    //                             }
    //                         }
    //                         checkDatabaseResults(results);  
    //                     } else {
    //                         List<Database.UpsertResult> resultsUpsert = Database.upsert(upsertAcc, Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(externalFieldApiName), false);
    //                         for(Database.UpsertResult result : resultsUpsert){ 
    //                             if(result.isSuccess()){
    //                                 SYS_debug.log('Payment update success');
    //                             } else {
    //                                 SYS_debug.log('Insertion error Account occured.');
    //                                 for(Database.Error err : result.getErrors()) {
    //                                     SYS_debug.log('The following error has occurred.');                    
    //                                     SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
    //                                     SYS_debug.log('Fields affected are: ' + err.getFields());
    //                                 }
    //                             }
    //                         }
    //                     }
    //                 }
    //             }
    //         }   
    //     }
        
    // }

    public class discountWrap{
        public cls_Line[] Line; 
    } 
    public class cls_Line {
        public Double Amount;	
		public String DetailType;
    }

    public static void checkDatabaseResults(Database.UpsertResult[] results) {
        for(Database.UpsertResult result : results){
            if(result.isSuccess()){
                SYS_debug.log('sObject update success');
            } else {
                SYS_debug.log('Insertion error has occured.');
                for(Database.Error err : result.getErrors()) {
                    SYS_debug.log('The following error has occurred.');                    
                    SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
                    SYS_debug.log('Fields affected are: ' + err.getFields());
                }
            }
        }
    }
    

    public static SYS_IntegrationLog__c getLogsToInsert(String requestBody) {
        SYS_IntegrationLog__c integrationLog = new SYS_IntegrationLog__c();
        List<String> data = getJSONChunckedValues(requestBody);
        integer i = 0;
        for(String json:data){
            integrationLog.put('data'+i+'__c',json);
            i++;
        }
        return integrationLog;
    }

    public static List<String> getJSONChunckedValues(String body){
        List<String> data = new List<String>{'','','','','','','','','',''};
        if (body.length() <= SYS_Constants.TEXT_AREA_MAX_SIZE){
			data[0] = body;
            SYS_debug.log('json is in single data field');
        } else {
            SYS_debug.log('json needs chunking');
            Integer di = 0;
            String jsonSubStrng;
            Integer endIndex = SYS_Constants.TEXT_AREA_MAX_SIZE;
            String outboundJSON = body;
            do {
                jsonSubStrng = outboundJSON.substring(0,endIndex);
                outboundJSON = outboundJSON.substring(endIndex);
                SYS_debug.log('substr= '+outboundJSON+' index='+endIndex+' '+jsonSubStrng);
                endIndex = (outboundJSON.length() < SYS_Constants.TEXT_AREA_MAX_SIZE) ? outboundJSON.length() : SYS_Constants.TEXT_AREA_MAX_SIZE;
                data[di] = jsonSubStrng;
                di++;
                if(di == SYS_Constants.MAX_DATA_FIELDS - 1 && body.length() > SYS_Constants.TEXT_AREA_MAX_SIZE){
                    SYS_debug.log('JSON too large. Truncated');
                    break;
                }
            } while (outboundJSON.length() > 0);
        }
        return data;
    }

    public static string getHashOfRecord(String toHash) {  
        String targetString = toHash;
        SYS_debug.log('str is==' + toHash);
        Blob targetBlob = Blob.valueOf(targetString);
        // Generate SHA1 digest
        Blob hashSHA1 = Crypto.generateDigest('SHA3-512', targetBlob);
        // For Rackspace Compatiblity encode the binary into BASE 64
        // this will result in 28 chars long string 
        String hashBase64SHA1 = EncodingUtil.base64encode (hashSHA1);
        SYS_debug.log('hash=='+hashBase64SHA1);

        return hashBase64SHA1;
    }
}