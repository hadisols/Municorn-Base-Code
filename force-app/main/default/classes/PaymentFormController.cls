public class PaymentFormController {

    public Payment_Intent__c paymentIntent { get; set; }
    public String apiLoginId {get; set;}
    public String apiPublicKey {get; set;}
    public String paymentToken {get; set;}
    public String street {get; set;}
    public String city {get; set;}
    public String state {get; set;}
    public String zipcode {get; set;}
    public String country {get; set;}
    public String email {get; set;}
    public String accountName {get; set;}
    public String error {get; set;}
    public String paymentMessage {get; set;}
    public Boolean savePayment {get; set;}
    public Boolean saveAsDefault {get; set;}
    public List<Payment_Method__c> cards {get; set;}
    public List<Payment_Method__c> banks {get; set;}
    public String nameOnAccount {get; set;}
    public String accountNumber {get; set;}
    public String accountRoutingNumber {get; set;}
    public String accountType {get; set;}
    public String paymentMethodId {get; set;}
    public Boolean isPaymentMethod {get; set;}

    public String pageUrl {get; set;}
    public Boolean isCreditcard {get; set;}
    public String pageToken {get; set;}
    public Authorize.cls_hostedPage paymentPagerequest = new Authorize.cls_hostedPage();
    public String selectedMethod {get; set;}
    public Decimal amount {get; set;}
    public String response {get; set;}
    public String accountId {get; set;} 
    

    public PaymentFormController() {
        
        string BaseURL = ApexPages.currentPage().getHeaders().get('Host');
        System.debug('BaseURL '+BaseURL);
        isCreditcard = true; 
    } 

    public void initPage() {
        List<Payment_Intent__c> intents = getPaymentRequestByGroupId(ApexPages.currentPage().getParameters().get('t'));
        
        if(intents.size() > 0) {
            paymentIntent = intents[0];
            if(paymentIntent.Status__c == 'payment_done') {
                this.paymentMessage = Athrz_utility.getReceipt(paymentIntent.Id);
                // paymentMessage = 'Payment done sucessfully!!';
            }
            System.debug('message '+paymentMessage);
            apiLoginId = paymentIntent.Payment_Gateway__r.Athrz_Api_Login_Id__c;
            apiPublicKey = paymentIntent.Payment_Gateway__r.Athrz_Public_Client_Key__c;

            amount = paymentIntent.Athrz_Amount__c;
            accountId = paymentIntent.Athrz_Account__c;
            street = paymentIntent.Athrz_Account__r.BillingStreet;
            city = paymentIntent.Athrz_Account__r.BillingCity;
            state = paymentIntent.Athrz_Account__r.BillingState;
            zipcode = paymentIntent.Athrz_Account__r.BillingPostalCode;
            country = paymentIntent.Athrz_Account__r.BillingCountry;
            email = paymentIntent.Athrz_Email__c;
            accountName = paymentIntent.Athrz_Account__r.Name;

            cards = Athrz_utility.getCardPaymentMethods(accountId);
            banks = Athrz_utility.getBankPaymentMethods(accountId);


        } else {
            paymentMessage = 'Payment url is invalid!!';
        }
    }

    public void updateIntentBankDetails() {
        
        paymentIntent.Name_on_Account__c = nameOnAccount;
        paymentIntent.Bank_Account_Number__c = accountNumber;
        paymentIntent.Account_Routing_Number__c = accountRoutingNumber;
        paymentIntent.Account_Type__c = accountType;

        paymentIntent.Athrz_Payment_Method__c = paymentMethodId;

        update paymentIntent;

    }

    public void updatePaymentMethod() {
        paymentIntent.Athrz_Payment_Method__c = paymentMethodId;

        update paymentIntent;
    }


    public void charge() {
        System.debug('token is '+paymentToken+' credit card'+isCreditcard);
        
        Decimal total = amount;
        if(isCreditcard) {
            total = (amount * 1.0399).setScale(2);
        }

        paymentIntent.Athrz_Amount__c = total;
        paymentIntent.Athrz_Data_Value__c = paymentToken;
        paymentIntent.Status__c = 'payment_done';
        try {
            
            String recordId = paymentIntent.Id, gatewayId;
            Payment_Intent__c intent = [select id, Payment_Gateway__c from Payment_Intent__c where id = :recordId LIMIT 1];
            gatewayId = intent.Payment_Gateway__c;
            Athrz_utility.token = paymentToken;
            Athrz_utility.amount = total;
            Athrz_utility.savePayment = this.savePayment != null ?this.savePayment : false;
            Athrz_utility.saveAsDefault = this.saveAsDefault != null ?this.saveAsDefault : false;

            String resource = isCreditcard ? 'Payment_Intent' : 'Payment_Intent_Bank';

            resource = isPaymentMethod ? 'Payment_Intent_Proile' : resource;

            Athrz_utility.chargePayment(recordId, gatewayId, resource, accountId);
            if(Athrz_utility.error != null) 
                this.error = Athrz_utility.error;

            this.paymentMessage = Athrz_utility.getReceipt(recordId);
            update paymentIntent;
            
        } catch(Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getMessage());
            error = e.getMessage();
        }
        System.debug('error '+Athrz_utility.error);

        // String token = apexpages.currentPage().getParameters().get('token');
        // System.debug('toekn '+token);
    }

    public void chargePayment(String requestBody) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String reqbody = requestBody;
        String endPoint = paymentIntent.Payment_Gateway__r.Athrz_Base_Endpoint__c;
        SYS_ApplicationService appService = new SYS_ApplicationService();
        SYS_DataCache.INT_TYPE = 'Authorize';
        SYS_IntegrationLog__c paymentMethodsLog = new SYS_IntegrationLog__c();
                
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setBody(reqbody);

        HttpResponse resp = http.send(req);
        System.debug('#### resp2 status: '+resp.getStatus());
        System.debug('#### resp2 code: '+resp.getStatusCode());
        System.debug('#### resp2: '+resp.getBody());
        if(resp.getStatusCode() == 200) {
            String fixedString = EncodingUtil.convertFromHex(
                                    EncodingUtil.convertToHex(resp.getBodyAsBlob())
                                        .removeStart('feff').removeStart('fffe')
                                    ).toString();
            SYS_IntegrationLog__c integrationLog = SYS_integrationLogHandler.getLogsToInsert(resp.getBody().replace('\uFEFF', '')); // TODO - Integartionlog handler SYS_integrationLogHandler
            integrationLog.Type__c = 'INBOUND';
            integrationLog.SYS_Operation_Type__c = 'INSERT';
            integrationLog.Status__c = 'DONE';
            integrationLog.SYS_IntegrationSettings__c = 'Authorize';
            integrationLog.Entity_Name__c = 'Transaction__c';
            integrationLog.How_to_process__c = 'ignore_log';

            
            List<sObject> sObjectsToDML = appService.transformJsonToSObject(resp.getBody().replace('\uFEFF', ''),'transaction-resp');
            String transactionId = (String)sObjectsToDML[0].get('Transaction_Id__c');
            System.debug('transaction '+transactionId);

            if(transactionId != null) {
                reqbody =  getTransactionRequest(transactionId);
                
                req.setEndpoint('https://apitest.authorize.net/xml/v1/request.api');
                req.setMethod('GET');
                req.setBody(reqbody);

                resp = http.send(req);
                System.debug('#### resp status: '+resp.getStatus());
                System.debug('#### resp code: '+resp.getStatusCode());
                System.debug('#### get Transaction: '+resp.getBody());

                if(resp.getStatusCode() == 200) {
                    List<sObject> upsertTrans = appService.transformJsonToSObject(resp.getBody().replace('\uFEFF', ''), 'transaction');
                    String paymentRequestId = (String)upsertTrans[0].get('Payment_Intent__c');
                    
                    Payment_Intent__c paymentReq = new Payment_Intent__c(
                        Id = paymentRequestId,
                        Status__c = 'payment_done'
                    );
                    
                    // List<sObject> upsertMethod = appService.transformJsonToSObject(resp.getBody().replace('\uFEFF', ''), 'paymentMethod');
                    // List<Database.UpsertResult> resultsUpsert = Database.upsert(upsertMethod, Schema.getGlobalDescribe().get('Payment_Method__c').getDescribe().fields.getMap().get('Profile_Id__c'), false);
                    // for(Database.UpsertResult result : resultsUpsert){ 
                    //     if(result.isSuccess()){
                    //         SYS_debug.log('Payment Method update success'+result.getId());
                    //     } else {
                    //         SYS_debug.log('Insertion error Payment Method occured.');
                    //         for(Database.Error err : result.getErrors()) {
                    //             SYS_debug.log('The following error has occurred.');                    
                    //             SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
                    //             SYS_debug.log('Fields affected are: ' + err.getFields());
                    //         }
                    //     }
                    // }
                    //New changes 
                    
                    // reqbody =  getTransactionRequest(transactionId);
                            
                    // req.setEndpoint('https://apitest.authorize.net/xml/v1/request.api');
                    // req.setMethod('GET');
                    // req.setBody(reqbody);

                    // HttpResponse resp0 = http.send(req);
                    // System.debug('#### resp0 status: '+resp0.getStatus());
                    // System.debug('#### resp0 code: '+resp0.getStatusCode());
                    // System.debug('#### resp0: '+resp0.getBody());
                    
                    reqbody = SYS_integrationLogHandler.getProfileFromTransaction(transactionId);
                    req.setMethod('POST');
                    req.setBody(reqbody);

                    HttpResponse resp2 = http.send(req);
                    System.debug('#### resp2 status: '+resp2.getStatus());
                    System.debug('#### resp2 code: '+resp2.getStatusCode());
                    System.debug('#### resp2: '+resp2.getBody());

                    Map<String, Object> profileMap = (Map<String, Object>)JSON.deserializeUntyped(resp2.getBody().replace('\uFEFF', ''));
                    String profileId = (String)profileMap.get('customerProfileId');

                    reqbody = SYS_integrationLogHandler.getProfileDetails(profileId, accountId);
                    req.setMethod('GET');
                    req.setBody(reqbody);

                    HttpResponse resp3 = http.send(req);
                    System.debug('#### resp3 status: '+resp3.getStatus());
                    System.debug('#### resp3 code: '+resp3.getStatusCode());
                    System.debug('#### resp3: '+resp3.getBody());

                    paymentMethodsLog = SYS_Helper.getLogsToInsert(resp3.getBody().replace('\uFEFF', ''));
                    paymentMethodsLog.Status__c = 'NEW';
                    paymentMethodsLog.Type__c = 'INBOUND';
                    paymentMethodsLog.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
                    paymentMethodsLog.SYS_Operation_Type__c = 'UPSERT';
                    paymentMethodsLog.whatid__c = accountId;
                    paymentMethodsLog.Entity_Name__c = 'Account';
                    paymentMethodsLog.How_to_process__c = 'use_object_setting';
                    paymentMethodsLog.SYS_Http_Status__c = resp3.getStatusCode();
                    paymentMethodsLog.ObjectSettingId__c = 'Athrz_Account';
                    paymentMethodsLog.Resource__c = 'customer-profile';

                    List<Database.UpsertResult> results = Database.upsert(upsertTrans, Schema.getGlobalDescribe().get('Transaction__c').getDescribe().fields.getMap().get('Transaction_Id__c'), false);
                    for(Database.UpsertResult result : results){ 
                        if(result.isSuccess()){
                            SYS_debug.log('Transaction update success'+result.getId());
                        } else {
                            SYS_debug.log('Insertion error Transaction occured.');
                            for(Database.Error err : result.getErrors()) {
                                SYS_debug.log('The following error has occurred.');                    
                                SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
                                SYS_debug.log('Fields affected are: ' + err.getFields());
                            }
                        }
                    }

                    

                    update paymentReq;
                    
                }

            }

            insert integrationLog;
            SYS_DataCache.OBJ_TYPE = 'Athrz_Account';
            SYS_DataCache.sObjectApiName = 'Account';
            insert paymentMethodsLog;

        }
    }

    public static String getTransactionRequest(String transId) {

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('getTransactionDetailsRequest'); gen.writeStartObject();
        gen.writeFieldName('merchantAuthentication'); gen.writeStartObject();
        gen.writeStringField('name', '84vMVmF6jP');
        gen.writeStringField('transactionKey', '42Xr3CAw9k83jzu6');
        gen.writeEndObject();
        // gen.writeStringField('refId', );
        gen.writeStringField('transId', transId);
        gen.writeEndObject();
        gen.writeEndObject();

        return gen.getAsString();
    }

    public List<Payment_Intent__c> getPaymentRequestByGroupId(String uuid) {
        return [SELECT Id,
                    Athrz_Email__c,
                    Athrz_Account__c,
                    Athrz_Account__r.Id,
                    Athrz_Account__r.Name,
                    Athrz_Account__r.AccountNumber,
                    Athrz_Account__r.email__c,
                    Athrz_Account__r.Profile_Id__c,
                    Athrz_Account__r.BillingStreet,
                    Athrz_Account__r.BillingCity,
                    Athrz_Account__r.BillingPostalCode,
                    Athrz_Account__r.BillingCountry,
                    Athrz_Account__r.BillingState,
                    Status__c,
                    Athrz_Currency_Code__c,
                    Athrz_PaymentType__c,
                    Athrz_Amount__c,
                    Athrz_Reference_Id__c,
                    Athrz_First_Charge_Date__c,
                    Payment_Gateway__r.Athrz_Api_Login_Id__c,
                    Payment_Gateway__r.Athrz_Base_Endpoint__c,
                    Payment_Gateway__r.Athrz_Public_Client_Key__c
                FROM Payment_Intent__c WHERE athrz_uuid__c = :uuid LIMIT 1];
    }
    
    /*************** TRASH CODE ****************/

    // public void getToken() {
    //     System.debug('method of payment'+selectedMethod);
    //     // PaymentFormController paymentController = new PaymentFormController();
    //     isCreditcard = selectedMethod == 'cc' ? true :false;
    //     amount = isCreditcard ? (paymentIntent[0].Athrz_Amount__c * (1.0399)).setScale(2) : (paymentIntent[0].Athrz_Amount__c).setScale(2);
    //     if(paymentIntent.size() > 0) {
    //         System.debug('payment'+paymentIntent);

    //         SYS_DataCache.INT_TYPE = 'Authorize';
    //         SYS_DataCache.OBJ_TYPE = 'Payment_Intent';
    //         SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ApexHandler__c).newInstance();
            

    //         String body = appService.transformSObjectToJson(paymentIntent).values()[0];
    //         // String body = hostedPageRequest(paymentIntent[0]);

    //         String temp = submitFormRequest(body);
    //         System.debug('token-is'+temp);
    //         pageToken = temp;
    //         System.debug('page-token='+pageToken);
    //     }
    // }

    public void updateTransaction() {
        System.debug(response);
        String transactionId;
        String profileId;
        // String accountId;
        SYS_IntegrationLog__c logTrans = new SYS_IntegrationLog__c();
        SYS_IntegrationLog__c logAccount = new SYS_IntegrationLog__c();
        SYS_IntegrationLog__c integrationLog = SYS_integrationLogHandler.getLogsToInsert(response.replace('\uFEFF', '')); // TODO - Integartionlog handler SYS_integrationLogHandler
        integrationLog.Type__c = 'INBOUND';
        integrationLog.SYS_Operation_Type__c = 'UPDATE';
        integrationLog.Status__c = 'DONE';
        integrationLog.SYS_IntegrationSettings__c = 'Authorize';
        integrationLog.Entity_Name__c = 'PaymentRequest__c';
        integrationLog.How_to_process__c = 'ignore_log';

        

        Map<String, Object> mapTrans = (Map<String, Object>)JSON.deserializeUntyped(response);
        transactionId = (String)mapTrans.get('transId');

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String reqbody = ProcessTransactionWebhook.getTransactionRequest(transactionId);
                
        req.setEndpoint('https://apitest.authorize.net/xml/v1/request.api');
        req.setMethod('GET');
        req.setBody(reqbody);

        HttpResponse resp = http.send(req);
        System.debug('#### resp status: '+resp.getStatus());
        System.debug('#### resp code: '+resp.getStatusCode());
        System.debug('#### resp: '+resp.getBody());

        if(resp.getStatusCode() == 200) {
            logTrans = SYS_integrationLogHandler.getLogsToInsert(resp.getBody().replace('\uFEFF', '')); // TODO - Integartionlog handler SYS_integrationLogHandler
            logTrans.Type__c = 'INBOUND';
            logTrans.SYS_Operation_Type__c = 'INSERT';
            logTrans.Status__c = 'DONE';
            logTrans.SYS_IntegrationSettings__c = 'Authorize';
            logTrans.Entity_Name__c = 'Transaction__c';
        }
        reqbody = SYS_integrationLogHandler.getProfileFromTransaction(transactionId);
        req.setMethod('POST');
        req.setBody(reqbody);

        HttpResponse resp2 = http.send(req);
        System.debug('#### resp2 status: '+resp2.getStatus());
        System.debug('#### resp2 code: '+resp2.getStatusCode());
        System.debug('#### resp2: '+resp2.getBody());

        Map<String, Object> profileMap = (Map<String, Object>)JSON.deserializeUntyped(resp2.getBody().replace('\uFEFF', ''));
        profileId = (String)profileMap.get('customerProfileId');

        reqbody = SYS_integrationLogHandler.getProfileDetails(profileId, accountId);
        req.setMethod('GET');
        req.setBody(reqbody);

        HttpResponse resp3 = http.send(req);
        System.debug('#### resp3 status: '+resp3.getStatus());
        System.debug('#### resp3 code: '+resp3.getStatusCode());
        System.debug('#### resp3: '+resp3.getBody());

        if(resp.getStatusCode() == 200) {
            logAccount = SYS_integrationLogHandler.getLogsToInsert(resp3.getBody().replace('\uFEFF', '')); // TODO - Integartionlog handler SYS_integrationLogHandler
            logAccount.Type__c = 'INBOUND';
            logAccount.SYS_Operation_Type__c = 'INSERT';
            logAccount.Status__c = 'DONE';
            logAccount.SYS_IntegrationSettings__c = 'Authorize';
            logAccount.Entity_Name__c = 'Account';
        }

        insert logTrans;
        insert integrationLog;
        insert logAccount;
    }

    /**
     * All utility classes
     * JSON object is onordered so submitFormRequest is not useful
     * // PaymentFormController.hostedPageRequest(getPaymentRequestByGroupId('xwaiu-nvaeiln-sdfalkvnlnace')[0]);
     */

