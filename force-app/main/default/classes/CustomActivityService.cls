public class CustomActivityService {
    public static Activity__c getActivityByUUID(String uuid){
        return [SELECT Id,Name,
            Customer__c,
            Customer__r.Name,
            Customer__r.Phone_Number__c,
            Customer__r.Email,
            Phone__c,Message__c,Email__c,Type__c,UUID__c,When__c,
            Log__c,Status__c,Subject__c,Trackable__c,CreatedDate,LastModifiedDate,OwnerId FROM Activity__c WHERE UUID__c =:uuid ];
    }

    public static Activity__c getActivityIntent(Id id) {
        return [SELECT Id,Name,
                Customer__c,
                Customer__r.Name,
                Customer__r.Phone_Number__c,
                Customer__r.Email,
                Phone__c,Message__c,Email__c,Type__c,UUID__c,When__c,
                Log__c,Status__c,Subject__c,Trackable__c,CreatedDate,LastModifiedDate,OwnerId FROM Activity__c WHERE Id = :id];
    }

    public static Activity__c createNewSmsActivity(
            //String paymentName,
            Id contactId,
            String toPhone,
            String email,
            String subject,
            String messageBody) {
        System.debug('Custom Activity service, create new Sms Activity for' +
                ', contact id=' + contactId +
                ', To Phone=' + toPhone +
                ', email=' + email +
                ', Subject =' + subject +
                ', Message Body =' + messageBody);

                Activity__c smsActivity = new Activity__c(
                Customer__c = contactId,
                Type__c = 'sms',
                Email__c = email,
                Status__c = 'Queued',
                When__c = System.now(),
                Phone__c = toPhone,
                Subject__c = subject,
                Message__c = messageBody
        );

        insert smsActivity;

        SYS_Tracker__c sysTracker = new SYS_Tracker__c();
        sysTracker.Type__c = 'Activity SMS';
        sysTracker.WhatId__c = contactId;
        sysTracker.WhoId__c = smsActivity.Id;
        //sysTracker.Valid_till__c = Now() + 865; 
        insert sysTracker;

        return getActivityIntent(smsActivity.Id);
    }

}
