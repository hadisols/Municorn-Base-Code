@isTest
public class SYS_OAuthRedirectHandlerTest {
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
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SYS_Municorn_Permission_Set'];
        System.debug('user id '+u.id);
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);

        return u;
    }

    @IsTest
    static void testAuthorizationCodeFlow(){
        
        //String body = SYS_TestUtil.getMockBody();
        Test.setMock(HttpCalloutMock.class, SYS_MockServer.startServer());
        System.runAs(getUser()) {
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

       
    }

    @IsTest
    static void testAuthCodeFlowNon2xx(){
        Test.setMock(HttpCalloutMock.class, SYS_MockServer.stopServer());
        System.runAs(getUser()) {
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


}