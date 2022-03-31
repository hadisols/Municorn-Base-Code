@isTest
public class ChargeControllerTest {
    @isTest
    static void getObjectDetails_positive() {
        String intentId = SYS_TestDataFactory.createPaymentIntent(1);

        ChargeController.ObjectDetails details = ChargeController.getObjectDetails(intentId, 'Athrz_Account__c');
        System.assert(details.record != null);
        System.assert(details.accountRecord != null);
    }
    @isTest
    static void getObjectDetails_negativeforAccount() {
        String intentId = SYS_TestDataFactory.createPaymentIntent(1);
        ChargeController.ObjectDetails details = new ChargeController.ObjectDetails();
        try {
            details = ChargeController.getObjectDetails(intentId, '');
        } catch(Exception e) {

        }
        System.assert(details.record == null);
        System.assert(details.accountRecord == null);
    }

    @isTest
    static void getObjectDetails_positiveforAccount() {
        SYS_TestDataFactory.createTestRecords(1,1);
        Account acc = [SELECT Id FROM Account LIMIT 1];
        ChargeController.ObjectDetails details = new ChargeController.ObjectDetails();
        try {
            details = ChargeController.getObjectDetails(acc.Id, '');
        } catch(Exception e) {

        }
        System.assert(details.record != null);
        System.assert(details.accountRecord != null);
    }

    @isTest
    static void syncPaymentMethod_positive(){
        String intentId = SYS_TestDataFactory.createPaymentIntent(1);
        Test.setMock(HttpCalloutMock.class, SYS_MockServer.paymentMethod());
        Account acc = [select id from Account limit 1];
        Payment_Gateway__c gateway = [select id, Athrz_Transaction_Key__c,Athrz_Api_Login_Id__c from Payment_Gateway__c limit 1];
        System.debug('gateway '+ gateway);

        Test.startTest();
        ChargeController.loadPaymentMethod(acc.Id, gateway.Id);
        Test.stopTest();
    }

    @isTest 
    static void getPaymentGateway_positive() {
        String intentId = SYS_TestDataFactory.createPaymentIntent(1);
        Payment_Gateway__c gateway = [select id, Athrz_Transaction_Key__c,Athrz_Api_Login_Id__c from Payment_Gateway__c limit 1];
        ChargeController.getPaymentGateway(gateway.id);
    }

    @isTest 
    static void createTransaction_positive() {
        String intentId = SYS_TestDataFactory.createPaymentIntent(1);
        Test.setMock(HttpCalloutMock.class, SYS_MockServer.transaction());
        Payment_Gateway__c gateway = [select id, Athrz_Transaction_Key__c,Athrz_Api_Login_Id__c from Payment_Gateway__c limit 1];
        Account acc = [select id from Account limit 1];
        Athrz_utility.Payload payload= new Athrz_utility.Payload();
        payload.savePayment = true;
        payload.saveAsDefault = true;
        payload.token = 'sample';

        Test.startTest();
        ChargeController.createTransaction(intentId, gateway.id, 'Payment_Intent', payload, acc.Id, 23);
        Test.stopTest();

        List<Transaction__c> tran = [select id from Transaction__c ];
        System.assert(tran.size() > 0);
    }

    @isTest 
    static void createTransaction_negative() {
        String intentId = SYS_TestDataFactory.createPaymentIntent(1);
        Test.setMock(HttpCalloutMock.class, SYS_MockServer.transaction());
        Payment_Gateway__c gateway = [select id, Athrz_Transaction_Key__c,Athrz_Api_Login_Id__c from Payment_Gateway__c limit 1];
        Account acc = [select id from Account limit 1];
        Athrz_utility.Payload payload= new Athrz_utility.Payload();
        payload.savePayment = true;
        payload.saveAsDefault = true;
        payload.token = 'sample';

        Test.startTest();
        try {
            ChargeController.createTransaction(intentId, '', 'Payment_Intent_Bank', payload, acc.Id, 23);
        } catch(Exception e) {

        }
        Test.stopTest();
        List<Transaction__c> tran = [select id from Transaction__c ];
        System.assert(tran.size() == 0);
    }

