global class PMA_ContactInvocableHandler {
    global class MyInvocableVariable {
        @InvocableVariable(label='Id' required=true)  
        global Id recId;
    
        @InvocableVariable(label='Old Value' required=true)  
        global Contact oldVal;
    
        @InvocableVariable(label='Current Value' required=true)
        global Contact newVal;

        @InvocableVariable(label= 'Operation Type' required = true)
        global String operationType;
    }
    @InvocableMethod(label='Capture Contact Change' description='To capture Activity and Payment Intent Record Creation')
    global static void captureContactChangeRequest(List<MyInvocableVariable> myInvocableVariableList) {
        List<Contact> newList = new List<Contact>();
        List<Contact> oldList = new List<Contact>();
        
        List<SYS_IntegrationLog__c> insertSysLog = new List<SYS_IntegrationLog__c>();

        String operationType = myInvocableVariableList.size() > 0 ? myInvocableVariableList[0].operationType.toUppercase() : 'INSERT';


        for(MyInvocableVariable itr:myInvocableVariableList){
            newList.add(itr.newVal);   
            oldList.add(itr.oldVal);   
        } 
        for (Contact g: newList) {
            g.UUID__c = PMA_ExternalSiteFormsUtility.getUUID();
        }
        PaymentsService paymentsService = new PaymentsService();
        List < Activity__c > activityList = new List < Activity__c > ();
        SYS_IntegrationLog__c errorLog = new SYS_IntegrationLog__c();

        //String activity_UUID;
        String guestPageUrl = 'StripePaymentPage?reqid=';
        //Payment Request Init
        Date firstChargeDate = System.TODAY();
        String frequency = 'single';
        String paymentType = 'immediate';
        String paymentRequestGroupId = PMA_ExternalSiteFormsUtility.getUUID();
        Double amount = 2.0;
        Integer itemNumber = 1;
        //activity_UUID = PMA_ExternalSiteFormsUtility.getUUID();
        for (Contact g: newList) {

            Id accountId = g.AccountId;
            Id contactId = g.Id;
            Id opportunityId = null;
            String email = g.Email;
            String paymentName = 'Request ' + g.FirstName + ' ' + g.LastName + ' For $2';

            if (g.Phone_Number__c != '' && contactId != null) {
                PaymentRequest__c payreq = paymentsService.createNewPaymentRequest(paymentName, contactId, accountId, opportunityId, paymentType, amount, email, frequency, firstChargeDate, itemNumber, paymentRequestGroupId);
                if (payreq.Id != null) {
                    //TODO move to Activity trigger
                    Activity__c activity = new Activity__c();
                    activity.Customer__c = g.Id;
                    //activity.UUID__c = activity_UUID;
                    activity.Type__c = 'sms';
                    activity.Email__c = g.Email;
                    activity.Status__c = 'Queued';
                    activity.Subject__c = 'Outbound SMS to ' + g.LastName + ' - ' + g.Phone_Number__c + ' For PMA Agreement';
                    activity.When__c = System.now();
                    activity.Phone__c = PMA_ExternalSiteFormsUtility.formatPhone(g.Phone_Number__c);
                    activity.Message__c = 'Please Pay $' + payreq.Amount__c + ' to Start PMA Membership ' + PMA_ExternalSiteFormsUtility.getIframeSiteUrl(guestPageUrl) + '' + payreq.PaymentRequests__r.uuid__c;
                    activityList.add(activity);
                } else{
                    //TODO write handler if failure
                }
            } else{
                //TODO write handler if failure
            }
        }
        if (activityList.size() > 0) {
            try {
                insert activityList;
            } catch (Exception e) {
                System.debug('Error in Storing Contact: ' + e.getMessage());
                //Generate a Log record
                errorLog.data0__c = 'Exception Type: ' + e.getTypeName() + ' Exception Message: ' + e.getMessage();
                // errorLog = SYS_integrationLogHandler.getLogsToInsert( error_message.toString() );
                errorLog.Type__c = 'OUTBOUND';
                errorLog.Status__c = 'ERROR';
                errorLog.How_To_Process__c = 'ignore_log';
            }
            if (errorLog != new SYS_IntegrationLog__c()) {
                insert errorLog;
            }
        }

    }
}