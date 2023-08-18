global without sharing class SYS_Helper {

    public class SYS_HelperException extends Exception{}
    /* ------------------------------------------------------------------------ */

    global static Datetime secondsToDatetime(String expiry){
        return secondsToDatetime(Integer.valueOf(expiry));
    }

    /* ------------------------------------------------------------------------ */

    global static Database.SaveResult[] insertLog(List<SYS_IntegrationLog__c> logs){
        Database.SaveResult[] results;
        if(logs.size()>0){ 

            
            String matrixId = SYS_DataCacheFactory.MATRIX_ID;
            if (matrixId == NULL) {
                SYS_Matrix__c matrixRec = new SYS_Matrix__c(
                    Date__c = Date.today()
                );
                Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.SYS_Matrix__c.fields.getMap();
                Map<String, Object> fieldsToValue = matrixRec.getPopulatedFieldsAsMap();
                for(String fieldKey : fieldsToValue.keySet()) {
                    if(!fieldMap.get(fieldKey).getDescribe().isCreateable() ) {
                        throw new SecurityException('Log cannot be created/updated. Field: '+fieldKey+' is missing permission');
                    }
                }
                Database.SaveResult result = Database.insert(matrixRec, false);
                if (result.isSuccess()) {
                    matrixId = matrixRec.Id;
                }
            } 

            for(SYS_IntegrationLog__c log:logs) {
                log.SYS_Matrix__c = matrixId;
            }
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.SYS_IntegrationLog__c.fields.getMap();
            Map<String, Object> fieldsToValue = logs[0].getPopulatedFieldsAsMap();
            for(String fieldKey : fieldsToValue.keySet()) {
                if(!fieldMap.get(fieldKey).getDescribe().isCreateable() ) {
                    throw new SecurityException('Log cannot be created/updated. Field: '+fieldKey+' is missing permission');
                }
            }
            System.debug('insert method');
            results = Database.insert( logs, false);
        }
        return results;
    }

    global static Database.SaveResult insertLog(SYS_IntegrationLog__c log){
        Database.SaveResult result;
        
        //insert log;
        String matrixId = SYS_DataCacheFactory.MATRIX_ID;
        if (matrixId == NULL) {
            SYS_Matrix__c matrixRec = new SYS_Matrix__c(
                Date__c = Date.today()
            );
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.SYS_Matrix__c.fields.getMap();
            Map<String, Object> fieldsToValue = matrixRec.getPopulatedFieldsAsMap();
            for(String fieldKey : fieldsToValue.keySet()) {
                if(!fieldMap.get(fieldKey).getDescribe().isCreateable() ) {
                    throw new SecurityException('Log cannot be created/updated. Field: '+fieldKey+' is missing permission');
                }
            }
            result = Database.insert(matrixRec, false);
            if (result.isSuccess()) {
                matrixId = matrixRec.Id;
            }
        } 
        log.SYS_Matrix__c = matrixId;
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.SYS_IntegrationLog__c.fields.getMap();
        Map<String, Object> fieldsToValue = log.getPopulatedFieldsAsMap();
        for(String fieldKey : fieldsToValue.keySet()){
            if(!fieldMap.get(fieldKey).getDescribe().isCreateable()) {
                throw new SecurityException('Log cannot be created/updated. Field: '+fieldKey+' is missing permission');
            }
        }
        result = Database.insert(log,false);
        return result;
    }

    /* ------------------------------------------------------------------------ */


    global static Database.DeleteResult[] deleteWithFLSCheck(List<sObject> sObjects){
        Database.DeleteResult[] results;
        if(sObjects.size()>0){
            Id recId = sObjects[0].Id;
            String sObjectApiName = String.valueOf(recId.getsobjecttype());
            Boolean isObjDeletable = Schema.getGlobalDescribe().get(sObjectApiName).getDescribe().isDeletable();
            System.debug('delete permission '+isObjDeletable);
            //removed the deletable permisssion check
            // if(isObjDeletable){
            //     results = Database.delete(sObjects,false);
            // }
            results = Database.delete(sObjects,false);
            
        }
        return results;
        
    }

    /* ------------------------------------------------------------------------ */

    global static List<Database.upsertResult> upsertLog(List<SYS_IntegrationLog__c> logs){
        List<Database.upsertResult> upsertResult;
        if(logs.size()>0){
            
            String matrixId = SYS_DataCacheFactory.MATRIX_ID;
            if (matrixId == NULL) {
                SYS_Matrix__c matrixRec = new SYS_Matrix__c(
                    Date__c = Date.today()
                );
                Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.SYS_Matrix__c.fields.getMap();
                Map<String, Object> fieldsToValue = matrixRec.getPopulatedFieldsAsMap();
                for(String fieldKey : fieldsToValue.keySet()) {
                    if(!fieldMap.get(fieldKey).getDescribe().isCreateable() ) {
                        throw new SecurityException('Log cannot be created/updated. Field: '+fieldKey+' is missing permission');
                    }
                }
                Database.SaveResult result = Database.insert(matrixRec, false);
                if (result.isSuccess()) {
                    matrixId = matrixRec.Id;
                }
            } 
            for(SYS_IntegrationLog__c log:logs) { //TODO identify UNABLE_TO_LOCK_ROW bug.
                if(log.SYS_Matrix__c == NULL)
                    log.SYS_Matrix__c = matrixId;
            }

            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.SYS_IntegrationLog__c.fields.getMap();
            Map<String, Object> fieldsToValue = logs[0].getPopulatedFieldsAsMap();
            for(String fieldKey : fieldsToValue.keySet() ) {
                if(fieldKey!=null && fieldMap.containsKey(fieldKey) && UserInfo.getUserType().toLowerCase()!='guest' ){
                    Schema.SObjectField fld = fieldMap.get(fieldKey);
                    
                    if( fld.getDescribe().isCustom() && UserInfo.getUserType().toLowerCase()!='guest' &&
                        !fld.getDescribe().isCalculated() && 
                        !fld.getDescribe().isCreateable() && 
                        !fld.getDescribe().isUpdateable()) {
                            // /*--*/SYS_debug.log('=========== fields with no permission ::'+fieldKey);
                        throw new SecurityException('Log cannot be created/updated. Field: '+fieldKey+' is missing permission');
                    }
                }
            }
            upsertResult =  Database.upsert(logs);
        }
        return upsertResult;
    }

    global static Database.upsertResult upsertLog(SYS_IntegrationLog__c log){
        
        String matrixId = SYS_DataCacheFactory.MATRIX_ID;
        if (matrixId == NULL) {
            SYS_Matrix__c matrixRec = new SYS_Matrix__c(
                Date__c = Date.today()
            );
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.SYS_Matrix__c.fields.getMap();
            Map<String, Object> fieldsToValue = matrixRec.getPopulatedFieldsAsMap();
            for(String fieldKey : fieldsToValue.keySet()) {
                if(!fieldMap.get(fieldKey).getDescribe().isCreateable() ) {
                    throw new SecurityException('Log cannot be created/updated. Field: '+fieldKey+' is missing permission');
                }
            }
            Database.SaveResult result = Database.insert(matrixRec, false);
            if (result.isSuccess()) {
                matrixId = matrixRec.Id;
            }
        } 

        log.SYS_Matrix__c = matrixId;
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.SYS_IntegrationLog__c.fields.getMap();
        Map<String, Object> fieldsToValue = log.getPopulatedFieldsAsMap();
        for(String fieldKey : fieldsToValue.keySet() ) {
            if(fieldKey!=null && fieldMap.containsKey(fieldKey) && UserInfo.getUserType().toLowerCase()!='guest'){
                Schema.SObjectField fld = fieldMap.get(fieldKey);
                
                if( fld.getDescribe().isCustom() && 
                    !fld.getDescribe().isCalculated() && 
                    !fld.getDescribe().isCreateable() && 
                    !fld.getDescribe().isUpdateable()) {
                    throw new SecurityException('Log cannot be created/updated. Field: '+fieldKey+' is missing permission');
                }
            }
        }
        return Database.upsert(log);
    }

    /* ------------------------------------------------------------------------ */

    global static void updateLog(List<SYS_IntegrationLog__c> logs){
        if(logs.size()>0){
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.SYS_IntegrationLog__c.fields.getMap();
            Map<String, Object> fieldsToValue = logs[0].getPopulatedFieldsAsMap();
            for(String fieldKey : fieldsToValue.keySet() ) {
                if(fieldKey!=null && fieldMap.containsKey(fieldKey) && UserInfo.getUserType().toLowerCase()!='guest'){
                    Schema.SObjectField fld = fieldMap.get(fieldKey);
                    
                    if(fld.getDescribe().isCustom() && !fld.getDescribe().isCalculated() && !fld.getDescribe().isUpdateable()) {
                        throw new SecurityException('Log cannot be created/updated. Field: '+fieldKey+' is missing permission');
                    }
                }
            }
            update logs;
        }
    }

    global static void updateLog(SYS_IntegrationLog__c log){
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.SYS_IntegrationLog__c.fields.getMap();
        Map<String, Object> fieldsToValue = log.getPopulatedFieldsAsMap();
        for(String fieldKey : fieldsToValue.keySet() ) {
            if(fieldKey!=null && fieldMap.containsKey(fieldKey) && UserInfo.getUserType().toLowerCase()!='guest'){
                Schema.SObjectField fld = fieldMap.get(fieldKey);
                
                if(fld.getDescribe().isCustom() && !fld.getDescribe().isCalculated() && !fld.getDescribe().isUpdateable()) {
                    throw new SecurityException('Log cannot be created/updated. Field: '+fieldKey+' is missing permission');
                }
            }
        }
        update log;
    }

    /* ------------------------------------------------------------------------ */

    global static String urlFromPattern(String httpMethod, Id recId){

        String finalurl;
        if(SYS_DataCacheFactory.OBJ_TYPE != null && httpMethod!=''){

            Set<String> fieldApis = new Set<String>();
            String url = (String)SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE)?.get(httpMethod.toUpperCase()+'_URL_Pattern__c');
            if(url == null) return null;
            else finalurl = url;

            Pattern p = Pattern.compile('\\{(.*?)\\}');
            Matcher m = p.matcher(url);

            while (m.find() == true){
                fieldApis.add(m.group(1));
            }
            
            String qry;
            if(fieldApis.size()>0){
                try{
                    qry = 'SELECT ' + String.join(new List<String>(fieldApis),',') + ' FROM ' + String.valueOf(recId.getsobjecttype());
                    String whereClause = ' WHERE Id = \'' + String.escapeSingleQuotes(recId)+'\'';
                    /*--*/SYS_debug.log('=========== ::'+qry);
                    sObject sobj = Database.query(String.escapeSingleQuotes(qry)+whereClause);
                    finalurl = urlFromPattern(httpMethod, sobj);
                }catch(QueryException e){
                    throw new SYS_HelperException('\nInvalid field api names provided for URL Pattern. Query execution failed.');
                }
            }

        }
        
        return finalurl;
    }

    global static String urlFromPattern(String httpMethod,sObject sobj){

        if(SYS_DataCacheFactory.OBJ_TYPE != null && httpMethod!=null && httpMethod!='' && sobj!=null){
            String url = (String)SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE)?.get(httpMethod.toUpperCase()+'_URL_Pattern__c');
            if(url == null) return null;

            Pattern p = Pattern.compile('\\{(.*?)\\}');      
            Matcher m = p.matcher(url);

            while (m.find() == true){
                if(sobj.get(m.group(1)) == null) {
                    throw new SYS_HelperException('\nInvaid field api name provided for URL Pattern');
                }
                else{
                    url = m.replacefirst((String)sobj.get(m.group(1)));
                    m = p.matcher(url);
                }
            }
            return url;
        }else{
            return null;
        }       
    }

    global static Datetime secondsToDatetime(Integer expiry){
        Integer day = 86400;
        Integer hour = 3600;
        Integer minute = 60;
        Integer totalSeconds = expiry;
        Integer daysout = Integer.valueOf(Math.floor(totalseconds / day));
        Integer hoursout = Integer.valueOf(Math.floor((totalseconds - daysout * day)/hour));
        Integer minutesout = Integer.valueOf(Math.floor((totalseconds - daysout * day - hoursout * hour)/minute));
        Integer secondsout = Integer.valueOf(totalseconds - daysout * day - hoursout * hour - minutesout * minute);
        String inpputString = System.now().yearGmt()+'-'+System.now().monthGmt()+'-'+(System.now().dayGmt()+daysout)+'T'+(System.now().hourGmt()+hoursout)+':'+(System.now().minuteGmt()+minutesout)+':'+(System.now().secondGmt()+secondsout)+'.'+'000Z';
        /*--*/SYS_debug.log('MS Date time:'+inpputString);
        DateTime resultDateTime = DateTime.valueof(inpputString.replace('T', ' '));
        return resultDateTime;
    }
    /* ------------------------------------------------------------------------ */

    global static String getUUID()
    {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return guid;
    }
    /* ------------------------------------------------------------------------ */

    global static void setNamespacePrefix(FieldSetting__mdt item)
    {
        String escapeChar = item?.ObjectSetting__r.IntegrationType__r?.EscapeCharacter__c != NULL ? item?.ObjectSetting__r.IntegrationType__r?.EscapeCharacter__c : '';
        item.FieldApiName__c = item.FieldApiName__c != null ? item.FieldApiName__c.replace(escapeChar, SYS_DataCache.namespacePrefix) :item.FieldApiName__c ;
        item.ObjectApiName__c = item.ObjectApiName__c != null ? item.ObjectApiName__c.replace(escapeChar, SYS_DataCache.namespacePrefix) :item.ObjectApiName__c ;
        
        item.Lookup_Object_API_Name__c = item.Lookup_Object_API_Name__c != null ? item.Lookup_Object_API_Name__c.replace(escapeChar, SYS_DataCache.namespacePrefix) :item.Lookup_Object_API_Name__c;
        item.Lookup_External_Key__c = item.Lookup_External_Key__c != null ? item.Lookup_External_Key__c.replace(escapeChar, SYS_DataCache.namespacePrefix) :item.Lookup_External_Key__c;
        item.ParentField__c = item.ParentField__c != null ? item.ParentField__c.replace(escapeChar, SYS_DataCache.namespacePrefix) :item.ParentField__c;
        item.Log_API_for_field_mapping__c = item.Log_API_for_field_mapping__c != null ? item.Log_API_for_field_mapping__c.replace(escapeChar, SYS_DataCache.namespacePrefix) :item.Log_API_for_field_mapping__c;
    }

    /* ------------------------------------------------------------------------ */
    
    //sys root log and childs to order the logs and read the json

    global static String getDataFrom(SYS_IntegrationLog__c log){
        String data='';
        for(Integer i=0 ; i<SYS_Constants.MAX_DATA_FIELDS; i++){
            if(log.get('data'+i+'__c')!=NULL){
                data+=log.get('data'+i+'__c');
            }
            else{
                break;
            }
            
        }
        return  data;
        
    }

    global static String getDataFromNew(SYS_IntegrationLog__c log, List<SYS_IntegrationLog__c> allChildLogs){
        String data='';
        Map<Integer, String> jsonOrderMap = new Map<Integer, String>();
        for(SYS_IntegrationLog__c childLog : allChildLogs) {
            if(childLog.Root_Log__c == log.Id) {
                jsonOrderMap.put((Integer)childLog.Order__c , getDataFrom(childLog));
            }
        }
        data = getDataFrom(log);
        if(jsonOrderMap != NULL && !jsonOrderMap.isEmpty()) {
            for(integer i = 0; i<jsonOrderMap.keySet()?.size() ;i++) {
                data += jsonOrderMap.get(i);
            }
        }
        System.debug('SP data parent child'+log.Status__c + allChildLogs[0].Order__c);
        return  data;
        
    }


    /* ------------------------------------------------------------------------ */
    //TODO list splitter implementation
    // read json from list

    global static List<SYS_IntegrationLog__c> getLogsAfterPartition(String requestBody) {
        List<String> data = getJSONChunckedValues(requestBody);
        List<SYS_IntegrationLog__c> logs = new List<SYS_IntegrationLog__c>();
        System.debug('SP data size() '+data.size());
        if(data != NULL && data.size() <= SYS_Constants.MAX_DATA_FIELDS) {
            logs.add(getLogsToInsertNew(data));
        } else {
            List<List<String>> dataPartition = (List<List<String>>)SYS_Helper.doPartions(data, SYS_Constants.MAX_DATA_FIELDS , List<List<String>>.class);
            if(dataPartition != NULL && dataPartition.size() > 0) {
                String handler = SYS_DataCacheFactory.integrationSetting?.ApexHandler__c != NULL ? SYS_DataCacheFactory.integrationSetting?.ApexHandler__c : 'SYS_ApplicationService';
                SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(handler).newInstance();
                
                SYS_IntegrationLog__c firstlog = getLogsToInsertNew(dataPartition[0]);
                String algo = SYS_DataCacheFactory.integrationSetting?.Hashing_Algo__c; 
                String requestDigest = appService.generateHash(requestBody, algo); 
                if(algo!=NULL && algo!='')
                    firstlog.Request_Digest__c = requestDigest;
                firstlog.Has_Child__c = true;
                firstlog.UUID__c = getUUID();
                firstlog.Type__c = SYS_Constants.INBOUND;
                logs.add(firstlog);


                for(integer i = 1; i<dataPartition.size() ; i++) {
                    SYS_IntegrationLog__c log = getLogsToInsertNew(dataPartition[i]);
                    log.Order__c = i-1;
                    log.Parent_UUID__c = firstlog.UUID__c;
                    log.Status__c = SYS_Constants.PENDING_PARTITIONED_LOOKUP;
                    log.Type__c = SYS_Constants.INBOUND;
                    logs.add(log);
                } 

            }
        }
        return logs;
    }

    global static List<SYS_IntegrationLog__c> getChildRecords(List<SYS_IntegrationLog__c> logs) {
        List<SYS_IntegrationLog__c> childs = new List<SYS_IntegrationLog__c>();
        for(integer i = 1; i<logs.size() ; i++) {
            logs[i].Root_Log__c = logs[0].Id;
            childs.add(logs[i]);
        }
        return childs;
    }


    global static SYS_IntegrationLog__c getLogsToInsertNew(List<String> data) {
        SYS_IntegrationLog__c integrationLog = new SYS_IntegrationLog__c();
        
        integer i = 0;
        for(String json:data){ 
            integrationLog.put('data'+i+'__c',json);
            i++;
        }
        integrationLog.UUID__c = getUUID();
        return integrationLog;
    }

    global static SYS_IntegrationLog__c getLogsToInsert(String requestBody) {
        SYS_IntegrationLog__c integrationLog = new SYS_IntegrationLog__c();
        List<String> data = getJSONChunckedValues(requestBody);
        integer i = 0;
        for(String json:data){ 
            integrationLog.put('data'+i+'__c',json);
            i++;
        }
        return integrationLog;
    }

    global static SYS_IntegrationLog__c writeDataFields(SYS_IntegrationLog__c integrationLog, String requestBody) {
        // SYS_IntegrationLog__c integrationLog = new SYS_IntegrationLog__c();
        List<String> data = getJSONChunckedValues(requestBody);
        integer i = 0;
        for(String json:data){ 
            integrationLog.put('data'+i+'__c',json);
            i++;
        }
        return integrationLog;
    }


    /* ------------------------------------------------------------------------ */

    global static List<String> getJSONChunckedValues(String body){
        List<String> data = new List<String>();
        
        if (body.length() <= SYS_Constants.TEXT_AREA_MAX_SIZE){
			data.add(body);
        } else {
            SYS_debug.log('json needs chunking');
            Integer di = 0; 
            String jsonSubStrng;
            Integer startIndex = 0;
            Integer endIndex = SYS_Constants.TEXT_AREA_MAX_SIZE;
            String outboundJSON = body;
            
            do {
                jsonSubStrng = outboundJSON.substring(startIndex, endIndex);
                outboundJSON = outboundJSON.substring(endIndex);
                // startIndex = endIndex;
                // endIndex = endIndex + SYS_Constants.TEXT_AREA_MAX_SIZE;
                SYS_debug.log('substr= '+outboundJSON+' index='+endIndex+' '+jsonSubStrng);
                endIndex = (outboundJSON.length() < SYS_Constants.TEXT_AREA_MAX_SIZE) ? outboundJSON.length() : SYS_Constants.TEXT_AREA_MAX_SIZE;
                data.add(jsonSubStrng);
                di++;
                // if(di == SYS_Constants.MAX_DATA_FIELDS - 1 && body.length() > SYS_Constants.TEXT_AREA_MAX_SIZE){
                //     SYS_debug.log('JSON too large. Truncated');
                //     break;
                // }
            } while (outboundJSON.length() > 0);
        }
        return data;
    }
   

    /* ------------------------------------------------------------------------ */

    global static void logException(SYS_IntegrationLog__c log,String stackTrace){
        //log.Type__c = 'EXCEPTION';

        //## flagLogForRetry(log.Id);
        log.retry__c = true;
        
        log.Status__c = 'FAIL';
        log.Message__c = stackTrace;
        
        // Commented to make bulkify error log generation.
        // upsertLog(new List<SYS_IntegrationLog__c>{log});
    }

    global static void logException(List<SYS_IntegrationLog__c> logs,Map<String, String> stackTraceMap){
        //log.Type__c = 'EXCEPTION';

        //## flagLogForRetry(log.Id);
        for(SYS_IntegrationLog__c log:logs) {
            log.retry__c = true;
        
            log.Status__c = 'FAIL';
            log.Message__c = stackTraceMap?.get(log.Id);
        }
        upsertLog(logs);
    }

    global static void handleSuccessDml(SYS_IntegrationLog__c log, Id recordId) {
        System.debug('Successful dml '+recordId);
        // String message = 'Record created/updated successfully';
        log.WhatId__c = recordId;
        // log.retry__c = false;
        // log.Status__c = 'DONE';
        // log.Message__c = message; 
    }

    global static void handleFailureDml(SYS_IntegrationLog__c log, Database.Error[] errors) {
        String error = '';            
        for(Database.Error err : errors) {
            System.debug('The following error has occurred.');                    
            System.debug(err.getStatusCode() + ': ' + err.getMessage());
            System.debug('Account fields that affected this error: ' + err.getFields());
            error += err.getStatusCode() + ': ' + err.getMessage()+'\n'+ 'Fields that affected this error: ' + err.getFields();
        }
        log.retry__c = true;
    
        log.Status__c = 'FAIL';
        log.Message__c = error;
    }

    global static void updateSYSLog(SYS_IntegrationLog__c log,Database.SaveResult sr){
        //log.Type__c = 'EXCEPTION';

        //## flagLogForRetry(log.Id);
        
        if (sr.isSuccess()) {
            // Operation was successful, so get the ID of the record that was processed
            System.debug('Successfully inserted SP' + sr.getId());
            log.WhatId__c = sr.getId();
            log.retry__c = false;
            log.Status__c = 'DONE';
        }
        else {
            // Operation failed, so get all errors    
            String error = '';            
            for(Database.Error err : sr.getErrors()) {
                System.debug('The following error has occurred.');                    
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('Account fields that affected this error: ' + err.getFields());
                error += err.getStatusCode() + ': ' + err.getMessage()+'\n'+ 'Fields that affected this error: ' + err.getFields();
            }
            log.retry__c = false;
        
            log.Status__c = 'FAIL';
            log.Message__c = error;
        }
    }

    /*
    @future
    global static void flagLogForRetry(Id logId){
        if(logId!=NULL){
            SYS_IntegrationLog__c log = new SYS_IntegrationLog__c(Id=logId);
            log.retry__c = true;
            updateLog(log);
        }else{
            //TODO - How to update the log record?
        }
    }
    */

    /* ------------------------------------------------------------------------ */

    global static Map<String, Object> getFlatKeys(String jsonObj,String pattern) {
        Object result = JSON.deserializeUntyped(jsonObj);
        Map<String, Object> flatKeyMap = new Map<String, Object>();
        if (result instanceof Map<String, Object>) {
            recursiveJsonParser((Map<String, Object>)result, new List<String>(), flatKeyMap,pattern);
        }
        return flatKeyMap;
    }
    
    global static void recursiveJsonParser(Map<String, Object> jsonObject, List<String> parents, Map<String, Object> result,String pattern) {
        
        //String pattern = 'A.B';
        
        pattern = pattern.rightPad(4);
        String open = String.fromCharArray( new List<integer>{pattern.getChars()[1]});
        String close = String.fromCharArray( new List<integer>{pattern.getChars()[3]});
        open = open.replace('_', SYS_DataCacheFactory.FLAT_KEY_SEPERATOR);
        close = close.trim();
        /*--*/SYS_debug.log('*********** open:'+open+' '+'close:'+close);

        for(String key : jsonObject.keySet()) {
            Object currentObj = jsonObject.get(key);
            if (currentObj instanceof Map<String, Object>) {
                Map<String, Object> child = (Map<String, Object>)currentObj;
                parents.add(key);
                recursiveJsonParser(child, parents, result,pattern);
                parents.remove(parents.size() - 1);
           
            }
            else{
                String parentKey = '';
                if(parents.size() > 0) {
                    parentKey = String.join(parents, SYS_DataCacheFactory.FLAT_KEY_SEPERATOR);
                }

                String resultKey = String.isBlank(parentKey) ? key : parentkey + open + key + close;

                if(pattern == 'A[B]'){
                    for(Integer i=0; i < parentKey.countMatches(SYS_DataCacheFactory.FLAT_KEY_SEPERATOR); i++){
                        resultKey+= close;
                    }
    
                    resultKey = resultKey.replace(SYS_DataCacheFactory.FLAT_KEY_SEPERATOR, open);
                }
                
                

                if(currentObj instanceof Decimal){

                	result.put(resultKey, (Decimal) currentObj);

                } else if (currentObj instanceof Integer){

                    result.put(resultKey, (Integer) currentObj);
                }
                else if(currentObj instanceof String){

                    result.put(resultKey,  currentObj);

                } else if(currentObj instanceof Boolean){

                    result.put(resultKey, (Boolean) currentObj);

                } 
                else if(currentObj == null) {
                    //TODO - Verify accuracy on what needs to be done
                    result.put(resultKey, null);
                }
                else if(currentObj instanceof List<Object>){

                    List<Object> childArray = (List<Object>)currentObj;

                    Integer arrLen = childArray.size();
                    for (Integer i = 0; i < arrLen; i++){
                        if(childArray[i] instanceof Map<String, Object>){
                            Map<String, Object> child = (Map<String, Object>)childArray[i];
                            parents.add(key+'[' + i + ']');
                            recursiveJsonParser(child, parents, result,pattern);
                            parents.remove(parents.size() - 1);
                        }
                        else{
                            //List is multiselect picklist. So recurse with values joined with ; and break - assuming rest will be same as first value
                            recursiveJsonParser(new Map<String, String>{key+'[]'=>String.join(childArray,';')},parents,result,pattern);
                            break;
                        }
                    }
                }
                else{
                	//TODO
                }
                
            }
            
        }
        return;
        
    }

    public static List<string> getFields(String selectedObject){
        List<String> reqFields = new List<String>();
        Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(selectedObject);
        Schema.DescribeSObjectResult r = sobjType.getDescribe();
        Map<String, Schema.SObjectField> MapofField = r.fields.getMap();
        
        for(String fieldName : MapofField.keySet()) {
            Schema.SObjectField field = MapofField.get(fieldName);
            Schema.DescribeFieldResult F = field.getDescribe();
            System.debug('field-->'+field);
            System.debug('F-->'+F.getType()); //type of field
	        reqFields.add(field+'');
        }
        System.debug(reqFields);
        return reqFields;
    }

    public static List<List<Object>> doPartions(List<Object> records, Integer size, Type destType){
        checkNotNull(records);
        checkArgument(size > 0);
        checkNotNull(destType);
        return new Partition(records, size, destType).doPartition();
    }

    private static void checkNotNull(Object reference) {
        if (reference == null) {
            throw new NullPointerException();
        }
    }

    private static void checkArgument(Boolean expression) {
        if (!expression) {
            throw new IllegalArgumentException();
        }
    }

    private class Partition{
        private List<Object> items;
        private Integer splitSize;
        private Type destType;

        Partition(List<Object> records, Integer size, Type destType){
            this.items = records;
            this.splitSize = size;
            this.destType = destType;
        }

        List<List<Object>> doPartition(){
            List<List<Object>> result = (List<List<Object>>)destType.newInstance();
            List<Object> protoList = items.clone();
            protoList.clear();
            List<Object> tempList = protoList.clone();
            Integer index = 0, count = 0, size = items.size();
            while(index < size) {
                tempList.add(items.get(index++));
                ++count;
                if(count == splitSize) {
                    result.add(tempList);
                    tempList = protoList.clone();
                    count = 0;
                }
            }
            if(!tempList.isEmpty()) {
                result.add(tempList);
            }
            return result;
        }
    }

    public class IllegalArgumentException extends Exception {}

    global static String getAllFieldsFor(String objName){

        return (String.join(getAllFields(objName),', '));
    }

    public static List<String> getPicklistEntryFor(String objectName, String fieldName) {
        List<String> result = new List<String>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            result.add(pickListVal.getValue());
        }
        return result;    
    }

    global static List<String> getAllFields(String objName) {
        objName = SYS_DataCache.namespacePrefix + objName;

        List<String> fields = new List<String>();
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objName).getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            Schema.DescribefieldResult field = sfield.getDescribe();
            // if(field.isAccessible())
                fields.add(field.getname()?.toLowerCase());
        }
        return fields;
    }

    global static String getAllParentFields(String prefix, String objName) {
        List<String> fields = getAllFields(objName);
        for(Integer i=0; i<fields.size(); i++) {
            fields[i] = prefix + fields[i];
        }

        return (String.join(fields,', '));
    }

    public static void generateRequestBody(SYS_IntegrationLog__c log, String requestBody) {

        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).ApexHandler__c).newInstance();
        String finalJsonForOutbound = appService.sanitizeJSONForOutbound(requestBody);
        /*--*/SYS_debug.log('cleanJSON'+finalJsonForOutbound); 

        if(log.Additional_Param__c != NULL ) {
            finalJsonForOutbound = appService.sanitizeJSONForOutbound(finalJsonForOutbound, log.Additional_Param__c);
        }
        writeDataFields(log, finalJsonForOutbound);

    }

    public static void processOutboundRequest(List<sObject> newList, String operationType, String httpMethod, Map<Id,sObject> newMap, List<String> paramList ) {
        List<SYS_IntegrationLog__c> insertSysLog = new List<SYS_IntegrationLog__c>();
        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).ApexHandler__c).newInstance();
        
        integer i = 0;
        if(newList.size() > 0){
            for(sObject jsonRecordId : newList) { 
                /*--*/SYS_debug.log('Id:'+jsonRecordId.Id);
                
                SYS_IntegrationLog__c  newSysLog = new SYS_IntegrationLog__c();

                
                newSysLog.Callout_URL__c = SYS_Helper.urlFromPattern(httpMethod,newMap.get(jsonRecordId.Id));

                newSysLog.Status__c = SYS_Constants.NEW_STATUS;
                newSysLog.Type__c = SYS_Constants.OUTBOUND;
                newSysLog.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
                newSysLog.SYS_Operation_Type__c = operationType;
                newSysLog.How_to_process__c = 'use_object_setting';
                newSysLog.whatid__c = jsonRecordId.Id;
                newSysLog.HTTP_Method__c = httpMethod;
                newSysLog.ObjectSettingId__c = SYS_DataCacheFactory.OBJ_TYPE;
                newSysLog.Account_Id__c = SYS_DataCacheFactory.accountId;
                newSysLog.Integration_Type__c = SYS_DataCacheFactory.integrationType;
                

                if(paramList != NULL && paramList.size() > i) {
                    newSysLog.Additional_Param__c = paramList[i];
                    newSysLog = appService.reworkSysLog(newSysLog, paramList[i]);
                    i++;
                }
                    // newSysLog = appService.reworkSysLog(newSysLog, parameterMap?.get(jsonRecordId.Id));
                
                insertSysLog.add(newSysLog);
            }
            if(!insertSysLog.isEmpty() && SYS_DataCacheFactory.enableCheck) { 
                SYS_Helper.insertLog(insertSysLog);
                /*--*/SYS_debug.log('insertSysLog=='+insertSysLog);
            } 
            else if (!insertSysLog.isEmpty() && !SYS_DataCacheFactory.enableCheck) {
                updateIntegrationSettingDisableMessage(insertSysLog);
                SYS_Helper.upsertLog(insertSysLog);
            }
            
        }
    }

    public static void updateIntegrationSettingDisableMessage(List<SYS_IntegrationLog__c> logs) {
        for(SYS_IntegrationLog__c log: logs) {
            log.Message__c = Label.IS_disabled + ' : ' + SYS_DataCacheFactory.INT_TYPE;
            log.Status__c = 'FAIL';
        }
    }

    /* ------------------------------------------------------------------------ */

    public static void insertErrorLog(String method, String message) {
        List<SYS_IntegrationLog__c> sysLogs = registerLogAfterError(method, message);
        SYS_Helper.upsertLog(sysLogs);
    }

    /* ------------------------------------------------------------------------ */

    public static List<SYS_IntegrationLog__c> registerLogAfterError(String method, String message) {
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

        if(SYS_DataCacheFactory.integrationSetting.Notifications_are_partial__c)
            log.Is_Notification_Only__c = true;

        log.Type__c = SYS_Constants.INBOUND;
        log.HTTP_Method__c = method;
        log.How_to_process__c = 'ignore_log';
        log.Message__c = message;
        log.Status__c = SYS_Constants.FAIL;
        log.retry__c = false;

    

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

    // public static void processOutboundRequest(List<sObject> newList, String operationType, String httpMethod, Map<Id,sObject> newMap, Map<Id, String> parameterMap ) {
    //     List<SYS_IntegrationLog__c> insertSysLog = new List<SYS_IntegrationLog__c>();
    //     SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).ApexHandler__c).newInstance();
    //     Map<Id, String> jsonListForOutbound = appService.transformSObjectToJson(newList);
        
    //     SYS_debug.log('SP Limits SOQL '+Limits.getQueries() +' : '+Limits.getLimitQueries());
       
    //     if(jsonListForOutbound.values().size() > 0){
    //         for(Id jsonRecordId:jsonListForOutbound.keyset()){ 
    //             /*--*/SYS_debug.log('Id:'+jsonRecordId);
    //             String finalJsonForOutbound;
                

    //             /*
    //             Pre-processing each transformed JSON record. Default is to remove newlines.
    //             For Custom pre-processing override sanitizeJSONForOutbound() method in SYS_ApplicationService
    //             by creating an extension class. Configure the new extended class in ObjectSettings metadata
    //             */

    //             finalJsonForOutbound = appService.sanitizeJSONForOutbound(jsonListForOutbound.get(jsonRecordId));
    //             /*--*/SYS_debug.log('cleanJSON'+finalJsonForOutbound); 

    //             if(parameterMap != NULL && parameterMap?.get(jsonRecordId) != NULL) {
    //                 finalJsonForOutbound = appService.sanitizeJSONForOutbound(finalJsonForOutbound, parameterMap?.get(jsonRecordId));
    //             }

    //             SYS_IntegrationLog__c  newSysLog = SYS_Helper.getLogsToInsert(finalJsonForOutbound);

                
    //             newSysLog.Callout_URL__c = SYS_Helper.urlFromPattern(httpMethod,newMap.get(jsonRecordId));

    //             newSysLog.Status__c = SYS_Constants.NEW_STATUS;
    //             newSysLog.Type__c = SYS_Constants.OUTBOUND;
    //             newSysLog.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
    //             newSysLog.SYS_Operation_Type__c = operationType;
    //             newSysLog.How_to_process__c = 'use_object_setting';
    //             newSysLog.whatid__c = jsonRecordId;
    //             newSysLog.HTTP_Method__c = httpMethod;
    //             newSysLog.ObjectSettingId__c = SYS_DataCacheFactory.OBJ_TYPE;
    //             newSysLog.Account_Id__c = SYS_DataCacheFactory.accountId;
    //             newSysLog.Integration_Type__c = SYS_DataCacheFactory.integrationType;

    //             if(parameterMap != NULL && parameterMap?.get(jsonRecordId) != NULL)
    //                 newSysLog = appService.reworkSysLog(newSysLog, parameterMap?.get(jsonRecordId));
                
    //             insertSysLog.add(newSysLog);
    //         }
    //         if(!insertSysLog.isEmpty() && SYS_DataCacheFactory.enableCheck){ 
    //             SYS_Helper.insertLog(insertSysLog);
    //             /*--*/SYS_debug.log('insertSysLog=='+insertSysLog);
    //         }
            
    //     }
    // }

    public static void updateRootLogLookUp(Set<String> parentUuids, Set<String> childIds) {
        String query = 'SELECT '+SYS_Helper.getAllFieldsFor('SYS_IntegrationLog__c')+', Parent__r.WhatId__c, Parent__r.SYS_Operation_Type__c FROM SYS_IntegrationLog__c';
        String whereClause = ' WHERE Id in (' + '\'' + String.join((Iterable<String>)childIds, ', ') + '\')' + ' OR UUID__c in ('+ '\'' + String.join((Iterable<String>)parentUuids, ', ') + '\')' ;
        System.debug('query '+ String.escapeSingleQuotes(query)+whereClause);
        List<SYS_IntegrationLog__c> sysLogs = Database.query(String.escapeSingleQuotes(query)+whereClause);
        Map<String, String> externalIdToSFIdMap = new Map<String, String>();
        for(SYS_IntegrationLog__c log : sysLogs) {
            if(log.Order__c == NULL)
                externalIdToSFIdMap.put(log.UUID__c, log.Id);
        }

        System.debug('SP uuid map '+JSON.serializePretty(externalIdToSFIdMap));
        for(SYS_IntegrationLog__c log : sysLogs) {
            if(log.Order__c != NULL && log.Root_Log__c == NULL) {
                log.Root_Log__c = externalIdToSFIdMap.get(log.Parent_UUID__c);
                log.Status__c = 'DONE';
            }
            else if(log.Order__c == NULL) {
                log.Status__c = SYS_Constants.READY_FOR_PROCESSING;
            }
            System.debug('Log info '+log.Status__c+log.Parent_UUID__c+externalIdToSFIdMap.get(log.Parent_UUID__c));
        }

        SYS_Helper.upsertLog(sysLogs);
    }
}