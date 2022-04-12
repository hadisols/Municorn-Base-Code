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
    @AuraEnabled
    public  static Boolean objectFieldLowercasecheck() {
        Boolean  objectFieldLowercase;
        list<FieldSetting__mdt> fsnullelemenated = new list<FieldSetting__mdt>();
        list <FieldSetting__mdt> objectFieldLowercaseList = [select FieldApiName__c,ObjectApiName__c from FieldSetting__mdt ];
        system.debug('objectFieldLowercaseList'+objectFieldLowercaseList);
        for(FieldSetting__mdt fs :objectFieldLowercaseList){
            if( fs.FieldApiName__c!= null && fs.ObjectApiName__c != null){
                fsnullelemenated.add(fs);
            }
        }
        for(FieldSetting__mdt fs :fsnullelemenated){
            if(fs.FieldApiName__c==fs.FieldApiName__c.toLowerCase() && fs.ObjectApiName__c==fs.ObjectApiName__c.toLowerCase()){
                
                objectFieldLowercase = true;
                system.debug('iffffff');
            } else{
                system.debug('errrrrrr');
            }
            
        }
        system.debug('objectFieldLowercase'+objectFieldLowercase);
        return objectFieldLowercase;
    }
    
    @AuraEnabled
    public  static Boolean flowActiveCheck() {
        Boolean flowActive;
       List<FlowDefinitionView> flows = [
            SELECT ApiName, DurableId, TriggerType, Label 
            FROM FlowDefinitionView 
            WHERE IsActive=true AND ApiName='SYS_Flow_for_log_retry'
        ];
        if( flows.size()!= 0){
            flowActive = true;
            system.debug('flows=='+flowActive);
            
        } else {
            flowActive = false;  
            system.debug('flowActive=='+flowActive);
        }
        
        return flowActive ;
        
    }
    @AuraEnabled
public  static Boolean NotificationInterfaceCheck() {
    Boolean NotificationInterface ;
    String className = 'QB_Wrapper';
Type t = Type.forName(className);
System.debug('========'+SYS_NotificationInterface.class.isAssignableFrom(t));
    if(SYS_NotificationInterface.class.isAssignableFrom(t)){
         NotificationInterface = true;
    }else{
        NotificationInterface = false;
    }
        return NotificationInterface;
}
@AuraEnabled
public  static Boolean ExtensionCheck() {
    Boolean Extension ;
    String classNameoutbound = 'SYS_QB_ApplicationServiceinbound';
    String classNameinbound ='SYS_QB_ApplicationServiceinbound';
Type outType = Type.forName(classNameoutbound);
Type inType = Type.forName(classNameoutbound);
System.debug('========'+SYS_ApplicationService.class.isAssignableFrom(outType));
    if(SYS_ApplicationService.class.isAssignableFrom(outType) && SYS_ApplicationService.class.isAssignableFrom(inType)){
         Extension = true;
        system.debug('Extension++++'+ Extension);
    }else{
        Extension = false;
    }
        return Extension;
}   
    
    
    /*@AuraEnabled
public  static Boolean fieldAvailabiltyCheck() {
Boolean fieldAvailabilty ;
set<ObjectSetting__C> objectsettingIds = [select Id from ObjectSetting__C];

return true;
}*/
}