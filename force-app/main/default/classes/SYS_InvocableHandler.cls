global class SYS_InvocableHandler {
	
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
    }
    
    //TODO - remove descriptio
    @InvocableMethod(label='Capture Request for Outbound' description='To capture outbound request and create a SYS_IntegrationLog record for Municorn')
    global static void captureOutboundRequest(List<MyInvocableVariable> myInvocableVariableList) {
    	List<sObject> newList = new List<sObject>();
        List<sObject> oldList = new List<sObject>();
        
        Map<String, Object> discountMap = new Map<String, Object>();
        String objectApiName = '';
        String operationType = myInvocableVariableList.size() > 0 ? myInvocableVariableList[0].operationType.toUppercase() : 'INSERT';

        for(MyInvocableVariable itr:myInvocableVariableList){
            objectApiName = ((Id)itr.recId).getSobjectType() + '';
            newList.add(itr.newVal);   
            oldList.add(itr.oldVal);
            SYS_DataCache.INT_TYPE = itr.integrationSetting;
            SYS_DataCache.OBJ_TYPE = itr.objectSetting;
            SYS_DataCache.objectApiName = objectApiName;
            System.debug('SYS_DataCache.objectApiName:'+SYS_DataCache.objectApiName);
        } 
        
        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ApexHandler__c).newInstance();
        
        Map<Id, String> jsonListForOutbound = appService.transformSObjectToJson(newList);
        List<SYS_IntegrationLog__c> insertSysLog = new List<SYS_IntegrationLog__c>();
       
        if(jsonListForOutbound.values().size() > 0){
            for(Id jsonRecordId:jsonListForOutbound.keyset()){ 
                system.debug('Id:'+jsonRecordId);
                String finalJsonForOutbound;
                

                /*
                Pre-processing each transformed JSON record. Default is to remove newlines.
                For Custom pre-processing override sanitizeJSONForOutbound() method in SYS_ApplicationService
                by creating an extension class. Configure the new extended class in ObjectSettings metadata
                */

                

                finalJsonForOutbound = appService.sanitizeJSONForOutbound(jsonListForOutbound.get(jsonRecordId));
                System.debug('cleanJSON'+finalJsonForOutbound);

                //TODO - QB specific change for bundle product  

                SYS_IntegrationLog__c  newSysLog = SYS_Helper.getLogsToInsert(finalJsonForOutbound);
                newSysLog.Status__c = 'NEW';
                newSysLog.Type__c = 'OUTBOUND';
                newSysLog.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
                newSysLog.SYS_Operation_Type__c = operationType;
                newSysLog.whatid__c = jsonRecordId;
                newSysLog.ObjectSettingId__c = SYS_DataCache.OBJ_TYPE;
                insertSysLog.add(newSysLog);
            }
            if(!insertSysLog.isEmpty() && SYS_DataCache.enableCheck.get(SYS_DataCache.INT_TYPE.toUpperCase())){ 
                SYS_debug.log('inside insert'+insertSysLog.size());
                insert insertSysLog;
                system.debug('insertSysLog=='+insertSysLog);
            }
            
        }
    }

    public class productWrapper {
        public String Type;
    }
}