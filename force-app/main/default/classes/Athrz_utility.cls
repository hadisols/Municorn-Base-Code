public class Athrz_utility {
    public static String token { get; set; }
    public static Decimal amount { get; set; }
    public static String cardNumber { get; set; }
    public static String transactionId { get; set; }
    public static String error { get; set; }

    public static String gatewayId { get; set; }
    public static String endpoint { get; set; }
    public static String transactionKey { get; set; }
    public static String loginKey { get; set; }

    public static Boolean savePayment { get; set; }
    public static Boolean saveAsDefault { get; set; }

    public Athrz_utility() {
        
    }

    public static void refund(String refundRequest, String gatewayId) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        SYS_IntegrationLog__c transactionLog = new SYS_IntegrationLog__c();
        Athrz_utility.gatewayId = gatewayId;
        getPaymentGateway(gatewayId);

        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setBody(refundRequest);

        HttpResponse resp = http.send(req);
        System.debug('#### refund call status: '+resp.getStatus());
        System.debug('#### refund call code: '+resp.getStatusCode());
        System.debug('#### refund : '+resp.getBody());
        if(!errorResponse(resp.getBody().replace('\uFEFF', ''))) {
            transactionLog = SYS_Helper.getLogsToInsert(resp.getBody().replace('\uFEFF', ''));
            transactionLog.Status__c = 'NEW';
            transactionLog.Type__c = 'INBOUND';
            transactionLog.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
            transactionLog.SYS_Operation_Type__c = 'UPSERT';
            // transactionLog.whatid__c = accountId;
            transactionLog.Entity_Name__c = 'Transaction__c';
            transactionLog.How_to_process__c = 'use_object_setting';
            transactionLog.SYS_Http_Status__c = 200;
            transactionLog.ObjectSettingId__c = 'Transaction';
            transactionLog.Resource__c = 'transaction';

            insert transactionLog;
        }
    }

    public static List<Messaging.SingleEmailMessage> getEmails(List<String> intentList) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        EmailTemplate tempID = [SELECT Id,HTMLValue,Name FROM EmailTemplate WHERE Name ='Payment request email'];

        for(Payment_Intent__c intent : [SELECT Id, Athrz_Account__r.Name, Athrz_Account__r.Email__c, Athrz_Payment_Link__c,
        Athrz_Frequency__c, Athrz_Amount__c, Athrz_Currency_Code__c, Athrz_Scheduled_Payment__c
        FROM Payment_Intent__c WHERE Id =:intentList]) {

            String body = tempID.HTMLValue;
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();// create instance of SingleEmailMessage class 
            
            
            mail.toAddresses = new String[] {intent.Athrz_Account__r.Email__c}; //To email address
            
            mail.setReplyTo(userinfo.getUserEmail());
            mail.setSaveAsActivity(false);
            mail.setSenderDisplayName(userinfo.getname());

            String subject = System.Label.email_subject;
            
            mail.setSubject(subject);

            mail.htmlBody = Athrz_utility.getDonationTemplate(body, intent);
            emailList.add(mail);
        }

        return emailList;
    }

        //TODO send email address dynamic>>
    public static Messaging.SendEmailResult sendEmail(String uuid) {
        EmailTemplate tempID = [SELECT Id,HTMLValue,Name FROM EmailTemplate WHERE Name ='Payment request email'];
        System.debug(uuid);
        Payment_Intent__c paymentRequest = [SELECT Id, Athrz_Email__c, Athrz_Account__r.Name, Athrz_Account__r.Email__c, Athrz_Payment_Link__c,
                                            Athrz_Frequency__c, Athrz_Amount__c, Athrz_Currency_Code__c, Athrz_Scheduled_Payment__c
                                            FROM Payment_Intent__c WHERE athrz_uuid__c =:uuid];

        String body = tempID.HTMLValue;
        Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();// create instance of SingleEmailMessage class 
        
        
        mail.toAddresses = new String[] {paymentRequest.Athrz_Email__c};
        
        mail.setReplyTo(userinfo.getUserEmail());
        mail.setSaveAsActivity(false);
        mail.setSenderDisplayName(userinfo.getname());

        String subject = System.Label.email_subject;
        
        mail.setSubject(subject);

        mail.htmlBody = Athrz_utility.getDonationTemplate(body, paymentRequest);
        
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {mail};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        return results[0];
    }


    public static String getDonationTemplate(String body, Payment_Intent__c paymentRequests) {
        // StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'donation_template' LIMIT 1];
        String emailMessage = System.Label.email_message;
        String userSalutation = System.Label.email_user_salutation;
        String orgName = 'Jason Emer MD';
        return body
                .replace('{{amount_field}}', PaymentRequest__c.fields.Amount__c.getDescribe().label)
                .replace('{{frequency_field}}', PaymentRequest__c.fields.Frequency__c.getDescribe().label)
                .replace('{{first_charge_date_field}}', PaymentRequest__c.fields.Scheduled_Payment__c.getDescribe().label)
                .replace('{{pay_button_text}}', System.Label.email_pay_button_text)
                .replace('{{email_message}}', emailMessage.replace('{{orgName}}', orgName))
                .replace('{{user_salutation}}', userSalutation.replace('{{userName}}', paymentRequests.Athrz_Account__r.Name))
                .replace('{{userName}}', paymentRequests.Athrz_Account__r.Name)
                .replace('{{payments}}', getPayments(new List<Payment_Intent__c>{paymentRequests}))
                .replace('{{link}}', paymentRequests.Athrz_Payment_Link__c);
                 
    }

    private static String getPayments(List<Payment_Intent__c> payments) {
        String paymentList = '';
        for (Payment_Intent__c paymentRequest : payments) {
            paymentList += '<tr>' +
                    '<td style="text-align:center">' + getFrequencyDisplayName(paymentRequest.Athrz_Frequency__c) + '</td>' +
                    '<td style="text-align:center">' + paymentRequest.Athrz_Amount__c + ' ' + 'USD' + '</td>' +
                    '<td style="text-align:center">' + paymentRequest.Athrz_Scheduled_Payment__c.format() + '</td>' +
                    '</tr>';
        }
        return paymentList;
    }

    private static String getFrequencyDisplayName(String frequency) {
       return frequency == 'single' ? System.Label.frequency_single
               : frequency == 'month' ? System.Label.frequency_month
                       : frequency == 'quarter' ? System.Label.frequency_quarter
                               : frequency == 'year' ? System.Label.frequency_year: null;
    }

    public static Payment_Intent__c getPaymentIntent(ChargeRequest chargeReq) {
        Payment_Intent__c intent = new Payment_Intent__c();
        intent.Name = chargeReq.intentName;
        intent.Athrz_Frequency__c	 = chargeReq.frequency;
        intent.Athrz_Email__c = chargeReq.emailId;
        intent.Athrz_Account__c = chargeReq.accountId;
        intent.Status__c = 'payment_new';
        intent.Athrz_First_Charge_Date__c = chargeReq.firstChargeDate;
        intent.Athrz_PaymentType__c = chargeReq.paymentType;
        intent.Payment_Gateway__c = chargeReq.gatewayId;
        intent.Athrz_Payment_Method__c = chargeReq.paymentMethod;
        intent.Athrz_Scheduled_Payment__c = chargeReq.firstChargeDate;
        intent.put(chargeReq.intentParentApiName, chargeReq.LookUp);
        return intent;
    }

    public static Activity__c getActivityRecord(ChargeRequest chargeReq, String intentId) {
        Activity__c activity = new Activity__c();
        activity.Account__c = chargeReq.accountId;
        activity.Payment_Intent__c = intentId;
        activity.Type__c = 'email';
        activity.Status__c = 'New';
        activity.When__c = Datetime.now();
        activity.Email__c = chargeReq.emailId;

        return activity;
    }

    public static Subscription__c getSubscription(ChargeRequest chargeReq) {
        Subscription__c sub = new Subscription__c();
        sub.Account__c = chargeReq.accountId;
        sub.Payment_Gateway__c = chargeReq.gatewayId;
        sub.Payment_Method__c = chargeReq.paymentMethod;
        sub.Athrz_Start_Date__c = chargeReq.firstChargeDate;
        sub.Athrz_Occurrence__c = chargeReq.occurrence + '';
        sub.Frequency__c = chargeReq.frequency;
        sub.Athrz_Interval_Unit__c	= 'months';
        sub.put(chargeReq.subscriptionParentApiName, chargeReq.LookUp);
        if(chargeReq.frequency == 'month') {
            sub.Athrz_Interval_Length__c = '1';
        } else if(chargeReq.frequency == 'quarter') {
            sub.Athrz_Interval_Length__c = '3';
        } else if(chargeReq.frequency == 'year') {
            sub.Athrz_Interval_Length__c = '12';
        } else {
            sub.Athrz_Interval_Length__c = '1';
        }

        return sub;
    }

    public static void subscribeRequest(String subscriptionId, String gatewayId, String obj_type, String accountId) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String reqbody, responseCode;
        SYS_ApplicationService appService = new SYS_ApplicationService();
        SYS_IntegrationLog__c subsLog = new SYS_IntegrationLog__c();
        Athrz_utility.gatewayId = gatewayId;
        Payment_Gateway__c gateway = getPaymentGateway(gatewayId);
        
        SYS_DataCache.INT_TYPE = 'Authorize';
        // SYS_DataCache.OBJ_TYPE = 'Subscription';
        SYS_DataCache.OBJ_TYPE = obj_type;
        List<Subscription__c> newList = [select id from Subscription__c where id = :subscriptionId];
        appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ApexHandler__c).newInstance();
                
        Map<Id, String> jsonListForOutbound = appService.transformSObjectToJson(newList);
        reqbody = jsonListForOutbound.get(subscriptionId);
                
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setBody(reqbody);

        System.debug('request '+req);
        System.debug('request body '+reqbody);
        HttpResponse resp = http.send(req);
        System.debug('#### subscription status: '+resp.getStatus());
        System.debug('#### subscription code: '+resp.getStatusCode());
        System.debug('#### subscription: '+resp.getBody());
        if(!errorResponse(resp.getBody().replace('\uFEFF', ''))) {
            subsLog = SYS_Helper.getLogsToInsert(resp.getBody().replace('\uFEFF', ''));
            subsLog.Status__c = 'NEW';
            subsLog.Type__c = 'INBOUND';
            subsLog.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
            subsLog.SYS_Operation_Type__c = 'UPDATE';
            // subsLog.whatid__c = accountId;
            subsLog.Entity_Name__c = 'Subscription__c';
            subsLog.How_to_process__c = 'use_object_setting';
            subsLog.SYS_Http_Status__c = 200;
            subsLog.ObjectSettingId__c = 'Subscription';
            subsLog.Resource__c = 'subscription';

            insert subsLog;
        } else {
            System.debug('subscription failed'+ error);
        }
    }


    public static String chargePayment(String intentId, String gatewayId, String obj_type, String accountId) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String reqbody, responseCode;
        SYS_ApplicationService appService = new SYS_ApplicationService();
        SYS_IntegrationLog__c transactionLog = new SYS_IntegrationLog__c();
        Athrz_utility.gatewayId = gatewayId;
        Payment_Gateway__c gateway = getPaymentGateway(gatewayId);
        Payment_Intent__c paymentReq = new Payment_Intent__c(Id = intentId);
        String transactionId = '';
        
        SYS_DataCache.INT_TYPE = 'Authorize';
        // SYS_DataCache.OBJ_TYPE = 'Payment_Intent';
        SYS_DataCache.OBJ_TYPE = obj_type;
        List<Payment_Intent__c> newList = [select id from Payment_Intent__c where id = :intentId];
        appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ApexHandler__c).newInstance();
                
        Map<Id, String> jsonListForOutbound = appService.transformSObjectToJson(newList);
        reqbody = jsonListForOutbound.get(intentId);
                
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setBody(reqbody);

        HttpResponse resp = http.send(req);
        System.debug('#### transaction status: '+resp.getStatus());
        System.debug('#### transaction code: '+resp.getStatusCode());
        System.debug('#### transaction: '+resp.getBody());
        if(!errorResponse(resp.getBody().replace('\uFEFF', ''))) {
            
            SYS_IntegrationLog__c integrationLog = SYS_Helper.getLogsToInsert(resp.getBody().replace('\uFEFF', '')); // TODO - Integartionlog handler SYS_integrationLogHandler
            integrationLog.Type__c = 'INBOUND';
            integrationLog.SYS_Operation_Type__c = 'INSERT';
            integrationLog.Status__c = 'DONE';
            integrationLog.SYS_IntegrationSettings__c = 'Authorize';
            integrationLog.Entity_Name__c = 'Transaction__c';
            integrationLog.How_to_process__c = 'ignore_log';

            
            List<sObject> sObjectsToDML = appService.transformJsonToSObject(resp.getBody().replace('\uFEFF', ''),'transaction-resp');
            transactionId = (String)sObjectsToDML[0].get('Transaction_Id__c');
            responseCode = (String)sObjectsToDML[0].get('Athrz_Response_Code__c');
            System.debug('transaction '+transactionId);

            if(transactionId != null) {
                reqbody =  getTransactionRequest(transactionId, loginKey, transactionKey);
                
                req.setMethod('GET');
                req.setBody(reqbody);

                resp = http.send(req);
                System.debug('#### resp status: '+resp.getStatus());
                System.debug('#### resp code: '+resp.getStatusCode());
                System.debug('#### get Transaction: '+resp.getBody());

                if(!errorResponse(resp.getBody().replace('\uFEFF', ''))) {
                    // List<sObject> upsertTrans = appService.transformJsonToSObject(resp.getBody().replace('\uFEFF', ''), 'transaction');
                    SYS_DataCache.OBJ_TYPE = 'Transaction';
                    transactionLog = SYS_Helper.getLogsToInsert(resp.getBody().replace('\uFEFF', ''));
                    transactionLog.Status__c = 'NEW';
                    transactionLog.Type__c = 'INBOUND';
                    transactionLog.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
                    transactionLog.SYS_Operation_Type__c = 'UPSERT';
                    // transactionLog.whatid__c = accountId;
                    transactionLog.Entity_Name__c = 'Transaction__c';
                    transactionLog.How_to_process__c = 'use_object_setting';
                    transactionLog.SYS_Http_Status__c = 200;
                    transactionLog.ObjectSettingId__c = 'Transaction';
                    transactionLog.Resource__c = 'transaction';

                    System.debug('boolean '+savePayment+' '+saveAsDefault);
                    if(responseCode != '1' && Athrz_utility.error != null) {

                        paymentReq = new Payment_Intent__c(
                            Id = intentId,
                            Status__c = 'payment_failed'
                        );
                        
                    } else {
                        paymentReq = new Payment_Intent__c(
                            Id = intentId,
                            Status__c = 'payment_done'
                        );
                    }

                    /* if((savePayment || saveAsDefault) && responseCode == '1') {
                        String paymentMethodId = processPaymentMethod(transactionId, accountId, gatewayId);
                    } */

                    // if(token == null && amount == null)  //WHY??
                    System.debug('responseCode =='+responseCode+' error =='+error);
                    
                    System.debug('transaction log inserted');
                    insert transactionLog;
                } else {
                    System.debug('error occured '+error);
                }
            }
            insert integrationLog;
            update paymentReq;
            
        } else {
            System.debug('transaction failed'+ error);
        } 
        return transactionId;
        /* if(responseCode != '1' && Athrz_utility.error != null) {

            Payment_Intent__c paymentReq = new Payment_Intent__c(
                Id = intentId,
                Status__c = 'payment_failed'
            );
            update paymentReq;
        } else {
            Payment_Intent__c paymentReq = new Payment_Intent__c(
                Id = intentId,
                Status__c = 'payment_done'
            );
            update paymentReq;
        } */
    }

    public static string getReceipt(String recordId) {
        Transaction__c transact = [select id, Transaction_Id__c, createddate, Amount__c from Transaction__c where Payment_Intent__c = :recordId order by createddate desc LIMIT 1];

        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
        gen.writeStringField('message', 'Payment done successfully!!');
        gen.writeStringField('amount', transact.Amount__c + '');
        gen.writeStringField('date', transact.createddate.format('MM/dd/yyyy HH:mm', 'Africa/Abidjan') + ' GMT');
        gen.writeStringField('transactionId', transact != null ? transact.Transaction_Id__c + '' : '');

        return gen.getAsString();
    }

    public static String processPaymentMethod(String transactionId, String accountId, String gatewayId) {
        String paymentMethodId, customerProfile, paymentProfile;
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        SYS_IntegrationLog__c paymentMethodLog = new SYS_IntegrationLog__c();

        SYS_DataCache.OBJ_TYPE = 'Payment_Method';
        SYS_DataCache.INT_TYPE = 'Authorize';

        getPaymentGateway(gatewayId);
        String reqbody = getProfileFromTransaction(transactionId, loginKey, transactionKey);
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setBody(reqbody);

        HttpResponse resp = http.send(req);
        System.debug('#### resp status: '+resp.getStatus());
        System.debug('#### resp code: '+resp.getStatusCode());
        System.debug('#### resp : '+resp.getBody());

        if(!errorResponse(resp.getBody().replace('\uFEFF', ''))) {
            System.debug('Profile created successfully');
            String body = resp.getBody().replace('\uFEFF', '');
            
            JSONParser parser = JSON.createParser(body);

            while (parser.nextToken() != null) {
                if (parser.getText() == 'customerPaymentProfileIdList') {
                    parser.nextToken();parser.nextToken();
                    // Compute the grand total price for all invoices.
                    paymentProfile= parser.getText();
                } 
                if (parser.getText() == 'customerProfileId') {
                    parser.nextToken();
                    customerProfile = parser.getText();
                }
            }
            Account acc = new Account(Id=accountId, Profile_Id__c=customerProfile);

            if(saveAsDefault) {
                
                reqbody = getPaymentProfileDetails(customerProfile, paymentProfile, accountId, loginKey, transactionKey);
                req.setMethod('GET');
                req.setBody(reqbody);

                resp = http.send(req);
                System.debug('#### resp payment method status: '+resp.getStatus());
                System.debug('#### resp code: '+resp.getStatusCode());
                System.debug('#### resp : '+resp.getBody());
                
                if(!errorResponse(resp.getBody().replace('\uFEFF', ''))) {
                    paymentMethodLog = SYS_Helper.getLogsToInsert(resp.getBody().replace('\uFEFF', ''));
                    paymentMethodLog.Status__c = 'NEW';
                    paymentMethodLog.Type__c = 'INBOUND';
                    paymentMethodLog.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
                    paymentMethodLog.SYS_Operation_Type__c = 'UPSERT';
                    // paymentMethodLog.whatid__c = accountId;
                    paymentMethodLog.Entity_Name__c = 'Payment_Method__c';
                    paymentMethodLog.How_to_process__c = 'use_object_setting';
                    paymentMethodLog.SYS_Http_Status__c = 200;
                    paymentMethodLog.ObjectSettingId__c = 'Payment_Method';
                    paymentMethodLog.Resource__c = 'paymentMethod';
                    paymentMethodLog.Gateway_Id__c = Athrz_utility.gatewayId;

                    insert paymentMethodLog;
                    Payment_Method__c method = [SELECT Id, Profile_Id__c FROM Payment_Method__c WHERE Profile_Id__c =: paymentProfile LIMIT 1];
                    if(method != null){
                        acc.Athrz_Default_Payment_Profile_Id__c	= method.Id;
                    }
                } else {
                    System.debug('Error in getpaymentMethod'+error);
                }
            }
            update acc;
        } else {
            System.debug('Error in createPaymentMethod'+error);
        }
        return paymentMethodId;
    }
    
    public static void syncPaymentMethod(String accountId, String gatewayId) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        SYS_IntegrationLog__c paymentMethodsLog = new SYS_IntegrationLog__c();
        String endpoint, transactionKey, loginKey;
        
        Athrz_utility.gatewayId = gatewayId;
        Payment_Gateway__c gateway = getPaymentGateway(gatewayId);
        if(gateway != null) {
            endpoint = gateway.Athrz_Base_Endpoint__c;
            transactionKey = gateway.Athrz_Transaction_Key__c;
            loginKey = gateway.Athrz_Api_Login_Id__c;
            String profileId = getProfileId(accountId);
            if(profileId == null) 
                return;
            
            String reqbody = getProfileDetails(profileId, accountId, loginKey, transactionKey);
            req.setMethod('GET');
            req.setEndpoint(endpoint);
            req.setBody(reqbody);

            HttpResponse resp = http.send(req);
            System.debug('#### resp status: '+resp.getStatus());
            System.debug('#### resp code: '+resp.getStatusCode());
            System.debug('#### resp: '+resp.getBody());

            if(!errorResponse(resp.getBody().replace('\uFEFF', ''))) {
                insertPaymentMethodsLog(resp.getBody().replace('\uFEFF', ''), accountId);
            } else {
                System.debug('Error occured while processing PaymentMethod');
            }
        }
        
    } 

    public static void insertPaymentMethodsLog(String responseBody, String accountId) {
        SYS_IntegrationLog__c paymentMethodsLog = new SYS_IntegrationLog__c();

        paymentMethodsLog = SYS_Helper.getLogsToInsert(responseBody);
        paymentMethodsLog.Status__c = 'NEW';
        paymentMethodsLog.Type__c = 'INBOUND';
        paymentMethodsLog.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
        paymentMethodsLog.SYS_Operation_Type__c = 'UPDATE';
        paymentMethodsLog.whatid__c = accountId;
        paymentMethodsLog.Entity_Name__c = 'Account';
        paymentMethodsLog.How_to_process__c = 'use_object_setting';
        paymentMethodsLog.SYS_Http_Status__c = 200;
        paymentMethodsLog.ObjectSettingId__c = 'Athrz_Account';
        paymentMethodsLog.Resource__c = 'customer-profile';
        paymentMethodsLog.Gateway_Id__c = Athrz_utility.gatewayId;
        try {
            insert paymentMethodsLog;
        } catch(Exception e) {
            System.debug('error '+e.getMessage());
        }
    }

    public static Boolean errorResponse(String response) {
        JSONParser parser = JSON.createParser(response);
        String message, responseCode;
        String errorToShow = '';
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText() == 'resultCode')) {
                // Get the value.
                parser.nextToken();
                // Compute the grand total price for all invoices.
                message = parser.getText();
            }
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME && 
            parser.getText() == 'responseCode') {

                parser.nextToken();
                responseCode = parser.getText();
            }
            System.debug('token '+parser.getText());
            if(parser.getCurrentToken() == JSONToken.START_ARRAY) {
                parser.nextToken();
                System.debug('token2 '+parser.getText());
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    
                    ErrorRead errorObj = (ErrorRead)parser.readValueAs(ErrorRead.class);
                    System.debug('error '+JSON.serialize(errorObj));
                    if(errorObj.code != '1')
                        errorToShow += (errorObj.errorText != null ? (errorObj.errorText + '(' + errorObj.errorCode + ') ') : '') +
                                    (errorObj.code != null ? (errorObj.text + '(' + errorObj.code + ') ') : '') ;
                }
            }
            // if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
            //     (parser.getText() == 'text')) {
                    
            //     parser.nextToken();
            //     if(message == 'Error' && Athrz_utility.error == null)
            //         error = parser.getText();
            // }
        }
        System.debug('error '+errorToShow +'\n'+Athrz_utility.error+'\n message'+message);
        System.debug('responseCode =='+responseCode);
        if(message == 'Error') {
            if(Athrz_utility.error == null)
                Athrz_utility.error = errorToShow;
            System.debug('return true');
            return true;
        } if(responseCode != '1' && responseCode != null) {
            if(Athrz_utility.error == null)
                Athrz_utility.error = errorToShow;
            return false;
        }
        else
            return false;
    }

    class ErrorRead {
        public String code;
        public String text;
        public String errorCode;
        public String errorText;
        
    }

    public static string getPaymentProfileDetails(String customerProfile, String paymentProfile, String accountId, String loginKey, String transactionKey) {
        String result;

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('getCustomerPaymentProfileRequest'); gen.writeStartObject();
        gen.writeFieldName('merchantAuthentication'); gen.writeStartObject();
        gen.writeStringField('name', loginKey);
        gen.writeStringField('transactionKey', transactionKey);
        gen.writeEndObject();
        gen.writeStringField('refId', accountId);
        gen.writeStringField('customerProfileId', customerProfile);
        gen.writeStringField('customerPaymentProfileId', paymentProfile);
        gen.writeStringField('includeIssuerInfo', 'true');
        gen.writeEndObject();
        gen.writeEndObject();

        result = gen.getAsString();
        System.debug('test'+result);

        return result;
    }

    public static string getProfileDetails(String profileId, String accountId, String loginKey, String transactionKey) {
        String result;

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('getCustomerProfileRequest'); gen.writeStartObject();
        gen.writeFieldName('merchantAuthentication'); gen.writeStartObject();
        gen.writeStringField('name', loginKey);
        gen.writeStringField('transactionKey', transactionKey);
        gen.writeEndObject();
        gen.writeStringField('refId', accountId);
        gen.writeStringField('customerProfileId', profileId);
        gen.writeStringField('includeIssuerInfo', 'true');
        gen.writeEndObject();
        gen.writeEndObject();

        result = gen.getAsString();
        System.debug('test'+result);

        return result;
    }

    public static String getTransactionRequest(String transId, String loginKey, String transactionKey) {

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('getTransactionDetailsRequest'); gen.writeStartObject();
        gen.writeFieldName('merchantAuthentication'); gen.writeStartObject();
        gen.writeStringField('name', loginKey);
        gen.writeStringField('transactionKey', transactionKey);
        gen.writeEndObject();
        // gen.writeStringField('refId', );
        gen.writeStringField('transId', transId);
        gen.writeEndObject();
        gen.writeEndObject();

        return gen.getAsString();
    }

    public static string getProfileFromTransaction(String transactionId, String loginKey, String transactionKey) {
        String result;

        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
        gen.writeFieldName('createCustomerProfileFromTransactionRequest'); gen.writeStartObject();
        gen.writeFieldName('merchantAuthentication'); gen.writeStartObject();
        gen.writeStringField('name', loginKey);
        gen.writeStringField('transactionKey', transactionKey);
        gen.writeEndObject();
        gen.writeStringField('transId', transactionId);
        gen.writeEndObject();
        gen.writeEndObject();

        result = gen.getAsString();
        System.debug('test'+result);

        return result;
    }

    public static Payment_Gateway__c getPaymentGateway(String gatewayId) {
        List<Payment_Gateway__c> gateway = [SELECT Id, Athrz_Active__c, Athrz_Api_Login_Id__c, Athrz_Base_Endpoint__c, Athrz_Public_Client_Key__c, Athrz_Transaction_Key__c
            FROM Payment_Gateway__c WHERE Id = :gatewayId LIMIT 1];
        if(gateway.size() > 0 ) {
            endpoint = gateway[0].Athrz_Base_Endpoint__c;
            transactionKey = gateway[0].Athrz_Transaction_Key__c;
            loginKey = gateway[0].Athrz_Api_Login_Id__c;
            return gateway[0];

        }
        return null;
    }

    public static String getProfileId(String accountId) {
        String profileId;
        Account acc = [SELECT Id , Profile_Id__c FROM Account WHERE Id = :accountId LIMIT 1];
        if(acc != null) {
            profileId = acc.Profile_Id__c;
        }
        return profileId;
    }

    public static List<Payment_Method__c> getCardPaymentMethods(String objectId) {
        System.debug('payment-methods');
        List<Payment_Method__c> paymentMethods = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, 
                                                    CreatedById, LastModifiedDate, LastModifiedById, 
                                                    SystemModstamp, Card_Number__c, Card_Type__c, 
                                                    Customer_Profile_Id__c, Profile_Id__c, Billing_City__c, 
                                                    Billing_Country__c, Billing_Email__c, Billing_First_Name__c, 
                                                    Billing_Last_Name__c, Billing_Phone__c, Billing_Postal_Code__c, 
                                                    Billing_Salutation__c, Billing_State__c, Billing_Street__c, 
                                                    Account__c , Athrz_Bank_Account_Number__c, Athrz_Bank_Account_Type__c 
                                                    FROM Payment_Method__c
                                                    WHERE Account__c = :objectId AND Athrz_Bank_Account_Number__c = null];
        
        return paymentMethods;
    }

    public static List<Payment_Method__c> getBankPaymentMethods(String objectId) {
        System.debug('payment-methods');
        List<Payment_Method__c> paymentMethods = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, 
                                                    CreatedById, LastModifiedDate, LastModifiedById, 
                                                    SystemModstamp, Card_Number__c, Card_Type__c, 
                                                    Customer_Profile_Id__c, Profile_Id__c, Billing_City__c, 
                                                    Billing_Country__c, Billing_Email__c, Billing_First_Name__c, 
                                                    Billing_Last_Name__c, Billing_Phone__c, Billing_Postal_Code__c, 
                                                    Billing_Salutation__c, Billing_State__c, Billing_Street__c, 
                                                    Account__c , Athrz_Bank_Account_Number__c, Athrz_Bank_Account_Type__c 
                                                    FROM Payment_Method__c
                                                    WHERE Account__c = :objectId AND Athrz_Bank_Account_Number__c != null];
        
        return paymentMethods;
    }

    public class Payload {
        @AuraEnabled public String token { get; set; }
        @AuraEnabled public Boolean savePayment { get; set; }
        @AuraEnabled public Boolean saveAsDefault { get; set; }
        @AuraEnabled public Boolean isCreditCard { get; set; }
        @AuraEnabled public String nameOnAccount { get; set; }
        @AuraEnabled public String accountNumber { get; set; }
        @AuraEnabled public String accountRoutingNumber { get; set; }
        @AuraEnabled public String accountType { get; set; }
    }

    public class ChargeRequest {
        @AuraEnabled public Id contactId { get; set; }
        @AuraEnabled public Id accountId { get; set; }
        @AuraEnabled public Id opportunityId { get; set; }
        @AuraEnabled public Decimal amount { get; set; }
        @AuraEnabled public Boolean newOpportunity { get; set; }
        @AuraEnabled public String opportunityName { get; set; }
        @AuraEnabled public String emailId { get; set; }
        @AuraEnabled public String frequency { get; set; }
        @AuraEnabled public Date firstChargeDate { get; set; }
        @AuraEnabled public String paymentType { get; set; }
        @AuraEnabled public String paymentRequestGroupId { get; set; }
        @AuraEnabled public Integer itemNumber { get; set; }
        @AuraEnabled public String contactName { get; set; }
        @AuraEnabled public String gatewayId { get; set; }
        @AuraEnabled public String paymentMethod { get; set; }
        @AuraEnabled public String intentName { get; set {
            intentName = Label.Payment_intent_prefix + ' ' + value;
        } }
        @AuraEnabled public String LookUp{ get; set; }
        @AuraEnabled public String intentParentApiName { get; set; }
        @AuraEnabled public String subscriptionParentApiName { get; set; }
        @AuraEnabled public Integer occurrence { get; set; }
    }
}