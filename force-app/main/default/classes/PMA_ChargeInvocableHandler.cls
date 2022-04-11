global class PMA_ChargeInvocableHandler {
    global class MyInvocableVariable {
    
        @InvocableVariable(label='Order Current Value' required=true)
        global List<Order__c> newVal;

    }
    @InvocableMethod(label='Create PaymentIntent and Charge Active Orders' description='To Create PaymentIntent and Charge Active Order')
    global static void chargeActiveOrders(List<MyInvocableVariable> myInvocableVariableList) {
        List<Order__c> newList = new List<Order__c>();
        List<Id> orderIds = new List<Id>();
        Payment_Gateway__c pmasandBox = new Payment_Gateway__c();
        List<SYS_IntegrationLog__c> errorLogs = new List<SYS_IntegrationLog__c>();
        List<Order__c> orders = new List<Order__c>();
        List<Payment_Intent__c> paymentIntentsList = new List<Payment_Intent__c>();
        List<Payment_Intent__c> paymentIntentsListAfterInsert = new List<Payment_Intent__c>();
        List<Id> paymentIntentIds = new List<Id>();
        List<Transaction__c> transactionsList = new List<Transaction__c>();
        List<Id> transactionIds = new List<Id>();

        List<SYS_IntegrationLog__c> insertSysLog = new List<SYS_IntegrationLog__c>();
        newList = myInvocableVariableList.size() > 0 ? myInvocableVariableList[0].newVal : new List<Order__c>();

        for(Order__c itr:newList){
            orderIds.add(itr.Id);
        } 

        orders = [SELECT Id,Name,Account__c,Account__r.Name,Member__c,Member__r.Name,Member__r.Email,Order_Type__c,Status__c,Vendor__c,Total_Price__c,UUID__c,CreatedDate,LastModifiedDate,OwnerId,
                (SELECT Id,Name,Line_Total_Price__c,List_Price__c,Order__c,Product__c,Quantity__c,Total_Price__c,CreatedDate,LastModifiedDate FROM Order_Items__r)
                FROM Order__c
                WHERE Id IN :orderIds AND (Order_Type__c = 'POS') AND (Status__c = 'Active' )];
        pmasandBox = [SELECT Access_Token__c,CreatedDate,Gateway_Public_Key__c,Id,LastModifiedDate,Name,OwnerId,Test_Mode__c FROM Payment_Gateway__c LIMIT 1];
        //Payment Intent Init
        Date firstChargeDate = System.TODAY();
        String frequency = 'single';
        String paymentType = 'immediate';
        for (Order__c order: orders) {
            Id accountId = order.Account__c;
            Id contactId = order.Member__c;
            Id orderId = order.Id;
            Id opportunityId = null;
            Double amount = order.Total_Price__c;
            String email = order.Member__r.Email;
            String paymentName = 'Payment for '+order.Account__r.Name+' Services Rendered by ' + order.Member__r.Name;
            Id paymentGatewayId = pmasandBox.Id;
            Payment_Intent__c paymentIntent = new Payment_Intent__c(
                Name = paymentName,
                Payment_Gateway__c = paymentGatewayId,
                Contact__c = contactId,
                Account__c = accountId,
                Opportunity__c = opportunityId,
                Order__c = orderId,
                Email__c = email,
                // Status__c = 'payment_new',
                Payment_Type__c = paymentType,
                Frequency__c = frequency,
                First_Charge_Date__c = firstChargeDate,
                Amount__c = amount,
                Currency_Code__c = UserInfo.getDefaultCurrency(),
                UUID__c = SYS_Helper.getUUID());
            paymentIntentsList.add(paymentIntent);
        }
        List<Database.SaveResult> insertResults = Database.insert(paymentIntentsList, false);
        for(Integer i=0;i<insertResults.size();i++){
            if (insertResults.get(i).isSuccess()){
                paymentIntentIds.add(insertResults.get(i).getId());
            }else if (!insertResults.get(i).isSuccess()){
                SYS_IntegrationLog__c errorLog = new SYS_IntegrationLog__c();
                // DML operation failed
                Database.Error error = insertResults.get(i).getErrors().get(0);
                String failedDML = error.getMessage();
                // paymentIntentsList.get(i);//failed record from the list
                // system.debug('Failed ID'+paymentIntentsList.get(i).Id);
                System.debug('DML Error in Creation of Payment Intent: ');
                //Generate a Log record
                errorLog.data0__c = 'PMA_ChargeInvocableHandler :: Exception Type: Error in Creation of Payment Intent' + insertResults[0].getErrors() + ' Error Message: ' + error.getMessage();
                errorLog.Type__c = 'RESPONSE';
                errorLog.Status__c = 'ERROR';
                errorLog.How_To_Process__c = 'ignore_log';
                errorLogs.add(errorLog);
            }

        }
        System.debug('Inserted Payment Intent Records ' + paymentIntentIds );
        paymentIntentsListAfterInsert = [SELECT Id,Name,
                Payment_Gateway__c,
                Payment_Gateway__r.Name,
                Payment_Gateway__r.Gateway_Public_Key__c,
                Payment_Gateway__r.Test_Mode__c,
                Account__c,
                Account__r.Name,
                Contact__c,
                Contact__r.Name,
                Contact__r.LastName,
                Contact__r.FirstName,
                Contact__r.Phone_Number__c,
                Contact__r.Email,
                Opportunity__c,
                Opportunity__r.Name,
                Order__c,
                Order__r.Name,
                Amount__c,
                Frequency__c,
                Currency_Code__c,Email__c,First_Charge_Date__c,Payment_Link__c,
                Payment_Reference_Id__c,Payment_Type__c,Status__c,UUID__c FROM Payment_Intent__c WHERE ( Id IN :paymentIntentIds ) AND (Status__c !='payment_done') ];
        for(Payment_Intent__c intent:paymentIntentsListAfterInsert){
            Transaction__c tx = new Transaction__c();
            // tx.UUID__c = SYS_Helper.getUUID();
            tx.Name = intent.Name;            
            tx.Status__c = 'initiated';
            tx.Amount__c = intent.Amount__c;
            tx.CurrencyCode__c = intent.Currency_Code__c;
            tx.Description__c = intent.Account__r.Name + ' Services Rendered';
            tx.Account__c = intent.Account__c;
            tx.Contact__c = intent.Contact__c;
            tx.Payment_Intent__c = intent.Id;
            tx.TransactionDate__c = Datetime.now();
            transactionsList.add(tx);
        }
        List<Database.SaveResult> insertTransactionResults = Database.insert(transactionsList, false);
        for(Integer i=0;i<insertTransactionResults.size();i++){
            if (insertTransactionResults.get(i).isSuccess()){
                transactionIds.add(insertTransactionResults.get(i).getId());
            }else if (!insertTransactionResults.get(i).isSuccess()){
                SYS_IntegrationLog__c errorLog = new SYS_IntegrationLog__c();
                // DML operation failed
                Database.Error error = insertTransactionResults.get(i).getErrors().get(0);
                String failedDML = error.getMessage();
                System.debug('DML Error in Creation of Payment Intent: ');
                //Generate a Log record
                errorLog.data0__c = 'PMA_ChargeInvocableHandler :: Exception Type: Error in Creation of Payment Intent' + insertResults[0].getErrors() + ' Error Message: ' + error.getMessage();
                errorLog.Type__c = 'RESPONSE';
                errorLog.Status__c = 'ERROR';
                errorLog.How_To_Process__c = 'ignore_log';
                errorLogs.add(errorLog);
            }

        }
        if(errorLogs.size()>0){
            List<Database.SaveResult> insertErrorLogsResults = Database.insert(errorLogs, false);
        }       
    }
}