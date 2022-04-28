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

        String pattern = SYS_Datacache.objectSettingMap.get(SYS_Datacache.OBJ_TYPE).PATCH_URL_Pattern__c;
        SYS_Helper.urlFromPattern('PATCH', accounts[0].Id);

        SYS_Helper.deleteWithFLSCheck(accounts);

        //Datetime and Time method coverage
        for(FieldSetting__mdt fs : [SELECT Key__c, StaticValue__c, Datetime_Conversion_Format__c FROM FieldSetting__mdt WHERE Is_Active__c=false AND ObjectSetting__r.DeveloperName = 'SYS_Test_Account_Object_Setting']) {

            SYS_ApplicationService appService = new SYS_ApplicationService();

            if(fs.Key__c == 'testdatetime' || fs.Key__c == 'testepoch'){
                appService.getDatetimeValue(fs,fs.StaticValue__c);
                appService.getDateValue(fs, '2022-10-10');
            }
            if(fs.Key__c == 'testtimefield'){
                appService.getTimeValue(fs,fs.StaticValue__c);
            }

            
        }
        

        System.assert(SYS_Datacache.objectSettingMap.get(SYS_Datacache.OBJ_TYPE).PATCH_URL_Pattern__c == pattern);
    }
}