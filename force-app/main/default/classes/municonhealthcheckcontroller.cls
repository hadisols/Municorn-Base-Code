public class municonhealthcheckcontroller {
    @AuraEnabled   
    public  static Boolean isExternalcheck() {
        Boolean isexternalcheck;
        try{
            List <FieldSetting__mdt> AllFieldSettingsList = new List <FieldSetting__mdt>();
            AllFieldSettingsList = [Select id from FieldSetting__mdt WHERE Is_Active__c=true 
                                    AND ObjectSetting__r.developerName = 'AccountQB' AND Is_External_Field__c = true];
                                    system.debug('AllFieldSettingsList++++=='+AllFieldSettingsList);
                                    if(AllFieldSettingsList.size()!=null){
                                        isexternalcheck = true ;
                                        return isexternalcheck ;
                                    }
                                        isexternalcheck = false;
                                        return isexternalcheck;
                                    
           
        } catch(Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
        }
        isexternalcheck = false;
        return isexternalcheck;
    
        //List<FieldSetting__mdt> ls1 = new List<FieldSetting__mdt>();
        
        
        
    }
    @AuraEnabled
    public  static void Escapcharectercheck() {
        try{ 
            list<IntegrationSetting__mdt> escapCharectorIntegList = [Select EscapeCharacter__c from IntegrationSetting__mdt LIMIT 100];
            SYSTEM.debug('escapCharectorIntegList+++=='+escapCharectorIntegList);
        } catch(Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
        }
    }
     @AuraEnabled
    public  static void fieldsettingLookupTowayCheck() {
        
             list<FieldSetting__mdt> fieldsettinglookup = [Select id from FieldSetting__mdt WHERE Is_Lookup__c = true AND Direction__c = 'TWOWAY' ];
             system.debug('fieldsettinglookup++'+fieldsettinglookup);
              try{ 
                  if(fieldsettinglookup.size()!=0){
                      system.debug('size is greaterthan 0');
                  }
             
              } catch(Exception e) {
            System.debug('An exception occurred:' + e.getMessage());
        }
    }
}