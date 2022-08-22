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
    }
    
    
    @InvocableMethod(label='Capture Request for Outbound' description='To capture outbound request and create a SYS_IntegrationLog record for Municorn')
    global static void captureOutboundRequest(List<MyInvocableVariable> myInvocableVariableList) {
        
        List<sObject> newList = new List<sObject>();
        Map<Id,sObject> newMap = new Map<Id,sObject>();

        List<sObject> oldList = new List<sObject>();
        
        List<SYS_IntegrationLog__c> insertSysLog = new List<SYS_IntegrationLog__c>();

        String operationType = myInvocableVariableList.size() > 0 ? myInvocableVariableList[0].operationType.toUppercase() : 'INSERT';
        String httpMethod = myInvocableVariableList.size() > 0 ? myInvocableVariableList[0]?.httpMethod?.toUppercase() : '';

        
        SYS_DataCache.INT_TYPE = myInvocableVariableList[0].integrationSetting;
        SYS_DataCache.OBJ_TYPE = myInvocableVariableList[0].objectSetting;

        for(MyInvocableVariable itr:myInvocableVariableList){
            newList.add(itr.newVal);
            newMap.put(itr.recId,itr.newVal);   
            oldList.add(itr.oldVal);   
        }

        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ApexHandler__c).newInstance();
        
        Map<Id, String> jsonListForOutbound = appService.transformSObjectToJson(newList);
        
       
        if(jsonListForOutbound.values().size() > 0){
            for(Id jsonRecordId:jsonListForOutbound.keyset()){ 
                /*--*/SYS_debug.log('Id:'+jsonRecordId);
                String finalJsonForOutbound;
                

                /*
                Pre-processing each transformed JSON record. Default is to remove newlines.
                For Custom pre-processing override sanitizeJSONForOutbound() method in SYS_ApplicationService
                by creating an extension class. Configure the new extended class in ObjectSettings metadata
                */

                finalJsonForOutbound = appService.sanitizeJSONForOutbound(jsonListForOutbound.get(jsonRecordId));
                /*--*/SYS_debug.log('cleanJSON'+finalJsonForOutbound); 

                SYS_IntegrationLog__c  newSysLog = SYS_Helper.getLogsToInsert(finalJsonForOutbound);

                
                newSysLog.Callout_URL__c = SYS_Helper.urlFromPattern(httpMethod,newMap.get(jsonRecordId));

                newSysLog.Status__c = 'NEW';
                newSysLog.Type__c = 'OUTBOUND';
                newSysLog.Integration_Setting__c = SYS_DataCache.INT_TYPE;
                newSysLog.SYS_Operation_Type__c = operationType;
                newSysLog.How_to_process__c = 'use_object_setting';
                newSysLog.whatid__c = jsonRecordId;
                newSysLog.HTTP_Method__c = httpMethod;
                newSysLog.ObjectSettingId__c = SYS_DataCache.OBJ_TYPE;
                insertSysLog.add(newSysLog);
            }
            if(!insertSysLog.isEmpty() && SYS_DataCache.enableCheck.get(SYS_DataCache.INT_TYPE.toUpperCase())){ 
                SYS_Helper.insertLog(insertSysLog);
                /*--*/SYS_debug.log('insertSysLog=='+insertSysLog);
            }
            
        }
    }

}