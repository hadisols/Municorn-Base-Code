global virtual inherited sharing class SYS_ApplicationService {

    public class SYS_ApplicationServiceException extends Exception{}

    global SYS_ApplicationService() {

    }

    /* ------------------------------------------------------------------------ */
    
    //WEBHOOK Virtuals
    
    /**
     * This hook is called from Webservice methods to verify the source.
     * Default is to cross check the token configured in Integration Setting
     * Zero Arguments. Relies on Integration Setting in DataCache
     * Override if custom signature check is required
     */
    global virtual Boolean doWebhookSignatureCheck(){

        String tokenFromUrl = RestContext.request.params.get('token');
        String tokenFromIntegrationSetting = SYS_DataCacheFactory.integrationSetting.webhookToken__c;

        return (tokenFromUrl == tokenFromIntegrationSetting);

    }

    /**
     * This hook is called from insertWebhookLog methods and webservice.
     * Default is to set the response body with incoming request
     * Zero Arguments. Relies on Integration Setting in DataCache and RestContext
     * Override if custom handler is required after successful log creation
     */
    global virtual void setSuccessHttpResponse(){
        if(RestContext.response!=NULL){
            RestContext.response.responseBody = Blob.valueOf(RestContext.request.requestBody.toString());
        }
        
    }

    /**
     * This hook is called from insertWebhookLog methods.
     * Default is just a message for Debug logs
     * Zero Arguments. Relies on Integration Setting in DataCache and RestContext
     * Override if custom handler is required when log creation causes error
     */
    global virtual void setErrorHttpResponse(String stackTrace){
        SYS_debug.log('Webhook Error:'+stackTrace);
        if(RestContext.response!=NULL)
        RestContext.response.responseBody = Blob.valueOf(stackTrace);

    }


    /**
     * These hooks are called from Webservice.
     * Default is to generate a log record using another hook (generateLogForWebhookReq) and insert using another concrete method
     * Zero Arguments. Relies on Integration Setting in DataCache and RestContext
     * Override if custom handler is required for any or all of Http Verbs
     */
    global virtual void doPost(){
        
        List<SYS_IntegrationLog__c> logs = generateLogForWebhookReq('POST');
        // insertWebhookLog(log);
        upsertWebhookLog(logs);
        
    }
    global virtual void doPut(){

        List<SYS_IntegrationLog__c> logs = generateLogForWebhookReq('PUT');
        // insertWebhookLog(log);
        upsertWebhookLog(logs);
    }
    global virtual void doGet(){
        
        List<SYS_IntegrationLog__c> logs = generateLogForWebhookReq('GET');
        // insertWebhookLog(log);
        upsertWebhookLog(logs);
    }
    global virtual void doPatch(){

        List<SYS_IntegrationLog__c> logs = generateLogForWebhookReq('PATCH');
        // insertWebhookLog(log);
        upsertWebhookLog(logs);
    }
    global virtual void doDelete(){

        List<SYS_IntegrationLog__c> logs = generateLogForWebhookReq('DELETE');
        // insertWebhookLog(log);
        upsertWebhookLog(logs);
    }

    /* ------------------------------------------------------------------------ */

    //TODO Test coverage
    global virtual String getIdFromExternalKey(String objectApiName, String externalKey, String externalId){
        List<sObject> parentRecord = new List<sObject>();
        if(externalKey == NULL || externalId == NULL) {
            return null;
        }
        String query = 'SELECT Id FROM '+objectApiName;
        String whereClause = ' WHERE '+String.escapeSingleQuotes(externalKey)+'= \''+String.escapeSingleQuotes(externalId)+'\'';
        parentRecord = Database.query(String.escapeSingleQuotes(query)+whereClause);
        if(parentRecord!=NULL && parentRecord.size()>0)
            return String.valueOf(parentRecord[0].get('Id'));
        else
            return null;
    }


    /* ------------------------------------------------------------------------ */

    /**
     * This hook is called from all DML hooks following this method
     * Default is just a message for Debug logs
     * Argument: Database.Error[]. Relies on Integration Setting in DataCache
     * Override if custom handler is required when there are errors in DMLs
     */
    global virtual void handleDMLErrors(Database.Error[] errors,SYS_IntegrationLog__c log){
        String errMsg='The following error has occurred while performing DML: ';
        for(Database.Error err : errors) {
            errMsg+= err.getStatusCode() + ': ' + err.getMessage() + '. Fields affected are: ' + err.getFields()+'\n';
            SYS_debug.log('The following error has occurred.');                    
            SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
            SYS_debug.log('Fields affected are: ' + err.getFields());
        }
        SYS_Helper.logException(log, errMsg);
    }

    /**
     * These hooks are called from doDML() concrete method which in turn is called from doInbound
     * Default is to call the DML based on operation type
     * Argument: List<sObject>. Additionally ExternalId field for upsert.
     * Relies on Integration Setting in DataCache
     * Override if custom handler is required for any DML
     */
    global virtual Boolean doInsert(List<sObject> records,SYS_IntegrationLog__c log){
        Database.SaveResult[] results;
        Boolean success = true;
        results = Database.insert(records, false);
        if(!results[0].isSuccess()){
            success = false;
            handleDMLErrors(results[0].getErrors(),log);
        }
        else{
            log.WhatId__c = results[0].getId();
        }

        return success;
    }

    global virtual Boolean doUpdate(List<sObject> records,SYS_IntegrationLog__c log){
        Database.SaveResult[] results;
        Boolean success = true;
        results = Database.update(records, false);
        if(!results[0].isSuccess()){
            success = false;
            handleDMLErrors(results[0].getErrors(),log);
        }
        else{
            log.WhatId__c = results[0].getId();
        }

        return success;
    }

    global virtual Boolean doDelete(List<sObject> records,SYS_IntegrationLog__c log){
        Database.DeleteResult[] results;
        Boolean success = true;
        results = SYS_Helper.deleteWithFLSCheck(records);
        if(!results[0].isSuccess()){
            success = false;
            handleDMLErrors(results[0].getErrors(),log);
        }
        else{
            log.WhatId__c = results[0].getId();
        }

        return success;
    }

    global virtual Boolean doUpsert(List<sObject> records,String additionalSetting,SYS_IntegrationLog__c log){
        Database.UpsertResult[] results;
        Boolean success = true;
        if(additionalSetting=='' || records[0]?.get('id') != null)
            results = Database.upsert(records, false);
        else{
            /*--*/SYS_debug.log('--MS externalIdField for:'+records[0]);
            //Schema.SObjectField externalIdField = Schema.getGlobalDescribe().get(SYS_DataCache.sObjectApiName).getDescribe().fields.getMap().get(additionalSetting); 
            
            Schema.SObjectField externalIdField = records[0].getSObjectType().getDescribe().fields.getMap().get(additionalSetting); 
            /*--*/SYS_debug.log('--MS externalIdField in doUpsert:'+externalIdField);
            
            results = Database.upsert(records, externalIdField, false);
        }
        
        /*--*/SYS_debug.log('--MS Log check # '+log.Id+' has WhatId: '+results[0].getId());

        if(!results[0].isSuccess()){
            success = false;
            handleDMLErrors(results[0].getErrors(),log);
        }
        else{
            log.WhatId__c = results[0].getId();
        }
        /*--*/SYS_debug.log('--MS Log re-check # '+log.Id+' has WhatId: '+log.WhatId__c);

        return success;
    }


    /* ------------------------------------------------------------------------ */
    /**
     * OUTBOUND
     * This hook is called from SYS_Transformer to set values for JSON record
     * Relies on Integration Setting in DataCache
     * Override if custom field mapping is required
     */
    global virtual Object getFieldValues(sObject obj, FieldSetting__mdt mapping, String fieldAPIName){
        //TODO - handle case - Account."CreatedBy".Name, where CreatedBy is not an sobject - This can be handled by overriding the current method and add the handler
        // on field setting

        String fvalue= (mapping.Send_Blanks_as_Empty_String__c)?'':null;
        
        if(fieldAPIName == null){
            fvalue = mapping.StaticValue__c;
        }
        else if(fieldAPIName.contains(SYS_DataCacheFactory.FLAT_KEY_SEPERATOR)){
            List<String> splitedFields = fieldAPIName.split('\\'+SYS_DataCacheFactory.FLAT_KEY_SEPERATOR);
            try{
                for(Integer i = 0; i < splitedFields.size() - 1; i++){
                    obj = obj.getSobject(splitedFields[i]);   
                } 
                return obj.get(splitedFields[splitedFields.size()-1]);
            }catch(exception ex){
               /*--*/SYS_debug.log('****** Exception while fetching fieldValues as relationship '+fieldAPIName+'  value is blank.'+ex.getmessage()); 
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
        else if(obj.get(fieldAPIName)!=null){
            SObjectType r = obj.getSObjectType();
            DescribeSObjectResult d = r.getDescribe();
                    
            String fieldType = d.fields
                                .getMap()
                                .get(mapping.FieldApiName__c)
                                .getDescribe()
                                .getType()+'';
            if(fieldType == 'MULTIPICKLIST'){
                return ((String)obj.get(fieldAPIName)).split(';');
            }
            else
                return obj.get(fieldAPIName);
        }
        return fvalue;
    }

    /* ---------------------------------------------------------------------------------------------------*/

    global virtual Datetime getDatetimeValue(FieldSetting__mdt mapping, String dt){

        String format = mapping.Datetime_Conversion_Format__c;
        if(format==null){
            throw new SYS_ApplicationServiceException('\nInvalid conversion format defined in Field Setting for Datetime field');
        }
        Datetime newDatetime;

        if(format == 'EPOCH'){
            Long epoch =  Long.valueOf(dt);
            return DateTime.newInstance(epoch*1000);
                
        }
        if(format == 'EPOCHmm'){
            Long epoch =  Long.valueOf(dt);
            return DateTime.newInstance(epoch);
                
        }
        else{
            
            
            Integer yearIndex = format.indexOf('YYYY');
            Integer monthIndex = format.indexOf('MM');
            Integer dateIndex = format.indexOf('DD');
            Integer hoursIndex = format.indexOf('hh');
            Integer minutesIndex = format.indexOf('mm');
            Integer secondsIndex = format.indexOf('ss');
            Integer millisecondsIndex = format.indexOf('sss');

            Integer tzHours = format.indexOf('zh');
            Integer tzMins = format.indexOf('zm');

            String value =  dt.substring(yearIndex, yearIndex + 4) + '-' +
                            dt.substring(monthIndex, monthIndex + 2) + '-' +
                            dt.substring(dateIndex, dateIndex + 2) +
                            ' ' +
                            dt.substring(hoursIndex, hoursIndex + 2) + ':' +
                            dt.substring(minutesIndex, minutesIndex + 2) + ':' +
                            (secondsIndex > 0?dt.substring(secondsIndex, secondsIndex + 2):'00');

            Integer tzHoursOffset = 0;
            Integer tzMinsOffset = 0;
            if(tzHours > 0 && tzMins > 0){
                Integer tzSymbol = format.indexOf('_');

                tzHoursOffset = Integer.valueOf((dt.substring(tzSymbol,tzSymbol+1) + dt.substring(tzHours,tzHours + 2)));
                tzMinsOffset = Integer.valueOf((dt.substring(tzSymbol,tzSymbol+1) + dt.substring(tzMins)));
            }

            newDatetime = DateTime.valueOfGmt(value).addHours(tzHoursOffset).addMinutes(tzMinsOffset);


            return newDatetime;
                
        }

    }

    global virtual Date getDateValue(FieldSetting__mdt mapping, String value){
       return Date.valueOf(value);
    }

    global virtual Time getTimeValue(FieldSetting__mdt mapping, String ts){
        
        String format = 'hh:mm:ss.sssZ';
        
        Integer hoursIndex = format.indexOf('hh');
        Integer minutesIndex = format.indexOf('mm');
        Integer secondsIndex = format.indexOf('ss');
        Integer millisecondsIndex = format.indexOf('sss');

        Integer hours = Integer.valueOf(ts.substring(hoursIndex, hoursIndex + 2));
        Integer minutes = Integer.valueOf(ts.substring(minutesIndex, minutesIndex + 2));
        Integer seconds = (secondsIndex > 0)?Integer.valueOf(ts.substring(secondsIndex, secondsIndex + 2)):0;
        Integer ms = (millisecondsIndex > 0)?Integer.valueOf(ts.substring(millisecondsIndex, millisecondsIndex + 3)):0;

        Time timeValue = 
        Time.newInstance(   hours, 
                            minutes, 
                            seconds, 
                            ms );
        /*--*/SYS_debug.log('=============== '+timeValue);

        return timeValue;
     }

    /* ------------------------------------------------------------------------ */
    
    /**
     * INBOUND
     * This hook is called from SYS_Transformer to set values for sObject record
     * Default is mapping based on field type
     * Relies on Integration Setting in DataCache
     * Override if custom field mapping is required
     */
    global virtual sObject processFieldMapping(FieldSetting__mdt mapping,sObject sObj,Object value, String sObjectApiName){

        /*--*/SYS_debug.log(mapping.FieldApiName__c+' +MS+ '+value);
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
        else if(fieldType == 'MULTIPICKLIST'){
            sObj.put(mapping.FieldApiName__c,  String.valueof(value));
        }
        else{
            sObj.put(mapping.FieldApiName__c, value);
        }

        SYS_debug.log('MS FINAL SOBJ:'+sObj);
        return sObj;
    }

    /* ------------------------------------------------------------------------ */ 
    
    /**
     * This hook is called from generateLogForWebhookReq to map Http verb to DML operation type
     * Override if a different mapping is required
     */
    global virtual String getOperationTypeFor(String method) {

        Map<String,String> methodToOperationMap = new Map<String,String>{'POST'=>'UPSERT','PUT'=>'UPSERT','DELETE'=>'DELETE','PATCH'=>'UPDATE'};

        String operationMapString = SYS_DataCacheFactory.integrationSetting.Operation_Map__c;
        if(operationMapString!=NULL){
            List<String> kvPair = operationMapString.split('\n');
            for(String kv:kvPair){
                methodToOperationMap.put(kv.split(':')[0],kv.split(':')[1]);

            }
        }
        
        return methodToOperationMap.get(method);
        
        
    }

    /**
     * This hook is called from generateLogForWebhookReq
     * Default is to get digest for Http request body based on algorithm configured on Integration Settings 
     * Relies on Integration Setting in DataCache and RestContext
     * Override if custom digest generation is requied
     */
    global virtual String generateHash(String requestBody,String algo) {

        Blob requestBlob = Blob.valueOf(requestBody);
        Blob hashBlob = Crypto.generateDigest(algo,requestBlob);
        String base64EncodedHash = EncodingUtil.base64encode(hashBlob);

        return base64EncodedHash;
    }

    /**
     * This hook is called from each of the hook for Http Verb processing
     * Arguement: Http Verb - POST,GET,PATCH,DELETE,PUT
     * Relies on Integration Setting in DataCache and RestContext
     * Override if custom log generation is required
     */
    global virtual List<SYS_IntegrationLog__c> generateLogForWebhookReq(String method) {
        String requestBody = RestContext.request.requestBody.toString();
        SYS_IntegrationLog__c log = new SYS_IntegrationLog__c();
        List<SYS_IntegrationLog__c> logAfterPartition = new List<SYS_IntegrationLog__c>();
        
        //Check criteria when chars more than 1M
        if(requestBody != NULL && requestBody.length() > SYS_Constants.TEXT_AREA_MAX_SIZE*10) {
            logAfterPartition = SYS_Helper.getLogsAfterPartition(requestBody);
            if(logAfterPartition != NULL && logAfterPartition.size() > 0) {
                // SYS_Helper.upsertLog(logs[0]);
                // List<SYS_IntegrationLog__c> childs = SYS_Helper.getChildRecords(logs);
                
                // SYS_Helper.upsertLog(childs);
                log = logAfterPartition[0];
            }
            System.debug('SP 1M<<');
        } else {
            log = SYS_Helper.getLogsToInsert(requestBody);
            System.debug('SP 1M>>');
        }

        String algo = SYS_DataCacheFactory.integrationSetting.Hashing_Algo__c;
        if(algo!=NULL && algo!='')
        log.Request_Digest__c = generateHash(requestBody,algo);

        if(SYS_DataCacheFactory.integrationSetting.Notifications_are_partial__c)
            log.Is_Notification_Only__c = true;

        log.Type__c = SYS_Constants.INBOUND;
        log.SYS_Operation_Type__c = getOperationTypeFor(method);
        log.Flat_Key_for_Resource__c = SYS_DataCacheFactory.integrationSetting.Flat_Key_for_Resource__c;
        log.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
        log.Status__c = SYS_Constants.NEW_STATUS;
        log.How_to_process__c = 'use_custom_apex_handler';
        log.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;

        log.Account_Id__c = SYS_DataCacheFactory.accountId;
        log.Integration_Type__c = SYS_DataCacheFactory.integrationSetting?.Integration_Type__c;

        List<SYS_IntegrationLog__c> returnVal = new List<SYS_IntegrationLog__c>();
        returnVal.add(log);
        if(logAfterPartition != NULL && logAfterPartition.size() > 0) {
            log.Status__c = SYS_Constants.PENDING_PARTITIONED_LOOKUP;
            for(integer i = 1 ; i < logAfterPartition.size() ; i++) {
                returnVal.add(logAfterPartition[i]);
            }
        }

        return returnVal;
    }

    /**
     * This hook is called from Webservice methods when the Signature check fails
     * Arguement: Http Verb - POST,GET,PATCH,DELETE,PUT and a String message
     * Relies on Integration Setting in DataCache and RestContext
     * Override if custom log generation is required
     */
    global virtual SYS_IntegrationLog__c generateLogForWebhookSigFail(String method, String msg) {
        String requestBody = RestContext.request.requestBody.toString();
        SYS_IntegrationLog__c log = SYS_Helper.getLogsToInsert(requestBody);
        log.Message__c = msg;

        String algo = SYS_DataCacheFactory.integrationSetting.Hashing_Algo__c;
        if(algo!=NULL && algo!='')
        log.Request_Digest__c = generateHash(requestBody,algo);

        log.Type__c = SYS_Constants.INBOUND;
        log.SYS_Operation_Type__c = getOperationTypeFor(method);
        log.Flat_Key_for_Resource__c = SYS_DataCacheFactory.integrationSetting.Flat_Key_for_Resource__c;
        log.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
        log.Status__c = 'FAIL';
        log.How_to_process__c = 'use_custom_apex_handler';
        log.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;

        return log;
    }

    /**
     * This hook is called from SYS_QueueableForInboundChild to generate logs for inbound child records
     * Arguement: record json and Integration setting
     * Override if custom log generation is required
     */
    global virtual SYS_IntegrationLog__c generateLogForChildRecords(SYS_IntegrationLog__c parentLog,String resource,String recordsJson,String integrationSetting) {

        /*
        String query = 'SELECT '+SYS_Helper.getAllFieldsFor('SYS_IntegrationLog__c')+', Parent__r.WhatId__c, Parent__r.SYS_Operation_Type__c FROM SYS_IntegrationLog__c';
        String whereClause = ' WHERE Id in (' + '\'' + String.escapeSingleQuotes(parentLogId) + '\')';
        List<SYS_IntegrationLog__c> parentLog = 
        Database.query(String.escapeSingleQuotes(query)+whereClause);
        */

        SYS_IntegrationLog__c log = SYS_Helper.getLogsToInsert(recordsJson);

        log.ObjectSettingId__c = parentLog.ObjectSettingId__c;
        log.Account_Id__c = parentLog.Account_Id__c;
        log.Integration_Type__c = parentLog.Integration_Type__c;
        /* ------------------------------------ FOR ALL OR NONE HANDLING -------------------------------------- */
        if(log.ObjectSettingId__c!=NULL && SYS_DataCacheFactory.objectSettingMap.get(log.ObjectSettingId__c).All_OR_None__c){
            //log.Custom_Field_Value__c = parentLog[0].WhatId__c;
            log.SYS_Operation_Type__c = 'INSERT';
        }
        else {
            log.SYS_Operation_Type__c = 'UPSERT';
        }
        /* ------------------------------------ FOR ALL OR NONE HANDLING -------------------------------------- */

        String algo = SYS_DataCacheFactory.integrationSetting.Hashing_Algo__c;
        if(algo!=NULL && algo!='')
            log.Request_Digest__c = generateHash(recordsJson,algo);

        SYS_debug.log('MS SYS_DataCache.log in generate child log:'+SYS_DataCache.log.Id);
        log.Parent__c = parentLog.Id;       
        log.Type__c = SYS_Constants.INBOUND;
 
        /**
         * If there the Parent Resource Map is defined on IS the use it to derive the resource for child records else
         * If Flat key to identify resource for child records is defined on Integration Setting, consider that
         * Else take the root key as Resource that is passed on while processing parent record
         */
        String flat_key_for_child = SYS_DataCacheFactory.integrationSetting.Flat_Key_for_Resource_Child__c;

        if(SYS_DataCacheFactory.PARENT_RESOURCE_MAP != NULL){
            log.Resource__c = SYS_DataCacheFactory.PARENT_RESOURCE_MAP.get(parentLog.Resource__c);
        }
        else if(flat_key_for_child != NULL && flat_key_for_child!='')
            log.Flat_Key_for_Resource__c = flat_key_for_child;
        else{
            log.Resource__c = resource;
            log.Flat_Key_for_Resource__c = '';
        }
        log.Integration_Setting__c = integrationSetting;
        log.Status__c = SYS_Constants.NEW_STATUS;
        /**
         * Applies when the child records require parenting after creation
         */
        log.Requires_process_on_complete__c = true;
        log.On_Complete_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
        /** */

        log.How_to_process__c = 'use_custom_apex_handler';
        log.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;

        return log;
    }
    

    /* ------------------------------------------------------------------------ */ 

    // For Outbound. Called from doInbound() in ApplicationService
    global virtual List<sObject> transformJsonToSObject(String jsonBody,String resource,SYS_IntegrationLog__c log) {
        return SYS_Transformer.getSObjectsToUpsert(new List<String>{jsonBody},resource,(log.Type__c==SYS_Constants.INBOUND));
    }

    // For Outbound. Called from Invocable Handler
    global virtual Map<Id,String> transformSObjectToJson(List<sObject> newSObjectList) {
        return SYS_Transformer.getRequestJson(newSObjectList);
    }

    /* ------------------------------------------------------------------------ */ 

    global virtual String preprocessJSONForInbound(SYS_IntegrationLog__c log,String jsonBody) {

        return jsonBody;
    }

    global virtual String preprocessJSONForOutbound(SYS_IntegrationLog__c log,String jsonBody,HttpRequest req) {
        /*--*/SYS_debug.log('Default preprocessJSONForOutbound called');
        
        if(req.getHeader('content-type') == 'application/x-www-form-urlencoded'){
            String formUrlEncodedBody='';
            Map<String,Object> jsonobj = SYS_Helper.getFlatKeys(jsonBody,SYS_DataCacheFactory.FLAT_KEY_PATTERN);//(Map<String,Object>)JSON.deserializeUntyped(flatJSON);
            List<String> reqkeymap = new List<String>(jsonobj.keySet());
            List<String> keyValueList = new List<String>();
            reqkeymap.sort();

            for (String key: reqkeymap) {
                if (!String.isBlank(key) /*&& jsonobj.get(key) != '' && (jsonobj.get(key)) instanceOf String*/){
                    
                    keyValueList.add(key.toLowerCase() + '=' + EncodingUtil.urlEncode(String.valueOf(jsonobj.get(key)!=NULL?jsonobj.get(key):''),'UTF-8'));
                }
            }
            formUrlEncodedBody = String.join(keyValueList,'&');
            log.data1__c = formUrlEncodedBody; 

            jsonBody = formUrlEncodedBody;
        }
        else if(req.getHeader('content-type') == 'multipart/form-data'){
            //TODO form-data with boundary calculation
        }
        else{
            //TODO throw exception invalid header or just log
        }
        return jsonBody;
    }

    /**
     * This hook is called from doInbound to identify resource from incoming JSON
     * Arguement: SYS Log record and JSON Body
     * Default is return the root if it exists or the value of falt key mentioned in Flat_Key_for_Resource__c field on log record
     * Override if custom implementation is required for identifying the resoruce for inbound request
     */
    global virtual String getResourceFromJSON(SYS_IntegrationLog__c log,String jsonBody){

        String resource = '';
        if(log.Resource__c!=NULL){
            /*--*/SYS_debug.log('-- MS Resource defined in Log'+log.Resource__c.toLowerCase());
            return log.Resource__c.toLowerCase();
        }

        if(log.Flat_Key_for_Resource__c == NULL || log.Flat_Key_for_Resource__c == ''){
            //Root element identifies Resource
  
            Object responseType = JSON.deserializeUntyped(jsonBody);
            if(responseType instanceof Map<String,Object>){
                resource = new List<String>(((Map<String, Object>)responseType).keySet())[0];
            }
            /*--*/SYS_debug.log('-- MS Root defines resource'+resource.toLowerCase());
        }
        else{
            //Key mentioned in Flat_Key_for_Resource__c identifies Resource
            Map<String, Object> flatKeyMap = SYS_Helper.getFlatKeys(jsonBody,'A_B');
            /*--*/SYS_debug.log('-- MS flatKeyMap in getResourceFromJSON:'+flatKeyMap);
            resource = (String)flatKeyMap.get(log.Flat_Key_for_Resource__c);
        }

        /*--*/SYS_debug.log('-- MS Final identified resource in getResourceFromJSON:'+resource?.toLowerCase());

        return resource?.toLowerCase();
    }

    /* ------------------------------------------------------------------------ */
    /**
     * This method sets the id to records in sObjectsToDML if its missing
     * Scenario: Record insert in SF triggers Outbound followed by Response Inbound to be processed
     * Since the newly created SF records won't have the external Id, we cannot do an upsert
     * on external key in the JSON (it will create duplicates). Hence we need to get the Id i.e.
     * the WhatId on the log record.
     */

    global virtual List<sObject> getMissingIdForUpdate(List<sObject> sObjectsToDML,SYS_IntegrationLog__c log) {
        for(sObject s:sObjectsToDML){
            if(s.Id == NULL){
                s.Id = log.WhatId__c;
            }
        }
        return sObjectsToDML;
    }

    /* ------------------------------------------------------------------------ */

    // global virtual Boolean doInbound(SYS_IntegrationLog__c log) {
        
    //     String jsonBody = '';
    //     jsonBody =  SYS_Helper.getDataFrom(log); 
    //     jsonBody = preprocessJSONForInbound(log,jsonBody);

    //     if(SYS_DataCacheFactory.integrationSetting.Notifications_are_partial__c && 
    //         log.Is_Notification_Only__c
    //         ){
    //         //String baseEndpoint = SYS_DataCacheFactory.integrationSetting.BaseAPIEndPoint__c;
    //         String getURLPattern = SYS_DataCacheFactory.integrationSetting.GET_URL_Pattern__c;
            
    //         SYS_NotificationInterface it = 
    //         (SYS_NotificationInterface)Type.forName(SYS_DataCacheFactory.integrationSetting.Notification_Wrapper__c).newInstance();
            
    //         List<SYS_IntegrationLog__c> insertSysLog = new List<SYS_IntegrationLog__c>();

    //         for(Map<String,String> rMap:it.getIterator(jsonBody)){
    //             String getURL = getURLPattern;
    //             SYS_IntegrationLog__c  newSysLog = new SYS_IntegrationLog__c();
    //             for(String key:rMap.keySet()){
    //                 getURL = getURL.replaceAll('\\{'+key+'\\}',rMap.get(key));
  
    //             }
    //             /*--*/SYS_debug.log('=============== '+ getURL);

    //             newSysLog.Status__c = SYS_Constants.NEW_STATUS;
    //             newSysLog.HTTP_Method__c = 'GET';
    //             newSysLog.Callout_URL__c = getURL;
    //             newSysLog.Type__c = SYS_Constants.OUTBOUND;
    //             newSysLog.WhatId__c = log.Id;
    //             newSysLog.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
    //             newSysLog.SYS_Operation_Type__c = 'UPSERT';
    //             newSysLog.How_to_process__c = 'use_custom_apex_handler';
    //             newSysLog.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
    //             insertSysLog.add(newSysLog);
    //         }

            
    //         if(insertSysLog.size()>0 && SYS_DataCacheFactory.enableCheck){
    //             SYS_Helper.insertLog(insertSysLog);
    //         }

    //         return true;

    //     }
    //     else{
    //         String resource = getResourceFromJSON(log,jsonBody);
    //         log.Resource__c = resource;
    //         SYS_debug.log('\n\n ------------------------------- \n\n Application Service resource:'+resource);

    //         List<sObject> sObjectsToDML = transformJsonToSObject(jsonBody, resource, log);

    //         SYS_debug.log('\n\n ------------------------------- \n\n Application Service sObjects to DML:'+sObjectsToDML);
    //         SYS_debug.log('\n\n ------------------------------- \n\n Application Service externalKeyByResourceMap:'+SYS_DataCacheFactory.externalKeyByResourceMap);

    //         String externalIdFieldAPIName = SYS_DataCacheFactory.externalKeyByResourceMap.get(resource);
    //         //String externalIdFieldAPIName = log.External_Id_Field_API_Name__c!=NULL?log.External_Id_Field_API_Name__c:'';
                
    //         return doDML(sObjectsToDML,log.SYS_Operation_Type__c,externalIdFieldAPIName,log);
    //     }
        
    // }

    /* ------------------------------------------------------------------------ */

    global virtual String getHttpRequestMethod(SYS_IntegrationLog__c log,String externalId){

        String httpMethod;
        if(log.HTTP_Method__c != NULL){
            httpMethod = log.HTTP_Method__c;
        }
        else if(externalId != NULL && externalId != ''){
            httpMethod =  SYS_DataCacheFactory.integrationSetting.UpdateMethod__c;
        }
        else{
            httpMethod = 'POST';
        }
        
        log.HTTP_Method__c = httpMethod;
        return httpMethod;

    }
    
    /* ------------------------------------------------------------------------ */

    global virtual String getHttpRequestEndpoint(HttpRequest req,SYS_IntegrationLog__c log, String externalId){
        

        if(log.Callout_URL__c!=NULL){
            return log.Callout_URL__c;
        }
        
        String urlFromPattern = SYS_Helper.urlFromPattern(log.HTTP_Method__c, log.WhatId__c);
        
        if(urlFromPattern != null){
            log.Callout_URL__c = urlFromPattern;
            return log.Callout_URL__c;
        }
        else{
            String baseEndpoint = SYS_DataCacheFactory.integrationSetting.BaseAPIEndPoint__c;
            String resourceUrl = baseEndpoint + SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).ResourcePath__c;
            
            /*--*/SYS_debug.log('====== MS Endpoint check:'+resourceUrl);

            //Log is to create resource
            if(req.getMethod() == 'POST' && (externalId == NULL || externalId == '')){
                String urlParams='';
                if(SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).url_params__c != NULL)
                        urlParams = SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).url_params__c;
                
                if(urlParams!=''){
                    resourceUrl+='/'+urlParams;
                }
            }
            else{
                //Method is PUT / PATCH / DELETE / GET - so the URL will be of the form https://<xyz.abc>/v1/resource/:id
                resourceUrl+= '/'+ externalId;
            }
            /*--*/SYS_debug.log('====== MS Endpoint check:'+resourceUrl);
            log.Callout_URL__c = resourceUrl;
            return resourceUrl;
        }
        
    }

    /* ------------------------------------------------------------------------ */
    global virtual void setHttpRequestHeaders(HttpRequest req,SYS_IntegrationLog__c log){
        
        List<HttpHeaders__mdt> httpHeader = SYS_DataCacheFactory.headerSetting;
        for(HttpHeaders__mdt head:httpHeader){
            SYS_debug.log('header is = '+head.header_name__c +' '+head.Value__c);
            req.setHeader(String.valueOf(head.header_name__c), String.valueOf(head.Value__c));       
        }
        
        String oauthGrantType = SYS_DataCacheFactory.integrationSetting.AuthenticationType__c;
        if(oauthGrantType.toLowerCase() == 'oauth'){
            String configId = SYS_DataCacheFactory.integrationSetting.OAuth_Config_Record_Id__c;
            List<SYS_OAuthConfig__c> configs = [SELECT 
                                                    Id, 
                                                    Access_Token__c,
                                                    Token_type__c 
                                                FROM SYS_OAuthConfig__c 
                                           	    WHERE Id =:configId];

            if(configs.size()>0){
                req.setHeader('Authorization',configs[0].Token_type__c+' '+configs[0].Access_Token__c);                                       
            }
            SYS_debug.log('MS Header:'+req.getHeader('Authorization'));
        }
    }

    /* ------------------------------------------------------------------------ */

    global virtual HttpRequest buildOutboundHttpRequest(SYS_IntegrationLog__c log){
        HttpRequest req = new HttpRequest();

        if(SYS_DataCacheFactory.OBJ_TYPE!=NULL){
            String objApiName = SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).ObjectApiName__c;
            objApiName = objApiName != null ? objApiName.replace(SYS_DataCacheFactory.integrationSetting?.EscapeCharacter__c !=null ? SYS_DataCacheFactory.integrationSetting?.EscapeCharacter__c :'', SYS_DataCacheFactory.namespacePrefix!=null ? SYS_DataCacheFactory.namespacePrefix :'') : objApiName;

            String externalIdField = SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).ExternalFieldApi__c;
            externalIdField = externalIdField != null ? externalIdField.replace(SYS_DataCacheFactory.integrationSetting?.EscapeCharacter__c !=null ? SYS_DataCacheFactory.integrationSetting?.EscapeCharacter__c :'' , SYS_DataCacheFactory.namespacePrefix!=null ? SYS_DataCacheFactory.namespacePrefix :'') : externalIdField;


            String query = 'SELECT ' + externalIdField + ' FROM ' +  objApiName;
            String whereClause = ' WHERE Id = \'' + String.escapeSingleQuotes(log.WhatId__c) + '\' ALL ROWS';
            List<sObject> recList = Database.query(String.escapeSingleQuotes(query)+whereClause);
                
    
            if(!recList.isEmpty()){
    
                String externalId = String.valueOf(recList[0].get(externalIdField));
                
                req.setMethod(getHttpRequestMethod(log,externalId));
                req.setEndpoint(getHttpRequestEndpoint(req,log,externalId));
            }
        }
        else{

            req.setMethod(getHttpRequestMethod(log,null));
            req.setEndpoint(getHttpRequestEndpoint(req,log,null));
            
        }


        setHttpRequestHeaders(req,log);

 
        return req;
    }
    

    /* ------------------------------------------------------------------------ */

    global virtual HttpResponse doOutbound(SYS_IntegrationLog__c log){

       
        Http http = new Http();
        HttpRequest req = buildOutboundHttpRequest(log);

        if(req.getMethod()!='GET'){
            String body = SYS_Helper.getDataFrom(log); 
            body = preprocessJSONForOutbound(log,body,req);
            req.setBody(body);
            SYS_debug.log('body:'+body);
        }
 
        HttpResponse response = http.send(req);
        SYS_debug.log('Outbound Request:'+req);
        SYS_debug.log('Outbound Response:'+response.getBody());
        return response;
        
    }

    /* ------------------------------------------------------------------------ */

    global virtual SYS_IntegrationLog__c generatelogForInboundResult(Boolean result,SYS_IntegrationLog__c log){

        SYS_IntegrationLog__c logResp = new SYS_IntegrationLog__c();
        
        /*--*/SYS_debug.log('Beginning. Log status for:'+logResp.Request_Digest__c+'='+logResp.Status__c);


        if(!result){
            
            //-- Error message is set in handleDmlErrors
            //String errorMessage = 'Error while processing inbound';

            logResp.Status__c = 'FAIL';
            logResp.retry__c = true;
            //## SYS_Helper.flagLogForRetry(logResp.Id);
            

            /*
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Message__c.isCreateable()) {
                logResp.Message__c = errorMessage;
            }
            */
            
            logResp.Id = log.Id;
            
        }
        else{
            
            //ID jobID = System.enqueueJob(new SYS_ParentChildRecordsQueueable(log,SYS_DataCacheFactory.INT_TYPE));
            logResp = log;
            if(logResp.ObjectSettingId__c == NULL)
                logResp.ObjectSettingId__c = SYS_DataCacheFactory.OBJ_TYPE;
            System.debug(' ObjectSettingId__c generatelogForInboundResult'+logResp.ObjectSettingId__c);

            //logResp.Status__c = 'DONE';

            /**
             * Check if there are other siblings. Call parenting queueable only if all are done
             */

            /*--*/SYS_debug.log('MS totalChildRecords B4:'+SYS_QueueableForInboundChild.totalChildRecords);
            SYS_QueueableForInboundChild.totalChildRecords--;
            /*--*/SYS_debug.log('MS totalChildRecords After:'+SYS_QueueableForInboundChild.totalChildRecords);
           
            /*--*/SYS_debug.log('MS Condition chck for Parenting:'+log.Requires_process_on_complete__c);
            /*--*/SYS_debug.log('MS Condition chck for Parenting:'+(SYS_QueueableForInboundChild.totalChildRecords==0));
            /*--*/SYS_debug.log('MS Condition chck for Parenting:'+log.Status__c);


            /**
             * If the log is for either a parent or the LAST sibling of n children or a child
             * being processed as part of retry. Therefore in  else we again need to make checks for parent vs. child
             * and set the Status accordingly.
             */
            if(log.Requires_process_on_complete__c 
                && (SYS_QueueableForInboundChild.totalChildRecords==0 || log.Status__c==SYS_Constants.READY_FOR_PROCESSING))
            {
                /*--*/SYS_debug.log('MS Queueable Jobs in queue:'+Limits.getQueueableJobs());
                /*--*/SYS_debug.log('MS Queueable Allowed:'+Limits.getLimitQueueableJobs());

                logResp.Status__c = 'PENDING_PARENT';
                logResp.retry__c = true;
                //## SYS_Helper.flagLogForRetry(logResp.Id);

                if(!(Limits.getQueueableJobs() + 1 > Limits.getLimitQueueableJobs())){
                    System.enqueueJob(new SYS_ParentingQueueable(String.valueOf(log.Parent__c),SYS_DataCacheFactory.INT_TYPE,log));

                }
            }
            else{

                //One of the sibling of n children. Save as pending parent
                if(log.Requires_process_on_complete__c){
                    logResp.Status__c = 'PENDING_PARENT';
                }
                else{
                    logResp.Message__c = 'Record created/updated successfully';
                    logResp.Status__c = 'DONE';
                    
                }

            }
            
        }

        return logResp;
    }

    public List<FieldSetting__mdt> getPrimaryLookupFieldSetting(String resource){
        List<FieldSetting__mdt> fsm = new List<FieldSetting__mdt>();
        SYS_debug.log('SP Obj Type '+SYS_DataCacheFactory.OBJ_TYPE);
        fsm = [SELECT FieldApiName__c,
                        ObjectApiName__c , ObjectSetting__r.developername
                        FROM FieldSetting__mdt 
                        WHERE RestResource__c = :resource 
                        AND Is_Lookup__c=true 
                        AND Lookup_External_Key__c=NULL 
                        AND Lookup_Object_API_Name__c=NULL
                        AND Is_Active__c=true];

        for(FieldSetting__mdt item : fsm) {
            item.FieldApiName__c = item.FieldApiName__c != null ? item.FieldApiName__c.replace(SYS_DataCacheFactory.ESCAPE_CHAR, SYS_DataCache.namespacePrefix) :item.FieldApiName__c ;
            item.ObjectApiName__c = item.ObjectApiName__c != null ? item.ObjectApiName__c.replace(SYS_DataCacheFactory.ESCAPE_CHAR, SYS_DataCache.namespacePrefix) :item.ObjectApiName__c ;
        
        }
        return fsm;
    }

    global virtual void fixParent(String parentLogId,SYS_IntegrationLog__c childLog){
        //SPNEW added OBJ_TYPE
        SYS_DataCacheFactory.OBJ_TYPE = childLog.ObjectSettingId__c;

        //SYS_DataCache.log = childLog;
        List<FieldSetting__mdt> fsm = getPrimaryLookupFieldSetting(childLog.Resource__c);
        List<FieldSetting__mdt> fsmFiltered = new List<FieldSetting__mdt>();
        if(fsm.size() == 0) {
            throw new SYS_ApplicationServiceException('Unable to find primary field setting for resource :'+childLog.Resource__c);
        } else {
            for(FieldSetting__mdt item : fsm) {
                if(SYS_DataCacheFactory.OBJ_TYPE != NULL && item?.ObjectSetting__r?.developername == SYS_DataCacheFactory.OBJ_TYPE) {
                    fsmFiltered.add(item);
                }
            }
        }
        /*--*/SYS_debug.log('MS Fixing Relationship:'+fsmFiltered);

        List<sObject> childRecords = new List<sObject>();
        List<String> dupeCheckList = new List<String>();
        List<SYS_IntegrationLog__c> childLogs = [SELECT Id,WhatId__c,Resource__c,Parent__r.WhatId__c FROM SYS_IntegrationLog__c WHERE Parent__c = :parentLogId AND Status__c='PENDING_PARENT' AND Resource__c =: childLog.Resource__c];

        for(SYS_IntegrationLog__c cLog:childLogs)
        {
            /*--*/SYS_debug.log('MS cLog.Resource__c: '+cLog.Resource__c);
            /*--*/SYS_debug.log('MS dupeCheckList:'+dupeCheckList);

            if(!dupeCheckList.contains(cLog.WhatId__c) && cLog.WhatId__c!=null){
                childRecords.clear();
                sObject sObj = Schema.getGlobalDescribe().get(fsmFiltered[0].ObjectApiName__c).newSObject();
                /*--*/SYS_debug.log('MS cLog:'+cLog);
                /*--*/SYS_debug.log('MS cLog.Parent__r.WhatId__c:'+cLog.Parent__r.WhatId__c);
                /*--*/SYS_debug.log('MS fsmFiltered[0].ObjectApiName__c:'+fsmFiltered[0].ObjectApiName__c);
                /*--*/SYS_debug.log('MS sObject Id:'+cLog.WhatId__c);
                sObj.put('Id',cLog.WhatId__c);
                sObj.put(fsmFiltered[0].FieldApiName__c,cLog.Parent__r.WhatId__c);
                childRecords.add(sObj);
                dupeCheckList.add(String.valueOf(sObj.get('Id')));

                //TODO Add Limit check. This is to make sure each log is processed separately and thereby avoid overriding of log properties
                if(doDML(childRecords, 'UPDATE', '',cLog)){
                    cLog.Status__c ='DONE';
                    cLog.retry__c =false;
                    SYS_Helper.updateLog(cLog);
                }
            }
            if(!dupeCheckList.contains(cLog.WhatId__c) && cLog.WhatId__c!=null ) {
                dupeCheckList.add(cLog.WhatId__c);
            }
        }
        /*--*/SYS_debug.log('SP dupeCheckList:'+dupeCheckList);


        /* ------------------------------------ ALL OR NONE HANDLING STARTS -------------------------------------- */

        /**
         * Check if Object Setting is configured with ALL-OR-NONE checked
         * If yes, delete the existing child records. To identify the EXISTING child records
         * on the SAME object to which this child records belong we will take just the first record
         * generate child log - identify the resource - followed by field setting for lookup
         * and get the object api name
         */


        if(SYS_DataCacheFactory.objectSettingMap.get(childLog.ObjectSettingId__c).All_OR_None__c){

            String qry = 
            'SELECT Id FROM '+
            fsmFiltered[0].ObjectApiName__c;
            
            String whereClauseVal = (childLogs[0].Parent__r.WhatId__c==null)?'':childLogs[0].Parent__r.WhatId__c;
            String whereClause = 
            ' WHERE '+String.escapeSingleQuotes(fsmFiltered[0].FieldApiName__c)+'=\''+
            String.escapeSingleQuotes(whereClauseVal)+'\''+
                            ' AND Id NOT IN (\''+ 
            String.join(dupeCheckList,'\',\'')+'\')';  
            
            /*--*/SYS_debug.log('MS All or none delete records query:'+qry);

            List<sObject> childRecordsToDelete = new List<sObject>();
            childRecordsToDelete = Database.query(String.escapeSingleQuotes(qry)+whereClause);

            /*--*/SYS_debug.log('MS All or none delete records:'+childRecordsToDelete);
            if(childRecordsToDelete.size() > 0)
                SYS_Helper.deleteWithFLSCheck(childRecordsToDelete);
        }

        /* ------------------------------------ ALL OR NONE HANDLING ENDS ---------------------------------------- */


    }

    /* ------------------------------------------------------------------------ */

    // global virtual SYS_IntegrationLog__c generatelogForOutboundResult(HttpResponse resp,SYS_IntegrationLog__c log){

    //     SYS_IntegrationLog__c logResp = SYS_Helper.getLogsToInsert(resp.getBody());

    //     String algo = SYS_DataCacheFactory.integrationSetting.Hashing_Algo__c;
    //     if(algo!=NULL && algo!='')
    //         logResp.Request_Digest__c = generateHash(resp.getBody(),algo);

    //     logResp.Force_Sync__c = log.Force_Sync__c;

    //     if(resp.getStatusCode() != 201 && resp.getStatusCode() != 200){

    //         SYS_debug.log('#### resp status: '+resp.getStatus());
    //         SYS_debug.log('#### resp code: '+resp.getStatusCode()); 
    //         SYS_debug.log('#### resp: '+resp.getBody());

    //         log.Status__c = 'FAIL';
    //         if(!log.Force_Sync__c)
    //             log.retry__c = true;

    //         logResp.Status__c = 'ERROR';
            
    //         logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
    //         logResp.WhatId__c = log.WhatId__c;
    //         logResp.Type__c = SYS_Constants.RESPONSE;
    //         logResp.How_To_Process__c = 'ignore_log';
    //         logResp.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
            
    //     }
    //     else{
    //         log.Status__c = 'DONE';

    //         if(log.SYS_Operation_Type__c == 'INSERT' || log.Force_Sync__c){
    //             logResp.Status__c = SYS_Constants.NEW_STATUS;
    //             logResp.SYS_Operation_Type__c = 'UPDATE';
    //             logResp.Flat_Key_for_Resource__c = SYS_DataCacheFactory.integrationSetting.Flat_Key_for_Resource_Response__c;

    //             if(SYS_DataCacheFactory.OBJ_TYPE!=NULL)
    //                 logResp.Resource__c = SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Resource_Name__c;
                
    //             logResp.How_To_Process__c = 'use_custom_apex_handler';
    //             logResp.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
            
    //         }
    //         else{

                
    //             if(SYS_DataCacheFactory.OBJ_TYPE != NULL && SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Always_Ignore_Response__c){
    //                     logResp.How_To_Process__c = 'ignore_log';
    //                     logResp.Status__c = 'DONE';
    //             }
    //             else{
    //                 logResp.SYS_Operation_Type__c = 'UPSERT';
    //                 logResp.How_To_Process__c = 'use_custom_apex_handler';
    //                 logResp.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
    //             }
    //             //logResp.Status__c = 'DONE';
    //             //logResp.How_To_Process__c = 'ignore_log';

    //         }
        
    //         logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
    //         logResp.WhatId__c = log.WhatId__c;
    //         logResp.Type__c = SYS_Constants.RESPONSE;
    //         logResp.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
    //         logResp.ObjectSettingId__c = log.ObjectSettingId__c;
            
    //     }

    //     //doDML(new List<SYS_IntegrationLog__c>{log}, 'UPSERT', '') ;
    //     SYS_Helper.upsertLog(log);
    //     logResp.SYS_RequestId__c = log.Id;

    //     return logResp;
    // }

    /* ------------------------------------------------------------------------ */

    global virtual String sanitizeJSONForOutbound(String jsonRecord){

        String finalJSON = jsonRecord.replace('\n',' ');
        return finalJSON;
    }

    /* ------------------------------------------------------------------------ */

    global virtual String sanitizeJSONForOutbound(String jsonRecord, String param){

        String finalJSON = jsonRecord.replace('\n',' ');
        return finalJSON;
    }

    /* ------------------------------------------------------------------------ */

    global virtual SYS_IntegrationLog__c reworkSysLog(SYS_IntegrationLog__c  newSysLog, String param) {
        newSysLog.Custom_Field_Value__c = param;
        return newSysLog;
    }

    /* ------------------------------------------------------------------------ */

    global virtual void processInboundRecord(SYS_IntegrationLog__c log, Map<SYS_IntegrationLog__c, sObject> mapLogrecVsObject, List<SYS_IntegrationLog__c> partialSysLogs, List<SYS_IntegrationLog__c> allChildLogs) {
        
        String jsonBody = '';
        // jsonBody =  SYS_Helper.getDataFrom(log);
        jsonBody =  SYS_Helper.getDataFromNew(log, allChildLogs); 
        jsonBody = preprocessJSONForInbound(log,jsonBody);

        if(SYS_DataCacheFactory.integrationSetting.Notifications_are_partial__c && 
            log.Is_Notification_Only__c
            ){
            String baseEndpoint = SYS_DataCache.integrationSetting.get(SYS_Datacache.INT_TYPE).BaseAPIEndPoint__c;
            String getURLPattern = baseEndpoint + SYS_DataCacheFactory.integrationSetting.GET_URL_Pattern__c;
            
            SYS_NotificationInterface it = 
            (SYS_NotificationInterface)Type.forName(SYS_DataCacheFactory.integrationSetting.Notification_Wrapper__c).newInstance();
            
            // List<SYS_IntegrationLog__c> insertSysLog = new List<SYS_IntegrationLog__c>();

            for(Map<String,String> rMap:it.getIterator(jsonBody)){
                String getURL = getURLPattern;
                SYS_IntegrationLog__c  newSysLog = new SYS_IntegrationLog__c();
                for(String key:rMap.keySet()){
                    getURL = getURL.replaceAll('\\{'+key+'\\}',rMap.get(key));
  
                }
                /*--*/SYS_debug.log('=============== '+ getURL);

                newSysLog.Status__c = SYS_Constants.NEW_STATUS;
                newSysLog.HTTP_Method__c = 'GET';
                newSysLog.Callout_URL__c = getURL;
                newSysLog.Type__c = SYS_Constants.OUTBOUND;
                newSysLog.WhatId__c = log.WhatId__c;
                newSysLog.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
                newSysLog.SYS_Operation_Type__c = 'UPSERT';
                newSysLog.How_to_process__c = 'use_custom_apex_handler';
                newSysLog.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
                newSysLog.Parent__c = log.Id;
                partialSysLogs.add(newSysLog);
            }

            
            // if(insertSysLog.size()>0 && SYS_DataCache.enableCheck.get(SYS_DataCache.INT_TYPE.toUpperCase())){
            //     SYS_Helper.insertLog(insertSysLog);
            // }

            // return true;

        }
        else{
            String resource = getResourceFromJSON(log,jsonBody);
            log.Resource__c = resource;
            SYS_debug.log('\n\n ------------------------------- \n\n Application Service resource:'+resource);

            List<sObject> sObjectsToDML = transformJsonToSObject(jsonBody, resource, log);

            SYS_debug.log('\n\n ------------------------------- \n\n Application Service sObjects to DML:'+sObjectsToDML);
            SYS_debug.log('\n\n ------------------------------- \n\n Application Service externalKeyByResourceMap:'+SYS_DataCache.externalKeyByResourceMap);

            String externalIdFieldAPIName = SYS_DataCacheFactory.externalKeyByResourceMap.get(resource);
            //String externalIdFieldAPIName = log.External_Id_Field_API_Name__c!=NULL?log.External_Id_Field_API_Name__c:'';
            
            for(sObject item: sObjectsToDML) {
                try {
                    item.put('Last_Processed_SYSLog__c', log.Id);
                } catch(Exception e) {
                    throw new SYS_ApplicationServiceException('Last Processed SYSLog field is not implemented : \n '+e.getMessage());
                }
                if( item.get('Id') == NULL && log.WhatId__c != NULL) {
                    item.put('Id', log.WhatId__c);
                }
            }
            if(sObjectsToDML.size() > 0)
                mapLogrecVsObject.put(log, sObjectsToDML[0]);
        }
        return ;
    }

    /* ------------------------------------------------------------------------ */

    global virtual List<SYS_IntegrationLog__c> generatelogForOutboundResultNew(HttpResponse resp,SYS_IntegrationLog__c log ){

        SYS_IntegrationLog__c logResp = new SYS_IntegrationLog__c();
        List<SYS_IntegrationLog__c> logAfterPartition = new List<SYS_IntegrationLog__c>();

        if(resp.getBody() != NULL && resp.getBody().length() > SYS_Constants.TEXT_AREA_MAX_SIZE*10) {
            logAfterPartition = SYS_Helper.getLogsAfterPartition(resp.getBody());
            if(logAfterPartition != NULL && logAfterPartition.size() > 0) {
                // SYS_Helper.upsertLog(logs[0]);
                // List<SYS_IntegrationLog__c> childs = SYS_Helper.getChildRecords(logs);
                
                // SYS_Helper.upsertLog(childs);
                logResp = logAfterPartition[0];
            }
        } else {
            logResp =  SYS_Helper.getLogsToInsert(resp.getBody());
        }

        String algo = SYS_DataCacheFactory.integrationSetting.Hashing_Algo__c;
        if(algo!=NULL && algo!='')
            logResp.Request_Digest__c = generateHash(resp.getBody(),algo);

        logResp.Force_Sync__c = log.Force_Sync__c;

        if(resp.getStatusCode() != 201 && resp.getStatusCode() != 200 && resp.getStatusCode() != 204){

            SYS_debug.log('#### resp status: '+resp.getStatus());
            SYS_debug.log('#### resp code: '+resp.getStatusCode()); 
            SYS_debug.log('#### resp: '+resp.getBody());

            log.Status__c = 'FAIL';
            if(!log.Force_Sync__c)
                log.retry__c = true;

            logResp.Status__c = 'ERROR';
            
            logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
            logResp.WhatId__c = log.WhatId__c;
            logResp.Type__c = SYS_Constants.RESPONSE;
            logResp.How_To_Process__c = 'ignore_log';
            logResp.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
            
        }
        else{
            log.Status__c = 'DONE';

            if(log.SYS_Operation_Type__c == 'INSERT' || log.Force_Sync__c){
                logResp.Status__c = SYS_Constants.NEW_STATUS;
                logResp.SYS_Operation_Type__c = 'UPDATE';
                // logResp.Flat_Key_for_Resource__c = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Flat_Key_for_Resource_Response__c;

                if(SYS_DataCacheFactory.OBJ_TYPE!=NULL)
                    logResp.Resource__c = SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Resource_Name__c;
                
                logResp.How_To_Process__c = 'use_custom_apex_handler';
                logResp.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
            
            }
            else{

                
                if(SYS_DataCacheFactory.OBJ_TYPE != NULL && SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Always_Ignore_Response__c){
                        logResp.How_To_Process__c = 'ignore_log';
                        logResp.Status__c = 'DONE';
                }
                else{
                    if(SYS_DataCacheFactory.OBJ_TYPE!=NULL)
                        logResp.Resource__c = SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Resource_Name__c;
                
                    logResp.SYS_Operation_Type__c = 'UPSERT';
                    logResp.How_To_Process__c = 'use_custom_apex_handler';
                    logResp.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
                }
                //logResp.Status__c = 'DONE';
                //logResp.How_To_Process__c = 'ignore_log';

            }
            logResp.Flat_Key_for_Resource__c = SYS_DataCacheFactory.integrationSetting.Flat_Key_for_Resource_Response__c;
            logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
            logResp.WhatId__c = log.WhatId__c;
            logResp.Type__c = SYS_Constants.RESPONSE;
            logResp.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
            logResp.ObjectSettingId__c = log.ObjectSettingId__c;
            
        }

        //doDML(new List<SYS_IntegrationLog__c>{log}, 'UPSERT', '') ;
        // ##SYS_Helper.upsertLog(new List<SYS_IntegrationLog__c>{log});
        
        logResp.SYS_RequestId__c = log.Id;
        if(log.Id == NULL && log.UUID__c == NULL) {
            log.UUID__c = SYS_Helper.getUUID();
            logResp.Parent_UUID__c = log.UUID__c;
            logResp.UUID__c = SYS_Helper.getUUID();
        }
        List<SYS_IntegrationLog__c> returnVal = new List<SYS_IntegrationLog__c>();
        returnVal.add(log);
        returnVal.add(logResp);
        if(logAfterPartition != NULL && logAfterPartition.size() > 0) {
            logResp.Status__c = SYS_Constants.PENDING_PARTITIONED_LOOKUP;
            for(integer i = 1 ; i < logAfterPartition.size() ; i++) {
                returnVal.add(logAfterPartition[i]);
            }
        }
        return returnVal;
    }

    /* ------------------------------------------------------------------------ */
    
    /************************** C O N C R E T E    M E T H O D S    S T A R T **************************/

     /* ------------------------------------------------------------------------ */

     //OVERLOADED
     public Boolean doDML(List<sObject> records,String dmlType,String additionalSetting,SYS_IntegrationLog__c log) {

        
        switch on dmlType.toUpperCase() {
            when 'INSERT'{
                return doInsert(records,log);
            }
            when 'UPSERT'{
                return doUpsert(records, additionalSetting,log);
            }
            when 'UPDATE'{
                return doUpdate(getMissingIdForUpdate(records,log),log);
            }
            when 'DELETE'{
                return doDelete(records,log);
            }
            when else {
                SYS_debug.log('Invalid DML Operation specified in log record:'+dmlType);
                return false;
            }
            
        }

    }

    public void insertWebhookLog(SYS_IntegrationLog__c log){
        try{
            Database.SaveResult[] result = SYS_Helper.insertLog(new List<SYS_IntegrationLog__c>{log});// Database.insert(log,false);
            //TODO check if result is success/error and take action
            if(result?.size() > 0){    
                if(!result[0].isSuccess()){
                    handleDMLErrors(result[0].getErrors(),log);
                }
                else{
                    setSuccessHttpResponse();
                }
            }
        } catch ( Exception e ) {
            setErrorHttpResponse(e.getStackTraceString());
        }
    } 

    public void upsertWebhookLog(List<SYS_IntegrationLog__c> logs){
        try{
            Database.upsertResult[] results = SYS_Helper.upsertLog(logs);// Database.insert(log,false);
            //TODO check if result is success/error and take action
            // if(result?.size() > 0){    
            //     if(!result[0].isSuccess()){
            //         handleDMLErrors(result[0].getErrors(),log);
            //     }
            //     else{
            //         setSuccessHttpResponse();
            //     }
            // }
            Database.Error[] errors;
            for(Database.upsertResult result : results) {
                if(!result.isSuccess()) {
                    errors.addAll(result.getErrors());
                }
            }
            if(errors != NULL) { 
                handleDMLErrors(errors,logs[0]);
            } else {
                setSuccessHttpResponse();
            }
        } catch ( Exception e ) {
            setErrorHttpResponse(e.getStackTraceString());
        }
    }
    /** NEW BULKIFIED METHODS*/

    

    public void doDMLNew(Map<SYS_IntegrationLog__c, sObject> records,String dmlType,String additionalSetting, Map<String, SYS_IntegrationLog__c> sysLogMap ) {
        
        
        switch on dmlType.toUpperCase() {
            when 'INSERT'{
                doInsertNew(records, sysLogMap);
            }
            when 'UPSERT'{
                doUpsertNew(records, additionalSetting, sysLogMap);
            }
            when 'UPDATE'{
                doUpdateNew(records, sysLogMap);
            }
            when 'DELETE'{
                doDeleteNew(records, sysLogMap);
            }
            when else {
                SYS_debug.log('Invalid DML Operation specified in log record:'+dmlType);
                return ;
            }
            
        }

    }

    public void doInsertNew(Map<SYS_IntegrationLog__c, sObject> records, Map<String, SYS_IntegrationLog__c> sysLogMap){
        Database.SaveResult[] results;
        Boolean success = true;
        results = Database.insert(records?.values(), false);

        for(integer i=0; i < records?.values()?.size() ; i++) {
            String syslogId = (String)records?.values()[i]?.get('Last_Processed_SYSLog__c');
            generatelogForInboundResult(results[i].isSuccess(), sysLogMap.get(syslogId));

            if( !results[i].isSuccess() ) { // Update the error in sysLog
                SYS_Helper.handleFailureDml(sysLogMap.get(syslogId), results[i]?.getErrors());
            } else {
                
                SYS_Helper.handleSuccessDml(sysLogMap.get(syslogId), results[i]?.getId());
            }
        }
        return ;
    }

    public void doUpdateNew(Map<SYS_IntegrationLog__c, sObject> records, Map<String, SYS_IntegrationLog__c> sysLogMap){
        Database.SaveResult[] results; 
        Boolean success = true;
        
        Map<Id, sObject> recordMap = new Map<Id, sObject>();
        recordMap.putAll(records?.values());

        results = Database.update(recordMap?.values(), false);

        for(integer i=0; i < recordMap?.values()?.size() ; i++) {
            String syslogId = (String)recordMap?.values()[i]?.get('Last_Processed_SYSLog__c');
            generatelogForInboundResult(results[i].isSuccess(), sysLogMap.get(syslogId));
            
            if( !results[i].isSuccess() ) { // Update the error in sysLog
                SYS_Helper.handleFailureDml(sysLogMap.get(syslogId), results[i]?.getErrors());
            } else {
                SYS_Helper.handleSuccessDml(sysLogMap.get(syslogId), results[i]?.getId());
            }
        }
        return ;
    }

    public void doDeleteNew(Map<SYS_IntegrationLog__c, sObject> records, Map<String, SYS_IntegrationLog__c> sysLogMap){
        Database.DeleteResult[] results;
        Boolean success = true;
        results = SYS_Helper.deleteWithFLSCheck(records?.values());


        for(integer i=0; i < records?.values()?.size() ; i++) {
            String syslogId = (String)records?.values()[i]?.get('Last_Processed_SYSLog__c');
            generatelogForInboundResult(results[i].isSuccess(), sysLogMap.get(syslogId));
            
            if( !results[i].isSuccess() ) { // Update the error in sysLog
                SYS_Helper.handleFailureDml(sysLogMap.get(syslogId), results[i]?.getErrors());
            } else {
                
                SYS_Helper.handleSuccessDml(sysLogMap.get(syslogId), results[i]?.getId());
            }
        }
        return ;
    }

    public void doUpsertNew(Map<SYS_IntegrationLog__c, sObject> records,String additionalSetting,Map<String, SYS_IntegrationLog__c> sysLogMap){
        Database.UpsertResult[] results;
        Boolean success = true;
        if(String.isBlank(additionalSetting))
            results = Database.upsert(records?.values(), false);
        else{
            /*--*/SYS_debug.log('--MS externalIdField for:'+records?.values()[0]+' : '+additionalSetting);
            //Schema.SObjectField externalIdField = Schema.getGlobalDescribe().get(SYS_DataCache.sObjectApiName).getDescribe().fields.getMap().get(additionalSetting); 
            
            Schema.SObjectField externalIdField = records?.values()[0].getSObjectType().getDescribe().fields.getMap().get(additionalSetting); 
            /*--*/SYS_debug.log('--MS externalIdField in doUpsert:'+externalIdField);
            
            results = Database.upsert(records?.values(), externalIdField, false);
        }

        for(integer i=0; i < records?.values()?.size() ; i++) {
            String syslogId = (String)records?.values()[i]?.get('Last_Processed_SYSLog__c');
            generatelogForInboundResult(results[i].isSuccess(), sysLogMap.get(syslogId));
            
            System.debug('record ifsuccess '+records?.values()[i]?.Id);
            if(!results[i].isSuccess()) { // Update the error in sysLog
                SYS_Helper.handleFailureDml(sysLogMap.get(syslogId), results[i]?.getErrors());
            } else {
                
                SYS_Helper.handleSuccessDml(sysLogMap.get(syslogId), results[i]?.getId());
            }
        }
        
        // /*--*/SYS_debug.log('--MS Log check # '+log.Id+' has WhatId: '+results[0].getId());

        // /*--*/SYS_debug.log('--MS Log re-check # '+log.Id+' has WhatId: '+log.WhatId__c);

        return ;
    }

    global virtual List<sObject> fetchSobject(String query, List<Id> parentIds) { 
        List<sObject> records = Database.query(query);
        return records;
    }

    

    /************************** C O N C R E T E    M E T H O D S    E N D *****************************/

    
}