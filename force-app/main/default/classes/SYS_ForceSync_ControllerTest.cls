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
        
    }

    @IsTest
    static void testForceSyncOut(){
        
        List<Account> accountList = [SELECT Id, Name, SYS_Key__c FROM Account];
        Test.startTest();
        for(sObject acc:accountList){
            SYS_ForceSync_Controller.invokeFlow(acc.Id, 'SYS_Test_Account_Object_Setting', 'SYS_ForceSync_Controller', 'OUT');
        }
        Test.stopTest();

    }
}