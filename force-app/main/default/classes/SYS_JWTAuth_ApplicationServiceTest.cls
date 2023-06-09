@isTest
public without sharing class SYS_JWTAuth_ApplicationServiceTest {
    @TestSetup
    static void makeData(){
        SYS_TestDataFactory.createTestRecordsFromStaticResource();
    }

    static User getUser() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        insert u;
        String namespaceprefix = SYS_datacache.namespacePrefix;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SYS_Municorn_Permission_Set' AND namespaceprefix =:namespaceprefix ];
        System.debug('user id '+u.id);
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);

        return u;
    }

    @IsTest
    static void testJWTFlow(){
        System.runAs(getUser()) {
            List<SYS_OAuthConfig__c> oauthConfigs = [SELECT Id FROM SYS_OAuthConfig__c];

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, SYS_MockServer.startServer());
            for(sObject auth:oauthConfigs){
                SYS_JWTAuth_ApplicationService.invokeTokenFlow(auth.Id);
            }
            Test.stopTest();

            List<SYS_IntegrationLog__c> log = [SELECT Id,Status__c FROM SYS_IntegrationLog__c];
            System.assert(log.size()>0);
        }
    }

    @IsTest
    static void testJWTFlowNon2xx(){
        System.runAs(getUser()) {
            List<SYS_OAuthConfig__c> oauthConfigs = [SELECT Id FROM SYS_OAuthConfig__c];

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, SYS_MockServer.stopServer());
            for(sObject auth:oauthConfigs){
                SYS_JWTAuth_ApplicationService.invokeTokenFlow(auth.Id);
            }
            Test.stopTest(); 

            List<SYS_IntegrationLog__c> log = [SELECT Id,Status__c FROM SYS_IntegrationLog__c];
            System.assert(log.size()>0);
        }
        
    }
}