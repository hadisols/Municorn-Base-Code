@isTest
public class SYS_ForceSync_ControllerTest {
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
    static void testForceSyncIn(){
        

        System.runAs(getUser()) {
            // List<Account> accountList = [SELECT Id, Name, SYS_Key__c FROM Account];
            List<Account> accountList = [SELECT Id, Name FROM Account];
            System.debug('SP accountList'+ accountList);
            Test.startTest();
            for(sObject acc:accountList){
                SYS_ForceSync_Controller.invokeFlow(acc.Id, 'SYS_Test_Account_Object_Setting', 'SYS_ForceSync_Controller', 'IN');
            }
            Test.stopTest();
    
            List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
            System.assert(log.size()>0); 
        }
    }

    @IsTest
    static void testForceSyncOut(){
        
        System.runAs(getUser()) {
                
            // List<Account> accountList = [SELECT Id, Name, SYS_Key__c FROM Account];
            List<Account> accountList = [SELECT Id, Name FROM Account];
            Test.startTest();
            for(sObject acc:accountList){
                SYS_ForceSync_Controller.invokeFlow(acc.Id, 'SYS_Test_Account_Object_Setting', 'SYS_ForceSync_Controller', 'OUT');
            }
            Test.stopTest();

            List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
            System.assert(log.size()>0);
        }

    }

    @IsTest
    static void testForceSyncOut_AccountShareModel(){
        
        System.runAs(getUser()) {
                
            List<Account> accountList = [SELECT Id, Name FROM Account];
            // List<Account> accountList = [SELECT Id, Name, SYS_Key__c FROM Account];
            List<Contact> contactList = [SELECT Id FROM Contact];

            Test.startTest();
            // for(sObject acc:accountList){
            //     SYS_ForceSync_Controller.invokeAccountFlow(acc.Id, 'SYS_Test_Account_Object_Setting', 'SYS_ForceSync_Controller', 'OUT');

            //     SYS_ForceSync_Controller.invokeFlow(acc.Id, 'SYS_Test_Account_Object_Setting', 'SYS_ForceSync_Controller', 'OUT');
            // }
            for(sObject contact : contactList) {
                SYS_ForceSync_Controller.invokeAccountFlow(contact.Id, 'SYS_Test_Contact_Object_Setting', 'SYS_ForceSync_Controller', 'OUT', 'AccountId');
            }
            Test.stopTest();

            List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
            System.assert(log.size()>0);
        }

    }
}