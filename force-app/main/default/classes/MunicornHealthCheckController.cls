public with sharing class MunicornHealthCheckController {
    
    @AuraEnabled
    public  static boolean Escapcharectercheck(String int_type) {
        Boolean Escapcharecter ;
        list<IntegrationSetting__mdt> integrationlist = [Select Id,Label  from IntegrationSetting__mdt WHERE developerName = :int_type And EscapeCharacter__c !=null];
        
        if(integrationlist.size()!= Null && integrationlist.size()!= 0){
            Escapcharecter = true;

        } else {
            Escapcharecter = false;  

        }
        
        return Escapcharecter;
    }
    
    
    @AuraEnabled   
    public  static Boolean isExternalcheck(String int_type) {
        Boolean isexternalcheck = true;

        Set<String> objWotExtField = new Set<String>();
        List<ObjectSetting__mdt> objSettings = [SELECT developername FROM ObjectSetting__mdt WHERE IntegrationType__c =:int_type LIMIT 1000];
        for(ObjectSetting__mdt item : objSettings) {
            List <FieldSetting__mdt> AllFieldSettingsList = new List <FieldSetting__mdt>();
            AllFieldSettingsList = [SELECT id,FieldApiName__c FROM FieldSetting__mdt WHERE Is_Active__c=true 
                                    AND ObjectSetting__r.developerName = :item.developerName AND Is_External_Field__c = true];
            if(AllFieldSettingsList.size() != null && AllFieldSettingsList.size() != 0 ) {
                continue;
            } else {
                objWotExtField.add(item.developerName);
                isexternalcheck = false;
            }
        }
        
        return isexternalcheck;
        
    }
    @AuraEnabled
    public  static Boolean intEnablement(String int_type) {
        Boolean enablemenInteg;
        List<IntegrationEnablement__mdt> enablemenIntegList = [Select developername, Integration_Setting__r.developername from IntegrationEnablement__mdt WHERE Integration_Setting__r.developerName = :int_type AND Enable__c = true];
        
        if(enablemenIntegList.size()!= Null && enablemenIntegList.size()!= 0){
            enablemenInteg = true;

        } else {
            enablemenInteg = false;  

        }
        return enablemenInteg;
        
    }
    @AuraEnabled
    public  static Boolean Notificationpartialcheck(String int_type) {
        Boolean Notificationpartial ;
        list<IntegrationSetting__mdt> NotificationIntList = [Select Id,Label  from IntegrationSetting__mdt WHERE developerName = :int_type AND Notifications_are_partial__c = true AND Notification_Wrapper__c =null ];
        
        if(NotificationIntList.size()== 0){
            Notificationpartial = true;
            
        } else {
            Notificationpartial = false;  
            
        }
        return Notificationpartial;
    }
    @AuraEnabled
    public  static Boolean fieldsettingLookupTowayCheck(String int_type) {
        Boolean fieldsettingLookup;
        list<FieldSetting__mdt> fieldsettinglookupList = [Select id from FieldSetting__mdt WHERE ObjectSetting__r.IntegrationType__r.developerName = :int_type AND Is_Lookup__c = true AND Direction__c = 'TWOWAY' ];
        
        if( fieldsettinglookupList.size()== 0){
            fieldsettingLookup = true;
            
        } else {
            fieldsettingLookup = false;  
            
        }
        return fieldsettingLookup ;
    }
    @AuraEnabled
    public  static Boolean objectFieldLowercasecheck() {
        Boolean  objectFieldLowercase = true;
        list<FieldSetting__mdt> fsnullelemenated = new list<FieldSetting__mdt>();
        list <FieldSetting__mdt> objectFieldLowercaseList = [select FieldApiName__c,ObjectApiName__c from FieldSetting__mdt ];
        
        for(FieldSetting__mdt fs :objectFieldLowercaseList){
            if( fs.FieldApiName__c!= null && fs.ObjectApiName__c != null){
                fsnullelemenated.add(fs);
            }
        }
        for(FieldSetting__mdt fs :fsnullelemenated){
            if(fs.FieldApiName__c==fs.FieldApiName__c.toLowerCase() && fs.ObjectApiName__c==fs.ObjectApiName__c.toLowerCase()){
                continue;
            } else{
                objectFieldLowercase = false;
            }
        }
        
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
    public  static Boolean NotificationInterfaceCheck(String int_type) {
        Boolean NotificationInterface = true;
        String className = IntegrationSetting__mdt.getInstance(int_type)?.Notification_Wrapper__c;
        if(className != null) {
            Type t = Type.forName(className);
            
            if(!SYS_NotificationInterface.class.isAssignableFrom(t)){
                NotificationInterface = false;
            }
        }
    return NotificationInterface;
        
    }
    @AuraEnabled
    public  static Boolean ExtensionCheck(String int_type) {
        Boolean Extension = true;
        // String classNameoutbound = 'SYS_QB_ApplicationServiceinbound';
        // String classNameinbound ='SYS_QB_ApplicationServiceinbound';
        Set<String> apexOverride  = new Set<String>();
        for(FieldSetting__mdt item : FieldSetting__mdt.getAll().values()) {
            apexOverride.add(item.Field_Mapping_Handler__c);
        }
        for(ObjectSetting__mdt item : ObjectSetting__mdt.getAll().values()) {
            apexOverride.add(item.ApexHandler__c);
        }
        for(IntegrationSetting__mdt item : IntegrationSetting__mdt.getAll().values()) {
            apexOverride.add(item.ApexHandler__c);
        }
        for(String item : apexOverride) {
            Type apexType = Type.forName(item);
            if(SYS_ApplicationService.class.isAssignableFrom(apexType)) {
                continue;
            } else {
                Extension = false;
            }
        }
        // Type outType = Type.forName(classNameoutbound);
        // Type inType = Type.forName(classNameinbound);
        // System.debug('========'+SYS_ApplicationService.class.isAssignableFrom(outType));
        // if(SYS_ApplicationService.class.isAssignableFrom(outType) && SYS_ApplicationService.class.isAssignableFrom(inType)){
        //     Extension = true;
        //     system.debug('Extension++++'+ Extension);
        // }else{
        //     Extension = false;
        // }
        return Extension;
    }   
    
}
