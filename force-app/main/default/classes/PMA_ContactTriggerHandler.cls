public class PMA_ContactTriggerHandler {
    public static void handleTrigger(List < Contact > contactList, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when BEFORE_INSERT {
                updateContactUUID(contactList);
            }

            when AFTER_INSERT { //AFTER_INSERT, AFTER_UPDATE
                addSMSActivityPaymentRequest(contactList);
            }
        }
    }
    public Static void updateContactUUID(List < Contact > contactList) {
        for (Contact g: contactList) {
            g.UUID__c = PMA_ExternalSiteFormsUtility.getUUID();
        }
    }
    Public Static Void addSMSActivityPaymentRequest(List < Contact > contactList) {
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
        for (Contact g: contactList) {

            Id accountId = g.AccountId;
            Id contactId = g.Id;
            Id opportunityId = null;
            String email = g.Email;
            String paymentName = 'Request ' + g.FirstName + ' ' + g.LastName + ' For $2';
            if (g.Phone_Number__c != '' && contactId != '') {
                PaymentRequest__c payreq = paymentsService.createNewPaymentRequest(paymentName, contactId, accountId, opportunityId, paymentType, amount, email, frequency, firstChargeDate, itemNumber, paymentRequestGroupId);
                if (payreq.Id != '') {
                    Activity__c activity = new Activity__c();
                    activity.Customer__c = g.Id;
                    //activity.UUID__c = activity_UUID;
                    activity.Type__c = 'sms';
                    activity.Email__c = g.Email;
                    activity.Status__c = 'Queued';
                    activity.Subject__c = 'Outbound SMS to ' + g.LastName + ' - ' + g.Phone_Number__c + ' For PMA Agreement';
                    activity.When__c = System.now();
                    activity.Phone__c = PMA_ExternalSiteFormsUtility.formatPhone(g.Phone_Number__c);
                    activity.Message__c = 'Please Pay $' + payreq.Amount__c + ' to Start PMA Membership ' + PMA_ExternalSiteFormsUtility.getGuestSiteUrl(guestPageUrl) + '' + payreq.PaymentRequests__r.uuid__c;
                    activityList.add(activity);
                }
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