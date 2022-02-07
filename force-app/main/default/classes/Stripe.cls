public class Stripe {

    public static Set<String> zeroDecimalCurrencies = new Set<String>();

    static {
        zeroDecimalCurrencies.add('MGA');
        zeroDecimalCurrencies.add('BIF');
        zeroDecimalCurrencies.add('CLP');
        zeroDecimalCurrencies.add('DJF');
        zeroDecimalCurrencies.add('GNF');
        zeroDecimalCurrencies.add('KMF');
        zeroDecimalCurrencies.add('KRW');
        zeroDecimalCurrencies.add('RWF');
        zeroDecimalCurrencies.add('VND');
        zeroDecimalCurrencies.add('VUV');
        zeroDecimalCurrencies.add('XAF');
        zeroDecimalCurrencies.add('XOF');
        zeroDecimalCurrencies.add('XPF');
    }

    public class CardsResponse {
        public List<Card> data { get; set; }
    }

    public class Card {
        @AuraEnabled public String id { get; set; }
        //@AuraEnabled public String address_city { get; set; }
        //@AuraEnabled public String address_country { get; set; }
        //@AuraEnabled public String address_line1 { get; set; }
        //@AuraEnabled public String address_line1_check { get; set; }
        //@AuraEnabled public String address_line2 { get; set; }
        //@AuraEnabled public String address_state { get; set; }
        //@AuraEnabled public String address_zip { get; set; }
        //@AuraEnabled public String address_zip_check { get; set; }
        @AuraEnabled public String brand { get; set; }
        @AuraEnabled public String country { get; set; }
        @AuraEnabled public String customer { get; set; }
        //@AuraEnabled public String cvc_check { get; set; }
        //@AuraEnabled public String dynamic_last4 { get; set; }
        @AuraEnabled public Integer exp_month { get; set; }
        @AuraEnabled public Integer exp_year { get; set; }
        @AuraEnabled public String fingerprint { get; set; }
        @AuraEnabled public String funding { get; set; }
        @AuraEnabled public String last4 { get; set; }
        @AuraEnabled public Map<String, String> metadata { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String tokenization_method { get; set; }
        @AuraEnabled public Boolean default_source { get; set; }
    }

    public class Customer {
        public String id { get; set; }
        public String default_source { get; set; }
    }

    public class Charge {
        public String id { get; set; }
        public Long amount { get; set; }
        public Long amount_refunded { get; set; }
        //public String application { get; set; }
        //public String application_fee { get; set; }
        //public Long application_fee_amount { get; set; }
        //public String balance_transaction { get; set; }
        public Boolean captured { get; set; }
        public Long created { get; set; }
        //public String currency_x { get; set; }
        public String customer { get; set; }
        public String description { get; set; }
        //public String destination { get; set; }
        public String failure_code { get; set; }
        public String failure_message { get; set; }
        public String invoice { get; set; }
        public Map<String, String> metadata { get; set; }
        public String order { get; set; }
        public Boolean paid { get; set; }
        //public String payment_intent { get; set; }
        public String payment_method { get; set; }
        public PaymentMethodDetails payment_method_details { get; set; }
        //public String receipt_email { get; set; }
        //public String receipt_number { get; set; }
        //public String receipt_url { get; set; }
        public Boolean refunded { get; set; }
        public String status { get; set; }
    }

    public class PaymentMethodDetails {
        public ChargeCardDetails card { get; set; }
        public ChargeAchDebitDetails ach_debit { get; set; }
        public String type { get; set; }
    }

    public class ChargeCardDetails {
        public String brand { get; set; }
        public String country { get; set; }
        //public Integer exp_month { get; set; }
        //public Integer exp_year { get; set; }
        public String funding { get; set; }
        public String last4 { get; set; }
        //public String network { get; set; }
        //public String fingerprint { get; set; }
    }

    public class ChargeAchDebitDetails {
        public String account_holder_type { get; set; }
        public String bank_name { get; set; }
        public String country { get; set; }
        public String fingerprint { get; set; }
        public String last4 { get; set; }
        public String routing_number { get; set; }
    }

    public class WebHook {
        public String id { get; set; }
        public String api_version { get; set; }
        public String application { get; set; }
        public Long created { get; set; }
        public List<String> enabled_events { get; set; }
        public Boolean livemode { get; set; }
        public String status { get; set; }
        public String url { get; set; }
        public String secret { get; set; }
    }

    public class WebHooks {
        public List<WebHook> data;
    }

    public class Invoice {
        public String id {get; set;}
        public String object_x {get; set;}
        public String account_country {get; set;}
        public Long amount_due {get; set;}
        public Long amount_paid {get; set;}
        public Long amount_remaining {get; set;}
        public Long application_fee_amount {get; set;}
        public Integer attempt_count {get; set;}
        public Boolean attempted {get; set;}
        public Boolean auto_advance {get; set;}
        public String billing_reason {get; set;}
        public String charge {get; set;}
        public String collection_method {get; set;}
        public Long created {get; set;}
        public String currency_x {get; set;}
        public String customer {get; set;}
        public String customer_email {get; set;}
        public String customer_name {get; set;}
        public String customer_phone {get; set;}
        public String customer_tax_exempt {get; set;}
        public String default_payment_method {get; set;}
        public String default_source {get; set;}
        public String description {get; set;}
        public Long ending_balance {get; set;}
        public String footer {get; set;}
        public String hosted_invoice_url {get; set;}
        public String invoice_pdf {get; set;}
        public Map<String, String> metadata { get; set; }
        public Long next_payment_attempt {get; set;}
        public Long number_x {get; set;}
        public Boolean paid {get; set;}
        public String payment_intent {get; set;}
        public Long period_end {get; set;}
        public Long period_start {get; set;}
        public Long post_payment_credit_notes_amount {get; set;}
        public Long pre_payment_credit_notes_amount {get; set;}
        public String receipt_number {get; set;}
        public Long starting_balance {get; set;}
        public String statement_descriptor {get; set;}
        public String status {get; set;}
        public String subscription {get; set;}
        public Long subtotal {get; set;}
        public Long tax {get; set;}
        public Long total {get; set;}
    }

    public class Subscription {
        public String id {get; set;}
        public String object_x {get; set;}
        public Map<String, String> metadata {get; set;}
        public Long current_period_end {get; set;}
        public Long current_period_start {get; set;}
        public String customer {get; set;}
    }

    public class Plan {
        public String id {get; set;}
        public String object_x {get; set;}
        public Boolean active {get; set;}
        public Long amount {get; set;}
        public String billing_scheme {get; set;}
        public Long created {get; set;}
        public String currency_x {get; set;}
        public String interval {get; set;}
        public Integer interval_count {get; set;}
        public Map<String, String> metadata {get; set;}
        public String product {get; set;}
        public String usage_type {get; set;}
    }

    public class Product {
        public String id {get; set;}
        public String object_x {get; set;}
        public Boolean active {get; set;}
        public Long created {get; set;}
        public String description {get; set;}
        public Map<String, String> metadata {get; set;}
        public String name {get; set;}
        public String unit_label {get; set;}
        public Long updated {get; set;}
        public String type {get; set;}
    }

    public class WebHookEvent {
        public String id {get; set;}
        public String type {get; set;}
        public String api_version {get; set;}
        public Long created {get; set;}
        public WebHookData data {get; set;}
    }

    public class WebHookData {
        public Charge object_x;
    }

    public class ErrorResponse {
        public Error error { get; set; }
    }

    public class Error {
        public String code { get; set; }
        public String message { get; set; }
        public String type { get; set; }
        public String doc_url { get; set; }
    }
    
    public class Account {
        public String stripe_user_id { get; set; }
        public String stripe_publishable_key { get; set; }
    }

    public class AchToken {
        public String id { get; set; }
        public String object_x { get; set; }
        public String BankAccount { get; set; }
        public Long created { get; set; }
        public Boolean livemode { get; set; }
        public String type { get; set; }
        public Boolean used { get; set; }
    }

    public class BankAccount {
        @AuraEnabled public String id { get; set; }
        public String object_x { get; set; }
        @AuraEnabled public String account_holder_name { get; set; }
        @AuraEnabled public String account_holder_type { get; set; }
        @AuraEnabled public String bank_name { get; set; }
        @AuraEnabled public String country { get; set; }
        @AuraEnabled public String currency_x { get; set; }
        @AuraEnabled public String last4 { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String routing_number { get; set; }
        @AuraEnabled public String status { get; set; } //new, validated, verified, verification_failed, or errored
    }

    public class BankAccountsResponse {
        public List<BankAccount> data { get; set; }
    }

    public class PaymentMethods {
        @AuraEnabled public List<Card> cards { get; set; }
        @AuraEnabled public List<BankAccount> bankAccounts { get; set; }
    }
    
    /*{
      "id": "acct_1Fs1tIDRpVqpQtHH",
      "object": "account",
      "business_profile": {
        "mcc": "5734",
        "name": null,
        "support_address": null,
        "support_email": null,
        "support_phone": "+918105918323",
        "support_url": null,
        "url": "https://www.google.com"
      },
      "capabilities": {
        "card_payments": "active",
        "transfers": "active"
      },
      "charges_enabled": true,
      "country": "IN",
      "default_currency": "inr",
      "details_submitted": true,
      "email": "sarath.pal4u@gmail.com",
      "payouts_enabled": true,
      "settings": {
        "branding": {
          "icon": null,
          "logo": null,
          "primary_color": null
        },
        "card_payments": {
          "statement_descriptor_prefix": null
        },
        "dashboard": {
          "display_name": "Google",
          "timezone": "Asia/Calcutta"
        },
        "payments": {
          "statement_descriptor": "YOLOIDIOT",
          "statement_descriptor_kana": null,
          "statement_descriptor_kanji": null
        }
      },
      "type": "custom"
    }*/
    
    public class ClientAccount {
        public String id { get; set; }
        public String email { get; set; }
        public String country { get; set; }
        public String default_currency { get; set; }
        public boolean charges_enabled { get; set; }
        public boolean payouts_enabled { get; set; }
    }

    public class UserPaymentResponse {
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public String devMessage { get; set; }
        @AuraEnabled public Transaction__c txn { get; set; }
    }

    public class UserPaymentRequest {
        @AuraEnabled public String paymentMethod { get; set; }
        @AuraEnabled public String stripeToken { get; set; }
        @AuraEnabled public String selectedPaymentSource { get; set; }
        @AuraEnabled public Boolean saveCard { get; set; }
        @AuraEnabled public String bankToken { get; set; }
    }

    public class RegisterBankAccountResponse {
        public BankAccount bankAccount { get; set; }
        public String errorCode { get; set; }
        public String errorMessage { get; set; }
    }

    public class BankVerificationRequest {
        @AuraEnabled public String customerId { get; set; }
        @AuraEnabled public String bankSourceId { get; set; }
        @AuraEnabled public Integer amount1 { get; set; }
        @AuraEnabled public Integer amount2 { get; set; }
    }

    public class AuthToken {
        public String token_type { get; set; }
        public String stripe_publishable_key { get; set; }
        public String scope { get; set; }
        public boolean livemode { get; set; }
        public String stripe_user_id { get; set; }
        public String refresh_token { get; set; }
        public String access_token { get; set; }
    }

    public class RestException extends Exception {
        public ErrorResponse errorResponse { get; set; }

        public RestException(ErrorResponse er) {
            this.errorResponse = er;
        }
    }

    public class Payments {
        @AuraEnabled public List<Payment> payments { get; set; }

        public Payments() {
            payments = new List<Payment>();
        }

        public void registerPayment(Transaction__c txn) {
            payments.add(new Payment(txn));
        }

        public void registerPayment(PaymentRequest__c paymentRequest) {
            payments.add(new Payment(paymentRequest));
        }
    }

    public class Payment implements Comparable {
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public Transaction__c txn { get; set; }
        @AuraEnabled public PaymentRequest__c paymentRequest { get; set; }
        @AuraEnabled public Integer itemNumber { get; set; }

        public Payment(Transaction__c txn) {
            this.type = 'TXN';
            this.txn = txn;
            this.itemNumber = txn.PaymentRequestId__r.ItemNumber__c.intValue();
        }

        public Payment(PaymentRequest__c paymentRequest) {
            this.type = 'OTHER';
            this.paymentRequest = paymentRequest;
            this.itemNumber = paymentRequest.ItemNumber__c.intValue();
        }

        public Integer compareTo(Object param1) {
            return itemNumber - ((Payment) param1).itemNumber;
        }
    }

    public class EventException extends Exception {

    }
}