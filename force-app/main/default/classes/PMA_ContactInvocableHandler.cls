global class PMA_ContactInvocableHandler {
    global class MyInvocableVariable {
        @InvocableVariable(label='Contact Id' required=true)  
        global Id recId;
    
        @InvocableVariable(label='Contact Old Value' required=true)  
        global Contact oldVal;
    
        @InvocableVariable(label='Contact Current Value' required=true)
        global Contact newVal;

        @InvocableVariable(label='Order Id' required=true)  
        global Id orderId;

        @InvocableVariable(label= 'Contact Operation Type' required = true)
        global String operationType;
    }
    @InvocableMethod(label='Capture Contact Change' description='To Create Order and Payment Intent Record and Activity')
    global static void captureContactChangeRequest(List<MyInvocableVariable> myInvocableVariableList) {
        List<Contact> newList = new List<Contact>();
        List<Contact> oldList = new List<Contact>();
        Id orderId;
        
        List<SYS_IntegrationLog__c> insertSysLog = new List<SYS_IntegrationLog__c>();

        String operationType = myInvocableVariableList.size() > 0 ? myInvocableVariableList[0].operationType.toUppercase() : 'CREATE';


        for(MyInvocableVariable itr:myInvocableVariableList){
            newList.add(itr.newVal);   
            oldList.add(itr.oldVal);   
            orderId = itr.orderId;
        } 
        /* for (Contact g: newList) {
            g.UUID__c = SYS_Helper.getUUID();
        } */
        Payment_Gateway__c pmasandBox = new Payment_Gateway__c();
        List < Activity__c > activityList = new List < Activity__c > ();
        SYS_IntegrationLog__c errorLog = new SYS_IntegrationLog__c();
        Order__c order = new Order__c();
        order = [SELECT Id,Name,Account__c,Order_Type__c,Status__c,Vendor__c,Total_Price__c,UUID__c,CreatedDate,LastModifiedDate,OwnerId,
                (SELECT Id,Name,Line_Total_Price__c,List_Price__c,Order__c,Product__c,Quantity__c,Total_Price__c,CreatedDate,LastModifiedDate FROM Order_Items__r)
                FROM Order__c
                WHERE Id = :orderId AND (Order_Type__c = 'Registration') AND (Status__c = 'Active' )];
        pmasandBox = [SELECT Access_Token__c,CreatedDate,Gateway_Public_Key__c,Id,LastModifiedDate,Name,OwnerId,Test_Mode__c FROM Payment_Gateway__c LIMIT 1];
        //Payment Intent Init
        Date firstChargeDate = System.TODAY();
        String frequency = 'single';
        String paymentType = 'immediate';
        for (Contact g: newList) {
            Id accountId = g.AccountId;
            Id contactId = g.Id;
            Id opportunityId = null;
            Double amount = order.Total_Price__c;
            //String fromPhone = PMA_ExternalSiteFormsUtility.formatPhone(g.Plivo_Sender_Id__c);
            String toPhone = PMA_ExternalSiteFormsUtility.formatPhone(g.Phone_Number__c);
            String email = g.Email;
            String paymentName = 'Payment for Membership Fees by ' + g.FirstName + ' ' + g.LastName;
            Id paymentGatewayId = pmasandBox.Id;
            Payment_Intent__c payreq = PaymentIntentService.createNewPaymentIntent(paymentName , paymentGatewayId , contactId, accountId, opportunityId, orderId, paymentType, amount, email, frequency, firstChargeDate);
            if (payreq.Id != null) {
                String subject = 'Outbound SMS to ' + g.LastName + ' - ' + toPhone + ' for PMA MemberShip Purchase';
                String messageBody = 'Please Pay $' + payreq.Amount__c + ' to Start PMA Membership ' + payreq.Payment_Link__c;
                Activity__c activityCreate = CustomActivityService.createNewSmsActivity(contactId, toPhone, email, subject, messageBody);
                
            } else{
                //TODO write handler if failure
                System.debug('DML Error in Creation of Payment Intent: ');
                //Generate a Log record
                errorLog.data0__c = 'Exception Type: DML Error Exception Message: Error in Creation of Payment Intent';
                errorLog.Type__c = 'RESPONSE';
                errorLog.Status__c = 'ERROR';
                errorLog.How_To_Process__c = 'ignore_log';
            }
        }
        if (errorLog != new SYS_IntegrationLog__c()) {
            insert errorLog;
        }
    }
}