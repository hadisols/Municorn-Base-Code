public class PaymentIntentService {

    public static List<Payment_Intent__c> getPaymentRequestByUUID(String uuid) {
        return [SELECT Id,Name,
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
                Payment_Reference_Id__c,Payment_Type__c,Status__c,UUID__c FROM Payment_Intent__c WHERE UUID__c = :uuid];
    }

    public static Payment_Intent__c getPaymentIntent(Id id) {
        return [SELECT Id,Name,
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
                Payment_Reference_Id__c,Payment_Type__c,Status__c,UUID__c FROM Payment_Intent__c WHERE Id = :id];
    }

    public static Payment_Intent__c createNewPaymentIntent(
            String paymentName,
            Id paymentGatewayId,
            Id contactId,
            Id accountId,
            Id opportunityId,
            Id orderId,
            String paymentType,
            Double amount,
            String email,
            String frequency,
            Date firstChargeDate) {
        System.debug('Payments Intent service, create new Intent for' +
                ', contact Name=' + paymentName +
                ', paymentGateway Id=' + paymentGatewayId +
                ', contact id=' + contactId +
                ', account id=' + accountId +
                ', opportunity id=' + opportunityId +
                ', Order id=' + orderId +
                ', amount=' + amount +
                ', email=' + email +
                ', frequency=' + frequency +
                ', first charge date=' + firstChargeDate);

                Payment_Intent__c paymentIntent = new Payment_Intent__c(
                Name = paymentName,
                Payment_Gateway__c = paymentGatewayId,
                Contact__c = contactId,
                Account__c = accountId,
                Opportunity__c = opportunityId,
                Order__c = orderId,
                Email__c = email,
                Status__c = 'payment_new',
                Payment_Type__c = paymentType,
                Frequency__c = frequency,
                First_Charge_Date__c = firstChargeDate,
                Amount__c = amount,
                Currency_Code__c = UserInfo.getDefaultCurrency(),
                UUID__c = SYS_Helper.getUUID()
        );

        insert paymentIntent;

        return getPaymentIntent(paymentIntent.Id);
    }
}