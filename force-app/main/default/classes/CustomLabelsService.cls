public with sharing class CustomLabelsService {

    public Map<String, Object> getCustomLabels() {
        Map<String, Object> labelsMap = new Map<String, Object>();
        labelsMap.put('error_message_stripe_setup_error', System.Label.error_message_stripe_setup_error);
        labelsMap.put('error_message_bad_request', System.Label.error_message_bad_request);
        labelsMap.put('error_message_invalid_organization', System.Label.error_message_invalid_organization);
        labelsMap.put('error_message_ach_verification_select_bank', System.Label.error_message_ach_verification_select_bank);
        labelsMap.put('error_message_ach_verification_enter_amount_1', System.Label.error_message_ach_verification_enter_amount_1);
        labelsMap.put('error_message_ach_verification_enter_amount_2', System.Label.error_message_ach_verification_enter_amount_2);
        labelsMap.put('error_message_ach_registration_account_number_invalid', System.Label.error_message_ach_registration_account_number_invalid);
        labelsMap.put('error_message_ach_registration_re_enter_account_number_invalid', System.Label.error_message_ach_registration_re_enter_account_number_invalid);
        labelsMap.put('error_message_ach_registration_routing_number_invalid', System.Label.error_message_ach_registration_routing_number_invalid);
        labelsMap.put('frequency_single', System.Label.frequency_single);
        labelsMap.put('frequency_month', System.Label.frequency_month);
        labelsMap.put('frequency_quarter', System.Label.frequency_quarter);
        labelsMap.put('frequency_year', System.Label.frequency_year);

        labelsMap.put('Account', getLabel(Account.SObjectType));
        labelsMap.put('Opportunity', getLabel(Opportunity.SObjectType));
        labelsMap.put('Contact', getLabel(Contact.SObjectType));
        labelsMap.put('Amount', Opportunity.SObjectType.getDescribe().fields.getMap().get('Amount').getDescribe().getLabel());

        labelsMap.putAll(getObjectFieldLabels(Account.SObjectType));
        labelsMap.putAll(getObjectFieldLabels(Opportunity.SObjectType));
        labelsMap.putAll(getObjectFieldLabels(Contact.SObjectType));
        labelsMap.putAll(getObjectFieldLabels(Transaction__c.SObjectType));
        labelsMap.putAll(getObjectFieldLabels(PaymentRequest__c.SObjectType));

        return labelsMap;
    }

    private static Map<String, String> getObjectFieldLabels(SObjectType sObjectType) {
        String objectName = sObjectType.getDescribe().getName();
        Map<String, String> fields = new Map<String, String>();
        fields.put(objectName + '.label', sObjectType.getDescribe().getLabel());
        fields.put(objectName + '.labelPlural', sObjectType.getDescribe().getLabelPlural());

        Map<String, Schema.SObjectField> fieldSetMap = sObjectType.getDescribe().fields.getMap();
        for (String field : fieldSetMap.keySet()) {
            fields.put(objectName + '.' + field, fieldSetMap.get(field).getDescribe().getLabel());
        }
        return fields;

    }

    private static Label getLabel(SObjectType sObjectType) {
        DescribeSObjectResult sObjectResult = sObjectType.getDescribe();
        return new Label(sObjectResult.getLabel(), sObjectResult.getLabelPlural());
    }

    public class Label {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String pluralLabel { get; set; }

        public Label(String label, String pluralLabel) {
            this.label = label;
            this.pluralLabel = pluralLabel;
        }
    }
}