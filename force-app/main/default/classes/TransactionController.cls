public with sharing class TransactionController {
    private static StripeService stripeService = new StripeService();
    private static CustomLabelsService customLabelsService = new CustomLabelsService();
    private static PaymentsService paymentsService = new PaymentsService();
	private static TransactionService txnService = new TransactionService();
    
    public List<Stripe.Card> cards { get; set; }

    public String organization { get; set; }

    public String stripePaymentRequestJson { get; set; }
    public String error { get; set; }
    public String stripePublishableKey { get; set; }
    public String appMode { get; set; }

    public String labelsJson { get; set; }
    public Map<String, Object> labels { get; set; }
    public List<PaymentRequest__c> paymentRequests { get; set; }

    public Stripe.Payments payments { get; set; }
    public Contact contact { get; set; }

    public TransactionController() {
        //Get Payment Request Details
        paymentRequests = paymentsService.getPaymentRequestByGroupId(ApexPages.currentPage().getParameters().get('reqid'));
        System.debug('test paymentRequests '+paymentRequests);
        assert(!paymentRequests.isEmpty(), 'No payment requests found');
        if(!paymentRequests.isEmpty()){
        contact = [SELECT Id, Name, StripeCustomerId__c FROM Contact WHERE Id = :paymentRequests[0].Contact__r.Id];
            System.debug('test contact '+contact);
        }
        // TO DO Make it Dynamic
        // Integration Config
        organization = 'PMA Sandbox';
        stripePublishableKey = 'pk_test_51KH9E5LOYmne24XMvoh2W9GzFFTmNtc55HikJmvO0ZchotsFySezeamrZiI6o2yarDikjPxBMOQRU51PLN9J66M2004r9kXdXe';
        appMode = 'test';
        assert(organization != null, System.Label.error_message_invalid_organization);
        assert(stripePublishableKey != null, System.Label.error_message_stripe_setup_error);
		
        //Custom Labels Collection
        labels = customLabelsService.getCustomLabels();
        labelsJson = JSON.serialize(labels);

    }
    public void assert(Boolean condition, String message) {
        if (!condition) {
            this.error = message;
        }
    }


    public void initCards() {
        if(!paymentRequests.isEmpty()){
            Stripe.PaymentMethods paymentMethods = stripeService.getPaymentMethods(contact.Id);
            cards = paymentMethods.cards;
        }
    }

    public void charge() {
        error = null;
        System.debug('User payment request : ' + stripePaymentRequestJson);
        Stripe.UserPaymentRequest stripePaymentRequest = new Stripe.UserPaymentRequest();
        try {
            stripePaymentRequest = (Stripe.UserPaymentRequest) JSON.deserialize(stripePaymentRequestJson, Stripe.UserPaymentRequest.class);

            payments = stripeService.processPayments(paymentRequests, stripePaymentRequest);
            System.debug('Bulk payment response : ' + JSON.serialize(payments));
            /*
            for(Stripe.Payments payment: payments){
                System.debug('test payment response : ' + payment);
                //Transaction__c txnDetails = txnService.getTransactionByChargeId(payment.txn.StripeChargeId__c);
                //payment.txn = txnDetails;
            }
            */

        } catch (JSONException ex) {
            error = System.Label.error_message_bad_request;
        }
        error = null;
    }
}