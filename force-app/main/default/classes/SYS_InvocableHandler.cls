global without sharing class SYS_InvocableHandler {
	
    global class MyInvocableVariable {
        @InvocableVariable(label='Id' required=true)  
        global Id recId;
    
        @InvocableVariable(label='Old Value' required=true)  
        global sObject oldVal;
    
        @InvocableVariable(label='Current Value' required=true)
        global sObject newVal;

        @InvocableVariable(label= 'Integration Setting' required = true)
        global String integrationSetting;
        
        @InvocableVariable(label= 'Object Setting' required = true)
        global String objectSetting; 

        @InvocableVariable(label= 'Operation Type' required = true)
        global String operationType;

        @InvocableVariable(label= 'Callout Method' required = false)
        global String httpMethod;

        @InvocableVariable(label= 'Additional Parameter' required = false)
        global String param;
    }
    
    
    @InvocableMethod(label='Capture Request for Outbound' description='To capture outbound request and create a SYS_IntegrationLog record for Municorn')
    global static void captureOutboundRequest(List<MyInvocableVariable> myInvocableVariableList) {
        
        List<sObject> newList = new List<sObject>();
        Map<Id,sObject> newMap = new Map<Id,sObject>();
        List<String> paramList = new List<String>();

        List<sObject> oldList = new List<sObject>();
        
        List<SYS_IntegrationLog__c> insertSysLog = new List<SYS_IntegrationLog__c>();

        String operationType = myInvocableVariableList.size() > 0 ? myInvocableVariableList[0].operationType.toUppercase() : 'INSERT';
        String httpMethod = myInvocableVariableList.size() > 0 ? myInvocableVariableList[0]?.httpMethod?.toUppercase() : '';

        
        if(myInvocableVariableList.size() > 0) {
            SYS_DataCacheFactory init = new SYS_DataCacheFactory(
                myInvocableVariableList[0].integrationSetting,
                myInvocableVariableList[0].objectSetting
            );
        } else {
            return ;
        }
        

        // SYS_DataCache.INT_TYPE = myInvocableVariableList[0].integrationSetting;
        // SYS_DataCache.OBJ_TYPE = myInvocableVariableList[0].objectSetting;

        for(MyInvocableVariable itr:myInvocableVariableList){
            newList.add(itr.newVal);
            newMap.put(itr.recId,itr.newVal);   
            oldList.add(itr.oldVal);   
            paramList.add(itr.param);
        }
        // System.debug('SP '+myInvocableVariableList[0].accountId + ' ' + myInvocableVariableList[0].integrationType);
        // System.debug('SP static '+SYS_DataCache.INT_TYPE+' '+SYS_DataCache.OBJ_TYPE);

        SYS_Helper.processOutboundRequest(newList, operationType, httpMethod, newMap, paramList);
    }

}