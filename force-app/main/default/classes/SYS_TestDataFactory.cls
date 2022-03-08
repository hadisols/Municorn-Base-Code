@isTest
public class SYS_TestDataFactory {
    public static void createTestRecords(Integer numAccts, Integer numContactsPerAcct){
        List<Account> accts = new List<Account>();
        
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(Name='Municorn Test Account' + i);
            accts.add(a);
        }
        insert accts;
        
        List<Contact> cons = new List<Contact>();
        for (Integer j=0;j<numAccts;j++) {
            Account acct = accts[j];            
            // For each account just inserted, add contacts
            for (Integer k=numContactsPerAcct*j;k<numContactsPerAcct*(j+1);k++) {
                cons.add(new Contact(firstname='Municorn'+k,
                                     lastname='Test Contact'+k,
                                     AccountId=acct.Id));
            }
        }
        // Insert all contacts for all accounts
        insert cons;
    }

    public static void createIgnoreLog(){
        SYS_IntegrationLog__c  newSysLog = SYS_Helper.getLogsToInsert('{\"Name\":\"Municorn Test Account\"}');
        newSysLog.Status__c = 'NEW';
        newSysLog.Type__c = 'OUTBOUND';
        newSysLog.Integration_Setting__c = 'SYS_Test_IntegrationSetting';
        newSysLog.SYS_Operation_Type__c = 'INSERT';
        newSysLog.whatid__c = 'a005f000007K9hlAAC';
        newSysLog.ObjectSettingId__c = 'SYS_Test_Account_Object_Setting';
        newSysLog.How_to_process__c = 'ignore_log';
        insert newSysLog;
    }

    public static void createObjectSettingLog(){
        SYS_IntegrationLog__c  newSysLog = SYS_Helper.getLogsToInsert('{\"Name\":\"Municorn Test Account\"}');
        newSysLog.Status__c = 'NEW';
        newSysLog.Type__c = 'OUTBOUND';
        newSysLog.Integration_Setting__c = 'SYS_Test_IntegrationSetting';
        newSysLog.SYS_Operation_Type__c = 'INSERT';
        newSysLog.whatid__c = [SELECT Id FROM Account][0].Id;
        newSysLog.ObjectSettingId__c = 'SYS_Test_Account_Object_Setting';
        newSysLog.How_to_process__c = 'use_object_setting';
        insert newSysLog;
    }

    public static void createCustomApexHandlerLog(){
        SYS_IntegrationLog__c  newSysLog = SYS_Helper.getLogsToInsert('{\"Name\":\"Municorn Test Account\"}');
        newSysLog.Status__c = 'NEW';
        newSysLog.Type__c = 'OUTBOUND';
        newSysLog.Integration_Setting__c = 'SYS_Test_IntegrationSetting';
        newSysLog.SYS_Operation_Type__c = 'INSERT';
        newSysLog.whatid__c = [SELECT Id FROM Account][0].Id;
        newSysLog.ObjectSettingId__c = 'SYS_Test_Account_Object_Setting';
        newSysLog.How_to_process__c = 'use_custom_apex_handler';
        newSysLog.Custom_Apex_Handler__c = 'SYS_ApplicationService';
        insert newSysLog;

    }


}