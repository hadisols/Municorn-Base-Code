@isTest
public class SYS_OAuthRedirectHandlerTest {
    @TestSetup
    static void makeData(){
        SYS_TestDataFactory.createTestRecordsFromStaticResource();
    }

    @IsTest
    static void testAuthorizationCodeFlow(){
        
        //String body = SYS_TestUtil.getMockBody();
        Test.setMock(HttpCalloutMock.class, SYS_MockServer.startServer());

        RestRequest request = new RestRequest();
        RestResponse actualres = new RestResponse();
        request.requestURI = 'services/apexrest/v1/callback';
        request.addParameter('code', 'authcode1234');

        List<SYS_OAuthConfig__c> configs = [SELECT Id FROM SYS_OAuthConfig__c WHERE Grant_Type__c = 'authorization_code' LIMIT 1];
        request.addParameter('state', configs[0].Id);
        //request.requestBody = Blob.valueOf(body);
        RestContext.request = request;
        RestContext.response = actualres;

        Test.startTest();
        SYS_OAuthRedirectHandler.doGet();
        Test.stopTest();

        List<SYS_IntegrationLog__c> log = [SELECT Id,Status__c FROM SYS_IntegrationLog__c WHERE Status__c = 'DONE'];
        System.assert(log.size()>0);

       
    }

    @IsTest
    static void testAuthCodeFlowNon2xx(){
        Test.setMock(HttpCalloutMock.class, SYS_MockServer.stopServer());

        RestRequest request = new RestRequest();
        RestResponse actualres = new RestResponse();
        request.requestURI = 'services/apexrest/v1/callback';
        request.addParameter('code', 'authcode1234');

        List<SYS_OAuthConfig__c> configs = [SELECT Id FROM SYS_OAuthConfig__c WHERE Grant_Type__c = 'authorization_code' LIMIT 1];
        request.addParameter('state', configs[0].Id);
        //request.requestBody = Blob.valueOf(body);
        RestContext.request = request;
        RestContext.response = actualres;

        Test.startTest();
        SYS_OAuthRedirectHandler.doGet();
        Test.stopTest();

        List<SYS_IntegrationLog__c> log = [SELECT Id,Status__c FROM SYS_IntegrationLog__c WHERE Status__c = 'FAIL'];
        System.assert(log.size()>0);
        
    }


}