    @isTest 
    static void createPaymentMethod_positive() {
        String intentId = SYS_TestDataFactory.createPaymentIntent(1);
        Test.setMock(HttpCalloutMock.class, SYS_MockServer.paymentMethodCreate());
        Payment_Gateway__c gateway = [select id, Athrz_Transaction_Key__c,Athrz_Api_Login_Id__c from Payment_Gateway__c limit 1];
        Account acc = [select id from Account limit 1];
        Athrz_utility.Payload payload= new Athrz_utility.Payload();
        payload.savePayment = true;
        payload.saveAsDefault = true;

        Test.startTest();
        ChargeController.createPaymentMethod('1234', acc.Id, gateway.id, payload);
        Test.stopTest();

        List<Payment_Method__c> method = [SELECT Id, Profile_Id__c FROM Payment_Method__c];
        System.assert(method.size() > 0);
        System.assert(method[0].Profile_Id__c == '157500');
    }

    @isTest 
    static void createPaymentMethod_negative() {
        String intentId = SYS_TestDataFactory.createPaymentIntent(1);
        Test.setMock(HttpCalloutMock.class, SYS_MockServer.paymentMethodCreate());
        Payment_Gateway__c gateway = [select id, Athrz_Transaction_Key__c,Athrz_Api_Login_Id__c from Payment_Gateway__c limit 1];
        Account acc = [select id from Account limit 1];
        Athrz_utility.Payload payload= new Athrz_utility.Payload();
        payload.savePayment = true;
        payload.saveAsDefault = true;

        Test.startTest();
        try{
            ChargeController.createPaymentMethod('1234', '', gateway.id, payload);
        } catch(Exception e) {

        }
        
        Test.stopTest();
        List<Payment_Method__c> method = [SELECT Id, Profile_Id__c FROM Payment_Method__c];
        System.assert(method.size() == 0);
        
    }

    @isTest
    static void createPaymentIntent_positive_with_getPaymentMethods() {
        String intentId = SYS_TestDataFactory.createPaymentIntent(1);
        Account acc = [select id from Account limit 1];
        Athrz_utility.Payload payload= new Athrz_utility.Payload();
        payload.savePayment = true;
        payload.saveAsDefault = true;
        payload.isCreditCard = true;
        Payment_Gateway__c gateway = [select id, Athrz_Transaction_Key__c,Athrz_Api_Login_Id__c from Payment_Gateway__c limit 1];

        Athrz_utility.ChargeRequest chargeReq = new Athrz_utility.ChargeRequest();
        chargeReq.accountId = acc.Id;
        chargeReq.intentName = 'Sample invoice';
        chargeReq.frequency = 'single';
        chargeReq.emailId = 'abc@xyz.com';
        chargeReq.firstChargeDate = Date.today();
        chargeReq.paymentType = 'immediate';
        chargeReq.gatewayId = gateway.Id;
        chargeReq.intentParentApiName = 'Athrz_Account__c';
        chargeReq.LookUp = acc.Id;
        chargeReq.amount = 100;

        List<Athrz_utility.ChargeRequest> requests = new List<Athrz_utility.ChargeRequest>{chargeReq};
        ChargeController.createPaymentIntent(payload, requests);
        ChargeController.getPaymentMethods(acc.Id);

        List<Payment_Intent__c> intent = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, athrz_uuid__c, Athrz_Amount__c, Athrz_Account__c, Athrz_Currency_Code__c, Athrz_Email__c, Athrz_First_Charge_Date__c, Athrz_Payment_Link__c, Athrz_PaymentType__c, Athrz_Scheduled_Payment__c, Status__c, Transaction__c, Athrz_Data_Value__c, Athrz_Reference_Id__c, Payment_Gateway__c, Athrz_Ref_Id__c, Athrz_Payment_Profile__c, Athrz_Payment_Method__c, Custom_Invoice__c, Athrz_Frequency__c, Account_Type__c, Account_Routing_Number__c, Bank_Account_Number__c, Name_on_Account__c FROM Payment_Intent__c LIMIT 1];

