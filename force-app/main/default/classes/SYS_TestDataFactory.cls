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
        newSysLog.SYS_IntegrationSettings__c = 'SYS_Test_IntegrationSetting';
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
        newSysLog.SYS_IntegrationSettings__c = 'SYS_Test_IntegrationSetting';
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
        newSysLog.SYS_IntegrationSettings__c = 'SYS_Test_IntegrationSetting';
        newSysLog.SYS_Operation_Type__c = 'INSERT';
        newSysLog.whatid__c = [SELECT Id FROM Account][0].Id;
        newSysLog.ObjectSettingId__c = 'SYS_Test_Account_Object_Setting';
        newSysLog.How_to_process__c = 'use_custom_apex_handler';
        newSysLog.Custom_Apex_Handler__c = 'SYS_ApplicationService';
        insert newSysLog;

    }

    public static void createAccount(Integer count) {

    }

    public static String createPaymentIntent(Integer count) {
        Account acc = new Account(
            Name = 'test name',
            Profile_Id__c = '504389592'
        );
        insert acc;
        Payment_Gateway__c gateway = new Payment_Gateway__c(
            Athrz_Api_Login_Id__c = 'sample',
            Athrz_Base_Endpoint__c = 'https://apitest.authorize.net/xml/v1/request.api',
            Name = 'Athrz',
            Athrz_Public_Client_Key__c = 'sample',
            Athrz_Transaction_Key__c = 'sample'
        );
        insert gateway;

        Payment_Intent__c intent = new Payment_Intent__c(
            Name = 'Payment for XYZ',
            Athrz_Frequency__c = 'single',
            Athrz_Email__c = 'abc@xyz.com',
            Status__c = 'payment_new',
            Athrz_First_Charge_Date__c = Datetime.now(),
            Payment_Gateway__c = gateway.Id,
            Athrz_Account__c = acc.Id,
            Athrz_Scheduled_Payment__c = Datetime.now(),
            athrz_uuid__c = UUIDGenerator.createId(),
            Athrz_Amount__c = 100
        );

        insert intent;
        return intent.id;
    }

    public static void createActivity(Integer count) {
        String intentId = createPaymentIntent(1);
        Activity__c activity = new Activity__c(
            Payment_Intent__c = intentId,
            Type__c = 'email',
            Status__c = 'New',
            When__c = Datetime.now(),
            Email__c = 'abc@xyz.com',
            UUID__c = UUIDGenerator.createId()
        );

        insert activity;
    }


}