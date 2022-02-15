@isTest
public class SYS_OutboundTest {
    
    @TestSetup
    static void makeData(){
        List<Custom_Parent__c> parents = new List<Custom_Parent__c>();
        for(Integer i=0;i<60;i++){
            Custom_Parent__c parent = new Custom_Parent__c(Text_Field__c='Custom Parent Test record'+i,SYS_Key__c='EXT-'+i);
            parents.add(parent); 
        }
        insert parents;

        SYS_IntegrationLog__c  newSysLog = SYS_Helper.getLogsToInsert('{\"Text_Field__c\":\"OB Async 2\"}');
        newSysLog.Status__c = 'NEW';
        newSysLog.Type__c = 'OUTBOUND';
        newSysLog.SYS_IntegrationSettings__c = 'SFsource';
        newSysLog.SYS_Operation_Type__c = 'INSERT';
        newSysLog.whatid__c = 'a005f000007K9hlAAC';
        newSysLog.ObjectSettingId__c = 'Custom_Parent_Object_Setting';
        newSysLog.How_to_process__c = 'use_custom_apex_handler';
        newSysLog.Custom_Apex_Handler__c = 'Override_SYS_ApplicationService';
        insert newSysLog;
    }

    @IsTest
    static void testSingleRecord(){
        
        
        List<sObject> parents = [SELECT Id, Text_Field__c,SYS_Key__c FROM Custom_Parent__c];
        List<SYS_InvocableHandler.MyInvocableVariable> ivs = new List<SYS_InvocableHandler.MyInvocableVariable>();
        for(sObject parent:parents){
            SYS_InvocableHandler.MyInvocableVariable iv = new SYS_InvocableHandler.MyInvocableVariable();
            iv.integrationSetting = 'SFsource';
            iv.objectSetting = 'Custom_Parent_Object_Setting';
            iv.newVal = parent;
            iv.oldVal = parent;
            iv.operationType = 'INSERT';
            iv.recId = parent.Id;
            ivs.add(iv);        
        }
        

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SYS_MockServer());
        SYS_InvocableHandler.captureOutboundRequest(ivs);
        Test.stopTest();

        List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
        System.assert(log.size()>0);
        
    }

    @isTest
    public static void testMultipleRecords(){

    }

    @isTest
    public static void testSingleParentMultipleChildRecords(){

    }

    @isTest
    public static void testOutboundboundImmediate(){

    }


}
