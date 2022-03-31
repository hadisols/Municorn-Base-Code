global class Athrz_SendEmailInvocableHandler {
    
    @InvocableMethod(label='Send email to customer')
    global static void sendEmailToCustomer(List<Activity__c> newList) {
        Set<String> intentList = new Set<String>();
        Map<String, String> mapIntentUuid = new Map<String, String>();

        for(Activity__c activity : newList) {
            intentList.add(activity.Payment_Intent__c);
        }
        for(Payment_Intent__c intent : [SELECT Id, athrz_uuid__c FROM Payment_Intent__c WHERE Id in :intentList]) {
            mapIntentUuid.put(intent.Id, intent.athrz_uuid__c);
        }
        try {
            for(Activity__c activity : newList) {
                System.debug('uuid '+mapIntentUuid.get(activity.Payment_Intent__c));
                activity.Message__c	= Athrz_utility.sendEmail(mapIntentUuid.get(activity.Payment_Intent__c)).success ? 
                                    'Email successfully sent' : 'Failed to send email';

            }
            update newList;

        } catch(Exception e) {
            System.debug(e.getStackTraceString());
        }
    }
}