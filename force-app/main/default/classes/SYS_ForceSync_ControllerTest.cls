@isTest
public class SYS_ForceSync_ControllerTest {
    @TestSetup
    static void makeData(){
        SYS_TestDataFactory.createTestRecords(1, 1);

    }

    @IsTest
    static void testForceSyncIn(){
    
        List<Account> accountList = [SELECT Id, Name, SYS_Key__c FROM Account];
        Test.startTest();
        for(sObject acc:accountList){
            SYS_ForceSync_Controller.invokeFlow(acc.Id, 'SYS_Test_Account_Object_Setting', 'SYS_ForceSync_Controller', 'IN');
        }
        Test.stopTest();

        List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
        System.assert(log.size()>0);       
        
    }

    @IsTest
    static void testForceSyncOut(){
        
        List<Account> accountList = [SELECT Id, Name, SYS_Key__c FROM Account];
        Test.startTest();
        for(sObject acc:accountList){
            SYS_ForceSync_Controller.invokeFlow(acc.Id, 'SYS_Test_Account_Object_Setting', 'SYS_ForceSync_Controller', 'OUT');
        }
        Test.stopTest();

        List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
        System.assert(log.size()>0);

    }
}