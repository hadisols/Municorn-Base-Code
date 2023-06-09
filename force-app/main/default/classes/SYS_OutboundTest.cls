@isTest
public class SYS_OutboundTest {
    
    @TestSetup
    static void makeData(){
        SYS_TestDataFactory.createTestRecords(1, 1);
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
    static void testRecordCreateOutbound(){
        
        System.runAs(getUser()) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, SYS_MockServer.startServer());
            SYS_TestUtil.invokeMockFlowForInsert();
            Test.stopTest();

            //TODO Assert on key fields on log record
            List<SYS_IntegrationLog__c> log = [SELECT Id,Status__c FROM SYS_IntegrationLog__c];
            System.assert(log.size()>1);
        }
    }

    @IsTest
    static void testRecordCreateOutbound_multiple(){
        
        System.runAs(getUser()) {
            SYS_TestDataFactory.createTestRecords(50, 1);
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, SYS_MockServer.startServer());
            SYS_TestUtil.invokeMockFlowForInsert();
            Test.stopTest();

            //TODO Assert on key fields on log record
            List<SYS_IntegrationLog__c> log = [SELECT Id,Status__c FROM SYS_IntegrationLog__c];
            System.assert(log.size()>1);
        }
    }

    @IsTest
    static void testRecordCreateOutbound_Account(){
        
        System.runAs(getUser()) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, SYS_MockServer.startServer());
            SYS_TestUtil.invokeMockFlowForInsertAccount();
            Test.stopTest();
    
            //TODO Assert on key fields on log record
            List<SYS_IntegrationLog__c> log = [SELECT Id,Status__c FROM SYS_IntegrationLog__c];
            System.assert(log.size()>1);
            
        }
    }

    @IsTest
    static void testRecordUpdateOutbound(){
        
        System.runAs(getUser()) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, SYS_MockServer.startServer());
            SYS_TestUtil.invokeMockFlowForUpsert();
            Test.stopTest();

            //TODO Assert on key fields on log record
            List<SYS_IntegrationLog__c> log = [SELECT Id,Status__c FROM SYS_IntegrationLog__c];
            System.assert(log.size()>0);
        }
        
        
    }

    @isTest
    public static void testIgnoreLogOutbound(){
        System.runAs(getUser()) {
            Test.startTest();
            SYS_TestDataFactory.createIgnoreLog();
            Test.stopTest();
            
            List<SYS_IntegrationLog__c> log = [SELECT Id,Status__c FROM SYS_IntegrationLog__c WHERE How_to_process__c = 'ignore_log'];
            System.assert(log.size()>0);
        }
    }

    @isTest
    public static void testCustomApexLogOutbound(){
        System.runAs(getUser()) {
            Test.startTest();
            SYS_TestDataFactory.createCustomApexHandlerLog();
            Test.stopTest();

            List<SYS_IntegrationLog__c> log = [SELECT Id,Status__c FROM SYS_IntegrationLog__c WHERE How_to_process__c ='use_custom_apex_handler'];
            System.assert(log.size()>0);
        }
    }

    @isTest
    public static void testNon2xxOutbound(){
        System.runAs(getUser()) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, SYS_MockServer.stopServer());
            SYS_TestUtil.invokeMockFlowForUpsert();
            Test.stopTest();

            //TODO Assert on key fields on log record
            List<SYS_IntegrationLog__c> log = [SELECT Id,Status__c FROM SYS_IntegrationLog__c];
            System.assert(log.size()>0);
        }
    }

    @isTest
    public static void testOutboundboundImmediate(){
        System.runAs(getUser()) {
            Test.setMock(HttpCalloutMock.class, SYS_MockServer.startServer());
            List<SYS_IntegrationLog__c> sysLogs = new List<SYS_IntegrationLog__c>();
            
            SYS_IntegrationLog__c  newSysLog = new SYS_IntegrationLog__c();
            newSysLog = SYS_Helper.getLogsToInsert('{\"Name\":\"Municorn Test Account\"}');
            newSysLog.Status__c = 'NEW';
            newSysLog.Type__c = 'OUTBOUND';
            newSysLog.Integration_Setting__c = 'SYS_Test_IntegrationSetting';
            newSysLog.SYS_Operation_Type__c = 'INSERT';
            newSysLog.whatid__c = 'a005f000007K9hlAAC';
            newSysLog.ObjectSettingId__c = 'SYS_Test_Account_Object_Setting';
            newSysLog.How_to_process__c = 'ignore_log';
            sysLogs.add(newSysLog);

            newSysLog = new SYS_IntegrationLog__c();
            newSysLog = SYS_Helper.getLogsToInsert('{\"Name\":\"Municorn Test Account\"}');
            newSysLog.Status__c = 'NEW';
            newSysLog.Type__c = 'OUTBOUND';
            newSysLog.Integration_Setting__c = 'SYS_Test_IntegrationSetting';
            newSysLog.SYS_Operation_Type__c = 'INSERT';
            newSysLog.whatid__c = [SELECT Id FROM Account][0].Id;
            newSysLog.ObjectSettingId__c = 'SYS_Test_Account_Object_Setting';
            newSysLog.How_to_process__c = 'use_object_setting';
            sysLogs.add(newSysLog);

            newSysLog = new SYS_IntegrationLog__c();
            newSysLog = SYS_Helper.getLogsToInsert('{\"Name\":\"Municorn Test Account\"}');
            newSysLog.Status__c = 'NEW';
            newSysLog.Type__c = 'OUTBOUND';
            newSysLog.Integration_Setting__c = 'SYS_Test_IntegrationSetting';
            newSysLog.SYS_Operation_Type__c = 'INSERT';
            newSysLog.whatid__c = [SELECT Id FROM Account][0].Id;
            newSysLog.ObjectSettingId__c = 'SYS_Test_Account_Object_Setting';
            newSysLog.How_to_process__c = 'use_custom_apex_handler';
            newSysLog.Custom_Apex_Handler__c = 'SYS_ApplicationService';
            sysLogs.add(newSysLog);

            Test.startTest();
            new SYS_IntegrationLogOutboundImmediate(sysLogs).execute();
            Test.stopTest();

            List<SYS_IntegrationLog__c> log = [SELECT Id,Status__c FROM SYS_IntegrationLog__c];
            System.assert(log.size()>0);
        }
    }

    @IsTest
    static void testLogUpdateForProcessing(){
        System.runAs(getUser()) {
            SYS_TestDataFactory.createIgnoreLog();
            List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c LIMIT 1];
            log[0].Type__c = 'OUTBOUND';
            log[0].Status__c = 'READY_FOR_PROCESSING';
            update log;

            System.assertEquals('READY_FOR_PROCESSING',log[0].Status__c);
        }
    }


}