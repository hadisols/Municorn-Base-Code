public class StripeService {

    private static StripeRestService stripeRest = new StripeRestService();
    private static TransactionService txnService = new TransactionService();
    private static PaymentsService paymentsService = new PaymentsService();

    public Stripe.PaymentMethods getPaymentMethods(Id contactId) {
        Stripe.PaymentMethods paymentMethods = new Stripe.PaymentMethods();
        try {
            Stripe.Customer cus = getCustomer(contactId);

            paymentMethods.bankAccounts = stripeRest.getBankAccounts(cus.id);
            paymentMethods.cards = stripeRest.getCards(cus.id);

            updateStripeCustomerId(contactId, cus.id);
        } catch (Stripe.RestException ex) {
            System.debug('Stripe error=' + ex.errorResponse);
        }
        return paymentMethods;
    }

    public Stripe.Payments processPayments(List<PaymentRequest__c> paymentRequests, Stripe.UserPaymentRequest request) {
        List<TxnResponseWrapper> txnResponses = new List<TxnResponseWrapper>();
        List<PaymentRequest__c> paymentRequestsResponse = new List<PaymentRequest__c>();

        Stripe.Payments payments = new Stripe.Payments();

        Id contactId = paymentRequests[0].Contact__c;
        Stripe.Customer customer = getCustomer(contactId);

        String stripeCustomerId = customer.id;
		System.debug('test paymentRequests proceess'+paymentRequests);
        System.debug('test customer proceess'+customer);
         System.debug('test stripeCustomerId proceess'+stripeCustomerId);
        String source = getSource(stripeCustomerId, request);
		System.debug('test source proceess'+source);
        for (PaymentRequest__c paymentRequest : paymentRequests) {
            if (paymentRequest.PaymentType__c == 'immediate') {
                Stripe.ErrorResponse error;
                Stripe.Charge charge = new Stripe.Charge();
                try {
                    String currencyType = UserInfo.getDefaultCurrency();
                    System.debug('Current currency=' + currencyType);
                    Long amount = getAmount(paymentRequest.Amount__c);
                    System.debug('test paymentRequest.Amount__c proceess'+paymentRequest.Amount__c);
                    System.debug('test amount proceess'+amount);
                    String description = 'Payment';

                    Map<String, Object> metadata = new Map<String, Object>();
                    metadata.put('opportunityId', paymentRequest.Opportunity__c);
                    metadata.put('contactId', paymentRequest.Contact__c);
                    metadata.put('accountId', paymentRequest.Account__c);
                    metadata.put('transactionId', paymentRequest.Id);
                    //metadata.put('uuid', paymentRequest.PaymentRequests__r.uuid__c);

                    charge = stripeRest.charge(amount, currencyType, description, source, metadata);
                } catch (Stripe.RestException ex) {
                    error = ex.errorResponse;
                }
                //Changed to Municorn Get Record
                Transaction__c txn = txnService.buildTransaction(paymentRequest);
                System.debug('test Charge Id '+charge.Id);
                //Transaction__c txn = txnService.getTransactionByChargeId(charge.Id);

                TxnResponseWrapper txnResponseWrapper = new TxnResponseWrapper();
                txnResponseWrapper.charge = charge;
                txnResponseWrapper.error = error;
                txnResponseWrapper.txn = txn;
                txnResponseWrapper.paymentRequest = paymentRequest;

                txnResponses.add(txnResponseWrapper);
                paymentRequestsResponse.add(paymentRequest);
            } else if (paymentRequest.PaymentType__c == 'subscription') {
                Double amount = paymentRequest.Amount__c;
                String interval = paymentRequest.Frequency__c;

                try {
                    Stripe.Product product = stripeRest.createProduct('defaultProduct');
                    Stripe.Plan plan = stripeRest.createPlan(getAmount(amount), UserInfo.getDefaultCurrency(), interval, product.name);

                    Stripe.Subscription subscription = stripeRest.createSubscription(plan.id, customer.id, paymentRequest);
                    paymentRequest.SubscriptionId__c = subscription.id;
                } catch (Stripe.RestException ex) {
                    Stripe.Error error = ex.errorResponse.error;
                    paymentRequest.Status__c = 'payment_failed';
                    paymentRequest.Status_Message__c = error.message;
                }
                if (paymentRequest.ItemNumber__c == null) {
                    paymentRequest.ItemNumber__c = 1;
                }
                paymentRequestsResponse.add(paymentRequest);
            }
        }
		//Todo get record details into  payments Wrapper
        for (TxnResponseWrapper txnResponse: txnResponses) {
            postProcessPayment(txnResponse.txn, txnResponse.paymentRequest, txnResponse.error, txnResponse.charge);
            // System.debug('item no='+txnService.getTransactionExtId(txnResponse.charge.id).PaymentRequestId__r.ItemNumber__c);
            System.debug('test txnResponse proceess '+txnResponse);
            System.debug('test txnResponse.charge.id proceess '+txnResponse.charge.id);
            //payments.registerPayment(txnService.getTransactionExtId(txnResponse.charge.id)); 
        }
        // update paymentRequestsResponse;
        // Todo Fix get Record details into  payments Wrapper
        for (PaymentRequest__c paymentRequest: paymentRequestsResponse) {
            System.debug('pymt id'+paymentRequest.Id);
            payments.registerPayment(paymentsService.getPaymentRequest(paymentRequest.Id));
        }
        payments.payments.sort();

        return payments;
    }

    public class TxnResponseWrapper {
        public Transaction__c txn;
        public PaymentRequest__c paymentRequest;
        public Stripe.ErrorResponse error;
        public Stripe.Charge charge;
    }

    private String getSource(String stripeCustomerId, Stripe.UserPaymentRequest request) {
        String paymentSource = request.selectedPaymentSource;
        String stripeToken = request.stripeToken == null ? request.bankToken : request.stripeToken;
        if (request.paymentMethod == 'new-card' && request.saveCard) {
            Stripe.Card card = registerCard(stripeToken, stripeCustomerId);
            paymentSource = card.id;
        }
        String source = '&customer=' + stripeCustomerId + '&source=' + paymentSource;
        source = String.isBlank(paymentSource) ? '&source=' + stripeToken: ('&customer=' + stripeCustomerId + '&source=' + paymentSource);
        return source;
    }

    public void charge(Transaction__c txn, Stripe.UserPaymentRequest request) {
        Stripe.ErrorResponse error;
        Stripe.Charge charge = new Stripe.Charge();
        String paymentSource = request.selectedPaymentSource;
        String stripeToken = request.stripeToken == null ? request.bankToken : request.stripeToken;
        try {
            Stripe.Customer customer = getCustomer(txn.PaymentRequestId__r.Contact__r.Id);

            String stripeCustomerId = customer.id;

            if (request.paymentMethod == 'new-card' && request.saveCard) {
                Stripe.Card card = registerCard(stripeToken, stripeCustomerId);
                paymentSource = card.id;
            }
            String source = '&customer=' + stripeCustomerId + '&source=' + paymentSource;
            source = String.isBlank(paymentSource) ? '&source=' + stripeToken: ('&customer=' + stripeCustomerId + '&source=' + paymentSource);

            String currencyType = UserInfo.getDefaultCurrency();
            System.debug('Current currency=' + currencyType);
            Long amount = getAmount(txn.Amount__c);
            String description = 'Payment';

            Map<String, Object> metadata = new Map<String, Object>();
            metadata.put('opportunityId', txn.PaymentRequestId__r.Opportunity__r.Id);
            metadata.put('contactId', txn.PaymentRequestId__r.Contact__r.Id);
            metadata.put('accountId', txn.PaymentRequestId__r.Account__r.Id);
            metadata.put('transactionId', txn.Id);

            charge = stripeRest.charge(amount, currencyType, description, source, metadata);
        } catch (Stripe.RestException ex) {
            error = ex.errorResponse;
        }
        postProcessPayment(txn, paymentsService.getPaymentRequest(txn.PaymentRequestId__r.Id), error, charge);
    }

    private Long getAmount(Decimal amount) {
        String currencyType = UserInfo.getDefaultCurrency();
        System.debug('Current currency=' + currencyType+' amount='+amount);
        return Math.roundToLong((Stripe.zeroDecimalCurrencies.contains(currencyType)) ? amount : amount * 100);
    }

    private void preProcessError(List<PaymentRequest__c> paymentRequests) {
        for (PaymentRequest__c paymentRequest : paymentRequests) {
            paymentRequest.Status__c = 'payment_failed'; 
        }

        // update paymentRequests;
    }

    //TODO - migrate to municorn
    private void postProcessPayment(Transaction__c txn,
            PaymentRequest__c sourcePaymentRequest,
            Stripe.ErrorResponse errorResp,
            Stripe.Charge charge) {
        Boolean success = errorResp == null && charge.captured == true;
        txn.Status__c = charge.status != null ? charge.status : 'failed';
        txn.StripeChargeId__c = success ? charge.id : null;
        txn.StatusMessage__c = success ? 'Transaction successful' : errorResp.error.message;
        txn.AmountRefunded__c = charge.amount_refunded;
        txn.FailureCode__c = errorResp != null ? errorResp.error.code : charge.failure_code;
        txn.FailureMessage__c = errorResp != null ? errorResp.error.message : charge.failure_message;
        txn.TransactionDate__c = Datetime.now();
        txn.PaymentMethodType__c = errorResp == null ? charge.payment_method_details.type : null;
        txn.PaymentMethod__c = errorResp != null ? '-' : charge.payment_method;
        txn.PaymentCardLast4Digits__c = errorResp == null && charge.payment_method_details.type == 'card' ? charge.payment_method_details.card.last4 : null;
        txn.PaymentBankLast4Digits__c = errorResp == null && charge.payment_method_details.type == 'ach_debit' ? charge.payment_method_details.ach_debit.last4 : null;
        txn.PaymentBankName__c = errorResp == null && charge.payment_method_details.type == 'ach_debit' ? charge.payment_method_details.ach_debit.bank_name : null;
        /*
        SYS_IntegrationLog__c logResp = SYS_integrationLogHandler.getLogsToInsert(JSON.serialize(charge));
        logResp.SYS_IntegrationSettings__c = SYS_Constants.INT_TYPE;
        logResp.Type__c = 'INBOUND';
        logResp.SYS_Operation_Type__c = 'RESPONSE';
        logResp.Status__c = 'NEW';
        logResp.QB_Entity__c = 'Transaction__c';
        System.debug('transaction==log');
        insert logResp;*/

        PaymentRequest__c paymentRequest = [SELECT Id, Status__c, ItemNumber__c, Opportunity__r.Id FROM PaymentRequest__c WHERE Id = :sourcePaymentRequest.Id];
        paymentRequest.Status__c = success ? 'payment_done' : 'payment_failed';
        if (paymentRequest.ItemNumber__c == null) {
            paymentRequest.ItemNumber__c = 1;
        }
/*
        if (success) {
            Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :paymentRequest.Opportunity__r.Id];
            opp.StageName = 'Closed';
            // update opp;
        }
*/
        // insert txn;
        // update paymentRequest; 
    }

    public void subscribe(PaymentRequest__c paymentRequest) {
        Id contactId = paymentRequest.Contact__c;
        Double amount = paymentRequest.Amount__c;
        String interval = paymentRequest.Frequency__c;
        Stripe.Customer cus = getCustomer(contactId);

        try {
            Stripe.Product product = stripeRest.createProduct('defaultProduct');
            Stripe.Plan plan = stripeRest.createPlan(getAmount(amount), UserInfo.getDefaultCurrency(), interval, product.name);

            Stripe.Subscription subscription = stripeRest.createSubscription(plan.id, cus.id, paymentRequest);
            paymentRequest.SubscriptionId__c = subscription.id;
        } catch (Stripe.RestException ex) {
            Stripe.Error error = ex.errorResponse.error;
            paymentRequest.Status__c = 'payment_failed';
            paymentRequest.Status_Message__c = error.message;
        } finally {
            update paymentRequest;
        }
    }

    private Stripe.Customer getCustomer(Id contactId) {
        String stripeCustomerId = [SELECT StripeCustomerId__c FROM Contact WHERE Id = :contactId].StripeCustomerId__c;

        Stripe.Customer cus = new Stripe.Customer();
        if (stripeCustomerId != null) {
            cus = stripeRest.getCustomer(stripeCustomerId);
        } else {
            cus = stripeRest.createCustomer();
            System.debug('Created new customer for account/contact=' + contactId + ' with stripe customer id=' + cus.id);
        }
        return cus;
    }

    private void updateStripeCustomerId(Id contactId, String stripeCustomerId) {
        Contact contact = [SELECT Id, StripeCustomerId__c FROM Contact WHERE Id = :contactId];
        if (contact.StripeCustomerId__c == null) {
            contact.StripeCustomerId__c = stripeCustomerId;
            update contact;
        }
    }

    private Stripe.Card registerCard(String stripeToken, String stripeCustomerId) {
        Stripe.Card card = stripeRest.createCard(stripeCustomerId, stripeToken);
        System.debug('Created new card for customer=' + stripeCustomerId + ' with stripe card id=' + card.id);

        stripeRest.setDefaultPaymentSource(stripeCustomerId, card.id);
        return card;
    }

    private void setDefaultSource(List<Stripe.Card> cards, Stripe.Customer cus) {
        String default_source = cus.default_source;
        System.debug('default_source=' + default_source);
        for (Stripe.Card card : cards) {
            if (card.id == default_source) {
                card.default_source = true;
            }
        }
    }
    public static String escape(String stripeResponse) {
        return stripeResponse.replace('"currency":', '"currency_x":').replace('"object":', '"object_x":');
    }
}