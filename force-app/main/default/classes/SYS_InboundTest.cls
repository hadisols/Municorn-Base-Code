@isTest
public class SYS_InboundTest {
    @TestSetup
    static void makeData(){
        
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
    static void testPost(){
        String body = SYS_TestUtil.getMockBody();
        System.runAs(getUser()) {

            SYS_TestDataFactory.createTestRecords(1, 1);
            List<account> accounts = [SELECT Id, UUID__c FROM Account LIMIT 1];
            
            System.debug('inte type before init '+SYS_DataCacheFactory.INT_TYPE);
            SYS_DataCacheFactory init = new SYS_DataCacheFactory(
                accounts[0].Id,
                'SYS_Test_IntegrationSetting', 
                SYS_DataCacheFactory.INT_TYPE,
                SYS_DataCacheFactory.OBJ_TYPE
            );
            
            RestRequest request = new RestRequest();
            RestResponse actualres = new RestResponse();
            request.requestURI = '/municorn/v1/SYS_Test_IntegrationSetting';
            request.addParameter('token', '9LR99107DF7343549');
            
            request.requestBody = Blob.valueOf(body);
            RestContext.request = request;

            Test.startTest();
            request.addParameter('key', '');
            try{
                SYS_Webservice.postRequest();
            } catch(Exception e) {
                System.assert(e.getMessage() != NULL);
            }
            request.addParameter('key', accounts[0].UUID__c);
            SYS_Webservice.postRequest();
            request.addParameter('token', 'incorrect_token');
            SYS_Webservice.postRequest();
            Test.stopTest();

            List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
            System.assert(log.size()>0);
        }
        
    }

    @IsTest
    static void testPost_failure_url(){
        String body = SYS_TestUtil.getMockBody();
        System.runAs(getUser()) {

            SYS_TestDataFactory.createTestRecords(1, 1);
            List<account> accounts = [SELECT Id, UUID__c FROM Account LIMIT 1];
            
            
            RestRequest request = new RestRequest();
            RestResponse actualres = new RestResponse();
            request.requestURI = '/municorn/v1/random_test_is,/&&^%%/';
            request.addParameter('token', '9LR99107DF7343549');
            
            request.requestBody = Blob.valueOf(body);
            RestContext.request = request;

            Test.startTest();
            request.addParameter('key', '');
            try{
                SYS_Webservice.postRequest();
            } catch(Exception e) {
                System.assert(e.getMessage() != NULL);
            }
            // request.addParameter('key', accounts[0].UUID__c);
            // SYS_Webservice.postRequest();
            // request.addParameter('token', 'incorrect_token');
            // SYS_Webservice.postRequest();
            Test.stopTest();

            List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
            System.assert(log.size() == 0);
        }
        
    }

    @IsTest
    static void testPost_failure_integrationSetting(){
        String body = SYS_TestUtil.getMockBody();
        System.runAs(getUser()) {

            SYS_TestDataFactory.createTestRecords(1, 1);
            List<account> accounts = [SELECT Id, UUID__c FROM Account LIMIT 1];
            
            
            RestRequest request = new RestRequest();
            RestResponse actualres = new RestResponse();
            request.requestURI = '/municorn/v1/SYS_Test_IntegrationSetting_Fail';
            request.addParameter('token', '9LR99107DF7343549');
            
            request.requestBody = Blob.valueOf(body);
            RestContext.request = request;

            Test.startTest();
            request.addParameter('key', '');
            try{
                SYS_Webservice.postRequest();
            } catch(Exception e) {
                System.assert(e.getMessage() != NULL);
            }
            // request.addParameter('key', accounts[0].UUID__c);
            // SYS_Webservice.postRequest();
            // request.addParameter('token', 'incorrect_token');
            // SYS_Webservice.postRequest();
            Test.stopTest();

            List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
            System.assert(log.size() == 0);
        }
        
    }

    
    @IsTest
    static void testGet(){
        String body = SYS_TestUtil.getMockBody();
        System.runAs(getUser()) {
            

            SYS_TestDataFactory.createTestRecords(1, 1);
            List<account> accounts = [SELECT Id, UUID__c FROM Account LIMIT 1];
            
            RestRequest request = new RestRequest();
            RestResponse actualres = new RestResponse();
            request.requestURI = '/municorn/v1/SYS_Test_IntegrationSetting';
            request.addParameter('token', '9LR99107DF7343549');
            
            request.requestBody = Blob.valueOf(body);
            RestContext.request = request;

            Test.startTest();
            request.addParameter('key', '');
            try{
                SYS_Webservice.getRequest();
            } catch(Exception e) {
                System.assert(e.getMessage() != NULL);
            }
            request.requestURI = '/municorn/v1/SYS_Test_IntegrationSetting';
            request.addParameter('key', accounts[0].UUID__c);
            SYS_Webservice.getRequest();
            request.addParameter('token', 'incorrect_token');
            SYS_Webservice.getRequest();
            Test.stopTest();

            List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
            System.assert(log.size()>0);
        }
    }

    @IsTest
    static void testPut(){
        String body = SYS_TestUtil.getMockBody();
        System.runAs(getUser()) {
            SYS_TestDataFactory.createTestRecords(1, 1);
            List<account> accounts = [SELECT Id, UUID__c FROM Account LIMIT 1];
            
            RestRequest request = new RestRequest();
            RestResponse actualres = new RestResponse();
            request.requestURI = '/municorn/v1/SYS_Test_IntegrationSetting';
            request.addParameter('token', '9LR99107DF7343549');
            
            request.requestBody = Blob.valueOf(body);
            RestContext.request = request;

            Test.startTest();
            request.addParameter('key', '');
            try{
                SYS_Webservice.putRequest();
            } catch(Exception e) {
                System.assert(e.getMessage() != NULL);
            }
            request.addParameter('key', accounts[0].UUID__c);
            SYS_Webservice.putRequest();
            request.addParameter('token', 'incorrect_token');
            SYS_Webservice.putRequest();
            Test.stopTest();

            List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
            System.assert(log.size()>0);
        }
    }

    @IsTest
    static void testPatch() {
        String body = SYS_TestUtil.getMockBody();
        System.runAs(getUser()) {
            
            SYS_TestDataFactory.createTestRecords(1, 1);
            List<account> accounts = [SELECT Id, UUID__c FROM Account LIMIT 1];
            
            RestRequest request = new RestRequest();
            RestResponse actualres = new RestResponse();
            request.requestURI = '/municorn/v1/SYS_Test_IntegrationSetting';
            request.addParameter('token', '9LR99107DF7343549');
            
            request.requestBody = Blob.valueOf(body);
            RestContext.request = request;

            Test.startTest();
            request.addParameter('key', '');
            try{
                SYS_Webservice.patchRequest();
            } catch(Exception e) {
                System.assert(e.getMessage() != NULL);
            }
            request.addParameter('key', accounts[0].UUID__c);
            SYS_Webservice.patchRequest();
            request.addParameter('token', 'incorrect_token');
            SYS_Webservice.patchRequest();
            Test.stopTest();

            List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
            System.assert(log.size()>0);
        }
    }

    @IsTest
    static void testDelete(){
        String body = SYS_TestUtil.getMockBody();
        
        System.runAs(getUser()) {

            SYS_TestDataFactory.createTestRecords(1, 1);
            List<account> accounts = [SELECT Id, UUID__c FROM Account LIMIT 1];
            
            RestRequest request = new RestRequest();
            RestResponse actualres = new RestResponse();
            request.requestURI = '/municorn/v1/SYS_Test_IntegrationSetting';
            request.addParameter('token', '9LR99107DF7343549');
            
            request.requestBody = Blob.valueOf(body);
            RestContext.request = request;

            Test.startTest();
            request.addParameter('key', '');
            try{
                SYS_Webservice.deleteRequest();
            } catch(Exception e) {
                System.assert(e.getMessage() != NULL);
            }
            // request.requestURI = '/municorn/v1/SYS_Test_IntegrationSetting';
            request.addParameter('key', accounts[0].UUID__c);
            SYS_Webservice.deleteRequest();
            request.addParameter('token', 'incorrect_token');
            SYS_Webservice.deleteRequest();
            Test.stopTest();

            List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
            System.assert(log.size()>0);
        }
        
    }

    @IsTest
    static void testLargeDataLog(){
        String body = SYS_TestUtil.getLargeMockBody();
        System.runAs(getUser()) {
        
            SYS_TestDataFactory.createTestRecords(1, 1);
            List<account> accounts = [SELECT Id, UUID__c FROM Account LIMIT 1];
            

            SYS_DataCacheFactory init = new SYS_DataCacheFactory(
                accounts[0].Id,
                'SYS_Test_IntegrationSetting', 
                SYS_DataCacheFactory.INT_TYPE,
                SYS_DataCacheFactory.OBJ_TYPE
            );
            
        
            RestRequest request = new RestRequest();
            RestResponse actualres = new RestResponse();
            request.requestURI = '/municorn/v1/SYS_Test_IntegrationSetting';
            request.addParameter('token', '9LR99107DF7343549');
            request.addParameter('key', accounts[0].UUID__c);
            request.requestBody = Blob.valueOf(body);
            RestContext.request = request;

            Test.startTest();
            SYS_Webservice.postRequest();
            Test.stopTest();

            List<SYS_IntegrationLog__c> log = [SELECT Id,data1__c FROM SYS_IntegrationLog__c];
            SYS_Helper.upsertLog(log);
            SYS_Helper.updateLog(log);
            SYS_Helper.updateLog(log[0]);
            System.assert(log.size()>0);
            System.assertNotEquals(NULL, log[0].data1__c);
        }
    }

    @IsTest
    static void testPost_verylargeData(){
        String body = SYS_TestUtil.getVeryLargeMockBody();
        System.runAs(getUser()) {

            SYS_TestDataFactory.createTestRecords(1, 1);
            List<account> accounts = [SELECT Id, UUID__c FROM Account LIMIT 1];
            

            SYS_DataCacheFactory init = new SYS_DataCacheFactory(
                accounts[0].Id,
                'SYS_Test_IntegrationSetting', 
                SYS_DataCacheFactory.INT_TYPE,
                SYS_DataCacheFactory.OBJ_TYPE
            );
            
        
            RestRequest request = new RestRequest();
            RestResponse actualres = new RestResponse();
            request.requestURI = '/municorn/v1/SYS_Test_IntegrationSetting';
            request.addParameter('token', '9LR99107DF7343549');
            request.addParameter('key', accounts[0].UUID__c);
            request.requestBody = Blob.valueOf(body);
            RestContext.request = request;

            Test.startTest();
            SYS_Webservice.postRequest();
            Test.stopTest();

            List<SYS_IntegrationLog__c> log = [SELECT Id,data1__c, Root_Log__c, Order__c, Status__c FROM SYS_IntegrationLog__c];
            SYS_Helper.upsertLog(log);
            SYS_Helper.updateLog(log);
            SYS_Helper.updateLog(log[0]);
            log = [SELECT Id,data1__c, Root_Log__c, Order__c, Status__c, Message__c FROM SYS_IntegrationLog__c];
            System.assert(log.size()>0);
            System.debug('sys logs size '+ log.size());
            System.assertNotEquals(NULL, log[0].data1__c);
            for(SYS_IntegrationLog__c l : log) {
                if(l.Root_Log__c != NULL) {
                    System.assert(l.Order__c == 0);
                    System.debug('Status '+l.Status__c);
                }
                System.debug('root log '+ l.Root_Log__c +' Status '+l.Status__c+ ' Order '+l.Order__c + ' Message__c '+l.Message__c);
            }
        }
        
    }


    @IsTest
    static void testLogUpdateForProcessing(){
        System.runAs(getUser()) {
            SYS_TestDataFactory.createIgnoreLog();
            List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c LIMIT 1];
            log[0].Type__c = 'INBOUND';
            log[0].Status__c = 'READY_FOR_PROCESSING';
            update log;

            System.assertEquals('READY_FOR_PROCESSING',log[0].Status__c);
        }
    }

}