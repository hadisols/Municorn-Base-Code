public class TransactionService {

    public Transaction__c createTransaction(PaymentRequest__c paymentRequest) {
        Transaction__c tx = buildTransaction(paymentRequest);
        
        insert tx;
        return getTransaction(tx.Id);
    }
    
    public Transaction__c getTransaction(String id) {
        return [SELECT Id,
                uuid__c,
                TransactionReference__c,
                Amount__c,
                PaymentRequestId__r.Contact__r.Id,
                PaymentRequestId__r.Email__c,
                PaymentRequestId__r.Contact__r.Name,
                PaymentRequestId__r.Contact__r.StripeCustomerId__c,
                PaymentRequestId__r.Opportunity__r.Id,
                PaymentRequestId__r.Opportunity__r.Name,
                PaymentRequestId__r.Account__r.Name,
                PaymentRequestId__r.PaymentType__c,
                PaymentRequestId__r.Amount__c,
                PaymentRequestId__r.Status__c,
                PaymentRequestId__r.ItemNumber__c,
                PaymentRequestId__r.Payment_Reference_Id__c,
                TransactionDate__c,
                CurrencyCode__c,
                AmountRefunded__c,
                FailureCode__c,
                FailureMessage__c,
                PaymentMethodType__c,
                PaymentMethod__c,
                PaymentCardLast4Digits__c,
                PaymentBankLast4Digits__c,
                PaymentBankName__c,
                Status__c,
                StripeChargeId__c,
                StatusMessage__c
                FROM Transaction__c WHERE Id = :id];
    }

    public Transaction__c getTransactionExtId(String txid) {
        return [SELECT Id,
                uuid__c,
                TransactionReference__c,
                Amount__c,
                PaymentRequestId__r.Contact__r.Id,
                PaymentRequestId__r.Email__c,
                PaymentRequestId__r.Contact__r.Name,
                PaymentRequestId__r.Contact__r.StripeCustomerId__c,
                PaymentRequestId__r.Opportunity__r.Id,
                PaymentRequestId__r.Opportunity__r.Name,
                PaymentRequestId__r.Account__r.Name,
                PaymentRequestId__r.PaymentType__c,
                PaymentRequestId__r.Amount__c,
                PaymentRequestId__r.Status__c,
                PaymentRequestId__r.ItemNumber__c,
                PaymentRequestId__r.Payment_Reference_Id__c,
                TransactionDate__c,
                CurrencyCode__c,
                AmountRefunded__c,
                FailureCode__c,
                FailureMessage__c,
                PaymentMethodType__c,
                PaymentMethod__c,
                PaymentCardLast4Digits__c,
                PaymentBankLast4Digits__c,
                PaymentBankName__c,
                Status__c,
                StripeChargeId__c,
                StatusMessage__c
                FROM Transaction__c WHERE StripeChargeId__c = :txid ORDER BY createddate desc LIMIT 1];
    }

    public Transaction__c getTransactionByUuid(String uuid) {
        return [SELECT Id,
                uuid__c,
                TransactionReference__c,
                Amount__c,
                PaymentRequestId__r.Contact__r.Id,
                PaymentRequestId__r.Email__c,
                PaymentRequestId__r.Contact__r.Name,
                PaymentRequestId__r.Contact__r.StripeCustomerId__c,
                PaymentRequestId__r.Opportunity__r.Id,
                PaymentRequestId__r.Opportunity__r.Name,
                PaymentRequestId__r.Account__r.Name,
                PaymentRequestId__r.PaymentType__c,
                PaymentRequestId__r.Amount__c,
                PaymentRequestId__r.Status__c,
                PaymentRequestId__r.ItemNumber__c,
                PaymentRequestId__r.Payment_Reference_Id__c,
                TransactionDate__c,
                CurrencyCode__c,
                AmountRefunded__c,
                FailureCode__c,
                FailureMessage__c,
                PaymentMethodType__c,
                PaymentMethod__c,
                PaymentCardLast4Digits__c,
                PaymentBankLast4Digits__c,
                PaymentBankName__c,
                Status__c,
                StripeChargeId__c,
                StatusMessage__c
        FROM Transaction__c WHERE uuid__c = :uuid];
    }
    
    public Transaction__c getTransactionByChargeId(String Id) {
       Transaction__c txs = [SELECT Id,
                uuid__c,
                TransactionReference__c,
                Amount__c,
                PaymentRequestId__r.Contact__r.Id,
                PaymentRequestId__r.Email__c,
                PaymentRequestId__r.Contact__r.Name,
                PaymentRequestId__r.Contact__r.StripeCustomerId__c,
                PaymentRequestId__r.Opportunity__r.Id,
                PaymentRequestId__r.Opportunity__r.Name,
                PaymentRequestId__r.Account__r.Name,
                PaymentRequestId__r.PaymentType__c,
                PaymentRequestId__r.Amount__c,
                PaymentRequestId__r.Status__c,
                PaymentRequestId__r.ItemNumber__c,
                PaymentRequestId__r.Payment_Reference_Id__c,
                TransactionDate__c,
                CurrencyCode__c,
                AmountRefunded__c,
                FailureCode__c,
                FailureMessage__c,
                PaymentMethodType__c,
                PaymentMethod__c,
                PaymentCardLast4Digits__c,
                PaymentBankLast4Digits__c,
                PaymentBankName__c,
                Status__c,
                StripeChargeId__c,
                StatusMessage__c
        FROM Transaction__c WHERE StripeChargeId__c = :Id];
        System.debug('test getTransactionByChargeId '+ txs);
        return [SELECT Id,
                uuid__c,
                TransactionReference__c,
                Amount__c,
                PaymentRequestId__r.Contact__r.Id,
                PaymentRequestId__r.Email__c,
                PaymentRequestId__r.Contact__r.Name,
                PaymentRequestId__r.Contact__r.StripeCustomerId__c,
                PaymentRequestId__r.Opportunity__r.Id,
                PaymentRequestId__r.Opportunity__r.Name,
                PaymentRequestId__r.Account__r.Name,
                PaymentRequestId__r.PaymentType__c,
                PaymentRequestId__r.Amount__c,
                PaymentRequestId__r.Status__c,
                PaymentRequestId__r.ItemNumber__c,
                PaymentRequestId__r.Payment_Reference_Id__c,
                TransactionDate__c,
                CurrencyCode__c,
                AmountRefunded__c,
                FailureCode__c,
                FailureMessage__c,
                PaymentMethodType__c,
                PaymentMethod__c,
                PaymentCardLast4Digits__c,
                PaymentBankLast4Digits__c,
                PaymentBankName__c,
                Status__c,
                StripeChargeId__c,
                StatusMessage__c
        FROM Transaction__c WHERE StripeChargeId__c = :Id];
    }
    
    public Transaction__c buildTransaction(PaymentRequest__c paymentRequest) {
        Transaction__c tx = new Transaction__c();
        tx.uuid__c = PMA_ExternalSiteFormsUtility.getUUID();
        tx.PaymentRequestId__c = paymentRequest.Id;
        tx.Status__c = 'initiated';
        tx.Amount__c = paymentRequest.Amount__c;
        tx.CurrencyCode__c = UserInfo.getDefaultCurrency();
        tx.TransactionDate__c = Datetime.now();
        
        return tx;
    }
}