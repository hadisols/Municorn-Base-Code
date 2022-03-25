public class Athrz_ApplicationService extends SYS_ApplicationService {
    public String gatewayId;
    
    public Athrz_ApplicationService() {
        // System.debug('constructor called');
        // this.gatewayId = Athrz_utility.gatewayId;
    }

    public override Boolean doWebhookSignatureCheck(){
        return true;
    }

    public override String getOperationTypeFor(String method) {

        Map<String,String> methodToOperationMap = new Map<String,String>{'POST'=>'UPSERT','PUT'=>'UPSERT','DELETE'=>'DELETE','PATCH'=>'UPDATE'};
        return methodToOperationMap.get(method);
    }

    public override SYS_IntegrationLog__c generateLogForWebhookReq(String method) {
        
        String requestBody = RestContext.request.requestBody.toString();
        SYS_IntegrationLog__c log = SYS_Helper.getLogsToInsert(requestBody);

        String algo = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Hashing_Algo__c;
        if(algo!=NULL && algo!='')
        log.Request_Digest__c = generateHash(requestBody,algo);

        log.Type__c = 'INBOUND';
        log.SYS_Operation_Type__c = getOperationTypeFor(method);
        log.Flat_Key_for_Resource__c = 'payload.entityName';
        log.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
        log.Status__c = 'NEW';
        //log.External_Id_Field_API_Name__c = 'SYS_Key__c';
        log.How_to_process__c = 'use_custom_apex_handler';
        log.Custom_Apex_Handler__c = 'Athrz_ApplicationService';

        return log;
    }

    public override HttpResponse doOutbound(SYS_IntegrationLog__c log){
        System.debug('\n In override_SYS_ApplicationService');
        return super.doOutbound(log);
    }

    public override SYS_IntegrationLog__c generateLogForChildRecords(SYS_IntegrationLog__c parentLog,String resource,String recordsJson,String integrationSetting) {
        SYS_IntegrationLog__c log = SYS_Helper.getLogsToInsert(recordsJson);

        String algo = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Hashing_Algo__c;
        if(algo!=NULL && algo!='')
            log.Request_Digest__c = generateHash(recordsJson,algo);

        SYS_debug.log('MS SYS_DataCache.log in generate child log:'+SYS_DataCache.log.Id);
        log.Parent__c = parentLog.Id;
        log.Resource__c = resource;
        log.Type__c = 'INBOUND';
        log.SYS_Operation_Type__c = 'UPSERT';
        log.Flat_Key_for_Resource__c = '';
        log.SYS_IntegrationSettings__c = integrationSetting;
        log.Status__c = 'NEW';//'WAITING_FOR_PARENT';

        /**
         * Applies when the child records require parenting after creation
         */

        log.Requires_process_on_complete__c = true;
        log.On_Complete_Handler__c = 'Athrz_ApplicationService';
        /** */

        log.External_Id_Field_API_Name__c = 'Profile_Id__c';
        log.How_to_process__c = 'use_custom_apex_handler';
        log.Custom_Apex_Handler__c = 'Athrz_ApplicationService';
        log.Gateway_Id__c = parentLog.Gateway_Id__c;

        return log;
    }

    public override Object getFieldValues(sObject obj, FieldSetting__mdt mapping, String fieldAPIName){
        //TODO - handle case - Account."CreatedBy".Name, where CreatedBy is not an sobject - This can be handled by overriding the current method and add the handler
        // on field setting

        String fvalue='';
        if(fieldAPIName == null){
            if(mapping.developername == 'Payment_Intent_dataDescriptor_refund') {
                fvalue = Athrz_utility.cardNumber.right(4);
            } else if (mapping.developername == 'Payment_Intent_type_refTransId') {
                fvalue = Athrz_utility.transactionId;
            } else {
                fvalue = mapping.StaticValue__c;
            }
        }
        else if(fieldAPIName.contains('.')){
            List<String> splitedFields = fieldAPIName.split('\\.');
            try{
                for(Integer i = 0; i < splitedFields.size() - 1; i++){
                    obj = obj.getSobject(splitedFields[i]);   
                } 
                return obj.get(splitedFields[splitedFields.size()-1]) != null ? obj.get(splitedFields[splitedFields.size()-1]) : '';
            }catch(exception ex){
               System.debug('******exception while fetching fieldValues as relationship '+fieldAPIName+'  value is blank.'+ex.getmessage()); 
               return null;
            }
            
        } 
        /*
        else if(obj.get(fieldAPIName)!=null && fieldAPIName == SYS_DataCache.namespacePrefix + 'Is_Taxable__c') { //TODO - specific to quickbooks
            return ((Boolean)obj.get(fieldAPIName)) ? 'TAX' : 'NON';
        } 
        else if(obj.get(fieldAPIName) != null && fieldAPIName == SYS_DataCache.namespacePrefix + 'Total_Tax__c') {
            return ((Decimal)obj.get(fieldAPIName)) == 0.00 ? 'null' : obj.get(fieldAPIName);  
        }
        */
        else if(fieldAPIName == 'Athrz_Data_Value__c' && Athrz_utility.token != null) {

            return Athrz_utility.token;

        } else if(fieldAPIName == 'Athrz_Amount__c' && Athrz_utility.amount != null) {
            return String.valueOf(Athrz_utility.amount);
        } 
        else if(obj.get(fieldAPIName)!=null){
            return obj.get(fieldAPIName);
        }
        return fvalue;
    }

    public override HttpRequest buildOutboundHttpRequest(SYS_IntegrationLog__c log){
        HttpRequest req = new HttpRequest();
        IntegrationSetting__mdt integrationSetting = SYS_DataCache.integrationSetting.get(SYS_Datacache.INT_TYPE);
        String baseEndpoint = integrationSetting.BaseAPIEndPoint__c;

        List<HttpHeaders__mdt> httpHeader = SYS_DataCache.headerSetting;
        req.setMethod(integrationSetting.UpdateMethod__c);
        for(HttpHeaders__mdt head:httpHeader){
            SYS_debug.log('header is = '+head.MasterLabel + ''+head.Value__c);
            req.setHeader(String.valueOf(head.MasterLabel), String.valueOf(head.Value__c));
                
        }
        String resourceUrl = integrationSetting.BaseAPIEndPoint__c;
        List<Custom_Parent__c> rec = [SELECT SYS_Key__c FROM Custom_Parent__c WHERE Id = :log.WhatId__c LIMIT 1];
        req.setEndpoint(resourceUrl);
        return req;
    }

    public override sObject processFieldMapping(FieldSetting__mdt mapping,sObject sObj,Object value, String sObjectApiName){

        System.debug(mapping.FieldApiName__c+' +MS+ '+value);
        if(mapping.Get_value_from_Log__c)
            value = SYS_DataCache.log.get(mapping.Log_API_for_field_mapping__c);

        if(mapping.Is_Lookup__c && mapping.Lookup_External_Key__c!=NULL && mapping.Lookup_Object_API_Name__c!=NULL){
            value = getIdFromExternalKey(mapping.Lookup_Object_API_Name__c,mapping.Lookup_External_Key__c,String.valueOf(value));
        }

        if(mapping.StaticValue__c != NULL)
            value = mapping.StaticValue__c;
            

        if(value==NULL) return sObj;

        System.debug('--MS In Field Mapping. Value check:'+mapping.Log_API_for_field_mapping__c);
        System.debug('--MS In Field Mapping. Value check Log:'+SYS_DataCache.log);

        SObjectType r = ((SObject)(Type.forName('Schema.'+sObjectApiName).newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();
                
        String fieldType = d.fields
                            .getMap()
                            .get(mapping.FieldApiName__c)
                            .getDescribe()
                            .getType()+'';

        
        //TODO add other field types
        if(mapping.FieldApiName__c == 'Athrz_Data_Value__c' && (value != null || value != '')) {
            sObj.put(mapping.FieldApiName__c, '##token##');
        } 
        /* else if(mapping.FieldApiName__c == 'Payment_Gateway__c' && (value != null || value != '')) {
            sObj.put(mapping.FieldApiName__c, Athrz_utility.gatewayId);
        } */
        else if(fieldType=='DATE'){
            sObj.put(mapping.FieldApiName__c, date.valueOf((String)value));
        }else if (fieldType == 'STRING') {
            sObj.put(mapping.FieldApiName__c, String.valueof(value));
        }else if (fieldType == 'BOOLEAN') {
            sObj.put(mapping.FieldApiName__c, Boolean.valueof(value));
        }
        else{
            sObj.put(mapping.FieldApiName__c, value);
        }

        SYS_debug.log('MS FINAL SOBJ:'+sObj);
        return sObj;
    }

}