public with sharing class SearchController {

    @AuraEnabled
    public static List<Contact> getOpenTabMembers(){
        List < Contact > membersList = new List< Contact >();
        RecordType memberRecordType = [SELECT Id,DeveloperName FROM RecordType WHERE DeveloperName = 'Member'];
        String memberRecordTypeId = (memberRecordType!=null) ? memberRecordType.Id : '' ;
        System.debug('test memberRecordTypeId'+ memberRecordTypeId);
        if(memberRecordTypeId!=''){
            membersList = [SELECT Id, Name, LastName, FirstName, Gender__c, Age__c, Birthdate, Phone_Number__c, Email,
                AccountId, Sponsor__c, StripeCustomerId__c, Active__c, Default_Payment_Method__c, Description, Fax,
                MailingAddress, MailingCity, MailingCountry, MailingPostalCode, MailingState, MailingStreet, Salutation, Title,
                Payment_Date_Time__c, Payment_SMS_Sent__c, RecordTypeId, LastModifiedDate, CreatedDate, OwnerId FROM Contact WHERE (RecordTypeId =: memberRecordTypeId) AND (Active__c = TRUE) ];
                System.debug('test membersList'+ membersList);
            return membersList;     
        }

        return membersList;
    }
    @AuraEnabled
    public static List<Contact> searchActiveMembers(String keyword){
        List < Contact > membersList = new List< Contact >();
        RecordType memberRecordType = [SELECT Id,DeveloperName FROM RecordType WHERE DeveloperName = 'Member'];
        String memberRecordTypeId = (memberRecordType!=null) ? memberRecordType.Id : '' ;
        System.debug('searched memberRecordTypeId'+ memberRecordTypeId);
        if(memberRecordTypeId!='' && keyword !=''){
            string tempkeyword= '%' + keyword + '%';
            membersList = [SELECT Id, Name, LastName, FirstName, Gender__c, Age__c, Birthdate, Phone_Number__c, Email,
                AccountId, Sponsor__c, StripeCustomerId__c, Active__c, Default_Payment_Method__c, Description, Fax,
                MailingAddress, MailingCity, MailingCountry, MailingPostalCode, MailingState, MailingStreet, Salutation, Title,
                Payment_Date_Time__c, Payment_SMS_Sent__c, RecordTypeId, LastModifiedDate, CreatedDate, OwnerId FROM Contact WHERE (RecordTypeId =: memberRecordTypeId) AND (Active__c = TRUE) AND (Phone_Number__c LIKE : tempkeyword ) ];
                System.debug('searched keyword'+ keyword);
                System.debug('searched membersList'+ membersList);
        }
        return membersList; 
    }
    @AuraEnabled(Cacheable = true)
    public static List<SObject> search(
            String objectType,
            Map<String, Object> filterParams,
            String searchText,
            String[] selectFields,
            String searchOnField,
            Integer numRecords) {
        String limitClause = numRecords == null || numRecords <= 0 ? ' LIMIT 20' : ' LIMIT ' + numRecords;

        String whereClause = '';
        for (String filter : filterParams.keySet()) {
            whereClause += '(' + filter + getQueryParamValue(filterParams.get(filter)) + ') AND ';
        }
        whereClause += searchOnField + ' LIKE \'%' + searchText.toLowerCase() + '%\'';

        String query = 'SELECT ' + String.join(selectFields, ',') + ' FROM ' + objectType +
                ' WHERE ' + whereClause + ' ORDER BY ' + searchOnField + ' ' + limitClause;
        System.debug('Search query=' + query);

        return Database.query(query);
    }

    private static String getQueryParamValue(Object paramValue) {
        if (paramValue instanceof Integer ||
                paramValue instanceof Long ||
                paramValue instanceof Double ||
                paramValue instanceof Decimal) {
            return String.valueOf(paramValue);
        }
        return '\'' + paramValue + '\'';
    }
}