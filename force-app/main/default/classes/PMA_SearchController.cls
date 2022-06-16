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
                Payment_Date_Time__c, Payment_SMS_Sent__c, RecordTypeId, LastModifiedDate, CreatedDate, OwnerId FROM Contact WHERE (RecordTypeId =: memberRecordTypeId) AND (Active__c = TRUE) AND ( (Phone_Number__c LIKE : tempkeyword ) OR ( LastName LIKE : tempkeyword )  OR ( FirstName LIKE : tempkeyword ) ) AND (Id NOT IN  : memberIds) ];
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
            (SELECT Id,Name,Order__c,Product__c,Product_Name__c,Quantity__c,List_Price__c,Line_Total_Price__c,Total_Price__c,Notes__c,CreatedDate,LastModifiedDate FROM Order_Items__r) FROM Order__c WHERE ( Order_Type__c = 'POS' ) AND ( Status__c != 'Completed' ) AND ( Id =: orderIdOrUUID )  ];
        }
        else{
            currentOrder = [SELECT Id,Name,Order_Type__c,Member__c,Member__r.Name,Member__r.Active__c, Member__r.Age__c, Member__r.Birthdate,Vendor__c,Vendor__r.Name,Account__c,Account__r.Name,Status__c,Total_Price__c,UUID__c,CreatedDate,LastModifiedDate,OwnerId,
            (SELECT Id,Name,Order__c,Product__c,Product_Name__c,Quantity__c,List_Price__c,Line_Total_Price__c,Total_Price__c,Notes__c,CreatedDate,LastModifiedDate FROM Order_Items__r)  FROM Order__c WHERE ( Order_Type__c = 'POS' ) AND ( Status__c != 'Completed' ) AND ( UUID__c =: orderIdOrUUID )  ];
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
    @AuraEnabled
    public static User fetchCurrentUser() {
        // query current user information  
        User currentUserRecord = [SELECT ContactId, Contact.Name, Contact.AccountId, Contact.Account.Name, Email,
            FirstName, Id, IsActive, LastName, MobilePhone, Name, Phone, ProfileId, Contact.RecordType.Name,
            Username, UserRoleId, UserType FROM User WHERE Id =: UserInfo.getUserId()
        ];

        return currentUserRecord;
    }
    @AuraEnabled
    public static List<Order_Item__c> getOrderItemsForFulfillment(){
        List<Order_Item__c> ordersList = new List< Order_Item__c >();
        ordersList = [SELECT Id,Name,Order__c,Item_Status__c,Product__c,Product__r.Name,Product_Name__c,Quantity__c,
        List_Price__c,Line_Total_Price__c,Total_Price__c,Notes__c,
        CreatedDate,LastModifiedDate,
        Order__r.Name,Order__r.Order_Type__c,Order__r.Member__c,Order__r.Member__r.Name,
        Order__r.Member__r.Active__c,Order__r.Member__r.Age__c,Order__r.Vendor__c,Order__r.Vendor__r.Name,
        Order__r.Account__c,Order__r.Account__r.Name,Order__r.Status__c,Order__r.Total_Price__c,
        Order__r.UUID__c,Order__r.CreatedDate,Order__r.LastModifiedDate,Order__r.OwnerId FROM Order_Item__c WHERE ( Order__r.Order_Type__c = 'POS' ) AND (  Order__r.Status__c != 'Completed' ) ];
        System.debug('ordersList '  + ordersList);
        return  ordersList;
    }
    @AuraEnabled(cacheable=true)
    public static List<Order_Item__c> getOrderItemsForFulfillmentCache(){
        List<Order_Item__c> ordersList = new List< Order_Item__c >();
        ordersList = [SELECT Id,Name,Order__c,Item_Status__c,Product__c,Product__r.Name,Product_Name__c,Quantity__c,
        List_Price__c,Line_Total_Price__c,Total_Price__c,Notes__c,
        CreatedDate,LastModifiedDate,
        Order__r.Name,Order__r.Order_Type__c,Order__r.Member__c,Order__r.Member__r.Name,
        Order__r.Member__r.Active__c,Order__r.Member__r.Age__c,Order__r.Vendor__c,Order__r.Vendor__r.Name,
        Order__r.Account__c,Order__r.Account__r.Name,Order__r.Status__c,Order__r.Total_Price__c,
        Order__r.UUID__c,Order__r.CreatedDate,Order__r.LastModifiedDate,Order__r.OwnerId FROM Order_Item__c WHERE ( Order__r.Order_Type__c = 'POS' ) AND (  Order__r.Status__c != 'Completed' ) ];
        System.debug('ordersList '  + ordersList);
        return  ordersList;
    }
    @AuraEnabled
    public static kanbanWrap getKanbanWrapperDetails_Apex(String sObjectName, String[] sObjectFields, String sObjectPickListValue) {
        List<String> lstPickvals=new List<String>();
        for (Schema.PicklistEntry a : Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().get(sObjectPickListValue).getDescribe().getPickListValues()) {
            lstPickvals.add(a.getValue());
        }
        String query = 'SELECT Id, ';
        for(String fields : sObjectFields){
            query += fields + ' ,';
        }
        query = query.removeEnd(',');
        query += ' FROM ' + sObjectName + ' WHERE Order__r.Order_Type__c = \'POS\' AND Order__r.Status__c != \'Completed\'' ;
        System.debug('query '+ query);
        return new kanbanWrap(Database.query(query), lstPickvals);
    }
    
    @AuraEnabled
    public static String getUpdatePickListValue_Apex(Id recordId, String sObjectPickListValue, String pickListUpdatedValue) {
        SObject sObjectRecord = recordId.getSObjectType().newSObject(recordId);
        sObjectRecord.put(sObjectPickListValue, pickListUpdatedValue);
        update sObjectRecord;
        return 'Success';
    }
    
    
    
    public class kanbanWrap{
        @AuraEnabled
        public List<sObject> records {get;set;}
        @AuraEnabled
        public List<String> pickVals {get;set;}
        
        public kanbanWrap(List<sObject> recs, List<String> pVals){
            this.records = recs;
            this.pickVals = pVals;
        }
    }
}