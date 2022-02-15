@isTest
public class SYS_OutboundTest {
    
    @TestSetup
    static void makeData(){
        SYS_TestDataFactory.createTestRecords(1, 3);

        /*
        SYS_IntegrationLog__c  newSysLog = SYS_Helper.getLogsToInsert('{\"Text_Field__c\":\"OB Async 2\"}');
        newSysLog.Status__c = 'NEW';
        newSysLog.Type__c = 'OUTBOUND';
        newSysLog.SYS_IntegrationSettings__c = 'SYS_Test_IntegrationSetting';
        newSysLog.SYS_Operation_Type__c = 'INSERT';
        newSysLog.whatid__c = 'a005f000007K9hlAAC';
        newSysLog.ObjectSettingId__c = 'SYS_Test_Account_Object_Setting';
        newSysLog.How_to_process__c = 'use_custom_apex_handler';
        newSysLog.Custom_Apex_Handler__c = 'SYS_Override_ApplicationService';
        insert newSysLog;
        */
    }

    @IsTest
    static void testSingleRecordOutbound(){
        

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SYS_MockServer());
        SYS_TestUtil.invokeMockFlowForInsert();
        Test.stopTest();

        //TODO Assert on key fields on log record
        List<SYS_IntegrationLog__c> log = [SELECT Id,Status__c FROM SYS_IntegrationLog__c];
        System.assert(log.size()>1);
        
        
    }

    @isTest
    public static void testIgnoreLogOutbound(){
        SYS_TestDataFactory.createIgnoreLog();
    }

    @isTest
    public static void testCustomApexLogOutbound(){
        SYS_TestDataFactory.createCustomApexHandlerLog();
    }

    @isTest
    public static void testMultipleRecordsOutbound(){

    }

    @isTest
    public static void testParentChildOutbound(){

    }

    @isTest
    public static void testOutboundboundImmediate(){

    }


}
