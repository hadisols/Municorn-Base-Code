@isTest
public class processRefundTest {
    @TestSetup
    static void makeData(){
        String intentId = SYS_TestDataFactory.createPaymentIntent(1);
        Transaction__c tran = new Transaction__c(
            Transaction_Id__c = '2382938293',
            Amount__c = 100.00,
            Payment_Intent__c = intentId
        );
        insert tran;
    }

    @isTest 
    static void refundTest() {
        List<Payment_Intent__c> intent = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, athrz_uuid__c, Athrz_Amount__c, Athrz_Account__c, Athrz_Currency_Code__c, Athrz_Email__c, Athrz_First_Charge_Date__c, Athrz_Payment_Link__c, Athrz_PaymentType__c, Athrz_Scheduled_Payment__c, Status__c, Transaction__c, Athrz_Data_Value__c, Athrz_Reference_Id__c, Payment_Gateway__c, Athrz_Ref_Id__c, Athrz_Payment_Profile__c, Athrz_Payment_Method__c, Custom_Invoice__c, Athrz_Frequency__c, Account_Type__c, Account_Routing_Number__c, Bank_Account_Number__c, Name_on_Account__c FROM Payment_Intent__c LIMIT 1];
        Account acc = [select id from Account limit 1];
        Payment_Gateway__c gateway = [select id, Athrz_Transaction_Key__c,Athrz_Api_Login_Id__c from Payment_Gateway__c limit 1];

        Athrz_processRefund.MyInvocableVariable var = new Athrz_processRefund.MyInvocableVariable();
        var.amount = 100;
        var.cardNumber = '2138';
        var.gatewayId = gateway.id;
        var.intent = intent[0];
        var.transactionId = '82349238';
        List<Athrz_processRefund.MyInvocableVariable> vars = new List<Athrz_processRefund.MyInvocableVariable>{var};

        Test.setMock(HTTPCalloutMock.class, SYS_MockServer.transaction());
        Test.startTest();
        Athrz_processRefund.processRefund(vars);
        Test.stopTest();

    }
}
