public with sharing class PMA_SearchController {
    @AuraEnabled
    public static List<Order__c> getOpenTabMembers(){
        User currentUserRecord = [SELECT ContactId,Contact.Name,Contact.AccountId,Contact.Account.Name,Email,FirstName,Id,IsActive,LastName,MobilePhone,Name,Phone,ProfileId,Username,UserRoleId,UserType FROM User WHERE Id =: UserInfo.getUserId() ];
        Id vendorContactId = currentUserRecord.ContactId;
        Id vendorAccountId = currentUserRecord.Contact.AccountId;
        List<Order__c> ordersList = new List< Order__c >();

        System.debug('vendorContactId '  + vendorContactId);
        ordersList = [SELECT Id,Name,Order_Type__c,Member__c,Member__r.Name,Member__r.Active__c,Vendor__c,Vendor__r.Name,Account__c,Account__r.Name,Status__c,Total_Price__c,UUID__c,CreatedDate,LastModifiedDate,OwnerId FROM Order__c WHERE ( Order_Type__c = 'POS' ) AND ( Status__c != 'Completed' ) AND ( Vendor__c =: vendorContactId ) ];
        System.debug('ordersList '  + ordersList);
        return ordersList;
    }
    @AuraEnabled
    public static List<Contact> searchActiveMembers(String keyword){
        User currentUserRecord = [SELECT ContactId,Contact.Name,Contact.AccountId,Contact.Account.Name,Email,FirstName,Id,IsActive,LastName,MobilePhone,Name,Phone,ProfileId,Username,UserRoleId,UserType FROM User WHERE Id =: UserInfo.getUserId() ];
        Id vendorContactId = currentUserRecord.ContactId;
        Id vendorAccountId = currentUserRecord.Contact.AccountId;
        List<Order__c> ordersList = new List< Order__c >();
        Set<Id> memberIds= new Set<Id>();
        List < Contact > membersList = new List< Contact >();

        ordersList = [SELECT Id,Name,Order_Type__c,Member__c,Member__r.Name,Member__r.Active__c,Vendor__c,Vendor__r.Name,Account__c,Account__r.Name,Status__c,Total_Price__c,UUID__c,CreatedDate,LastModifiedDate,OwnerId FROM Order__c WHERE ( Order_Type__c = 'POS' ) AND ( Status__c != 'Completed' ) AND ( Vendor__c =: vendorContactId ) ];
        for(Order__c iterOrder : ordersList){
           if(!memberIds.contains(iterOrder.Member__c)){
            memberIds.add(iterOrder.Member__c);
           }
       }
        RecordType memberRecordType = [SELECT Id,DeveloperName FROM RecordType WHERE DeveloperName = 'Member'];
        String memberRecordTypeId = (memberRecordType!=null) ? memberRecordType.Id : '' ;
        if(String.isNotBlank(memberRecordTypeId) && String.isNotBlank(keyword)){
            string tempkeyword= '%' + keyword + '%';
            membersList = [SELECT Id, Name, LastName, FirstName, Gender__c, Age__c, Birthdate, Phone_Number__c, Email,
                AccountId, Sponsor__c, StripeCustomerId__c, Active__c, Default_Payment_Method__c, Description, Fax,
                MailingAddress, MailingCity, MailingCountry, MailingPostalCode, MailingState, MailingStreet, Salutation, Title,
                Payment_Date_Time__c, Payment_SMS_Sent__c, RecordTypeId, LastModifiedDate, CreatedDate, OwnerId FROM Contact WHERE (RecordTypeId =: memberRecordTypeId) AND (Active__c = TRUE) AND (Phone_Number__c LIKE : tempkeyword ) AND (Id NOT IN  : memberIds) ];
                System.debug('searched keyword'+ keyword);
                System.debug('searched membersList'+ membersList);
        }
        return membersList; 
    }
    @AuraEnabled
    public static Order__c getOrderDetailsByIdOrUUID( String orderIdOrUUID ){
        Order__c currentOrder = new Order__c();
        if( (orderIdOrUUID.length()==15) || (orderIdOrUUID.length()==18) ){
            currentOrder = [SELECT Id,Name,Order_Type__c,Member__c,Member__r.Name,Member__r.Active__c,Vendor__c,Vendor__r.Name,Account__c,Account__r.Name,Status__c,Total_Price__c,UUID__c,CreatedDate,LastModifiedDate,OwnerId FROM Order__c WHERE ( Order_Type__c = 'POS' ) AND ( Status__c != 'Completed' ) AND ( Id =: orderIdOrUUID )  ];
        }
        else{
            currentOrder = [SELECT Id,Name,Order_Type__c,Member__c,Member__r.Name,Member__r.Active__c,Vendor__c,Vendor__r.Name,Account__c,Account__r.Name,Status__c,Total_Price__c,UUID__c,CreatedDate,LastModifiedDate,OwnerId FROM Order__c WHERE ( Order_Type__c = 'POS' ) AND ( Status__c != 'Completed' ) AND ( UUID__c =: orderIdOrUUID )  ];
        }
        return currentOrder;
    }
    @AuraEnabled
    public static Order__c createDraftOrderRecord( Id memberId ){
        User currentUserRecord = [SELECT ContactId,Contact.Name,Contact.AccountId,Contact.Account.Name,Email,FirstName,Id,IsActive,LastName,MobilePhone,Name,Phone,ProfileId,Username,UserRoleId,UserType FROM User WHERE Id =: UserInfo.getUserId() ];
        Id vendorContactId = currentUserRecord.ContactId;
        Id vendorAccountId = currentUserRecord.Contact.AccountId;
        //Create Draft Order
        String orderUUID = SYS_Helper.getUUID();
        Order__c newDraftOrder = new Order__c();
        newDraftOrder.Order_Type__c = 'POS';
        newDraftOrder.Status__c = 'Draft';
        newDraftOrder.Vendor__c = vendorContactId;
        newDraftOrder.Account__c = vendorAccountId;
        newDraftOrder.Member__c = memberId;
        newDraftOrder.UUID__c = orderUUID;
        insert newDraftOrder;
        Order__C getOrderDetails = getOrderDetailsByIdOrUUID(orderUUID);
        return getOrderDetails;
    }
    
}