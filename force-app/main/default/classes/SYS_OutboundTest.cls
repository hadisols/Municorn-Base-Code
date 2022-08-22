@isTest
public class SYS_OutboundTest {
    
    @TestSetup
    static void makeData(){
        SYS_TestDataFactory.createTestRecords(1, 1);
    }

    @IsTest
    static void testRecordCreateOutbound(){
        

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, SYS_MockServer.startServer());
        SYS_TestUtil.invokeMockFlowForInsert();
        Test.stopTest();

        //TODO Assert on key fields on log record
        List<SYS_IntegrationLog__c> log = [SELECT Id,Status__c FROM SYS_IntegrationLog__c];
        System.assert(log.size()>1);
        
        
    }

    @IsTest
    static void testRecordUpdateOutbound(){
        

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, SYS_MockServer.startServer());
        SYS_TestUtil.invokeMockFlowForUpsert();
        Test.stopTest();

        //TODO Assert on key fields on log record
        List<SYS_IntegrationLog__c> log = [SELECT Id,Status__c FROM SYS_IntegrationLog__c];
        System.assert(log.size()>0);
        
        
    }

    @isTest
    public static void testIgnoreLogOutbound(){
        Test.startTest();
        SYS_TestDataFactory.createIgnoreLog();
        Test.stopTest();
        
        List<SYS_IntegrationLog__c> log = [SELECT Id,Status__c FROM SYS_IntegrationLog__c WHERE How_to_process__c = 'ignore_log'];
        System.assert(log.size()>0);
    }

    @isTest
    public static void testCustomApexLogOutbound(){
        Test.startTest();
        SYS_TestDataFactory.createCustomApexHandlerLog();
        Test.stopTest();

        List<SYS_IntegrationLog__c> log = [SELECT Id,Status__c FROM SYS_IntegrationLog__c WHERE How_to_process__c ='use_custom_apex_handler'];
        System.assert(log.size()>0);
    }

    @isTest
    public static void testNon2xxOutbound(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, SYS_MockServer.stopServer());
        SYS_TestUtil.invokeMockFlowForUpsert();
        Test.stopTest();

        //TODO Assert on key fields on log record
        List<SYS_IntegrationLog__c> log = [SELECT Id,Status__c FROM SYS_IntegrationLog__c];
        System.assert(log.size()>0);
    }

    @isTest
    public static void testOutboundboundImmediate(){
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

    @IsTest
    static void testLogUpdateForProcessing(){

        SYS_TestDataFactory.createIgnoreLog();
        List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c LIMIT 1];
        log[0].Type__c = 'OUTBOUND';
        log[0].Status__c = 'READY_FOR_PROCESSING';
        update log;

        System.assertEquals('READY_FOR_PROCESSING',log[0].Status__c);
    }


}