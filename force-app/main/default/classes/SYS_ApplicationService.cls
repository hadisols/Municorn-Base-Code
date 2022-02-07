global virtual class SYS_ApplicationService {
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
        String tokenFromIntegrationSetting = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).webhookToken__c;

        return (tokenFromUrl == tokenFromIntegrationSetting);

    }

    /**
     * This hook is called from insertWebhookLog methods and webservice.
     * Default is to set the response body with incoming request
     * Zero Arguments. Relies on Integration Setting in DataCache and RestContext
     * Override if custom handler is required after successful log creation
     */
    global virtual void setSuccessHttpResponse(){
        if(RestContext.request!=NULL)
        RestContext.response.responseBody = Blob.valueOf(RestContext.request.requestBody.toString());
    }

    /**
     * This hook is called from insertWebhookLog methods.
     * Default is just a message for Debug logs
     * Zero Arguments. Relies on Integration Setting in DataCache and RestContext
     * Override if custom handler is required when log creation causes error
     */
    global virtual void setErrorHttpResponse(String stackTrace){
        SYS_debug.log('Webhook Error:'+stackTrace);
    }


    /**
     * These hooks are called from Webservice.
     * Default is to generate a log record using another hook (generateLogForWebhookReq) and insert using another concrete method
     * Zero Arguments. Relies on Integration Setting in DataCache and RestContext
     * Override if custom handler is required for any or all of Http Verbs
     */
    global virtual void doPost(){
        
        SYS_IntegrationLog__c log = generateLogForWebhookReq('POST');
        insertWebhookLog(log);
        
    }
    global virtual void doPut(){

        SYS_IntegrationLog__c log = generateLogForWebhookReq('PUT');
        insertWebhookLog(log);
        
    }
    global virtual void doGet(){
        
        SYS_IntegrationLog__c log = generateLogForWebhookReq('GET');
        insertWebhookLog(log);
        
    }
    global virtual void doPatch(){

        SYS_IntegrationLog__c log = generateLogForWebhookReq('PATCH');
        insertWebhookLog(log);
        
    }
    global virtual void doDelete(){

        SYS_IntegrationLog__c log = generateLogForWebhookReq('DELETE');
        insertWebhookLog(log);
        
    }


    /* ------------------------------------------------------------------------ */

    /**
     * This hook is called from all DML hooks following this method
     * Default is just a message for Debug logs
     * Argument: Database.Error[]. Relies on Integration Setting in DataCache
     * Override if custom handler is required when there are errors in DMLs
     */
    global virtual void handleDMLErrors(Database.Error[] errors){
        String errMsg='The following error has occurred while performing DML: ';
        for(Database.Error err : errors) {
            errMsg+= err.getStatusCode() + ': ' + err.getMessage() + '. Fields affected are: ' + err.getFields()+'\n';
            SYS_debug.log('The following error has occurred.');                    
            SYS_debug.log(err.getStatusCode() + ': ' + err.getMessage());
            SYS_debug.log('Fields affected are: ' + err.getFields());
        }
        SYS_ApplicationService.logException(SYS_DataCache.log, errMsg);
    }

    /**
     * These hooks are called from doDML() concrete method which in turn is called from doInbound
     * Default is to call the DML based on operation type
     * Argument: List<sObject>. Additionally ExternalId field for upsert.
     * Relies on Integration Setting in DataCache
     * Override if custom handler is required for any DML
     */
    global virtual Boolean doInsert(List<sObject> records){
        Database.SaveResult[] results;
        Boolean success = true;
        results = Database.insert(records, false);
        if(!results[0].isSuccess()){
            success = false;
            handleDMLErrors(results[0].getErrors());
        }
        else{
            SYS_DataCache.log.WhatId__c = results[0].getId();
        }

        return success;
    }

    global virtual Boolean doUpdate(List<sObject> records){
        Database.SaveResult[] results;
        Boolean success = true;
        results = Database.update(records, false);
        if(!results[0].isSuccess()){
            success = false;
            handleDMLErrors(results[0].getErrors());
        }
        else{
            SYS_DataCache.log.WhatId__c = results[0].getId();
        }

        return success;
    }

    global virtual Boolean doDelete(List<sObject> records){
        Database.DeleteResult[] results;
        Boolean success = true;
        results = Database.delete(records, false);
        if(!results[0].isSuccess()){
            success = false;
            handleDMLErrors(results[0].getErrors());
        }
        else{
            SYS_DataCache.log.WhatId__c = results[0].getId();
        }

        return success;
    }

    global virtual Boolean doUpsert(List<sObject> records,String additionalSetting){
        Database.UpsertResult[] results;
        Boolean success = true;
        if(additionalSetting=='')
            results = Database.upsert(records, false);
        else{
            System.debug('--MS SYS_DataCache.sObjectApiName in Applicaiton Service:'+SYS_DataCache.sObjectApiName);
            Schema.SObjectField externalIdField = Schema.getGlobalDescribe().get(SYS_DataCache.sObjectApiName).getDescribe().fields.getMap().get(additionalSetting); 
            results = Database.upsert(records, externalIdField, false);
        }
        
        if(!results[0].isSuccess()){
            success = false;
            handleDMLErrors(results[0].getErrors());
        }
        else{
            SYS_DataCache.log.WhatId__c = results[0].getId();
        }

        return success;
    }


    /* ------------------------------------------------------------------------ */ 

    
    /**
     * This hook is called from SYS_Transformer to set values for sObject record
     * Default is map based on field type
     * Relies on Integration Setting in DataCache
     * Override if custom field mapping is required
     */
    global virtual sObject processFieldMapping(FieldSetting__mdt mapping,sObject sObj,Object value, String sObjectApiName){

        SObjectType r = ((SObject)(Type.forName('Schema.'+sObjectApiName).newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();
                
        String fieldType = d.fields
                            .getMap()
                            .get(mapping.FieldApiName__c)
                            .getDescribe()
                            .getType()+'';

        
        //TODO add other field types
        if(fieldType=='DATE'){
            try{
                sObj.put(mapping.FieldApiName__c, date.valueOf((String)value));
            }catch(Exception e){
                
            }
        }else if (fieldType == 'STRING') {
            sObj.put(mapping.FieldApiName__c, String.valueof(value));
        }else if (fieldType == 'BOOLEAN') {
            sObj.put(mapping.FieldApiName__c, String.valueof(value));
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

        Map<String,String> methodToOperationMap = new Map<String,String>{'POST'=>'INSERT','PUT'=>'UPSERT','DELETE'=>'DELETE','PATCH'=>'UPDATE'};
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
    global virtual SYS_IntegrationLog__c generateLogForWebhookReq(String method) {
        String requestBody = RestContext.request.requestBody.toString();
        SYS_IntegrationLog__c log = SYS_ApplicationService.getLogsToInsert(requestBody);

        String algo = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Hashing_Algo__c;
        if(algo!=NULL && algo!='')
        log.Request_Digest__c = generateHash(requestBody,algo);

        log.Type__c = 'INBOUND';
        log.SYS_Operation_Type__c = getOperationTypeFor(method);
        log.Flat_Key_for_Resource__c = 'attributes.type';
        log.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
        log.Status__c = 'NEW';
        log.External_Id_Field_API_Name__c = 'SYS_Key__c';
        log.How_to_process__c = 'use_custom_apex_handler';
        log.Custom_Apex_Handler__c = 'SYS_ApplicationService';

        return log;
    }

    /**
     * This hook is called from SYS_QueueableForInboundChild to generate logs for inbound child records
     * Arguement: record json and Integration setting
     * Override if custom log generation is required
     */
    global virtual SYS_IntegrationLog__c generateLogForChildRecords(String parentLogId,String resource,String recordsJson,String integrationSetting) {
        SYS_IntegrationLog__c log = SYS_ApplicationService.getLogsToInsert(recordsJson);

        String algo = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Hashing_Algo__c;
        if(algo!=NULL && algo!='')
            log.Request_Digest__c = generateHash(recordsJson,algo);

        SYS_debug.log('MS SYS_DataCache.log in generate child log:'+SYS_DataCache.log.Id);
        log.Parent__c = parentLogId;
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
        log.On_Complete_Handler__c = 'SYS_ApplicationService';
        /** */

        log.External_Id_Field_API_Name__c = 'SYS_Child_Key__c';
        log.How_to_process__c = 'use_custom_apex_handler';
        log.Custom_Apex_Handler__c = 'SYS_ApplicationService';

        return log;
    }
    

    /* ------------------------------------------------------------------------ */ 

    // For Outbound. Called from doInbound() in ApplicationService
    global virtual List<sObject> transformJsonToSObject(String jsonBody,String resource) {
        return SYS_Transformer.getSObjectsToUpsert(new List<String>{jsonBody},resource);
    }

    // For Outbound. Called from Invocable Handler
    global virtual Map<Id,String> transformSObjectToJson(List<sObject> newSObjectList) {
        return SYS_Transformer.getRequestJson(newSObjectList);
    }

    /* ------------------------------------------------------------------------ */ 

    global virtual String preprocessJSONForInbound(SYS_IntegrationLog__c log,String jsonBody) {

        return jsonBody;
    }

    global virtual String preprocessJSONForOutbound(SYS_IntegrationLog__c log,String jsonBody) {

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
        if(log.Flat_Key_for_Resource__c == NULL || log.Flat_Key_for_Resource__c == ''){
            //Root element identifies Resource
            Object responseType = JSON.deserializeUntyped(jsonBody);
            if(responseType instanceof Map<String,Object>){
                resource = new List<String>(((Map<String, Object>)responseType).keySet())[0];
            }
        }
        else{
            //Key mentioned in Flat_Key_for_Resource__c identifies Resource
            Map<String, Object> flatKeyMap = getFlatKeys(jsonBody);
            System.debug('-- MS flatKeyMap in getResourceFromJSON:'+flatKeyMap);
            resource = (String)flatKeyMap.get(log.Flat_Key_for_Resource__c);
        }

        return resource;
    }

    /* ------------------------------------------------------------------------ */ 

    global virtual Boolean doInbound(SYS_IntegrationLog__c log) {
        
        String jsonBody = '';
        
        jsonBody =  log.data0__c != null ? log.data0__c : '' +
                    log.data1__c != null ? log.data1__c : '' +
                    log.data2__c != null ? log.data2__c : '' +
                    log.data3__c != null ? log.data3__c : '' +
                    log.data4__c != null ? log.data4__c : '' +
                    log.data5__c != null ? log.data5__c : '' +
                    log.data6__c != null ? log.data6__c : '' +
                    log.data7__c != null ? log.data7__c : '' +
                    log.data8__c != null ? log.data8__c : '' +
                    log.data9__c != null ? log.data9__c : '' ;

        jsonBody = preprocessJSONForInbound(log,jsonBody);
        List<sObject> sObjectsToDML = transformJsonToSObject(jsonBody, getResourceFromJSON(log,jsonBody));

        SYS_debug.log('\n\n ------------------------------- \n\n Application Service sObjects to DML:'+sObjectsToDML);

        String externalIdFieldAPIName = log.External_Id_Field_API_Name__c!=NULL?log.External_Id_Field_API_Name__c:'';
        //Schema.SObjectField externalIdField = Schema.getGlobalDescribe().get(SYS_DataCache.sObjectApiName).getDescribe().fields.getMap().get(externalIdFieldAPIName);

        //TODO DML Based on log operation type
        //Database.UpsertResult[] results = Database.upsert(sObjectsToDML,externalIdField, false);
        
               
        return doDML(sObjectsToDML,log.SYS_Operation_Type__c,externalIdFieldAPIName);
    }
    /* ------------------------------------------------------------------------ */

    global virtual HttpRequest buildOutboundHttpRequest(SYS_IntegrationLog__c log){
        HttpRequest req = new HttpRequest();
        IntegrationSetting__mdt integrationSetting = SYS_DataCache.integrationSetting.get(SYS_Datacache.INT_TYPE);
        String baseEndpoint = integrationSetting.BaseAPIEndPoint__c;

        List<HttpHeaders__mdt> httpHeader = SYS_DataCache.headerSetting;
        req.setMethod(integrationSetting.UpdateMethod__c);
        for(HttpHeaders__mdt head:httpHeader){
            SYS_debug.log('header is = '+head.MasterLabel + ''+head.Value__c);
            req.setHeader(String.valueOf(head.MasterLabel), String.valueOf(head.Value__c));       
        }
        
        String oauthGrantType = SYS_DataCache.integrationSetting.get(SYS_Datacache.INT_TYPE).AuthenticationType__c;
        if(oauthGrantType.toLowerCase() == 'oauth'){
            String configId = SYS_DataCache.integrationSetting.get(SYS_Datacache.INT_TYPE).OAuth_Config_Record_Id__c;
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

        String resourceUrl = integrationSetting.BaseAPIEndPoint__c+SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ResourcePath__c;
        req.setEndpoint(resourceUrl);
        return req;
    }
    

    /* ------------------------------------------------------------------------ */

    global virtual HttpResponse doOutbound(SYS_IntegrationLog__c log){

       
        Http http = new Http();
        HttpRequest req = buildOutboundHttpRequest(log);

        String body = log.data0__c != null ? log.data0__c : '' +
                            log.data1__c != null ? log.data1__c : '' +
                            log.data2__c != null ? log.data2__c : '' +
                            log.data3__c != null ? log.data3__c : '' +
                            log.data4__c != null ? log.data4__c : '' +
                            log.data5__c != null ? log.data5__c : '' +
                            log.data6__c != null ? log.data6__c : '' +
                            log.data7__c != null ? log.data7__c : '' + 
                            log.data8__c != null ? log.data8__c : '' +
                            log.data9__c != null ? log.data9__c : '' ; 
        
        

        body = preprocessJSONForOutbound(log,body);
        req.setBody(body);
        SYS_debug.log('body:'+body);
         
        HttpResponse response = http.send(req);
        SYS_debug.log('Outbound Request:'+req);
        SYS_debug.log('Outbound Response:'+response.getBody());
        return response;
        
    }

    /* ------------------------------------------------------------------------ */

    global virtual SYS_IntegrationLog__c generatelogForInboundResult(Boolean result,SYS_IntegrationLog__c log){

        SYS_IntegrationLog__c logResp = new SYS_IntegrationLog__c();

        if(!result){
            
            String errorMessage = 'Error while processing inbound';
            /*
            String errorMessage = 'The following error has occurred.';
            for(Database.Error err : result.getErrors()) {
                errorMessage += err.getStatusCode() + ': ' + err.getMessage();
                SYS_debug.log('Fields affected are: ' + err.getFields());
            }
            errorMessage += 'Fields affected are: ' + err.getFields();
            */

            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Status__c.isCreateable()) {
                logResp.Status__c = 'FAIL';
            }

            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Message__c.isCreateable()) {
                logResp.Message__c = errorMessage;
            }
            
            logResp.Id = log.Id;
            
        }
        else{
            
            /**
             * TODO For Guest user the fields are not creatable. 
             * This won't cause any error becoz the rest service class is without sharing
             */

            //if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Status__c.isCreateable()) {
                
            //}

            //if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Message__c.isCreateable()) {
            //}

            
            //ID jobID = System.enqueueJob(new SYS_ParentChildRecordsQueueable(log,SYS_DataCache.INT_TYPE));
            logResp = SYS_DataCache.log;
            logResp.ObjectSettingId__c = SYS_DataCache.OBJ_TYPE;
            logResp.Status__c = 'DONE';
            logResp.Message__c = 'Record created/updated successfully';

            /**
             * Check if there are other siblings. Call parenting queueable only if all are done
             */

            System.debug('MS totalChildRecords B4:'+SYS_QueueableForInboundChild.totalChildRecords);
            SYS_QueueableForInboundChild.totalChildRecords--;
            System.debug('MS totalChildRecords After:'+SYS_QueueableForInboundChild.totalChildRecords);
            if(SYS_DataCache.log.Requires_process_on_complete__c && (SYS_QueueableForInboundChild.totalChildRecords==0))
            {
                System.enqueueJob(new SYS_ParentingQueueable(String.valueOf(SYS_DataCache.log.Parent__c),SYS_DataCache.INT_TYPE,SYS_DataCache.log));
            }
            
        }

        return logResp;
    }

    global virtual void fixParent(String parentLogId,SYS_IntegrationLog__c childLog){

        List<FieldSetting__mdt> fsm = new List<FieldSetting__mdt>();
        fsm = [SELECT ParentField__c,ObjectApiName__c FROM FieldSetting__mdt WHERE RestResource__c = :childLog.Resource__c AND Get_value_from_Log__c=true];
        System.debug('MS Fixing Relationship:'+fsm);
        List<sObject> childRecords = new List<sObject>();
        
        for(SYS_IntegrationLog__c cLog:[SELECT Id,WhatId__c,Parent__r.WhatId__c FROM SYS_IntegrationLog__c WHERE Parent__c = :parentLogId AND Status__c='DONE'])
        {
            sObject sObj = Schema.getGlobalDescribe().get(fsm[0].ObjectApiName__c).newSObject();
            System.debug('MS cLog:'+cLog);
            System.debug('MS cLog.Parent__r.WhatId__c:'+cLog.Parent__r.WhatId__c);
            sObj.put('Id',cLog.WhatId__c);
            sObj.put(fsm[0].ParentField__c,cLog.Parent__r.WhatId__c);
            childRecords.add(sObj);
        }
        System.debug('MS Child Records for Parenting:'+childRecords);
       
        doDML(childRecords, 'UPDATE', '');
        

    }

    /* ------------------------------------------------------------------------ */

    global virtual SYS_IntegrationLog__c generatelogForOutboundResult(HttpResponse resp,SYS_IntegrationLog__c log){

        SYS_IntegrationLog__c logResp = getLogsToInsert(resp.getBody());
        if(resp.getStatusCode() != 201 && resp.getStatusCode() != 200){
            SYS_debug.log('#### resp status: '+resp.getStatus());
            SYS_debug.log('#### resp code: '+resp.getStatusCode()); 
            SYS_debug.log('#### resp: '+resp.getBody());

            
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Status__c.isCreateable()) {
                logResp.Status__c = 'ERROR';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Http_Status__c.isCreateable()) {
                logresp.SYS_Http_Status__c = integer.valueOf(resp.getStatusCode());
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_RequestId__c.isCreateable()) {
                logResp.SYS_RequestId__c = log.Id;
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.WhatId__c.isCreateable()) {
                logResp.WhatId__c = log.WhatId__c;
            }
            
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Type__c.isCreateable()) {
                logResp.Type__c = 'INBOUND';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                logResp.SYS_Operation_Type__c = 'RESPONSE';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.How_To_Process__c.isCreateable()) {
                logResp.How_To_Process__c = 'ignore_log';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                logResp.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
            }
            
        }
        else{

            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Status__c.isCreateable()) {
                logResp.Status__c = 'DONE';
            }
            
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Http_Status__c.isCreateable()) {
                logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_RequestId__c.isCreateable()) {
                logResp.SYS_RequestId__c = log.Id;
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.WhatId__c.isCreateable()) {
                logResp.WhatId__c = log.WhatId__c;
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.Type__c.isCreateable()) {
                logResp.Type__c = 'INBOUND';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                logResp.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.How_To_Process__c.isCreateable()) {
                logResp.How_To_Process__c = 'ignore_log';
            }
            if (Schema.sObjectType.SYS_IntegrationLog__c.fields.SYS_Operation_Type__c.isCreateable()) {
                logResp.SYS_Operation_Type__c = 'RESPONSE';
            }
        }

        return logResp;
    }

    /* ------------------------------------------------------------------------ */

    global virtual String sanitizeJSONForOutbound(String jsonRecord){

        String finalJSON = jsonRecord.replace('\n',' ');
        return finalJSON;
    }

    /* ------------------------------------------------------------------------ */

    
    /************************** C O N C R E T E    M E T H O D S    S T A R T **************************/


    /* ------------------------------------------------------------------------ */

    public static SYS_IntegrationLog__c getLogsToInsert(String requestBody) {
        SYS_IntegrationLog__c integrationLog = new SYS_IntegrationLog__c();
        List<String> data = getJSONChunckedValues(requestBody);
        integer i = 0;
        for(String json:data){
            integrationLog.put('data'+i+'__c',json);
            i++;
        }
        return integrationLog;
    }


    /* ------------------------------------------------------------------------ */

    public static List<String> getJSONChunckedValues(String body){
        List<String> data = new List<String>{'','','','','','','','','',''};
        
        if (body.length() <= SYS_Constants.TEXT_AREA_MAX_SIZE){
			data[0] = body;
        } else {
            SYS_debug.log('json needs chunking');
            Integer di = 0;
            String jsonSubStrng;
            Integer endIndex = SYS_Constants.TEXT_AREA_MAX_SIZE;
            String outboundJSON = body;
            do {
                jsonSubStrng = outboundJSON.substring(0,endIndex);
                outboundJSON = outboundJSON.substring(endIndex);
                SYS_debug.log('substr= '+outboundJSON+' index='+endIndex+' '+jsonSubStrng);
                endIndex = (outboundJSON.length() < SYS_Constants.TEXT_AREA_MAX_SIZE) ? outboundJSON.length() : SYS_Constants.TEXT_AREA_MAX_SIZE;
                data[di] = jsonSubStrng;
                di++;
                if(di == SYS_Constants.MAX_DATA_FIELDS - 1 && body.length() > SYS_Constants.TEXT_AREA_MAX_SIZE){
                    SYS_debug.log('JSON too large. Truncated');
                    break;
                }
            } while (outboundJSON.length() > 0);
        }
        return data;
    }
    /* ------------------------------------------------------------------------ */

    public Boolean doDML(List<sObject> records,String dmlType,String additionalSetting) {
        
        switch on dmlType.toUpperCase() {
            when 'INSERT'{
                return doInsert(records);
            }
            when 'UPSERT'{
                return doUpsert(records, additionalSetting);
            }
            when 'UPDATE'{
                return doUpdate(records);
            }
            when 'DELETE'{
                return doDelete(records);
            }
            when else {
                SYS_debug.log('Invalid DML Operation specified in log record:'+dmlType);
                return false;
            }
            
        }

    }
    /* ------------------------------------------------------------------------ */

    public void insertWebhookLog(SYS_IntegrationLog__c log){
        try{
            Database.SaveResult result = Database.insert(log,false);
            //TODO check if result is success/error and take action

            if(!result.isSuccess()){
                handleDMLErrors(result.getErrors());
            }
            else{
                setSuccessHttpResponse();
            }
        } catch ( Exception e ) {
            setErrorHttpResponse(e.getStackTraceString());
        }
    }

    /* ------------------------------------------------------------------------ */

    public static void logException(SYS_IntegrationLog__c log,String stackTrace){
        //log.Type__c = 'EXCEPTION';
        log.Status__c = 'FAIL';
        log.Message__c = stackTrace;
        upsert log;
    }

    /* ------------------------------------------------------------------------ */

    public static Map<String, Object> getFlatKeys(String jsonObj) {
        Object result = JSON.deserializeUntyped(jsonObj);
        Map<String, Object> flatKeyMap = new Map<String, Object>();
        if (result instanceof Map<String, Object>) {
            recursiveJsonParser((Map<String, Object>)result, new List<String>(), flatKeyMap);
        }
        return flatKeyMap;
    }
    
    private static void recursiveJsonParser(Map<String, Object> jsonObject, List<String> parents, Map<String, Object> result) {
        for(String key : jsonObject.keySet()) {
            Object currentObj = jsonObject.get(key);
            if (currentObj instanceof Map<String, Object>) {
                Map<String, Object> child = (Map<String, Object>)currentObj;
                parents.add(key);
                recursiveJsonParser(child, parents, result);
                parents.remove(parents.size() - 1);
           
            } else {
                String parentKey = '';
                if(parents.size() > 0) {
                    parentKey = String.join(parents, '.');
                } 
                if (currentObj instanceof Decimal) {
                    //Add
                	result.put(String.isBlank(parentKey) ? key : parentkey+'.'+ key, (Decimal) currentObj);
                } else if (currentObj instanceof Integer) {
                    //Add
                    result.put(String.isBlank(parentKey) ? key : parentkey+'.'+ key, (Integer) currentObj);
                }
                else if (currentObj instanceof String) {
                    //Add
                    result.put(String.isBlank(parentKey) ? key : parentkey+'.'+ key,  currentObj);
                } else if (currentObj instanceof Boolean) {
                    //Add
                    result.put(String.isBlank(parentKey) ? key : parentkey+'.'+ key, (Boolean) currentObj);
                } 
                else if (currentObj == null) {
                    //TODO - Verify accuracy on what needs to be done
                    result.put(String.isBlank(parentKey) ? key : parentkey+'.'+ key, null);
                }
                else{
                	//TODO
                }
                
            }
            
        }
        return;
        
    }

    /************************** C O N C R E T E    M E T H O D S    E N D *****************************/

    
}