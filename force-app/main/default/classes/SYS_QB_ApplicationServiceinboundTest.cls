@IsTest
private class SYS_QB_ApplicationServiceinboundTest {
@IsTest
    private static void transformJsonToSObject(){
        test.startTest();
         SYS_TestDataFactory.createIgnoreLog();
        List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c LIMIT 1];
        system.debug('log'+log[0].Type__c);
        string resource = 'Customer';
        string jsonBody = '{\"Name\":\"Municorn Test Account\"}';
        SYS_QB_ApplicationServiceinbound Qbinb = new SYS_QB_ApplicationServiceinbound();
        Qbinb.transformJsonToSObject(jsonBody, resource, log[0]);
      test.stopTest();
    }
            
}