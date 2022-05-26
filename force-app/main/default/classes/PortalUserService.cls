public without sharing class PortalUserService {
    private System.TriggerOperation triggerEvent;
    public static void handle() {
        handleByOperation(Trigger.New, Trigger.operationType);
    }
    
    public static void handleByOperation(List < Contact > contactList, System.TriggerOperation triggerEvent) {
        
        switch on triggerEvent {
            when AFTER_INSERT { //AFTER_INSERT, AFTER_UPDATE
                Id ManagerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Manager').getRecordTypeId();
                Id VendorRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
                for (Contact currentContact: contactList) {
                    if( (String.isNotBlank(currentContact.Email)) && ( (currentContact.RecordTypeId == ManagerRecordTypeId ) || (currentContact.RecordTypeId == VendorRecordTypeId ) ) ){
                        createPartnerUser(currentContact.Id);
                    }

                }
                 
            }
        }
    }

    @future
    public static void createPartnerUser(Id contactId)
    {
        UserCreationResponse response = new UserCreationResponse();
        Contact currentContact = new Contact();
        String currentRecordProfile;
        currentContact = [Select Id,Name,FirstName,LastName, Email, Account.Name,RecordType.Name FROM Contact where Id =: contactId LIMIT 1];
        if (currentContact.RecordType.Name == 'Manager'){
            currentRecordProfile = 'PMA Manager External App';
        } 
        else if (currentContact.RecordType.Name == 'Vendor') {
            currentRecordProfile = 'PMA Vendor External App';
        } else {
            response.ErrorMessage = 'Profile with Name PMA Manager | Vendor External App not exist';
            // return response;
        }
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name =: currentRecordProfile LIMIT 1];
        if(partnerProfile==null)
        {
            response.ErrorMessage = 'Profile with Name PMA Manager | Vendor External App not exist';
            // return response;
        }
        
        List<User> users=[SELECT Id,Name from USER WHERE ContactId=:contactId];
        if(!users.isEmpty())
        {
            response.ErrorMessage='User already exist for contact ('+users[0].Name+')';
            // return response;
        }
        
        String userNameSuffix='pma';
        String userName=currentContact.Email+'.'+userNameSuffix;
        String alias=currentContact.Name.length()>8 ? currentContact.Name.substring(0,8) : currentContact.Name;
        
        User theUser = new User(
            Username = userName,
            ContactId = currentContact.Id,	
            ProfileId = partnerProfile.Id,
            Alias = alias,
            Email = currentContact.Email,
            EmailEncodingKey = 'UTF-8',
            LastName = currentContact.LastName,
            CommunityNickname = alias,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        // User currentUserRecord = PMA_SearchController.fetchCurrentUser();
        // UserRole userRole=getUserRole(currentUserRecord.Contact.Account.Name);
        // if(userRole!=null)
        // {
        //    theUser.UserRoleId = userRole.Id;
        // }
        System.debug('theUser ' + theUser);
        insert theUser;
        
       	// if(userRole!=null)
        // {
        //     userRole=getUserRole(currentUserRecord.Contact.Account.Name);
        //     update theUser;
        // }
        response.UserId=theUser.id;
        response.UserName=theUser.Username;
        // return response;
    }
    
    public static UserRole getUserRole(string actName)
    {
        // Account Name + Partner User
        // Account Name + Partner Manager
        // Account Name + Partner Executive
        // Account Name + Customer User
        string roleName=actName+' Customer User';
        UserRole userRole;
        List<UserRole> portalRoles = [Select Id From UserRole Where PortalType = 'CustomerPortal' and Name=:roleName Limit 1];
		if(!portalRoles.isEmpty())
        {
            userRole=portalRoles[0];
        }
        System.debug('userRole ' + userRole);
        return userRole;
    }
}