public with sharing class ChargeController {
    
    @AuraEnabled
    public static ObjectDetails getObjectDetails(String objectId, String accountLookupApiName) {
        System.debug('object-details');
        ObjectDetails details = new ObjectDetails();
        try {
            if(accountLookupApiName == '') {
                String accountQuery = 'SELECT '+ SYS_Helper.getAllFieldsFor('Account') + ' FROM Account ' +
                ' WHERE Id =:objectId';
                sObject accountRecord = Database.query(accountQuery);
    
                details.record = accountRecord;
                details.accountRecord = accountRecord;
            } else {
                String sObjectApiName = ((Id)objectId).getSObjectType().getDescribe().getName() + '';
                String objectQuery = 'SELECT '+ SYS_Helper.getAllFieldsFor(sObjectApiName) + ' FROM ' + sObjectApiName +
                                        ' WHERE Id =:objectId';
                System.debug('objectQuery '+objectQuery);
                sObject objectRecord = Database.query(objectQuery);
                String accountId = objectRecord.get(accountLookupApiName) + '';
                String accountQuery = 'SELECT '+ SYS_Helper.getAllFieldsFor('Account') + ' FROM ' + 'Account' +
                ' WHERE Id =:accountId';
                System.debug('accountQuery '+accountQuery);
                sObject accountRecord = Database.query(accountQuery);
    
                details.record = objectRecord;
                details.accountRecord = accountRecord;
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return details;
    }

    public class ObjectDetails {
        @AuraEnabled public Object record { get; set; }
        @AuraEnabled public Object accountRecord { get; set; }
    }

    @AuraEnabled
    public static void loadPaymentMethod(String accountId, String gatewayId) {
        SYS_DataCache.INT_TYPE = 'Authorize';
        SYS_DataCache.OBJ_TYPE = 'Athrz_Account';
        Athrz_utility.syncPaymentMethod(accountId, gatewayId);
    }

    @AuraEnabled
    public static List<Payment_Gateway__c> getPaymentGateway(String gatewayId) {
        List<Payment_Gateway__c> gateways = [SELECT Id, Name, Athrz_Active__c, Athrz_Api_Login_Id__c, Athrz_Base_Endpoint__c, Athrz_Public_Client_Key__c 
                                            FROM Payment_Gateway__c WHERE Id = :gatewayId];
        return gateways;
    }

    @AuraEnabled
    public static String createTransaction(String intentId, String gatewayId, String obj_type, Athrz_utility.Payload payload, String accountId, Decimal total) {
        try{
            System.debug(intentId+ ' '+gatewayId+' '+obj_type+' '+payload);
            Athrz_utility.savePayment = payload.savePayment != null ?payload.savePayment : false;
            Athrz_utility.saveAsDefault = payload.saveAsDefault != null ?payload.saveAsDefault : false;
            Athrz_utility.token = payload.token;
            Athrz_utility.amount = total;
            Athrz_utility.chargePayment(intentId, gatewayId, obj_type, accountId);
            Payment_Intent__c intent = new Payment_Intent__c(
                Id = intentId,
                Athrz_Amount__c = total
            );
            update intent;
        } catch(Exception e) {
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        
        return Athrz_utility.error;
    } 

    @AuraEnabled
    public static String requestSubscription(String subscriptionId, String gatewayId, String obj_type, Athrz_utility.Payload payload, String accountId, Decimal total) {
        try{
            System.debug(subscriptionId+ ' '+gatewayId+' '+obj_type+' '+payload);
            Athrz_utility.savePayment = payload.savePayment != null ?payload.savePayment : false;
            Athrz_utility.saveAsDefault = payload.saveAsDefault != null ?payload.saveAsDefault : false;
            Athrz_utility.token = payload.token;
            Athrz_utility.amount = total;
            Athrz_utility.subscribeRequest(subscriptionId, gatewayId, obj_type, accountId);
            Subscription__c sub = new Subscription__c(
                Id = subscriptionId,
                Athrz_Amount__c = total
            );
            update sub;
        } catch(Exception e) {
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }

        return Athrz_utility.error;
    }

    @AuraEnabled
    public static string createSubscription(Athrz_utility.Payload payload, List<Athrz_utility.ChargeRequest> chargeRequests){
        String subscriptionId;
        String nonce = payload.token;

        Subscription__c sub = new Subscription__c();
        Decimal total = 0.00;

        sub = Athrz_utility.getSubscription(chargeRequests[0]);
        sub.Athrz_uuid__c = UUIDGenerator.createId();
        sub.Athrz_Data_Value__c = payload.token;

        for(Athrz_utility.ChargeRequest chg : chargeRequests) {
            System.debug('req '+chg);
            if(chg.paymentType != 'immediate')
                total += chg.amount;
        }

        if(payload.isCreditCard) {
            total = (total * 1.0399).setScale(2);
        }
        sub.Athrz_Amount__c = total;

        try {
            insert sub;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        subscriptionId = sub.Id;
        return subscriptionId;
    }

    @AuraEnabled
    public static String createPaymentIntent(Athrz_utility.Payload payload, List<Athrz_utility.ChargeRequest> chargeRequests) {
        String intentId;
        String nonce = payload.token;
        Payment_Intent__c intent = new Payment_Intent__c();
        Decimal total = 0.00;

        intent = Athrz_utility.getPaymentIntent(chargeRequests[0]);
        intent.athrz_uuid__c = UUIDGenerator.createId();
        intent.Athrz_Data_Value__c = payload.token;

        intent.Name_on_Account__c = payload.nameOnAccount;
        intent.Bank_Account_Number__c = payload.accountNumber;
        intent.Account_Routing_Number__c = payload.accountRoutingNumber;
        intent.Account_Type__c = payload.accountType;

        for(Athrz_utility.ChargeRequest chg : chargeRequests) {
            System.debug('req '+chg);
            if(chg.paymentType == 'immediate')
                total += chg.amount;
        }

        if(payload.isCreditCard) {
            total = (total * 1.0399).setScale(2);
        }

        intent.Athrz_Amount__c = total;
        try { 
            insert intent;
            intentId = intent.Id;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return intentId;
    }

    @AuraEnabled
    public static List<Payment_Method__c> getPaymentMethods(String objectId) {
        System.debug('payment-methods');
        List<Payment_Method__c> paymentMethods = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, 
                                                    CreatedById, LastModifiedDate, LastModifiedById, 
                                                    SystemModstamp, Card_Number__c, Card_Type__c, 
                                                    Customer_Profile_Id__c, Profile_Id__c, Billing_City__c, 
                                                    Billing_Country__c, Billing_Email__c, Billing_First_Name__c, 
                                                    Billing_Last_Name__c, Billing_Phone__c, Billing_Postal_Code__c, 
                                                    Billing_Salutation__c, Billing_State__c, Billing_Street__c, 
                                                    Account__c , Athrz_Bank_Account_Number__c, Athrz_Bank_Account_Type__c 
                                                    FROM Payment_Method__c
                                                    WHERE Account__c = :objectId];
        
        return paymentMethods;
    }

    @AuraEnabled
    public static string sendCheckoutEmail(List<Athrz_utility.ChargeRequest> chargeRequests){
        String result = '';
        System.debug('email checkout');
        Date today = Date.today();
        Payment_Intent__c intent = new Payment_Intent__c();
        String uuid;

        Decimal total = 0.00;
        uuid = UUIDGenerator.createId();
        
        intent = Athrz_utility.getPaymentIntent(chargeRequests[0]);
        intent.athrz_uuid__c = uuid;
        
        for(Athrz_utility.ChargeRequest chg : chargeRequests) {
            total += chg.amount;
        }
        intent.Athrz_Amount__c = total.setScale(2);
        try {
            insert intent;
            result = Athrz_utility.sendEmail(uuid).success ?
                    ('Successfully sent payment request email to ' + intent.Athrz_Email__c ) :
                    ('Sending email failed to ' + intent.Athrz_Email__c + ', please try again!');
            
        } catch (Exception e) {
            System.debug('exception '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    
}