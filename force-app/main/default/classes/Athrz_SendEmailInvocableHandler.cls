global class Athrz_SendEmailInvocableHandler {
    public Athrz_SendEmailInvocableHandler() {

    }

    @InvocableMethod(label='Send email to customer')
    global static void sendEmailToCustomer(List<Payment_Intent__c> newList) {
        List<String> intentIds = new List<String>();
        for(Payment_Intent__c intent : newList) {
            intent.athrz_uuid__c = UUIDGenerator.createId();
            intentIds.add(intent.Id);
        }
        try {
            update newList;
            List<Messaging.SingleEmailMessage> emails = Athrz_utility.getEmails(intentIds);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
            for(Messaging.SendEmailResult res : results ){
                if(res.isSuccess()) 
                    System.debug('email sent');
                else {
                    for(Messaging.SendEmailError err: res.getErrors()) {
                        System.debug(err.getFields());
                        System.debug(err.getMessage());
                        System.debug('Object Id## '+err.getTargetObjectId());

                    }
                }
            }

        } catch(Exception e) {
            System.debug(e.getStackTraceString());
        }
    }
}
