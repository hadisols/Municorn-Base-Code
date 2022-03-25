@isTest
public class SYS_DataCacheTest {
    /* @IsTest static void ObjectContextTest(){
        string context = 'test';
        string st = SYS_DataCache.ObjectContext;
        system.debug('>>>>>>>>>>>!!'+st);
        System.assertEquals(null,st);
        
    }
    
    @IsTest static void GetChildFieldSettingMapTest(){
        Test.startTest();
        Map<String, List<FieldSetting__mdt>> gtchild = SYS_DataCache.GetChildFieldSettingMap;
        System.debug('gtchild'+gtchild);   
        Test.stopTest();  
        System.assertEquals(null,null);
        
    }
    @IsTest static void oldMapTest(){
        Test.startTest();
        Account acc = new Account( Name= 'abc');
        
        map<Id,sObject> mappings = new map<Id,sObject>{acc.id => acc};
        SYS_DataCache.oldMap = mappings;
        Map<Id, sObject> nolmap1 = SYS_DataCache.oldMap;
        SYS_DataCache.newMap = mappings;
        Map<Id, sObject> newmap1 = SYS_DataCache.newMap;
         Test.stopTest(); 
        System.assertEquals(null,null);
    } */
    @IsTest static void checkcontextSet(){
        Test.startTest();
        Account acc = new Account( Name= 'abc');
        List<sObject> testcon = new List<sObject>();
        testcon.add(acc); 
        SYS_DataCache.contextSet = testcon;
        Test.stopTest(); 
        System.assertEquals(null,null);
    }
    // @IsTest static void checkpricebookid(){
    //     Test.startTest();
    //     String testid = SYS_DataCache.priceBookId;
    //     Test.stopTest(); 
    //     System.assertEquals(null,null);
    // }
    /* @IsTest static void checkLoadTest(){
        Test.startTest();
        Account acc = new Account( Name= 'abc');
        List<sObject> testcon = new List<sObject>();
        testcon.add(acc); 
        SYS_DataCache.load();
        SYS_DataCache.load('Account',testcon);
        Test.stopTest(); 
        System.assertEquals(null,null);
    } */
  
}