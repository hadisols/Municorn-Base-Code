public without sharing class PMA_ExternalSiteFormsUtility {
    public static  TimeZone tz = UserInfo.getTimeZone();
    public static  DateTime dt = Datetime.now();
    
    Public static String getUUID()
    {        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        System.debug(guid);
        return guid;               
    }
    public pageReference checkActive() {
        String requestid =  ApexPages.currentPage().getParameters().get('reqid');
        System.debug('requestid '+requestid);
        if(requestid!=null){
            Contact contobj = new Contact();
            contobj = [Select Id, Active__c, Payment_Date_Time__c, Payment_SMS_Sent__c from Contact where UUID__c=:requestid];
            if( (contobj.Active__c==false) && (contobj.Payment_SMS_Sent__c==true) ){
                return new PageReference('/apex/PaymentPage');
            }else if( (contobj.Active__c==true) && (contobj.Payment_Date_Time__c!=null) ){
                return new PageReference('/apex/HomePage');
            }else{
                return null;
            }
        }else{
            return null; 
        }
    }
    
     @AuraEnabled
    Public static List<Contact> getContactFields(String reqId){
        System.debug('reqId '+reqId);
        if(reqId != null)
            return [SELECT Account.Name,UUID__c,Id, Name, Gender__c, Birthdate, Phone, Email, Active__c, Payment_Date_Time__c, Payment_SMS_Sent__c,AccountId from Contact
                    where UUID__c=: reqId Limit 1];
        else
            return new List<Contact>();
    }
    
    public static String formatPhone(String Phone) {
        if(!String.isBlank(Phone)) {
            string nondigits = '[^0-9]';
            string PhoneDigits;
            
            // remove all non numeric
            PhoneDigits = Phone.replaceAll(nondigits,'');
            
            // 10 digit: reformat with dashes
            if (PhoneDigits.length() == 10) {
                // 10 digit: if starts with 9,8,9, format as 91 country code for india
                if(PhoneDigits.substring(0,1) == '7' || PhoneDigits.substring(0,1) == '8' || PhoneDigits.substring(0,1) == '9' ){
                    return '91'+PhoneDigits.substring(0,10);
                } else{
                	return '1'+PhoneDigits.substring(0,10);
                }
            }
            // 11 digit: if starts with 1, format as 10 digit 
            if (PhoneDigits.length() == 11 && PhoneDigits.substring(0,1) == '1') {          
                return  PhoneDigits.substring(0,11);
            }
        }
        
        return( Phone );
    }
    public static String getPageBasePublicUrl(){
        String sfdcBaseURL = getOrgUrl();
        String stripePageBaseUrl = sfdcBaseURL.split('\\.')[0] + '--c.visualforce.com';
        return stripePageBaseUrl;
    }
    Public Static String getIframeSiteUrl(String page){
        String stripePageBaseUrl = getPageBasePublicUrl();
        stripePageBaseUrl += '/apex/' + page;
        System.debug(stripePageBaseUrl);
        return stripePageBaseUrl;
    } 
    
    Public Static String getGuestSiteUrl(String page){
        String sfdcBaseURL = getOrgUrl();
        String stripePageBaseUrl = 'https://selfscheduling-dev-developer-edition.ap27.force.com/' + page;
        System.debug(stripePageBaseUrl);
        return stripePageBaseUrl;
    } 
    
    public static String getOrgUrl() {
        return Url.getOrgDomainUrl().toExternalForm();
    }
    /*
    @AuraEnabled
    Public static void updateGuestForm(Contact contactform,String parentId,string attachId){
        System.debug('contactform: '+contactform+' parentId: '+parentId);
        if(contactform.First_submitted_date__c ==  null){
            contactform.First_submitted_date__c =  dt.addSeconds((tz.getOffset(dt)/1000));
        }
        contactform.Last_submitted_date__c = dt.addSeconds((tz.getOffset(dt)/1000));
        if(contactform.Number_of_submissions__c == null){
            contactform.Number_of_submissions__c = 1;
        }else{
            contactform.Number_of_submissions__c = contactform.Number_of_submissions__c + 1;
        }
        contactform.Parent__c = parentId;
        contactform.Status__c = constants.SUBMITTED;
        try{
            update contactform;
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    */
    public static List<Sobject> getRecord(Id rId) {
        
        String sObjName = Rid.getSObjectType().getDescribe().getName();
        String query='';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sObjName).getDescribe().fields.getMap();
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
        query = 'select ' + commaSepratedFields + ' from ' + sObjName;
        query += ' WHERE Id = \''+rId+'\'';
        System.debug('******soqlQuery*********'+query );
        list<Sobject> olist =  new list<Sobject>();
        olist = database.query(query);
        System.debug(olist);
        return olist;
    }

    
}