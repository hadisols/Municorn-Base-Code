@isTest
public class SYS_InboundTest {
    @TestSetup
    static void makeData(){
        
    }

    @IsTest
    static void testPost(){
        
        String body = SYS_TestUtil.getMockBody();

        RestRequest request = new RestRequest();
        RestResponse actualres = new RestResponse();
        request.requestURI = '/municorn/v1/SYS_Test_IntegrationSetting';
        request.addParameter('token', '9LR99107DF7343549');
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;

        Test.startTest();
        SYS_Webservice.postRequest();
        request.addParameter('token', 'incorrect_token');
        SYS_Webservice.postRequest();
        Test.stopTest();

        List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
        System.assert(log.size()>0);
        
    }

    @IsTest
    static void testPost_AuthorizeDotNet(){
        
        String body = SYS_TestUtil.getMockBody();

        RestRequest request = new RestRequest();
        RestResponse actualres = new RestResponse();
        request.requestURI = '/municorn/v1/Authorize';
        request.addParameter('token', '9LR99107DF7343549');
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;

        Test.startTest();
        SYS_Webservice.postRequest();
        request.addParameter('token', 'incorrect_token');
        SYS_Webservice.postRequest();
        Test.stopTest();

        List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
        System.assert(log.size()>0);
        
    }

    @IsTest
    static void testGet(){
        
        String body = SYS_TestUtil.getMockBody();

        RestRequest request = new RestRequest();
        RestResponse actualres = new RestResponse();
        request.requestURI = '/municorn/v1/SYS_Test_IntegrationSetting';
        request.addParameter('token', '9LR99107DF7343549');
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;

        Test.startTest();
        SYS_Webservice.getRequest();
        request.addParameter('token', 'incorrect_token');
        SYS_Webservice.getRequest();
        Test.stopTest();

        List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
        System.assert(log.size()>0);
        
    }

    @IsTest
    static void testPut(){
        
        String body = SYS_TestUtil.getMockBody();

        RestRequest request = new RestRequest();
        RestResponse actualres = new RestResponse();
        request.requestURI = '/municorn/v1/SYS_Test_IntegrationSetting';
        request.addParameter('token', '9LR99107DF7343549');
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;

        Test.startTest();
        SYS_Webservice.putRequest();
        request.addParameter('token', 'incorrect_token');
        SYS_Webservice.putRequest();
        Test.stopTest();

        List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
        System.assert(log.size()>0);
        
    }

    @IsTest
    static void testPatch(){
        
        String body = SYS_TestUtil.getMockBody();

        RestRequest request = new RestRequest();
        RestResponse actualres = new RestResponse();
        request.requestURI = '/municorn/v1/SYS_Test_IntegrationSetting';
        request.addParameter('token', '9LR99107DF7343549');
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;

        Test.startTest();
        SYS_Webservice.patchRequest();
        request.addParameter('token', 'incorrect_token');
        SYS_Webservice.patchRequest();
        Test.stopTest();

        List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
        System.assert(log.size()>0);
        
    }

    @IsTest
    static void testDelete(){
        
        String body = SYS_TestUtil.getMockBody();

        RestRequest request = new RestRequest();
        RestResponse actualres = new RestResponse();
        request.requestURI = '/municorn/v1/SYS_Test_IntegrationSetting';
        request.addParameter('token', '9LR99107DF7343549');
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;

        Test.startTest();
        SYS_Webservice.deleteRequest();
        request.addParameter('token', 'incorrect_token');
        SYS_Webservice.deleteRequest();
        Test.stopTest();

        List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
        System.assert(log.size()>0);
        
    }

    @IsTest
    static void testLargeDataLog(){

        String body = SYS_TestUtil.getLargeMockBody();
      
        RestRequest request = new RestRequest();
        RestResponse actualres = new RestResponse();
        request.requestURI = '/municorn/v1/SYS_Test_IntegrationSetting';
        request.addParameter('token', '9LR99107DF7343549');
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;

        Test.startTest();
        SYS_Webservice.postRequest();
        Test.stopTest();

        List<SYS_IntegrationLog__c> log = [SELECT Id,data1__c FROM SYS_IntegrationLog__c];
        System.assert(log.size()>0);
        System.assertNotEquals(NULL, log[0].data1__c);
    }

    @IsTest
    static void testLogUpdateForProcessing(){

        SYS_TestDataFactory.createIgnoreLog();
        List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c LIMIT 1];
        log[0].Type__c = 'INBOUND';
        log[0].Status__c = 'READY_FOR_PROCESSING';
        update log;
    }

}