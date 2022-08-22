@isTest
public without sharing class SYS_JWTAuth_ApplicationServiceTest {
    @TestSetup
    static void makeData(){
        SYS_TestDataFactory.createTestRecordsFromStaticResource();
    }

    @IsTest
    static void testJWTFlow(){
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

    @IsTest
    static void testJWTFlowNon2xx(){
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