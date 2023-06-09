@isTest
public class SYS_TestDataFactory {
    public static Boolean personAccountsEnabled() {
        return Schema.sObjectType.Account.fields.getMap().containsKey( 'isPersonAccount' );
    }

    public static void createTestRecords(Integer numAccts, Integer numContactsPerAcct){
        List<Account> accts = new List<Account>();
        
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account();
            if(!personAccountsEnabled()) {
                a.put('Name', 'Municorn Test Account' + i);
            } else {
                a.put('LastName', 'Municorn Test Account' + i);
            }
            a.UUID__c = SYS_Helper.getUUID();
            accts.add(a);
        }
        insert accts;

        List<SYS_Integration_Metadata__c> metadata = new List<SYS_Integration_Metadata__c>();
        for(Account acc:accts) {
            SYS_Integration_Metadata__c md = new SYS_Integration_Metadata__c();
            md.Integration_Type__c = 'SYS_Test_IntegrationSetting';
            md.Key__c = 'int-set';
            md.Value__c = 'SYS_Test_IntegrationSetting';
            md.Account__c = acc.Id;
            metadata.add(md);
            SYS_Integration_Metadata__c md1 = new SYS_Integration_Metadata__c();
            md1.Integration_Type__c = 'SYS_Test_IntegrationSetting';
            md1.Key__c = 'int-set';
            md1.Value__c = 'SYS_Test_IntegrationSetting';
            md1.Account__c = acc.Id;

            metadata.add(md1);
        }
        
        insert metadata;
        
        List<Contact> cons = new List<Contact>();
        for (Integer j=0;j<numAccts;j++) {
            Account acct = accts[j];            
            // For each account just inserted, add contacts
            // for (Integer k=numContactsPerAcct*j;k<numContactsPerAcct*(j+1);k++) {
            for (Integer k=0 ; k<numContactsPerAcct ; k++) {
                cons.add(new Contact(firstname='Municorn'+k,
                                     lastname='Test Contact'+k,
                                     AccountId=acct.Id));
            }
        }
        // Insert all contacts for all accounts
        insert cons;

    }

    public static void createTestRecordsFromStaticResource(){
        Test.loadData(SYS_OAuthConfig__c.sObjectType, 'OAuth_Test_Records');
        
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

        SYS_Helper.insertLog(newSysLog);
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
        // insert newSysLog;
        SYS_Helper.insertLog(newSysLog);
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
        // insert newSysLog;
        SYS_Helper.insertLog(newSysLog);

    }


}