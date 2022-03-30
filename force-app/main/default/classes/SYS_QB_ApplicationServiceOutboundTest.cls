@IsTest
private class SYS_QB_ApplicationServiceOutboundTest {
@IsTest
    private static void transformJsonToSObjecttest(){
        
        
        SYS_TestDataFactory.createObjectSettingLog();
        List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c LIMIT 1];
        string resource = 'customer';
        string jsonBody = '{"Customer":{"Taxable":true,"Job":false,"BillWithParent":false,"Balance":0,"BalanceWithJobs":0,"CurrencyRef":{"value":"USD","name":"United States Dollar"},"PreferredDeliveryMethod":"Print","IsProject":false,"domain":"QBO","sparse":false,"Id":"443","SyncToken":"0","MetaData":{"CreateTime":"2022-03-29T13:12:01-07:00","LastUpdatedTime":"2022-03-29T13:12:01-07:00"},"Title":"Mr.","FullyQualifiedName":"testtest1234567","DisplayName":"testtest1234567","PrintOnCheckName":"Mr.","Active":true,"DefaultTaxCodeRef":{"value":"6"}},"time":"2022-03-29T13:55:25.155-07:00"}';
         SYS_QB_ApplicationServiceOutbound Qbinb = new SYS_QB_ApplicationServiceOutbound();
        Qbinb.transformJsonToSObject(jsonBody, resource, log[0]);
      
    }
}