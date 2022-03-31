@isTest
public class PaymentFormControllerTest {
    @TestSetup
    static void makeData(){
        String intentId = SYS_TestDataFactory.createPaymentIntent(1);
    }
    @isTest 
    static void pageInitTest_newPayment() {
        List<Payment_Intent__c> intent = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, athrz_uuid__c, Athrz_Amount__c, Athrz_Account__c, Athrz_Currency_Code__c, Athrz_Email__c, Athrz_First_Charge_Date__c, Athrz_Payment_Link__c, Athrz_PaymentType__c, Athrz_Scheduled_Payment__c, Status__c, Transaction__c, Athrz_Data_Value__c, Athrz_Reference_Id__c, Payment_Gateway__c, Athrz_Ref_Id__c, Athrz_Payment_Profile__c, Athrz_Payment_Method__c, Custom_Invoice__c, Athrz_Frequency__c, Account_Type__c, Account_Routing_Number__c, Bank_Account_Number__c, Name_on_Account__c FROM Payment_Intent__c LIMIT 1];
        
        PageReference pageRef = Page.PaymentForm;
        pageRef.getParameters().put('t', intent[0].athrz_uuid__c);
        Test.setCurrentPage(pageRef);

        PaymentFormController form = new PaymentFormController();
        form.initPage();
        Test.setMock(HttpCalloutMock.class, SYS_MockServer.transaction());

        form.paymentToken = 'sample';
        form.isCreditcard = true;
        form.savePayment = true;
        form.saveAsDefault = true;
        form.isPaymentMethod = false;

        Test.startTest();
        form.charge();
        Test.stopTest();
    }

    @isTest 
    static void pageInitTest_newPayment_bankPayment() {
        List<Payment_Intent__c> intent = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, athrz_uuid__c, Athrz_Amount__c, Athrz_Account__c, Athrz_Currency_Code__c, Athrz_Email__c, Athrz_First_Charge_Date__c, Athrz_Payment_Link__c, Athrz_PaymentType__c, Athrz_Scheduled_Payment__c, Status__c, Transaction__c, Athrz_Data_Value__c, Athrz_Reference_Id__c, Payment_Gateway__c, Athrz_Ref_Id__c, Athrz_Payment_Profile__c, Athrz_Payment_Method__c, Custom_Invoice__c, Athrz_Frequency__c, Account_Type__c, Account_Routing_Number__c, Bank_Account_Number__c, Name_on_Account__c FROM Payment_Intent__c LIMIT 1];
        
        PageReference pageRef = Page.PaymentForm;
        pageRef.getParameters().put('t', intent[0].athrz_uuid__c);
        Test.setCurrentPage(pageRef);

        PaymentFormController form = new PaymentFormController();
        form.initPage();
        Test.setMock(HttpCalloutMock.class, SYS_MockServer.transaction());

        form.paymentToken = 'sample';
        form.isCreditcard = false;
        form.savePayment = true;
        form.saveAsDefault = true;
        form.isPaymentMethod = false;
        form.nameOnAccount = 'John Doe';
        form.accountNumber = '23892389283';
        form.accountRoutingNumber = '23923829382';
        form.accountType = 'savings';

        form.updateIntentBankDetails();
        Test.startTest();
        form.charge();
        Test.stopTest();
    }

    @isTest 
    static void pageInitTest_payment_done() {
        List<Payment_Intent__c> intent = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, athrz_uuid__c, Athrz_Amount__c, Athrz_Account__c, Athrz_Currency_Code__c, Athrz_Email__c, Athrz_First_Charge_Date__c, Athrz_Payment_Link__c, Athrz_PaymentType__c, Athrz_Scheduled_Payment__c, Status__c, Transaction__c, Athrz_Data_Value__c, Athrz_Reference_Id__c, Payment_Gateway__c, Athrz_Ref_Id__c, Athrz_Payment_Profile__c, Athrz_Payment_Method__c, Custom_Invoice__c, Athrz_Frequency__c, Account_Type__c, Account_Routing_Number__c, Bank_Account_Number__c, Name_on_Account__c FROM Payment_Intent__c LIMIT 1];
        intent[0].Status__c = 'payment_done';
        update intent;

        Transaction__c tran = new Transaction__c(
            Transaction_Id__c = '2382938293',
            Amount__c = 100.00,
            Payment_Intent__c = intent[0].Id
        );
        insert tran;

        PageReference pageRef = Page.PaymentForm;
        pageRef.getParameters().put('t', intent[0].athrz_uuid__c);
        Test.setCurrentPage(pageRef);

        PaymentFormController form = new PaymentFormController();
        form.initPage();
        Test.setMock(HttpCalloutMock.class, SYS_MockServer.transaction());

        form.paymentToken = 'sample';
        form.isCreditcard = true;
        form.savePayment = true;
        form.saveAsDefault = true;
        form.isPaymentMethod = false;

        Test.startTest();
        form.charge();
        Test.stopTest();
    }
}
