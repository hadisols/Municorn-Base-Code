public class municonhealthcheckcontroller {
    @AuraEnabled
    public  static boolean Escapcharectercheck() {
        Boolean Escapcharecter ;
        list<IntegrationSetting__mdt> integrationlist = [Select Id,Label  from IntegrationSetting__mdt WHERE developerName = 'Quickbooks'And EscapeCharacter__c !=null];
        system.debug('integrationlist+++'+integrationlist);
        
        if(integrationlist.size()!= Null && integrationlist.size()!= 0){
            Escapcharecter = true;
            system.debug('Escapcharecter=='+Escapcharecter);
            
        } else {
            Escapcharecter = false;  
            system.debug('Escapcharecter=='+Escapcharecter);
        }
        
        return Escapcharecter ;
    }
    
    
    @AuraEnabled   
    public  static Boolean isExternalcheck() {
        Boolean isexternalcheck;
        try{
            List <FieldSetting__mdt> AllFieldSettingsList = new List <FieldSetting__mdt>();
            AllFieldSettingsList = [Select id,FieldApiName__c from FieldSetting__mdt WHERE Is_Active__c=true 
                                    AND ObjectSetting__r.developerName = 'AccountQB' AND Is_External_Field__c = true];
            system.debug('AllFieldSettingsList++++=='+AllFieldSettingsList);
            if(AllFieldSettingsList.size()!=null && AllFieldSettingsList.size()!=0 ){
                
                isexternalcheck = true ;
                system.debug('isexternalcheckif'+isexternalcheck);
                
            }else{
                
                isexternalcheck = false;
                
                system.debug('isexternalcheck'+isexternalcheck);
                
            }
        } catch(Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
        }
        
        return isexternalcheck;
        
        //List<FieldSetting__mdt> ls1 = new List<FieldSetting__mdt>();
        
        
        
    }
    @AuraEnabled
    public  static Boolean intEnablement() {
        Boolean enablemenInteg;
        list<IntegrationEnablement__mdt> enablemenIntegList = [Select MasterLabel from IntegrationEnablement__mdt WHERE Integration_Setting__r.developerName ='Quickbooks' AND Enable__c = true];
        System.debug('enablemenIntegList+++=='+enablemenIntegList);
        if(enablemenIntegList.size()!= Null && enablemenIntegList.size()!= 0){
            enablemenInteg = true;
            system.debug('enablemenInteg=='+enablemenInteg);
        } else {
            enablemenInteg = false;  
            system.debug('enablemenInteg=='+enablemenInteg);
        }
        return enablemenInteg;
        
    }
    @AuraEnabled
    public  static Boolean Notificationpartialcheck() {
        Boolean Notificationpartial ;
        list<IntegrationSetting__mdt> NotificationIntList = [Select Id,Label  from IntegrationSetting__mdt WHERE developerName = 'Quickbooks'AND Notifications_are_partial__c = true AND Notification_Wrapper__c =null ];
        system.debug('NotificationIntList+++=='+NotificationIntList);
        if(NotificationIntList.size()== 0){
            Notificationpartial = true;
            system.debug('NotificationpartialIF'+Notificationpartial);
        } else {
            Notificationpartial = false;  
            system.debug('NotificationpartialElse=='+Notificationpartial);
        }
        return Notificationpartial;
    }
    @AuraEnabled
    public  static Boolean fieldsettingLookupTowayCheck() {
         Boolean fieldsettingLookup;
        list<FieldSetting__mdt> fieldsettinglookupList = [Select id from FieldSetting__mdt WHERE Is_Lookup__c = true AND Direction__c = 'TWOWAY' ];
        system.debug('fieldsettinglookup++'+fieldsettinglookupList);
       if( fieldsettinglookupList.size()== 0){
            fieldsettingLookup = true;
            system.debug('fieldsettingLookup=='+fieldsettingLookup);
            
        } else {
            fieldsettingLookup = false;  
            system.debug('fieldsettingLookup=='+fieldsettingLookup);
        }
        
        return fieldsettingLookup ;
    }
    
    
}