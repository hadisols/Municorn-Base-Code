public with sharing class PMA_SearchController {
    // wrapper class membersOrdersWrapper
    public class membersOrdersWrapper {
        @AuraEnabled
        public Order__c order = new Order__c();
        @AuraEnabled
        public Contact member = new Contact();
        @AuraEnabled
        public String shortNameCode;
        @AuraEnabled
        public Boolean hasPictureURL = false;
        @AuraEnabled
        public String pictureURL;
    }
    @AuraEnabled
    public static List<membersOrdersWrapper> getOpenTabMembers(){
        User currentUserRecord = [SELECT ContactId,Contact.Name,Contact.AccountId,Contact.Account.Name,Email,FirstName,Id,IsActive,LastName,MobilePhone,Name,Phone,ProfileId,Username,UserRoleId,UserType FROM User WHERE Id =: UserInfo.getUserId() ];
        Id vendorContactId = currentUserRecord.ContactId;
        Id vendorAccountId = currentUserRecord.Contact.AccountId;
        List<Order__c> ordersList = new List< Order__c >();
        List<membersOrdersWrapper> orderWrapperList = new List<membersOrdersWrapper>();

        System.debug('vendorContactId '  + vendorContactId);
        ordersList = [SELECT Id,Name,Order_Type__c,Member__c,Member__r.Name,Member__r.Active__c,Member__r.Age__c,Vendor__c,Vendor__r.Name,Account__c,Account__r.Name,Status__c,Total_Price__c,UUID__c,CreatedDate,LastModifiedDate,OwnerId FROM Order__c WHERE ( Order_Type__c = 'POS' ) AND ( Status__c != 'Completed' ) ];
        System.debug('ordersList '  + ordersList);
        for(Order__c order: ordersList){
            String recordPictureURL = ImageController.getSysTrackRecordPictureURL(order.Member__c);
            System.debug('Member Name ' + order.Member__r.Name + ' recordPictureURL '+ recordPictureURL);
            membersOrdersWrapper currentOrder = new membersOrdersWrapper();
            currentOrder.order = order;
            currentOrder.hasPictureURL = (recordPictureURL=='noimage') ? false : true;
            currentOrder.shortNameCode = ImageController.getShortendImageName(order.Member__r.Name);
            currentOrder.pictureURL = recordPictureURL;
            orderWrapperList.add(currentOrder);
        }
        return orderWrapperList;
    }
    @AuraEnabled
    public static List<membersOrdersWrapper> searchActiveMembers(String keyword){
        User currentUserRecord = [SELECT ContactId,Contact.Name,Contact.AccountId,Contact.Account.Name,Email,FirstName,Id,IsActive,LastName,MobilePhone,Name,Phone,ProfileId,Username,UserRoleId,UserType FROM User WHERE Id =: UserInfo.getUserId() ];
        Id vendorContactId = currentUserRecord.ContactId;
        Id vendorAccountId = currentUserRecord.Contact.AccountId;
        List<membersOrdersWrapper> memberWrapperList = new List<membersOrdersWrapper>();
        List<Order__c> ordersList = new List< Order__c >();
        Set<Id> memberIds= new Set<Id>();
        List < Contact > membersList = new List< Contact >();

        ordersList = [SELECT Id,Name,Order_Type__c,Member__c,Member__r.Name,Member__r.Active__c,Vendor__c,Vendor__r.Name,Account__c,Account__r.Name,Status__c,Total_Price__c,UUID__c,CreatedDate,LastModifiedDate,OwnerId FROM Order__c WHERE ( Order_Type__c = 'POS' ) AND ( Status__c != 'Completed' ) ];
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
                for(Contact member : membersList){
                    String recordPictureURL = ImageController.getSysTrackRecordPictureURL(member.Id);
                    System.debug('Member Name ' + member.Name + ' recordPictureURL '+ recordPictureURL);
                    membersOrdersWrapper currentMember = new membersOrdersWrapper();
                    currentMember.member = member;
                    currentMember.hasPictureURL = (recordPictureURL=='noimage') ? false : true;
                    currentMember.shortNameCode = ImageController.getShortendImageName(member.Name);
                    currentMember.pictureURL = recordPictureURL;
                    memberWrapperList.add(currentMember);   
                }
        }
        return memberWrapperList; 
    }
    @AuraEnabled
    public static Order__c getOrderDetailsByIdOrUUID( String orderIdOrUUID ){
        Order__c currentOrder = new Order__c();
        if( (orderIdOrUUID.length()==15) || (orderIdOrUUID.length()==18) ){
            currentOrder = [SELECT Id,Name,Order_Type__c,Member__c,Member__r.Name,Member__r.Active__c, Member__r.Age__c, Member__r.Birthdate,Vendor__c,Vendor__r.Name,Account__c,Account__r.Name,Status__c,Total_Price__c,UUID__c,CreatedDate,LastModifiedDate,OwnerId,
            (SELECT Id,Name,Order__c,Product__c,Product_Name__c,Quantity__c,List_Price__c,Line_Total_Price__c,Total_Price__c,CreatedDate,LastModifiedDate FROM Order_Items__r) FROM Order__c WHERE ( Order_Type__c = 'POS' ) AND ( Status__c != 'Completed' ) AND ( Id =: orderIdOrUUID )  ];
        }
        else{
            currentOrder = [SELECT Id,Name,Order_Type__c,Member__c,Member__r.Name,Member__r.Active__c, Member__r.Age__c, Member__r.Birthdate,Vendor__c,Vendor__r.Name,Account__c,Account__r.Name,Status__c,Total_Price__c,UUID__c,CreatedDate,LastModifiedDate,OwnerId,
            (SELECT Id,Name,Order__c,Product__c,Product_Name__c,Quantity__c,List_Price__c,Line_Total_Price__c,Total_Price__c,CreatedDate,LastModifiedDate FROM Order_Items__r)  FROM Order__c WHERE ( Order_Type__c = 'POS' ) AND ( Status__c != 'Completed' ) AND ( UUID__c =: orderIdOrUUID )  ];
        }
        return currentOrder;
    }
    @AuraEnabled
    public static Order__c createDraftOrderRecord( Id memberId ){
        User currentUserRecord = [SELECT ContactId,Contact.Name,Contact.AccountId,Contact.Account.Name,Email,FirstName,Id,IsActive,LastName,MobilePhone,Name,Phone,ProfileId,Username,UserRoleId,UserType FROM User WHERE Id =: UserInfo.getUserId() ];
        Id vendorAccountId = currentUserRecord.Contact.AccountId;
        //Create Draft Order
        String orderUUID = SYS_Helper.getUUID();
        Order__c newDraftOrder = new Order__c();
        newDraftOrder.Order_Type__c = 'POS';
        newDraftOrder.Status__c = 'Draft';
        newDraftOrder.Account__c = vendorAccountId;
        newDraftOrder.Member__c = memberId;
        newDraftOrder.UUID__c = orderUUID;
        insert newDraftOrder;
        Order__C getOrderDetails = getOrderDetailsByIdOrUUID(orderUUID);
        return getOrderDetails;
    }
}