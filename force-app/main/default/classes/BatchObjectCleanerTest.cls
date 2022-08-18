@isTest
public with sharing class BatchObjectCleanerTest {
    
    @isTest
    static void test_batchcleaner() {
        SYS_TestDataFactory.createTestRecords(5,5);

        Test.startTest();
        Database.executebatch(new BatchObjectCleaner('select id from contact', 'dev@adisols.com'));
        Test.stopTest();

        List<Contact> contacts = [select id from contact];
        System.assertEquals(contacts.size(), 0);
    }
}