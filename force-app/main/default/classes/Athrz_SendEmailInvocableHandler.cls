global class Athrz_SendEmailInvocableHandler {
    public Athrz_SendEmailInvocableHandler() {

    }

    @InvocableMethod(label='Send email to customer')
    global static void sendEmailToCustomer(List<Activity__c> newList) {
        Set<String> intentList = new List<String>();
        
        try {
            for(Activity__c activity : newList) {
                System.debug('uuid '+activity.UUID__c);
                activity.Message__c	= Athrz_utility.sendEmail(activity.UUID__c).success ? 
                                    'Email successfully sent' : 'Failed to send email';

            }
            update newList;

        } catch(Exception e) {
            System.debug(e.getStackTraceString());
        }
    }
}