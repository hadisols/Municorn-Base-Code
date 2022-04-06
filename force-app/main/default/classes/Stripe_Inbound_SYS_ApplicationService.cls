public with sharing class Stripe_Inbound_SYS_ApplicationService extends SYS_ApplicationService {
    public Stripe_Inbound_SYS_ApplicationService() {

    }
    /**
     * This hook is called from each of the hook for Http Verb processing
     * Arguement: Http Verb - POST,GET,PATCH,DELETE,PUT
     * Relies on Integration Setting in DataCache and RestContext
     * Override if custom log generation is required
     */
    //Process Webhook Responses for Stripe Integration
    public override SYS_IntegrationLog__c generateLogForWebhookReq(String method) {
        String requestBody = RestContext.request.requestBody.toString();
        SYS_IntegrationLog__c log = SYS_Helper.getLogsToInsert(requestBody);

        String algo = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Hashing_Algo__c;
        if(algo!=NULL && algo!='')
        log.Request_Digest__c = generateHash(requestBody,algo);

        log.Type__c = 'INBOUND';
        log.SYS_Operation_Type__c = getOperationTypeFor(method);
        log.Flat_Key_for_Resource__c = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Flat_Key_for_Resource__c;
        log.Integration_Setting__c = SYS_DataCache.INT_TYPE;
        log.Status__c = 'NEW';
        log.How_to_process__c = 'use_custom_apex_handler';
        log.Custom_Apex_Handler__c = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).ApexHandler__c;

        return log;
    }

    // For Outbound. Called from doInbound() in ApplicationService
    //Upsert Webhook Response using externalid and preprocess values in sobject
    public override List<sObject> transformJsonToSObject(String jsonBody,String resource,SYS_IntegrationLog__c log) {
        List < sObject > sObjectsToDML = SYS_Transformer.getSObjectsToUpsert(new List<String>{jsonBody},resource,(log.Type__c=='INBOUND'));
        if (sObjectsToDML.size() > 0) {
            for (sObject currentObj: sObjectsToDML) {
                if (currentObj instanceOf Transaction__c) {
                    String contactId = (String) currentObj.get('Contact__c');
                    if (contactId != '') {
                        List < Sobject > contactRecords = PMA_ExternalSiteFormsUtility.getRecord(contactId);
                        Contact contactRecord = (contactRecords.size() > 0) ? (Contact)contactRecords[0] : new Contact();
                        String paymentName = 'Payment For ' + contactRecord.Name;
                        currentObj.put('Name', paymentName);
                    }
                }
                if (currentObj instanceOf Payment_Method__c) {
                    String cardToken = (String) currentObj.get('Payment_Method_Id__c');
                    String cardBrand = (String) currentObj.get('Brand__c');
                    String cardLast4Digits = (String) currentObj.get('Card_Last_4_Digit__c');
                    currentObj.put('Card_Id__c', cardToken);
                    currentObj.put('Name', cardBrand +' ('+cardLast4Digits +')' );
                }
            }
        }
        return sObjectsToDML;
    }

    /**
     * INBOUND
     * This hook is called from SYS_Transformer to set values for sObject record
     * Default is mapping based on field type
     * Relies on Integration Setting in DataCache
     * Override if custom field mapping is required
     */
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

        SObjectType r = ((SObject)(Type.forName('Schema.'+sObjectApiName).newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();
                
        String fieldType = d.fields
                            .getMap()
                            .get(mapping.FieldApiName__c)
                            .getDescribe()
                            .getType()+'';

        
        //TODO add other field types
        if(fieldType=='DATE'){
            sObj.put(mapping.FieldApiName__c, getDateValue(mapping,String.valueOf(value)) /*Date.valueOf((String)value)*/);
        }
        else if(fieldType=='DATETIME'){
            
            sObj.put(mapping.FieldApiName__c, getDatetimeValue(mapping, String.valueOf(value)));
        }
        else if(fieldType=='TIME'){
            sObj.put(mapping.FieldApiName__c, getTimeValue(mapping, String.valueOf(value)));
        }
        else if (fieldType == 'STRING') {
            sObj.put(mapping.FieldApiName__c, String.valueof(value));
        }else if (fieldType == 'BOOLEAN') {
            sObj.put(mapping.FieldApiName__c, Boolean.valueof(value));
        }
        else if ( (mapping.FieldApiName__c == 'Amount__c') || (mapping.FieldApiName__c == 'Amount_Captured__c') || (mapping.FieldApiName__c == 'AmountRefunded__c') ) {
            sObj.put(mapping.FieldApiName__c, Double.valueof(value)/100);
        }
        else{
            sObj.put(mapping.FieldApiName__c, value);
        }

        SYS_debug.log('MS FINAL SOBJ:'+sObj);
        return sObj;
    }
    /* ------------------------------------------------------------------------ */
    /**
     * OUTBOUND
     * This hook is called from SYS_Transformer to set values for JSON record
     * Relies on Integration Setting in DataCache
     * Override if custom field mapping is required
     */
    public override Object getFieldValues(sObject obj, FieldSetting__mdt mapping, String fieldAPIName){
        //TODO - handle case - Account."CreatedBy".Name, where CreatedBy is not an sobject - This can be handled by overriding the current method and add the handler
        // on field setting

        String fvalue= (mapping.Send_Blanks_as_Empty_String__c)?'':null;
        
        if(fieldAPIName == null){
            fvalue = mapping.StaticValue__c;
        }
        else if(fieldAPIName.contains(SYS_DataCache.FLAT_KEY_SEPERATOR)){
            List<String> splitedFields = fieldAPIName.split('\\'+SYS_DataCache.FLAT_KEY_SEPERATOR);
            try{
                for(Integer i = 0; i < splitedFields.size() - 1; i++){
                    obj = obj.getSobject(splitedFields[i]);   
                } 
                return obj.get(splitedFields[splitedFields.size()-1]);
            }catch(exception ex){
               System.debug('****** Exception while fetching fieldValues as relationship '+fieldAPIName+'  value is blank.'+ex.getmessage()); 
               return null;
            }
            
        } 
        else if(obj.get(fieldAPIName)!=null && ( (fieldAPIName == SYS_DataCache.namespacePrefix + 'Amount__c') || (fieldAPIName == SYS_DataCache.namespacePrefix + 'Amount_Captured__c') || (fieldAPIName == SYS_DataCache.namespacePrefix + 'AmountRefunded__c') ) ){
            Decimal amount = (Decimal)obj.get(fieldAPIName);
            return (amount > 0) ? ( (amount.intValue()) * 100 ) : 0;
        }
        /*
        else if(obj.get(fieldAPIName)!=null && fieldAPIName == SYS_DataCache.namespacePrefix + 'Is_Taxable__c') { //TODO - specific to quickbooks
            return ((Boolean)obj.get(fieldAPIName)) ? 'TAX' : 'NON';
        } 
        else if(obj.get(fieldAPIName) != null && fieldAPIName == SYS_DataCache.namespacePrefix + 'Total_Tax__c') {
            return ((Decimal)obj.get(fieldAPIName)) == 0.00 ? 'null' : obj.get(fieldAPIName);  
        }
        */
        else if(obj.get(fieldAPIName)!=null){
            return obj.get(fieldAPIName);
        }
        return fvalue;
    }

}