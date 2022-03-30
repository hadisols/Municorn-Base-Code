@IsTest
private class SYS_QB_ApplicationServiceOutboundTest {
@IsTest
    private static void transformJsonToSObjecttest(){
       
        
        
            Account a = new Account(Name='Municorn Test Account');
           
        
        insert a;
        SYS_IntegrationLog__c  newSysLog = new SYS_IntegrationLog__c();
        newSysLog.Status__c = 'NEW';
        newSysLog.data0__c = '{"Customer":{"Taxable":true,"Job":false,"BillWithParent":false,"Balance":0,"BalanceWithJobs":0,"CurrencyRef":{"value":"USD","name":"United States Dollar"},"PreferredDeliveryMethod":"Print","IsProject":false,"domain":"QBO","sparse":false,"Id":"450","SyncToken":"0","MetaData":{"CreateTime":"2022-03-30T07:58:44-07:00","LastUpdatedTime":"2022-03-30T07:58:44-07:00"},"FullyQualifiedName":"displayname","DisplayName":"displayname","PrintOnCheckName":"displayname","Active":true,"DefaultTaxCodeRef":{"value":"6"}},"time":"2022-03-30T07:58:53.110-07:00"}';
        newSysLog.Type__c = 'INBOUND';
        newSysLog.Integration_Setting__c = 'Quickbooks';
        newSysLog.SYS_Operation_Type__c = 'INSERT';
        newSysLog.whatid__c = a.Id;
        newSysLog.ObjectSettingId__c = 'AccountQB';
        newSysLog.How_to_process__c = 'use_custom_apex_handler';
        newSysLog.Custom_Apex_Handler__c = 'SYS_QB_ApplicationServiceinbound';
        newSysLog.Resource__c = 'customer';
        insert newSysLog;
    
        
      
        List<SYS_IntegrationLog__c> log = [SELECT Id,Type__c FROM SYS_IntegrationLog__c LIMIT 1];
        string resource = 'customer';
        string jsonBody = '{"Customer":{"Taxable":true,"Job":false,"BillWithParent":false,"Balance":0,"BalanceWithJobs":0,"CurrencyRef":{"value":"USD","name":"United States Dollar"},"PreferredDeliveryMethod":"Print","IsProject":false,"domain":"QBO","sparse":false,"Id":"450","SyncToken":"0","MetaData":{"CreateTime":"2022-03-30T07:58:44-07:00","LastUpdatedTime":"2022-03-30T07:58:44-07:00"},"FullyQualifiedName":"displayname","DisplayName":"displayname","PrintOnCheckName":"displayname","Active":true,"DefaultTaxCodeRef":{"value":"6"}},"time":"2022-03-30T07:58:53.110-07:00"}';
                SYS_QB_ApplicationServiceOutbound Qbinb = new SYS_QB_ApplicationServiceOutbound();
        Qbinb.transformJsonToSObject(jsonBody, resource, log[0]);
      
    }
}