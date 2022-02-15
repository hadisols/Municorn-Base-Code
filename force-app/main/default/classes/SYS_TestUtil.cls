@isTest
public class SYS_TestUtil {
    
    public static void invokeMockFlowForInsert(){
        
        List<Account> accountList = [SELECT Id, Name, SYS_Key__c FROM Account];

        List<SYS_InvocableHandler.MyInvocableVariable> ivs = new List<SYS_InvocableHandler.MyInvocableVariable>();
        for(sObject acc:accountList){
            SYS_InvocableHandler.MyInvocableVariable iv = new SYS_InvocableHandler.MyInvocableVariable();
            iv.integrationSetting = 'SYS_Test_IntegrationSetting';
            iv.objectSetting = 'SYS_Test_Account_Object_Setting';
            iv.newVal = acc;
            iv.oldVal = acc;
            iv.operationType = 'INSERT';
            iv.recId = acc.Id;
            ivs.add(iv);
        }
        SYS_InvocableHandler.captureOutboundRequest(ivs);
    }

    
}
