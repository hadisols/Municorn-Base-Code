@IsTest
public class SYS_TestUtil {
    
    public static void invokeMockFlowForInsert(){
        
        // List<Account> accountList = [SELECT Id, Name, SYS_Key__c FROM Account];
        List<Account> accountList = [SELECT Id, Name FROM Account];
        SYS_DataCache.testAccountId = accountList[0].Id;
        List<SYS_InvocableHandler.MyInvocableVariable> ivs = new List<SYS_InvocableHandler.MyInvocableVariable>();
        for(sObject acc:accountList){
            SYS_InvocableHandler.MyInvocableVariable iv = new SYS_InvocableHandler.MyInvocableVariable();
            iv.integrationSetting = 'SYS_Test_IntegrationSetting';
            iv.objectSetting = 'SYS_Test_Account_Object_Setting';
            iv.newVal = acc;
            iv.oldVal = acc;
            iv.operationType = 'INSERT';
            iv.recId = acc.Id;
            //iv.accountId = SYS_DataCache.testAccountId;
            //iv.integrationType = 'SYS_Test_IntegrationSetting';
            ivs.add(iv);
        }
        SYS_InvocableHandler.captureOutboundRequest(ivs);
    }

    public static void invokeMockFlowForInsertAccount(){
        
        // List<Account> accountList = [SELECT Id, Name, SYS_Key__c FROM Account];
        List<Account> accountList = [SELECT Id, Name FROM Account];
        SYS_DataCache.testAccountId = accountList[0].Id;
        List<SYS_AccountInvocableHandler.MyInvocableVariable> ivs = new List<SYS_AccountInvocableHandler.MyInvocableVariable>();
        for(sObject acc:accountList){
            SYS_AccountInvocableHandler.MyInvocableVariable iv = new SYS_AccountInvocableHandler.MyInvocableVariable();
            // iv.integrationSetting = 'SYS_Test_IntegrationSetting';
            iv.objectSetting = 'SYS_Test_Account_Object_Setting';
            iv.newVal = acc;
            iv.oldVal = acc;
            iv.operationType = 'INSERT';
            iv.recId = acc.Id;
            iv.accountId = SYS_DataCache.testAccountId;
            iv.integrationType = 'SYS_Test_IntegrationSetting';
            ivs.add(iv);
        }
        SYS_AccountInvocableHandler.captureOutboundRequest(ivs);
    }

    public static void invokeMockFlowForUpsert(){
        
        // List<Account> accountList = [SELECT Id, Name, SYS_Key__c FROM Account];
        List<Account> accountList = [SELECT Id, Name FROM Account];
        SYS_DataCache.testAccountId = accountList[0].Id;
        List<SYS_InvocableHandler.MyInvocableVariable> ivs = new List<SYS_InvocableHandler.MyInvocableVariable>();
        for(sObject acc:accountList){
            SYS_InvocableHandler.MyInvocableVariable iv = new SYS_InvocableHandler.MyInvocableVariable();
            iv.integrationSetting = 'SYS_Test_IntegrationSetting';
            iv.objectSetting = 'SYS_Test_Account_Object_Setting';
            iv.newVal = acc;
            iv.oldVal = acc;
            iv.operationType = 'UPSERT';
            iv.recId = acc.Id;
            // iv.accountId = SYS_DataCache.testAccountId;
            // iv.integrationType = 'SYS_Test_IntegrationSetting';
            ivs.add(iv);
        }
        SYS_InvocableHandler.captureOutboundRequest(ivs);
    }

    public static String getLargeMockBody(){
        
        Test.setMock(HttpCalloutMock.class, SYS_MockServer.startServer());


        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://get_large_mock_body.inbound');
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        return res.getBody();

    }

    public static String getVeryLargeMockBody(){
        
        Test.setMock(HttpCalloutMock.class, SYS_MockServer.startServer());


        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://get_very_large_mock_body.inbound');
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        return res.getBody();

    }

    public static String getMockBody(){
        
        Test.setMock(HttpCalloutMock.class, SYS_MockServer.startServer());


        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://get_mock_body.inbound');
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        return res.getBody();

    }
    
    
}