        System.assert(intent.size() > 0);

    }

    
    @isTest 
    static void sendCheckoutEmail_positive() {
        String intentId = SYS_TestDataFactory.createPaymentIntent(1);
        Account acc = [select id from Account limit 1];
        Payment_Gateway__c gateway = [select id, Athrz_Transaction_Key__c,Athrz_Api_Login_Id__c from Payment_Gateway__c limit 1];

        Athrz_utility.ChargeRequest chargeReq = new Athrz_utility.ChargeRequest();
        chargeReq.accountId = acc.Id;
        chargeReq.intentName = 'Sample invoice';
        chargeReq.frequency = 'single';
        chargeReq.emailId = 'abc@xyz.com';
        chargeReq.firstChargeDate = Date.today();
        chargeReq.paymentType = 'immediate';
        chargeReq.gatewayId = gateway.Id;
        chargeReq.intentParentApiName = 'Athrz_Account__c';
        chargeReq.LookUp = acc.Id;
        chargeReq.amount = 100;

        List<Athrz_utility.ChargeRequest> requests = new List<Athrz_utility.ChargeRequest>{chargeReq};
        ChargeController.sendCheckoutEmail(requests);
    }

    @isTest 
    static void sendCheckoutEmail_negative() {
        String intentId = SYS_TestDataFactory.createPaymentIntent(1);
        Account acc = [select id from Account limit 1];
        Payment_Gateway__c gateway = [select id, Athrz_Transaction_Key__c,Athrz_Api_Login_Id__c from Payment_Gateway__c limit 1];

        Athrz_utility.ChargeRequest chargeReq = new Athrz_utility.ChargeRequest();
        chargeReq.accountId = acc.Id;
        chargeReq.intentName = 'Sample invoice';
        chargeReq.frequency = 'single';
        // chargeReq.emailId = 'abc@xyz.com';
        chargeReq.firstChargeDate = Date.today();
        chargeReq.paymentType = 'immediate';
        chargeReq.gatewayId = gateway.Id;
        chargeReq.intentParentApiName = 'Athrz_Account__c';
        chargeReq.LookUp = acc.Id;
        chargeReq.amount = 100;

        List<Athrz_utility.ChargeRequest> requests = new List<Athrz_utility.ChargeRequest>{chargeReq};
        try{
            ChargeController.sendCheckoutEmail(requests);
        } catch(Exception e) {
            
        }
        
    }

    @isTest 
    static void createSubscription_positive() {
        String intentId = SYS_TestDataFactory.createPaymentIntent(1);
        Account acc = [select id from Account limit 1];
        Payment_Gateway__c gateway = [select id, Athrz_Transaction_Key__c,Athrz_Api_Login_Id__c from Payment_Gateway__c limit 1];
        Athrz_utility.Payload payload= new Athrz_utility.Payload();
        payload.savePayment = true;
        payload.saveAsDefault = true;
        payload.isCreditCard = true;

        Athrz_utility.ChargeRequest chargeReq = new Athrz_utility.ChargeRequest();
        chargeReq.accountId = acc.Id;
        chargeReq.intentName = 'Sample invoice';
        chargeReq.frequency = 'single';
        chargeReq.emailId = 'abc@xyz.com';
        chargeReq.firstChargeDate = Date.today();
        chargeReq.paymentType = 'subscription';
        chargeReq.gatewayId = gateway.Id;
        chargeReq.intentParentApiName = 'Account__c';
        chargeReq.subscriptionParentApiName = 'Account__c';
        chargeReq.LookUp = acc.Id;
        chargeReq.amount = 100;

        List<Athrz_utility.ChargeRequest> requests = new List<Athrz_utility.ChargeRequest>{chargeReq};
        ChargeController.createSubscription(payload, requests);
        List<Subscription__c> subs = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Payment_Gatway_Customer__c, Account__c, Payment_Method__c, Payment_Gateway__c, Athrz_Start_Date__c, Athrz_Occurrence__c, Trail_Occurrence__c, Athrz_Trail_Amount__c, Athrz_Ref_Id__c, Athrz_Interval_Length__c, Athrz_Interval_Unit__c, Athrz_Amount__c, Athrz_Data_Value__c, Athrz_First_Name__c, Athrz_Last_Name__c, Athrz_Company_Name__c, Athrz_Address__c, Athrz_City__c, Athrz_State__c, Athrz_Zip_Code__c, Athrz_Country__c, Athrz_uuid__c, Frequency__c, Athrz_Subscription_Id__c, Custom_Invoice__c FROM Subscription__c];

        Test.setMock(HttpCalloutMock.class, SYS_MockServer.paymentSubscription());
        Test.startTest();
        ChargeController.requestSubscription(subs[0].Id, gateway.Id, 'Subscription', payload, acc.Id, 100);
        Test.stopTest();
    }
}