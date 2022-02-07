public class PaymentsService {

    public List<PaymentRequest__c> getPaymentRequestByGroupId(String parentRequestGroupId) {
        return [SELECT Id,
                Email__c,
                Contact__c,
                Contact__r.Id,
                Contact__r.Name,
                Account__c,
                Account__r.Id,
                Account__r.Name,
                Opportunity__c,
                Opportunity__r.Id,
                Opportunity__r.Name,
                Status__c,
                Status_Message__c,
                Currency_Code__c,
                PaymentType__c,
                Amount__c,
                ItemNumber__c,
                Payment_Reference_Id__c,
                Frequency__c,
                FirstChargeDate__c,
                PaymentRequests__c
        FROM PaymentRequest__c WHERE PaymentRequests__r.uuid__c = :parentRequestGroupId];
    }

    public PaymentRequest__c getPaymentRequest(Id id) {
        return [SELECT Id,
                Email__c,
                Contact__c,
                Contact__r.Id,
                Contact__r.Name,
                Account__c,
                Account__r.Id,
                Account__r.Name,
                Opportunity__c,
                Opportunity__r.Id,
                Opportunity__r.Name,
                Status__c,
                Status_Message__c,
                Currency_Code__c,
                PaymentType__c,
                Amount__c,
                ItemNumber__c,
                Payment_Reference_Id__c,
                Frequency__c,
                FirstChargeDate__c,
                PaymentRequests__c,
                PaymentRequests__r.Id,
                PaymentRequests__r.uuid__c
        FROM PaymentRequest__c WHERE Id = :id];
    }

    public PaymentRequest__c createNewPaymentRequest(
            String paymentName,
            Id contactId,
            Id accountId,
            Id opportunityId,
            String paymentType,
            Double amount,
            String email,
            String frequency,
            Date firstChargeDate,
            Integer itemNumber,
            String paymentRequestGroupId) {
        System.debug('Payments service, create new request for' +
                ', contact Name=' + paymentName +
                ', contact id=' + contactId +
                ', account id=' + accountId +
                ', opportunity id=' + opportunityId +
                ', amount=' + amount +
                ', email=' + email +
                ', frequency=' + frequency +
                ', first charge date=' + firstChargeDate);

        List<Payment_Request_Group__c> paymentRequestGroups = [SELECT Id, uuid__c FROM Payment_Request_Group__c WHERE uuid__c=:paymentRequestGroupId];

        Payment_Request_Group__c paymentRequestGroup;
        if (paymentRequestGroups.isEmpty()) {
            paymentRequestGroup = new Payment_Request_Group__c(uuid__c = paymentRequestGroupId);
            insert paymentRequestGroup;
        } else {
            paymentRequestGroup = paymentRequestGroups.get(0);
        }

        PaymentRequest__c paymentRequest = new PaymentRequest__c(
                Email__c = email,
                Name = paymentName,
                Contact__c = contactId,
                Account__c = accountId,
                Opportunity__c = opportunityId,
                Status__c = 'payment_new',
                PaymentType__c = paymentType,
                Frequency__c = frequency,
                ItemNumber__c = itemNumber,
                FirstChargeDate__c = firstChargeDate,
                Amount__c = amount,
                Currency_Code__c = UserInfo.getDefaultCurrency(),
                PaymentRequests__c = paymentRequestGroup.Id
        );

        insert paymentRequest;

        return getPaymentRequest(paymentRequest.Id);
    }
}