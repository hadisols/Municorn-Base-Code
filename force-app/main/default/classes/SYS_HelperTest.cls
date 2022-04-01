@isTest
public class SYS_HelperTest {

    @TestSetup
    static void makeData(){
        SYS_TestDataFactory.createTestRecords(1, 1);

    }

    @IsTest
    static void testStaticMethods(){
        SYS_Helper.getUUID();
        SYS_Helper.secondsToDatetime('1632817530');
        SYS_Transformer.subList(new List<String>{'test'},0);

        SYS_Datacache.OBJ_TYPE = 'SYS_Test_Account_Object_Setting';
        List<account> accounts = [SELECT Id FROM Account LIMIT 1];
        SYS_Helper.urlFromPattern('PATCH', accounts[0].Id);
    }
}