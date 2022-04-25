public virtual class SYS_Transformer {

    public class SYS_TransformerException extends Exception{}
	
    //NOT USED - It was when the child records were being processed in the same trx without additional logs
    //The flag was set in the Old Queueable class
    /*
    private static Boolean childRecordsProcess = false;
    public static Boolean isChild{ 
        get{return childRecordsProcess;}
        set{childRecordsProcess = value;}
    }
    */
    
    //NOT USED
    /*
    public static String childRoot = '';
    public static String childRootElement {
        get{return childRoot;}
        set{childRoot = value;}
    }
    */

    //NOT USED - Being populated and used for Debug only
    public static List<Map<String, Object>> childFlatKeyList = new List<Map<String, Object>>();

    /* *************************************************************************************************************************** */
    public static Map<Id, String> getRequestJson(List<sObject> objsList) {

        Map<Id,String> jsonMap = new Map<Id, String>();
        
        for(sObject obj : objsList){

            String objId = (String)obj.get('Id');
            Map<String, Object> jsonMapObject = getRequestJsonRecurse(obj,'0');
            jsonMap.put(objId, JSON.serialize(jsonMapObject));
            
        }
        return jsonMap;
    }

    /* *************************************************************************************************************************** */
    
    public static Map<String, Object> getRequestJsonRecurse(sObject singleObj,String level) {

        String parentLevel = Integer.valueOf(level)+'';
        String childLevel = (Integer.valueOf(level) + 1) +'';

        /*--*/SYS_debug.log('MS parentLevel '+ parentLevel);
        /*--*/SYS_debug.log('MS childLevel '+ childLevel);

        SObjectType objectType = singleObj.getSObjectType();
        String primaryObj = JSON.serialize(objectType.getDescribe().getName()).replace('\"','');
        
        /*--*/SYS_debug.log('hbdebug objectType.getDescribe().getName() '+ primaryObj);
        /*--*/SYS_debug.log('hbdebug mappings '+ JSON.serialize(SYS_DataCache.FieldMappingOutbound));

        Map<Id, Map<String, List<sObject>>> parentChildObjMap = new Map<Id, Map<String, List<sObject>>>();
        Map<String, List<FieldSetting__mdt>> childMappingsMap = new Map<String, List<FieldSetting__mdt>>();
        Map<String, List<String>> childFieldsMap = new Map<String, List<String>>();
        Map<String, List<String>> primaryObjFieldsMap = new Map<String, List<String>>();
        
        List<FieldSetting__mdt> parentMappings = new List<FieldSetting__mdt>(); //NOT USED
        Map<String, String> parentObjectFieldMap = new Map<String, String>();//NOT USED anywhere
		
        
        
        for(FieldSetting__mdt mapping : SYS_DataCache.FieldMappingOutbound) {

            //TODO check if below if condition is really required
            if(mapping.FieldApiName__c == NULL) {
                if(mapping.ParentField__c != null && mapping.Level__c == childLevel){
                    if(childMappingsMap.get(mapping.ObjectApiName__c) == null) {
                        childMappingsMap.put(mapping.ObjectApiName__c, new List<FieldSetting__mdt>()); 
                    }
                    childMappingsMap.get(mapping.ObjectApiName__c).add(mapping);
                }
                continue;
            }
            
            if(/*mapping.ObjectApiName__c == primaryObj &&*/ mapping.Level__c == parentLevel){
                if(primaryObjFieldsMap.get(mapping.ObjectApiName__c.toLowerCase()) == null) {
                    primaryObjFieldsMap.put(mapping.ObjectApiName__c.toLowerCase(), new List<String>()); 
                }
                if(!primaryObjFieldsMap.get(mapping.ObjectApiName__c.toLowerCase()).contains(mapping.FieldApiName__c))
				    primaryObjFieldsMap.get(mapping.ObjectApiName__c.toLowerCase()).add(mapping.FieldApiName__c);
            }
            
            if(/*mapping.ParentField__c != null &&*/ mapping.Level__c == childLevel) {
                if(childMappingsMap.get(mapping.ObjectApiName__c) == null) {
                    childMappingsMap.put(mapping.ObjectApiName__c, new List<FieldSetting__mdt>()); 
                }
                childMappingsMap.get(mapping.ObjectApiName__c).add(mapping);
                
                if(childFieldsMap.get(mapping.ObjectApiName__c) == null) {
                    childFieldsMap.put(mapping.ObjectApiName__c, new List<String>()); 
                }

				if(!childFieldsMap.get(mapping.ObjectApiName__c).contains(mapping.FieldApiName__c))
                    childFieldsMap.get(mapping.ObjectApiName__c).add(mapping.FieldApiName__c);
      
            } else {
                parentMappings.add(mapping);   
            }
        }
		
        /*--*/SYS_debug.log('hbdebug parentMappings '+ JSON.serialize(parentMappings));
        /*--*/SYS_debug.log('hbdebug childMappingsMap '+ JSON.serialize(childMappingsMap));
        /*--*/SYS_debug.log('hbdebug childFieldsMap '+ JSON.serialize(childFieldsMap));
        /*--*/SYS_debug.log('hbdebug primaryObjFieldsMap '+ JSON.serialize(primaryObjFieldsMap));
        
        List<String> parentIds = new List<String>();
        //for(sObject obj : objsList) {
        	parentIds.add((String)singleObj.get('Id'));
        //}
		
        /*--*/SYS_debug.log('MS check 101:'+parentIds);
        //Dynamically fetch all metadata fields for the primary object
        List<sObject> objs = new List<sObject>();
        /*--*/SYS_debug.log('=============== external key by obj api name: '+ SYS_DataCache.externalKeyByObject);
        if(primaryObjFieldsMap.size()>0){
            /*--*/SYS_debug.log('MS check 101 2:'+primaryObj+' ');
            String externalIdField = SYS_DataCache.externalKeyByObject.get(primaryObj.toLowerCase());//!=NULL ? (SYS_DataCache.externalKeyByObject.get(primaryObj.toLowerCase())):',';
            String finalSubQuery = '';
            if(externalIdField != NULL ){
                if(!primaryObjFieldsMap.get(primaryObj.toLowerCase()).contains(externalIdField.toLowerCase()))
                finalSubQuery = externalIdField +',';
            }
            
            
            
            String qry = 'Select Id,'+ finalSubQuery +
                     String.join(primaryObjFieldsMap.get(primaryObj.toLowerCase()), ',') +
                     ' from ' + 
                     primaryObj + 
                     ' where Id in :parentIds';
            
            /*--*/SYS_debug.log('query res@@=='+qry);
       
        	objs = Database.query(String.escapeSingleQuotes(qry));
        }
        // /*--*/SYS_debug.log('query res@@=='+objs[0].getSObject('Account').get('SYS_Key__c'));
         
        
        for(String objectName : childFieldsMap.keySet()) {
            String query = 'Select Id, '+ String.join(childFieldsMap.get(objectName), ',') + ',' +childMappingsMap.get(objectName)[0].ParentField__c +' from ' + objectName;
            String whereClause = ' where '+ String.escapeSingleQuotes(childMappingsMap.get(objectName)[0].ParentField__c) +' in :parentIds';
            /*--*/SYS_debug.log('child query=='+query);
            List<sObject> childObjects = Database.query(String.escapeSingleQuotes(query)+whereClause);

            for(sObject obj : childObjects) {
                if(parentChildObjMap.get((String)obj.get(childMappingsMap.get(objectName)[0].ParentField__c)) == null) {
                    parentChildObjMap.put((String)obj.get(childMappingsMap.get(objectName)[0].ParentField__c), new Map<String, List<sObject>>());
                }
                if(parentChildObjMap.get((String)obj.get((String)childMappingsMap.get(objectName)[0].ParentField__c)).get(objectName) == null) {
                	parentChildObjMap.get((String)obj.get((String)childMappingsMap.get(objectName)[0].ParentField__c)).put(objectName, new List<sObject>());	       
                }
            	parentChildObjMap.get((String)obj.get((String)childMappingsMap.get(objectName)[0].ParentField__c)).get(objectName).add(obj);
            }
        } 
		
        /*--*/SYS_debug.log('hbdebug parentChildObjMap '+ JSON.serialize(parentChildObjMap));
        Map<String, Object> jsonMapObject = new Map<String, Object>();

        //objs will have only record
        for(sObject obj : objs) {
            jsonMapObject = getRequestJsonSingle(parentLevel,obj,SYS_DataCache.FieldMappingOutbound, parentChildObjMap);
           
            String objId = (String)obj.get('Id');
            
            if(parentChildObjMap.get(objId) != null ) {
                 for(String childObjectName : parentChildObjMap.get(objId).keySet()) {
                    if(childMappingsMap.get(childObjectName)[0].ChildRootElement__c != null){

                        if(jsonMapObject.get(childMappingsMap.get(childObjectName)[0].ChildRootElement__c) == null) {
                            jsonMapObject.put(childMappingsMap.get(childObjectName)[0].ChildRootElement__c, new List<Map<String, Object>>()); 
                        } 
                        /*--*/SYS_debug.log('hbdebug getRequestJsonSingle child - '+ childObjectName);
                    
                        for(sObject childObj : parentChildObjMap.get(objId).get(childObjectName)) {
                            
                            //((List<Map<String, Object>>)jsonMapObject.get((String)childMappingsMap.get(childObjectName)[0].ChildRootElement__c)).add(getRequestJsonSingle(childLevel,childObj, childMappingsMap.get(childObjectName), parentChildObjMap)); 
                            Integer nextLevel = Integer.valueOf(childLevel); 
                            
                            if(nextLevel <= SYS_Constants.MAX_CHILD_NESTING_DEPTH)
                            ((List<Map<String, Object>>)jsonMapObject.get((String)childMappingsMap.get(childObjectName)[0].ChildRootElement__c)).add(getRequestJsonRecurse(childObj,String.valueOf(nextLevel))); 
                            
                        }
                    }
                }
            }
            /*--*/SYS_debug.log('Obj jsonMapObject==' + jsonMapObject);
            //jsonMap.put(objId, JSON.serialize(jsonMapObject));
            
        }
        return jsonMapObject;//jsonMap;
    }

    /* *************************************************************************************************************************** */
    
    public static Map<String, Object> getRequestJsonSingle(String level,sObject obj , List<FieldSetting__mdt> mappings, Map<Id, Map<String, List<sObject>>> mapVal) {
        Map<String, Object> jsonMapObject = new Map<String, Object>();
        /*--*/SYS_debug.log('hbdebug getRequestJsonSingle obj'+ JSON.serialize(obj));
        /*--*/SYS_debug.log('hbdebug getRequestJsonSingle mapping'+ JSON.serialize(mappings));
                
        for(FieldSetting__mdt mapping : mappings) {

            if(fieldSettingIsToBeSkipped(obj,mapping))
                continue;

            String fsLevel = (mapping.Level__c == NULL)?'0':mapping.Level__c;
            if(fsLevel == level){
                //TODO handle .'s and nested
                /*--*/SYS_debug.log('*** hbdebug getRequestJsonSingle mapping.Key__c'+ JSON.serialize(mapping.Key__c));
                List<String> nodeList = new List<String>();
                for(String node : mapping.Key__c.split('\\'+SYS_DataCache.FLAT_KEY_SEPERATOR)) {
                    if(SYS_DataCache.ESCAPE_CHAR != null) {
                        nodeList.add(node.replace(SYS_DataCache.ESCAPE_CHAR, SYS_DataCache.FLAT_KEY_SEPERATOR));
                    } else {
                        nodeList.add(node);
                    }
                }
                /*--*/SYS_debug.log('hbdebug getRequestJsonSingle nodeList'+ JSON.serialize(nodeList));
                if(nodeList.size() < 2) {
                    
                    /*--*/SYS_debug.log('hbdebug getRequestJsonSingle nodeList[0]'+ JSON.serialize(nodeList[0]));
                    /*--*/SYS_debug.log('hbdebug getRequestJsonSingle mapping.FieldApiName__c'+ JSON.serialize(mapping.FieldApiName__c));
                    
                    //TODO mapping.FieldApiName__c can be parent queries on standard/custom
                    if(mapping.FieldApiName__c==NULL){

                        /*--*/SYS_debug.log('MS PBE If 1');
                        jsonMapObject.put(nodeList[0], mapping.StaticValue__c);

                    }
                    /*
                    else if (mapping.ObjectApiName__c != mapping.ObjectSetting__r.ObjectApiName__c && mapping.Level__c =='0' ) {
                        
                        //SYS_debug.log('MS PBE If 2');
                        //SYS_debug.log('inequality executed??' + mapVal.get(obj.Id).get(mapping.ObjectApiName__c)+'obj api anme=='+mapping.ObjectApiName__c );
                        //SYS_debug.log('inequality executed??' + mapVal.get(obj.Id).get(mapping.ObjectApiName__c)[0].get(mapping.FieldApiName__c));

                        jsonMapObject.put(nodeList[0], mapVal.get(obj.Id).get(mapping.ObjectApiName__c)[0].get(mapping.FieldApiName__c));
                    }*/
                    else{
                        /*--*/SYS_debug.log('MS PBE If 3');
                        //-- SP jsonMapObject.put(nodeList[0], obj.get(mapping.FieldApiName__c));
                        String fieldMappingHandler = 'SYS_ApplicationService';
                        if(mapping.Field_Mapping_Handler__c != '' && mapping.Field_Mapping_Handler__c != NULL){
                            fieldMappingHandler = mapping.Field_Mapping_Handler__c;
                        }
                        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(fieldMappingHandler).newInstance();
                        
                        jsonMapObject.put(nodeList[0], appService.getFieldValues(obj, mapping, mapping.FieldApiName__c));
                    }
                    
                }
                else {
                    /*--*/SYS_debug.log('hbdebug getRequestJsonSingle else'+ JSON.serialize(nodeList[0]));
                    jsonMapObject = constructNestedObject(obj, mapping, nodeList, jsonMapObject);
                    /*--*/SYS_debug.log('returned json=='+jsonMapObject);
                }
            }
        }
        return jsonMapObject;
    }

    /* *************************************************************************************************************************** */
    
    public static Map<String, Object> constructNestedObject(sObject obj, FieldSetting__mdt mapping, List<String> nodeList, Map<String, Object> jsonObj) {
        
        /*--*/SYS_debug.log('hbdebug constructNestedObject obj'+ JSON.serialize(obj));
        /*--*/SYS_debug.log('hbdebug constructNestedObject mapping'+ JSON.serialize(mapping));
        /*--*/SYS_debug.log('hbdebug constructNestedObject nodeList'+ JSON.serialize(nodeList));
        /*--*/SYS_debug.log('hbdebug constructNestedObject jsonObj'+ JSON.serialize(jsonObj));
       
        if(nodeList.size() == 2) {
            
            if(jsonObj.get(nodeList[0]) == null) {
                jsonObj.put(nodeList[0], new Map<String, Object>()); 
            }
            /*--*/SYS_debug.log('node json=='+jsonObj.get(nodeList[0]));

            String fieldMappingHandler = 'SYS_ApplicationService';
            if(mapping.Field_Mapping_Handler__c != '' && mapping.Field_Mapping_Handler__c != NULL){
                fieldMappingHandler = mapping.Field_Mapping_Handler__c;
            }

            SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(fieldMappingHandler).newInstance();

            ((Map<String, Object>)jsonObj.get(nodeList[0])).put(nodeList[1], appService.getFieldValues(obj, mapping, mapping.FieldApiName__c));
            return jsonObj;
        }
        else if(nodeList.size() > 0) {
            if(jsonObj.get(nodeList[0]) == null) {
                
                List<String> nodeSubList = subList(nodeList, 1);
                Map<String, Object> intermediateJsonObj = new Map<String, Object>();
                /*--*/SYS_debug.log('inside node sublist=='+nodeSubList+ '@@==');
                intermediateJsonObj = constructNestedObject(obj, mapping, nodeSubList, new Map<String, Object>());
                jsonObj.put(nodeList[0], intermediateJsonObj);
                
            } else {
               
                Map<String, Object> intermediateJsonObj = new Map<String, Object>();
                Map<String, Object> intermediateTwoJsonObj = new Map<String, Object>();
                intermediateTwoJsonObj = (Map<String, Object>)jsonObj.get(nodeList[0]);
                /*--*/SYS_debug.log('inside node sublist else==' + ' @@==');
                intermediateJsonObj = constructNestedObject(obj, mapping, subList(nodeList, 1), intermediateTwoJsonObj);
                
                ((Map<String, Object>)jsonObj.get(nodeList[0])).put(nodeList[1], intermediateJsonObj.get(nodeList[1]));
            
            }
            
            return jsonObj;  
        }
        else {
           
            return jsonObj; 
        }
		
        //return jsonObj;
    }
    
    /* *************************************************************************************************************************** */

    /**
     * Router makes sure that if the json is List, it breaks it down and passes to this method
     * Also, each resource gets broken down - TODO see if we can enhance this.
     */

    public static List<sObject> getSObjectsToUpsert(List<String> jsonList, String resource, Boolean isNotification) {

        if(resource == NULL){
            throw new SYS_TransformerException('\nResource not identified. getSObjectsToUpsert() cannot be processed');
        }

        List<sObject> objectsToUpsert = new List<sObject>();
       
        List<FieldSetting__mdt> mappings = new List<FieldSetting__mdt>();
        Map<String, FieldSetting__mdt> mapOfPaths = new Map<String, FieldSetting__mdt>();

        /*--*/SYS_debug.log('resource=='+resource); 
        /*--*/SYS_debug.log('jsonList=='+jsonList); 
        
        for(FieldSetting__mdt item : SYS_DataCache.FieldMappingInbound) { 
            if(resource.equals(item.RestResource__c.toLowerCase()) /*&& item.ChildRootElement__c == null*/) {
                mappings.add(item);
                String newKey = (isNotification && item.Key_For_Events__c!=NULL)?item.Key_For_Events__c:item.Key__c;//--M .replace( SYS_DataCache.ESCAPE_CHAR, '.'); 
                mapOfPaths.put(newKey, item);
                /*--*/SYS_debug.log('mapof name== '+newKey + ' value==' + item.FieldApiName__c +' obj=='+item.ObjectApiName__c);
            }
        }
        for(Integer i = 0; i < mappings.size() ; i++) {
            /*--*/SYS_debug.log('Field APIs for Inbound'+mappings[i].FieldApiName__c);
        }
        
        //If the current processing is not for child records the primary object is the Object setting value
        String sObjectApiName = null; 
        if(/*!SYS_Transformer.isChild &&*/ mappings.size()>0){
            // sObjectApiName = mappings[0].ObjectSetting__r.Object__r.QualifiedAPIName;
            sObjectApiName = mappings[0].ObjectApiName__c;
            SYS_DataCache.sObjectApiName = sObjectApiName; // NOT USED
            SYS_DataCache.OBJ_TYPE = mappings[0].ObjectSetting__r.DeveloperName;
            
        }

        /*--*/SYS_debug.log('-- MS SYS_DataCache.sObjectApiName in SYS_Transformer:'+SYS_DataCache.sObjectApiName);
        //--M String sObjectApiName = null;
        SYS_DataCache.load();
        //TODO - To automate selection of integration setting
        String integrationSetting = '';  //IMS_SIU Middleware_hl7
        
        //-- SYS_Transformer.isChild = false;
        
        //TODO - refactor the below code
        String rootKey;

        for(String jsonObj : jsonList) {
            Map<String, Object> mapDeserialized = (Map<String, Object>)JSON.deserializeUntyped(jsonObj);
            rootKey = new List<String>(mapDeserialized.keySet())[0];
            /*--*/SYS_debug.log('-- MS SYS_DataCache.sObjectApiName in SYS_Transformer b4 method call:'+sObjectApiName);
            objectsToUpsert.add(parseJsonToObject(jsonObj, sObjectApiName, mapOfPaths));
        }
        
        
       	/*--*/SYS_debug.log('\n\n ########### \n Child objects to upsert:'+objectsToUpsert+'\n ########### \n\n');
        return objectsToUpsert;
    }
    
    /* *************************************************************************************************************************** */

    public static sObject parseJsonToObject(String jsonObj, String sObjectApiName, Map<String, FieldSetting__mdt> mapOfPaths) {
        Map<String, Object> flatKeyMapWithCaseSensitiveKeys = makeJsonIntoKeyValuePairs(jsonObj);

        // MS Added to avoid dependency on Casing of key in JSON [
        Map<String, Object> flatKeyMap = new Map<String,Object>();
        for(String casedKey : flatKeyMapWithCaseSensitiveKeys.keySet()){
            flatKeyMap.put(casedKey.toLowerCase(),flatKeyMapWithCaseSensitiveKeys.get(casedKey));
        }
        // MS Added to avoid dependency on Casing of key in JSON ]
        sObject sObj;
        try{
            /*--*/SYS_debug.log('SYS_DataCache.sObjectApiName in parseJsonToObject:'+sObjectApiName);
            sObj = Schema.getGlobalDescribe().get(sObjectApiName).newSObject();
        }
        catch(Exception e){
            throw new SYS_TransformerException('\nCould not identify the resource from JSON or there is no field setting for the given resource');
        }
        
        
        //We are processing array so identify obj name from flatkeymap
        if(sObjectApiName ==null && flatKeyMap.size()>0) {
            //mapOfPaths map doesn't contain outbound fieldsetting. Therefore the key to get the objectname should be a NON outbound key
            
            for(String s:flatKeyMap.keySet()){
                if(mapOfPaths.get(s)!=null){
                    if(mapOfPaths.get(s).Direction__c!='OUTBOUND'){
                        sObjectApiName =  mapOfPaths.get(s).ObjectApiName__c;            
                    }
                }
            }
            /*
            FieldSetting__mdt fieldMapping = mapOfPaths.get((new List<String>(flatKeyMap.keySet()))[0]);
            if(fieldMapping!=null)
            	sObjectApiName = fieldMapping.ObjectApiName__c;
			*/
        }
        /*--*/SYS_debug.log('\n\n++++++++++++ After sObjectApiName: '+sObjectApiName);
        
        //sObjectApiName is still empty means there are no outbound fields for the object as part of array processing
        if(sObjectApiName=='' || sObjectApiName==null) return null;
        
        
        /*--*/SYS_debug.log('flatKeyMap=='+JSON.serialize(flatKeyMap));
        /*--*/SYS_debug.log('mapofPath=='+JSON.serialize(mapOfPaths));
        for(String key : mapOfPaths.keySet()) {
            
            FieldSetting__mdt mapping = mapOfPaths.get(key);
            String fieldObj = mapping.ObjectApiName__c;
            //sObj.put('SYS_Key__c', '001');
            /*--*/SYS_debug.log('\n\nRunning for '+mapping.FieldApiName__c+' on:'+sObjectApiName + ' '+fieldObj+ 'key=='+key);
            
            if(mapping.FieldApiName__c==null){
                continue;
            }
   
            if(fieldObj == sObjectApiName /*&& !SYS_Transformer.isChild*/){

                String fieldMappingHandler = 'SYS_ApplicationService';
                if(mapping.Field_Mapping_Handler__c != '' && mapping.Field_Mapping_Handler__c != NULL){
                    fieldMappingHandler = mapping.Field_Mapping_Handler__c;
                }

                SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(fieldMappingHandler).newInstance();
                appService.processFieldMapping(mapping,sObj,flatKeyMap.get(key.toLowerCase()),sObjectApiName);

                
            } 
            
        }
        return sObj;
    }

    /* *************************************************************************************************************************** */
    
    public static Map<String, Object> makeJsonIntoKeyValuePairs(String jsonObj) {
        Object result = JSON.deserializeUntyped(jsonObj);
        Map<String, Object> flatKeyMap = new Map<String, Object>();
        /*--*/SYS_debug.log('MS Double check. in makeJsonIntoKeyValuePairs');
        if (result instanceof Map<String, Object>) {
            recursiveJsonParser((Map<String, Object>)result, new List<String>(), flatKeyMap);
        }
        return flatKeyMap;
    }

    /* *************************************************************************************************************************** */
    
    private static void recursiveJsonParser(Map<String, Object> jsonObject, List<String> parents, Map<String, Object> result) {
        /*--*/SYS_debug.log('MS Double check. jsonObject:'+jsonObject);
        
        List<String> skipKeys;
        if(SYS_DataCache.INT_TYPE != null){
            String skipKeysString = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Skip_Keys__c?.toLowerCase();
            skipKeys = skipKeysString?.split(',');
        }

        for(String key : jsonObject.keySet()) {

            /*--*/SYS_debug.log('MS ****** key:'+key);
            /*--*/SYS_debug.log('MS ****** skipKeys:'+skipKeys);

            if(skipKeys!=null && skipKeys.contains(key.toLowerCase())) continue;
            
            Object currentObj = jsonObject.get(key);
            /*--*/SYS_debug.log('##key='+key);
            if (currentObj instanceof Map<String, Object>) {
                /*--*/SYS_debug.log('MS Double check. in IF:'+currentObj);
                Map<String, Object> child = (Map<String, Object>)currentObj;
                
                parents.add(key);
                /*--*/SYS_debug.log('MS Double check. Parents:'+parents);
                recursiveJsonParser(child, parents, result);
                parents.remove(parents.size() - 1);
                /*--*/SYS_debug.log('MS Double check. Parents after:'+parents);
           
            } else {
                /*--*/SYS_debug.log('MS Double check. in else:'+currentObj);
                String parentKey = '';
                /*--*/SYS_debug.log('params=='+key+' =='+parents.size()+' res=='+result);
                if(parents.size() > 0) {
                    parentKey = String.join(parents, SYS_DataCache.FLAT_KEY_SEPERATOR);
                } 
                /*--*/SYS_debug.log('parentkey=='+parentKey + ' @@custom obj is==' +currentObj);
                if (currentObj instanceof Decimal) {
                    //Add
                	result.put(String.isBlank(parentKey) ? key : parentkey+SYS_DataCache.FLAT_KEY_SEPERATOR+ key, (Decimal) currentObj);
                } else if (currentObj instanceof Integer) {
                    //Add
                    result.put(String.isBlank(parentKey) ? key : parentkey+SYS_DataCache.FLAT_KEY_SEPERATOR+ key, (Integer) currentObj);
                }
                else if (currentObj instanceof String) {
                    //Add
                    result.put(String.isBlank(parentKey) ? key : parentkey+SYS_DataCache.FLAT_KEY_SEPERATOR+ key,  currentObj);
                } else if (currentObj instanceof Boolean) {
                    //Add
                    result.put(String.isBlank(parentKey) ? key : parentkey+SYS_DataCache.FLAT_KEY_SEPERATOR+ key, (Boolean) currentObj);
                } 
                else if (currentObj == null) {
                    //TODO - Verify accuracy on what needs to be done
                    result.put(String.isBlank(parentKey) ? key : parentkey+SYS_DataCache.FLAT_KEY_SEPERATOR+ key, null);
                }
                else if (currentObj instanceof List<Object> /*&& SYS_Transformer.isChild && key == childRootElement*/) {
                	List<String> childRecList = new List<String>();
                    //result.clear();
                    if (((List<Object>)currentObj).size() > 0) {
                        for(Object obj:(List<Object>)currentObj){
                            if(obj instanceof Map<String, Object>) {
                                /*--*/SYS_debug.log('obj list inside@@ parent=='+result);
                                // --MS recursiveJsonParser((Map<String, Object>)obj, new List<String>(), result);
                                /*--*/SYS_debug.log('result after=='+result);
                                childFlatKeyList.add(result.clone());
                                /*--*/SYS_debug.log('check**'+childFlatKeyList[0]);
                            }
                            //--MSresult.clear();
                            String objString = JSON.serialize(obj);
                            //-- MS childRecList.add('{\"'+key+'\":'+objString+'}');
                            //-- MS Root element of array is not required. The Resource field on log record
                            // will be used to identify fieldmappings
                            childRecList.add(objString);
                            
                        }
                        /*--*/SYS_debug.log('in else=='+result);
                        /*--*/SYS_debug.log('MS Child Objects to be processed:'+childRecList);
                        /*--*/SYS_debug.log('MS condition for Key: '+key+' = '+(SYS_DataCache.externalKeyByResourceMap.containsKey(key.toLowerCase())));

                        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).ApexHandler__c).newInstance();


                        SYS_DataCache.log.ObjectSettingId__c = SYS_DataCache.OBJ_TYPE;
                        //AP-106
                        if(Limits.getQueueableJobs() + 1 < Limits.getLimitQueueableJobs())
                        {
                            ID jobID = System.enqueueJob(new SYS_QueueableForInboundChild(SYS_DataCache.log,childRecList,key,SYS_DataCache.INT_TYPE));
                        }
                        else{

                            List<SYS_IntegrationLog__c> childRecordsToInsert = new List<SYS_IntegrationLog__c>();
        
                            for(String singleChildJSON : childRecList){
                                if(Limits.getDmlStatements() < Limits.getLimitDmlStatements() - 1){
                                    SYS_IntegrationLog__c newlog = appService.generateLogForChildRecords(SYS_DataCache.log,key,singleChildJSON,SYS_DataCache.INT_TYPE);
                                    newLog.Status__c = 'ENQUEUED_FOR_RETRY';
                                    newlog.Message__c = 'Out of Queue Limits. Enqueued for retry';
                                    newlog.retry__c = true;
                                    
                                    if(newlog!=NULL){
                                        childRecordsToInsert.add(newlog);
                                    }
                                }
                            }
                            if(!childRecordsToInsert.isEmpty()){
                                //appService.doDML(childRecordsToInsert, 'INSERT', '');
                                SYS_Helper.insertLog(childRecordsToInsert);
                            }
                            

                        }
                        ///*--*/SYS_debug.log('job id is==='+jobID);
                    }
                }
                
            }
            
        }
        return;
        
    }
    
    /* *************************************************************************************************************************** */
    
    public static List<String> subList(List<String> master, Integer index) {
        List<String> sList = new List<String>();
        for(Integer i = index; i < master.size(); i ++) {
            sList.add(master[i]);
        }
        return sList;
    }

    /* *************************************************************************************************************************** */

    public static Boolean fieldSettingIsToBeSkipped(sObject sobj, FieldSetting__mdt mapping){

        /*--*/SYS_debug.log('MS fieldSettingIsToBeSkipped Mapping: '+mapping+', sobj:'+sobj);
        Boolean skip = false;

        String objApiName = mapping.ObjectApiName__c;
        objApiName = objApiName != null ? objApiName.replace(SYS_DataCache.namespacePrefix,SYS_DataCache.ESCAPE_CHAR) : objApiName;


        List<FieldSetting__mdt> extIdMapping = [SELECT FieldApiName__c 
                                                    FROM FieldSetting__mdt 
                                                    WHERE ObjectSetting__c=:mapping.ObjectSetting__c 
                                                    AND Is_Active__c = true 
                                                    AND Is_External_Field__c = true
                                                    AND ObjectApiName__c =:objApiName
                                                    ];
        /*--*/SYS_debug.log('MS fieldSettingIsToBeSkipped Mapping========: '+extIdMapping+' '+mapping.ObjectSetting__c );
        if(extIdMapping.size()>0){
            String externalIdField = extIdMapping[0].FieldApiName__c;
            String mappingIsAllowedFor = mapping.Mapping_is_for__c;

            externalIdField = externalIdField != null ? externalIdField.replace(SYS_DataCache.ESCAPE_CHAR, SYS_DataCache.namespacePrefix) : externalIdField;

            
            if(mappingIsAllowedFor == NULL || mappingIsAllowedFor == 'All Records'){
                return skip;
            } 
            
            if(sobj.get(externalIdField) == NULL || sobj.get(externalIdField) == ''){
                // Record doesn't exist in External system
                if(mappingIsAllowedFor == 'Existing Records Only'){
                    skip = true;
                }
            }
            else{
                // Record exist in External system
                if(mappingIsAllowedFor == 'New Records Only'){
                    skip = true;
                }
            }
        }
        
        return skip;
        

    }
    /* *************************************************************************************************************************** */


}