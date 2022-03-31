@isTest
public with sharing class Athrz_SendEmailInvocableHandlerTest {
    public Athrz_SendEmailInvocableHandlerTest() {

    }
    @isTest
    static void sendEmail_positive() {
        SYS_TestDataFactory.createActivity(1);

        List<Activity__c> activities = [SELECT Id, UUID__c, Payment_Intent__c FROM Activity__c];
        Athrz_SendEmailInvocableHandler.sendEmailToCustomer(activities);

        activities = [SELECT Id, Message__c FROM Activity__c];
        System.debug('activity '+ activities[0]);
        System.assert(activities.size() > 0);
        System.assert(activities[0].Message__c == 'Email successfully sent');

    }
}