/**
    public String hostedPageRequest(PaymentRequest__c paymentReq) {
        String result;
        System.debug(paymentReq.Amount__c);
        String transferId = paymentReq.Id;
        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
        gen.writeFieldName('getHostedPaymentPageRequest'); gen.writeStartObject();
        gen.writeFieldName('merchantAuthentication'); gen.writeStartObject();
        gen.writeStringField('name', '84vMVmF6jP');
        gen.writeStringField('transactionKey', '42Xr3CAw9k83jzu6');
        gen.writeEndObject();
        gen.writeStringField('refId', transferId);
        gen.writeFieldName('transactionRequest'); gen.writeStartObject();
        gen.writeStringField('transactionType', 'authCaptureTransaction');
        gen.writeStringField('amount', String.valueOf(amount) );
        gen.writeFieldName('profile'); gen.writeStartObject();
        if(paymentReq.Account__r.Profile_Id__c != null) {
            gen.writeStringField('customerProfileId', paymentReq.Account__r.Profile_Id__c );
        }
        gen.writeEndObject();
        gen.writeFieldName('customer'); gen.writeStartObject();
        gen.writeStringField('email', paymentReq.Account__r.email__c != null ? paymentReq.Account__r.email__c : '');
        gen.writeEndObject();
        gen.writeFieldName('billTo'); gen.writeStartObject();
        gen.writeStringField('firstName', paymentReq.Account__r.name != null ? paymentReq.Account__r.name : '');
        gen.writeStringField('lastName', paymentReq.Account__r.name != null ? paymentReq.Account__r.name : '');
        gen.writeStringField('company', paymentReq.Account__r.name != null ? paymentReq.Account__r.name : '');
        gen.writeStringField('address', paymentReq.Account__r.BillingStreet != null ? paymentReq.Account__r.BillingStreet : '');
        gen.writeStringField('city', paymentReq.Account__r.BillingCity != null ? paymentReq.Account__r.BillingCity : '');
        gen.writeStringField('state', paymentReq.Account__r.BillingState != null ? paymentReq.Account__r.BillingState : '');
        gen.writeStringField('zip', paymentReq.Account__r.BillingPostalCode != null ? paymentReq.Account__r.BillingPostalCode : '');
        gen.writeStringField('country', paymentReq.Account__r.BillingCountry != null ? paymentReq.Account__r.BillingCountry : '');
        gen.writeEndObject();
        gen.writeEndObject();
        gen.writeFieldName('hostedPaymentSettings');gen.writeStartObject(); 
        gen.writeFieldName('setting');gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('settingName', 'hostedPaymentReturnOptions');
        gen.writeStringField('settingValue', '{\"showReceipt\": true, \"url\": \"' + pageUrl + '", \"urlText\": \"Continue\", \"cancelUrl\": \"'+ pageUrl +'", \"cancelUrlText\": \"Cancel\"}');
        gen.writeEndObject();
        gen.writeStartObject();
        gen.writeStringField('settingName', 'hostedPaymentButtonOptions');
        gen.writeStringField('settingValue', '{\"text\": \"Pay\"}');
        gen.writeEndObject();
        gen.writeStartObject();
        gen.writeStringField('settingName', 'hostedPaymentStyleOptions');
        gen.writeStringField('settingValue', '{\"bgColor\": \"blue\"}');
        gen.writeEndObject();
        gen.writeStartObject();
        gen.writeStringField('settingName', 'hostedPaymentPaymentOptions');
        gen.writeStringField('settingValue', '{\"cardCodeRequired\": false, \"showCreditCard\": '+ isCreditcard +', \"showBankAccount\": '+ !isCreditcard +'}');
        gen.writeEndObject();
        gen.writeStartObject();
        gen.writeStringField('settingName', 'hostedPaymentSecurityOptions');
        gen.writeStringField('settingValue', '{\"captcha\": false}');
        gen.writeEndObject();
        gen.writeStartObject();
        gen.writeStringField('settingName', 'hostedPaymentShippingAddressOptions');
        gen.writeStringField('settingValue', '{\"show\": false, \"required\": false}');
        gen.writeEndObject();
        gen.writeStartObject();
        gen.writeStringField('settingName', 'hostedPaymentBillingAddressOptions');
        gen.writeStringField('settingValue', '{\"show\": true, \"required\": false}');
        gen.writeEndObject();
        gen.writeStartObject();
        gen.writeStringField('settingName', 'hostedPaymentCustomerOptions');
        gen.writeStringField('settingValue', '{\"showEmail\": false, \"requiredEmail\": false, \"addPaymentProfile\": true}');
        gen.writeEndObject();
        gen.writeStartObject();
        gen.writeStringField('settingName', 'hostedPaymentOrderOptions');
        gen.writeStringField('settingValue', '{\"show\": true, \"merchantName\": \"Jason Emer MD\"}');
        gen.writeEndObject();
        gen.writeStartObject();
        gen.writeStringField('settingName', 'hostedPaymentIFrameCommunicatorUrl');
        gen.writeStringField('settingValue', '{\"url\": \"' + pageUrl + '"}');
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject();
        gen.writeEndObject();
        gen.writeEndObject();

        result = gen.getAsString();
        System.debug('test'+result);

        return result;
    } */

    public String submitFormRequest(String body) {
        String tokenKey;
        SYS_IntegrationLog__c integrationLog = new SYS_IntegrationLog__c();
        IntegrationSetting__mdt integrationSetting = SYS_DataCache.integrationSetting.get(SYS_Datacache.INT_TYPE);
        String baseEndpoint = integrationSetting.BaseAPIEndPoint__c;

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(baseEndpoint);
        req.setMethod('POST');
        req.setBody(body);

        HttpResponse resp = http.send(req);
        System.debug('#### resp status: '+resp.getStatus());
        System.debug('#### resp code: '+resp.getStatusCode());
        System.debug('#### resp: '+resp.getBody());
        System.debug('## resp: '+EncodingUtil.convertToHex(resp.getBodyAsBlob()));
        if(resp.getStatusCode() == 200) {
            String fixedString = EncodingUtil.convertFromHex(
                                    EncodingUtil.convertToHex(resp.getBodyAsBlob())
                                        .removeStart('feff').removeStart('fffe')
                                    ).toString();
            integrationLog = SYS_integrationLogHandler.getLogsToInsert(resp.getBody()); // TODO - Integartionlog handler SYS_integrationLogHandler
            integrationLog.Type__c = 'INBOUND';
            integrationLog.SYS_Operation_Type__c = 'INSERT';
            integrationLog.Status__c = 'DONE';
            integrationLog.SYS_IntegrationSettings__c = 'Authorize';

            insert integrationLog;

            // JSON2Apex tokenObj = JSON2Apex.parse(resp.getBody().replace('\uFEFF', ''));
            // tokenKey = tokenObj.token;

            // Object tokenMap = JSON.deserializeUntyped(sysLog[0].data0__c);
            // if(tokenMap instanceOf Map<String, Object>) {
            //     tokenKey = (String)((Map<String, Object>)tokenMap).get('token');
            // }

            // JSONParser parser = JSON.createParser(resp.getBody().replace('\uFEFF', ''));
            // System.debug(parser.getText());
            // while (parser.nextToken() != null) {
            //     if(parser.getCurrentName() == 'token') {
            //         tokenKey = parser.getText();
            //     }
            //     System.debug('kleys=='+parser.getText());
            //     parser.nextToken();
            // }

        }
        return tokenKey;
    }

    

    public Authorize.cls_hostedPaymentSettings getSetting(Boolean creditCard) {
        Authorize.cls_hostedPaymentSettings result = new Authorize.cls_hostedPaymentSettings();

        String creditcardJson = '{"setting":[{"settingName":"hostedPaymentReturnOptions","settingValue":"{\\"showReceipt\\": true, \\"url\\": \\"https://mysite.com/receipt\\", \\"urlText\\": \\"Continue\\", \\"cancelUrl\\": \\"https://mysite.com/cancel\\", \\"cancelUrlText\\": \\"Cancel\\"}"},{"settingName":"hostedPaymentButtonOptions","settingValue":"{\\"text\\": \\"Pay\\"}"},{"settingName":"hostedPaymentStyleOptions","settingValue":"{\\"bgColor\\": \\"blue\\"}"},{"settingName":"hostedPaymentPaymentOptions","settingValue":"{\\"cardCodeRequired\\": false, \\"showCreditCard\\": true, \\"showBankAccount\\": false}"},{"settingName":"hostedPaymentSecurityOptions","settingValue":"{\\"captcha\\": false}"},{"settingName":"hostedPaymentShippingAddressOptions","settingValue":"{\\"show\\": false, \\"required\\": false}"},{"settingName":"hostedPaymentBillingAddressOptions","settingValue":"{\\"show\\": true, \\"required\\": false}"},{"settingName":"hostedPaymentCustomerOptions","settingValue":"{\\"showEmail\\": false, \\"requiredEmail\\": false, \\"addPaymentProfile\\": true}"},{"settingName":"hostedPaymentOrderOptions","settingValue":"{\\"show\\": true, \\"merchantName\\": \\"G and S Questions Inc.\\"}"},{"settingName":"hostedPaymentIFrameCommunicatorUrl","settingValue":"{\\"url\\": \\"https://mysite.com/special\\"}"}]}';
        String achJson = '{"setting":[{"settingName":"hostedPaymentReturnOptions","settingValue":"{\\"showReceipt\\": true, \\"url\\": \\"https://mysite.com/receipt\\", \\"urlText\\": \\"Continue\\", \\"cancelUrl\\": \\"https://mysite.com/cancel\\", \\"cancelUrlText\\": \\"Cancel\\"}"},{"settingName":"hostedPaymentButtonOptions","settingValue":"{\\"text\\": \\"Pay\\"}"},{"settingName":"hostedPaymentStyleOptions","settingValue":"{\\"bgColor\\": \\"blue\\"}"},{"settingName":"hostedPaymentPaymentOptions","settingValue":"{\\"cardCodeRequired\\": false, \\"showCreditCard\\": false, \\"showBankAccount\\": true}"},{"settingName":"hostedPaymentSecurityOptions","settingValue":"{\\"captcha\\": false}"},{"settingName":"hostedPaymentShippingAddressOptions","settingValue":"{\\"show\\": false, \\"required\\": false}"},{"settingName":"hostedPaymentBillingAddressOptions","settingValue":"{\\"show\\": true, \\"required\\": false}"},{"settingName":"hostedPaymentCustomerOptions","settingValue":"{\\"showEmail\\": false, \\"requiredEmail\\": false, \\"addPaymentProfile\\": true}"},{"settingName":"hostedPaymentOrderOptions","settingValue":"{\\"show\\": true, \\"merchantName\\": \\"G and S Questions Inc.\\"}"},{"settingName":"hostedPaymentIFrameCommunicatorUrl","settingValue":"{\\"url\\": \\"https://mysite.com/special\\"}"}]}';

        result = creditCard ?
                    (Authorize.cls_hostedPaymentSettings)JSON.deserialize(creditcardJson , Authorize.cls_hostedPaymentSettings.class) :
                    (Authorize.cls_hostedPaymentSettings)JSON.deserialize(achJson, Authorize.cls_hostedPaymentSettings.class);

        return result;
    }

    

    public String getHostedPageRequest(PaymentRequest__c paymentReq) {

        String requestBody;
        
        Authorize.cls_merchantAuthentication auth = new Authorize.cls_merchantAuthentication();

        Authorize.cls_customer email = new Authorize.cls_customer();
        email.email = paymentReq.Account__r.email__c;

        Authorize.cls_profile profile = new Authorize.cls_profile();
        profile.customerProfileId = paymentReq.Account__r.Profile_Id__c;

        Authorize.cls_billTo billingInfo = new Authorize.cls_billTo();
        billingInfo.firstName = paymentReq.Account__r.Name;
        billingInfo.lastName = paymentReq.Account__r.AccountNumber;

        Authorize.cls_transactionRequest request = new Authorize.cls_transactionRequest();
        request.amount = String.valueOf(paymentReq.Amount__c);
        request.profile = profile;
        request.customer = email;
        request.billTo = billingInfo;

        Authorize.cls_getHostedPaymentPageRequest pagerequest = new Authorize.cls_getHostedPaymentPageRequest();
        pagerequest.merchantAuthentication = auth;
        pagerequest.transactionRequest = request;
        pagerequest.hostedPaymentSettings = getSetting(isCreditcard);

        Authorize.cls_hostedPage form = new Authorize.cls_hostedPage();
        form.getHostedPaymentPageRequest = pagerequest;

        requestBody = JSON.serialize(form);
        System.debug('request ='+requestBody);
        return requestBody;
    }
}