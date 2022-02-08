public virtual class SYS_Transformer {
	/*
    public IntegrationData {
        sObject obj
        Map<String, Object> jsonTree;
        Map<String, Object> jsonFlatOuboundTree;
        Map<String, Object> jsonFlatInboundTree;
        Boolean shouldProcess; //if false don't process further
        IntegrationData(sObject obj) {
        
        }
        set(String key, Object value) {
        
        }
    }
    */
    
    private static Boolean childRecordsProcess = false;
    public static Boolean isChild{ 
        get{return childRecordsProcess;}
        set{childRecordsProcess = value;}
    }
    public static String childRoot = '';
    public static String childRootElement {
        get{return childRoot;}
        set{childRoot = value;}
    }
    public static List<Map<String, Object>> childFlatKeyList = new List<Map<String, Object>>();
    
    public static Map<Id, String> getRequestJson(List<sObject> objsList) {
        //This will take list of object and generate outbound JSON body
        SYS_DataCache.contextSet = objsList;
        if(objsList == null || objsList.size() == 0) {
            return null;
        }
        SObjectType objectType = objsList[0].getSObjectType();
        String primaryObj = JSON.serialize(objectType.getDescribe().getName()).replace('\"','');
        System.debug('hbdebug objectType.getDescribe().getName() '+ primaryObj);
        
        //now fetch the object and field settings
        Map<Id, String> jsonMap = new Map<Id, String>();
        
        /*
        SYS_DataCache.load(primaryObj,objsList);
        
        List<FieldSetting__mdt> mappings = SYS_DataCache.mappings;
        Map<Id, Map<String, List<sObject>>> parentChildObjMap = SYS_DataCache.parentChildObjMap;
        Map<String, List<FieldSetting__mdt>> childMappingsMap = SYS_DataCache.childMappingsMap;
        List<FieldSetting__mdt> parentMappings = SYS_DataCache.parentMappings;
        Map<String, List<String>> childFieldsMap = SYS_DataCache.childFieldsMap;
        Map<String, List<String>> primaryObjFieldsMap = SYS_DataCache.primaryObjFieldsMap;
		*/
        
        
        /*
        List<FieldSetting__mdt> mappings = [Select Id,IsChild__c, ObjectApiName__c, FieldApiName__c , Key__c, RestResource__c, Direction__c, ParentField__c, 
                                           ObjectSetting__r.Direction__c, ObjectSetting__r.ResourcePath__c , ObjectSetting__r.ApexHandler__c 
                                           from FieldSetting__mdt where ObjectSetting__r.ObjectApiName__c = :objectType.getDescribe().getName()
                                           and FieldApiName__c != null];
		*/
        
       
        // -- No longer needed as this is handled in DataCache while setting maps 
        // SYS_DataCache.ObjectContext = primaryObj;
        
        System.debug('hbdebug mappings '+ JSON.serialize(SYS_DataCache.fieldSettingMappingUsingObjSetting));
        //TODO - fix query above to remove filter on FieldApiName__c + add code for statis
        //check if there are children, query records
        

        Map<Id, Map<String, List<sObject>>> parentChildObjMap = new Map<Id, Map<String, List<sObject>>>();
        Map<String, List<FieldSetting__mdt>> childMappingsMap = new Map<String, List<FieldSetting__mdt>>();
        List<FieldSetting__mdt> parentMappings = new List<FieldSetting__mdt>();
        Map<String, List<String>> childFieldsMap = new Map<String, List<String>>();
        Map<String, List<String>> primaryObjFieldsMap = new Map<String, List<String>>();
        Map<String, String> parentObjectFieldMap = new Map<String, String>();//NOT USED anywhere
		
        
        
        for(FieldSetting__mdt mapping : SYS_DataCache.fieldSettingMappingUsingObjSetting) {
            if(mapping.FieldApiName__c == NULL) {
                if(mapping.ParentField__c != null){
                    if(childMappingsMap.get(mapping.ObjectApiName__c) == null) {
                        childMappingsMap.put(mapping.ObjectApiName__c, new List<FieldSetting__mdt>()); 
                    }
                    childMappingsMap.get(mapping.ObjectApiName__c).add(mapping);
                    System.debug(mapping.StaticValue__c+' static json##key==' + mapping.ObjectApiName__c + ' value==' +mapping);
                }
                continue;
            }
            
            System.debug('\n\n -------------- \n Object check:'+mapping.ObjectApiName__c +' vs. '+primaryObj+'\n -------------- \n\n');
            if(mapping.ObjectApiName__c == primaryObj){
                System.debug('\n\n -------------- \n Object check:'+mapping.ObjectApiName__c +' vs. '+mapping.FieldApiName__c+'\n -------------- \n\n');
                if(primaryObjFieldsMap.get(mapping.ObjectApiName__c) == null) {
                    primaryObjFieldsMap.put(mapping.ObjectApiName__c, new List<String>()); 
                }
				primaryObjFieldsMap.get(mapping.ObjectApiName__c).add(mapping.FieldApiName__c);
            }
            
            if(mapping.ParentField__c != null) {
                if(childMappingsMap.get(mapping.ObjectApiName__c) == null) {
                    childMappingsMap.put(mapping.ObjectApiName__c, new List<FieldSetting__mdt>()); 
                }
                childMappingsMap.get(mapping.ObjectApiName__c).add(mapping);
                System.debug(mapping.StaticValue__c+' static json##key==' + mapping.ObjectApiName__c + ' value==' +mapping);
                
                if(childFieldsMap.get(mapping.ObjectApiName__c) == null) {
                    childFieldsMap.put(mapping.ObjectApiName__c, new List<String>()); 
                }
				childFieldsMap.get(mapping.ObjectApiName__c).add(mapping.FieldApiName__c);
                System.debug('static jsonsecond##key==' + mapping.ObjectApiName__c + ' value==' +mapping.FieldApiName__c);
      
            } else {
                parentMappings.add(mapping);   
            }
        }
		
        System.debug('hbdebug parentMappings '+ JSON.serialize(parentMappings));
        System.debug('hbdebug childMappingsMap '+ JSON.serialize(childMappingsMap));
        System.debug('hbdebug childFieldsMap '+ JSON.serialize(childFieldsMap));
        System.debug('hbdebug primaryObjFieldsMap '+ JSON.serialize(primaryObjFieldsMap));
        
        //TODO put this behind if condition
        //now query child objects
        
        List<String> parentIds = new List<String>();
        for(sObject obj : objsList) {
        	parentIds.add((String)obj.get('Id'));
        }
		
        
        //Dynamically fetch all metadata fields for the primary object
        List<sObject> objs = new List<sObject>();
        if(primaryObjFieldsMap.size()>0){
            String qry = 'Select Id, '+ 
                     String.join(primaryObjFieldsMap.get(primaryObj), ',') +
                     ' from ' + 
                     primaryObj + 
                     ' where Id in :parentIds';
                    
            System.debug('query res@@=='+qry);
       
        	objs = Database.query(qry);
        }
        // System.debug('query res@@=='+objs[0].getSObject('Account').get('SYS_Key__c'));
         
        
        for(String objectName : childFieldsMap.keySet()) {
            String query = 'Select Id, '+ String.join(childFieldsMap.get(objectName), ',').removeEnd(',') +' from ' + objectName + ' where '+ childMappingsMap.get(objectName)[0].ParentField__c +' in :parentIds';
           	System.debug('child query=='+query);
            List<sObject> childObjects = Database.query('Select Id, '+ String.join(childFieldsMap.get(objectName), ',') + ',' +childMappingsMap.get(objectName)[0].ParentField__c +' from ' + objectName + ' where '+ childMappingsMap.get(objectName)[0].ParentField__c +' in :parentIds');
           	
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
		
        System.debug('hbdebug parentChildObjMap '+ JSON.serialize(parentChildObjMap)); 
        for(sObject obj : objs) {  //looping through quoteline
            Map<String, Object> jsonMapObject = getRequestJsonSingle(false,obj,SYS_DataCache.fieldSettingMappingUsingObjSetting, parentChildObjMap);
           System.debug('received data==' + jsonMapObject);
            String objId = (String)obj.get('Id');
            //now fill children - childMappingsMap.get(objectName)[0].
            //Map<Id, Map<String, List<sObject>>> parentChildObjMap
            if(parentChildObjMap.get(objId) != null ) {
                 for(String childObjectName : parentChildObjMap.get(objId).keySet()) { //each quoteLine from map
                    if(childMappingsMap.get(childObjectName)[0].ChildRootElement__c != null){
                        if(jsonMapObject.get(childMappingsMap.get(childObjectName)[0].ChildRootElement__c) == null) {
                        jsonMapObject.put(childMappingsMap.get(childObjectName)[0].ChildRootElement__c, new List<Map<String, Object>>()); 
                        } 
                        System.debug('hbdebug getRequestJsonSingle child - '+ childObjectName);
                    
                        for(sObject childObj : parentChildObjMap.get(objId).get(childObjectName)) {
                            System.debug('Obj added==' + getRequestJsonSingle(true,childObj, childMappingsMap.get(childObjectName) , parentChildObjMap));
                            System.debug('Obj jsonMapObject==' + jsonMapObject + ' objectKey==' + (String)childMappingsMap.get(childObjectName)[0].ChildRootElement__c);
                           ((List<Map<String, Object>>)jsonMapObject.get((String)childMappingsMap.get(childObjectName)[0].ChildRootElement__c)).add(getRequestJsonSingle(true,childObj, childMappingsMap.get(childObjectName), parentChildObjMap)); 
                            //Need to debug as line should be an array.
                        }
                    }
                }
            }
            System.debug('Obj jsonMapObject==' + jsonMapObject);
            jsonMap.put(objId, JSON.serialize(jsonMapObject));
            
        }
        return jsonMap;
    }
    
    public static Map<String, Object> getRequestJsonSingle(Boolean considerChild,sObject obj , List<FieldSetting__mdt> mappings, Map<Id, Map<String, List<sObject>>> mapVal) {
        Map<String, Object> jsonMapObject = new Map<String, Object>();
        System.debug('hbdebug getRequestJsonSingle obj'+ JSON.serialize(obj));
        System.debug('hbdebug getRequestJsonSingle mapping'+ JSON.serialize(mappings));
                
        for(FieldSetting__mdt mapping : mappings) {
            
            
            if(mapping.IsChild__c == considerChild){
                //TODO handle .'s and nested
                System.debug('*** hbdebug getRequestJsonSingle mapping.Key__c'+ JSON.serialize(mapping.Key__c));
                List<String> nodeList = new List<String>();
                for(String node : mapping.Key__c.split('\\.')) {
                    if(SYS_DataCache.ESCAPE_CHAR != null) {
                        nodeList.add(node.replace(SYS_DataCache.ESCAPE_CHAR, '.'));
                    } else {
                        nodeList.add(node);
                    }
                }
                System.debug('hbdebug getRequestJsonSingle nodeList'+ JSON.serialize(nodeList));
                if(nodeList.size() < 2) {
                    System.debug('hbdebug getRequestJsonSingle nodeList[0]'+ JSON.serialize(nodeList[0]));
                    System.debug('hbdebug getRequestJsonSingle mapping.FieldApiName__c'+ JSON.serialize(mapping.FieldApiName__c));
                    //TODO mapping.FieldApiName__c can be parent queries on standard/custom
                    if(mapping.FieldApiName__c==NULL){
                        jsonMapObject.put(nodeList[0], mapping.StaticValue__c);
                    } else if (mapping.ObjectApiName__c != mapping.ObjectSetting__r.ObjectApiName__c && mapping.IsChild__c == false) {
                        System.debug('inequality executed??' + mapVal.get(obj.Id).get(mapping.ObjectApiName__c)+'obj api anme=='+mapping.ObjectApiName__c );
                        
                        System.debug('inequality executed??' + mapVal.get(obj.Id).get(mapping.ObjectApiName__c)[0].get(mapping.FieldApiName__c));
                        jsonMapObject.put(nodeList[0], mapVal.get(obj.Id).get(mapping.ObjectApiName__c)[0].get(mapping.FieldApiName__c));
                    }
                    else {
                        jsonMapObject.put(nodeList[0], obj.get(mapping.FieldApiName__c));
                    }
                    
                }
                else {
                    System.debug('hbdebug getRequestJsonSingle else'+ JSON.serialize(nodeList[0]));
                    jsonMapObject = constructNestedObject(obj, mapping, nodeList, jsonMapObject);
                    System.debug('returned json=='+jsonMapObject);
                }
            }
        }
        return jsonMapObject;
    }
    
    public static Map<String, Object> constructNestedObject(sObject obj, FieldSetting__mdt mapping, List<String> nodeList, Map<String, Object> jsonObj) {
        
        System.debug('hbdebug constructNestedObject obj'+ JSON.serialize(obj));
        System.debug('hbdebug constructNestedObject mapping'+ JSON.serialize(mapping));
        System.debug('hbdebug constructNestedObject nodeList'+ JSON.serialize(nodeList));
        System.debug('hbdebug constructNestedObject jsonObj'+ JSON.serialize(jsonObj));
       
        if(nodeList.size() == 2) {
            
            if(jsonObj.get(nodeList[0]) == null) {
                jsonObj.put(nodeList[0], new Map<String, Object>()); 
            }
            System.debug('node json=='+jsonObj.get(nodeList[0]));

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
                System.debug('inside node sublist=='+nodeSubList+ '@@==');
                intermediateJsonObj = constructNestedObject(obj, mapping, nodeSubList, new Map<String, Object>());
                jsonObj.put(nodeList[0], intermediateJsonObj);
                
            } else {
               
                Map<String, Object> intermediateJsonObj = new Map<String, Object>();
                Map<String, Object> intermediateTwoJsonObj = new Map<String, Object>();
                intermediateTwoJsonObj = (Map<String, Object>)jsonObj.get(nodeList[0]);
                System.debug('inside node sublist else==' + ' @@==');
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
    
    //The router calls this method and it will have all relevant information
    //Router makes sure that if the json is List, it breaks it down and passes to this method
    //Also, each resource gets broken down - TODO see if we can enhance this.
    public static List<sObject> getSObjectsToUpsert(List<String> jsonList, String resource) {
        List<sObject> objectsToUpsert = new List<sObject>();
        //TODO filters based on INBOUND, OUTBOUND etc
        // List<FieldSetting__mdt> mappings = [Select Id, ChildFieldApiName__c, FieldApiName__c, ObjectApiName__c,Key__c, RestResource__c, Direction__c,
        //                                    ObjectSetting__r.Object__r.QualifiedApiName , ObjectSetting__r.Direction__c, ObjectSetting__r.ResourcePath__c , ObjectSetting__r.ApexHandler__c 
        //                                    from FieldSetting__mdt where RestResource__c = :resource and Direction__c!='OUTBOUND' AND ChildRootElement__c = null ];
        
        List<FieldSetting__mdt> mappings = new List<FieldSetting__mdt>();
        Map<String, FieldSetting__mdt> mapOfPaths = new Map<String, FieldSetting__mdt>();

        System.debug('resource=='+resource); 
        System.debug('jsonList=='+jsonList); 
        // for(Integer i = 0; i < SYS_DataCache.FieldMappingOutbound.size() ; i++) {
        //     System.debug('check--'+SYS_DataCache.FieldMappingOutbound[i].FieldApiName__c+' sd--'+resource.equals(SYS_DataCache.FieldMappingOutbound[i].RestResource__c));
            
        //     if(resource.equals(SYS_DataCache.FieldMappingOutbound[i].RestResource__c) && SYS_DataCache.FieldMappingOutbound[i].ChildRootElement__c == null) {
        //         String newKey = SYS_DataCache.FieldMappingOutbound[i].Key__c.replace( SYS_DataCache.ESCAPE_CHAR, '.'); 
        //         mappings.add(SYS_DataCache.FieldMappingOutbound[i]);
        //         mapOfPaths.put(newKey, SYS_DataCache.FieldMappingOutbound[i]);
        //         System.debug('mapof name== '+newKey + ' value==' + SYS_DataCache.FieldMappingOutbound[i].FieldApiName__c);
        //     }
        //     //-- M sObjectApiName = mapping.ObjectSetting__r.Object__r.QualifiedAPIName;
        // }
        for(FieldSetting__mdt item : SYS_DataCache.FieldMappingOutbound) { 
            if(resource.equals(item.RestResource__c) /*&& item.ChildRootElement__c == null*/) {
                mappings.add(item);
                String newKey = item.Key__c;//--M .replace( SYS_DataCache.ESCAPE_CHAR, '.'); 
                mapOfPaths.put(newKey, item);
                System.debug('mapof name== '+newKey + ' value==' + item.FieldApiName__c +' obj=='+item.ObjectApiName__c);
            }
        }
        for(Integer i = 0; i < mappings.size() ; i++) {
            System.debug('objApiname=='+mappings[i].FieldApiName__c);
        }
        
        //If the current processing is not for child records the primary object is the Object setting value
        String sObjectApiName = null; 
        if(!SYS_Transformer.isChild && mappings.size()>0){
            // sObjectApiName = mappings[0].ObjectSetting__r.Object__r.QualifiedAPIName;
            sObjectApiName = mappings[0].ObjectApiName__c;
            SYS_DataCache.sObjectApiName = sObjectApiName;
            SYS_DataCache.OBJ_TYPE = mappings[0].ObjectSetting__r.DeveloperName;
        }

        System.debug('-- MS SYS_DataCache.sObjectApiName in SYS_Transformer:'+SYS_DataCache.sObjectApiName);
        //--M String sObjectApiName = null;
        SYS_DataCache.load();
        //TODO - To automate selection of integration setting
        String integrationSetting = '';  //IMS_SIU Middleware_hl7
        SYS_Transformer.isChild = false;
        
        //TODO - refactor the below code
        String rootKey;

        /* --MS Repeated code block
        for(String jsonObj : jsonList) {
            if(jsonObj != null || jsonObj != ''){
                Map<String, Object> mapDeserialized = (Map<String, Object>)JSON.deserializeUntyped(jsonObj);
            	rootKey = new List<String>(mapDeserialized.keySet())[0];
                break;
            }
        }
        */
        
        
        for(String jsonObj : jsonList) {
            Map<String, Object> mapDeserialized = (Map<String, Object>)JSON.deserializeUntyped(jsonObj);
            rootKey = new List<String>(mapDeserialized.keySet())[0];
            System.debug('-- MS SYS_DataCache.sObjectApiName in SYS_Transformer b4 method call:'+SYS_DataCache.sObjectApiName);
            objectsToUpsert.add(parseJsonToObject(jsonObj, SYS_DataCache.sObjectApiName, mapOfPaths));
        }
        
        
       	System.debug('\n\n ########### \n Child objects to upsert:'+objectsToUpsert+'\n ########### \n\n');
        return objectsToUpsert;
    }
    
    /*************************************************** D E P R E C A T E D [ ***************************************************************/
    public static List<sObject> parseJsonToChildObject_DEPRECATED(String jsonObj, String sObjectApiName, Map<String, FieldSetting__mdt> mapOfPaths) {
        Map<String, Object> flatKeyMap = makeJsonIntoKeyValuePairs(jsonObj);
        if(SYS_Transformer.isChild){
        	System.debug('\n\n++++++++++++ flatKeyMap: '+flatKeyMap);
            System.debug('\n\n++++++++++++ mapOfPaths: '+mapOfPaths);
 	   }
        
		System.debug('\n\n++++++++++++ B4 sObjectApiName: '+sObjectApiName+' when child process is: '+SYS_Transformer.isChild);
        //We are processing array so identify obj name from flatkeymao
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
        System.debug('\n\n++++++++++++ After sObjectApiName23: '+sObjectApiName);
        
        //sObjectApiName is still empty means there are no outbound fields for the object as part of array processing
        if(sObjectApiName=='' || sObjectApiName==null) return null;

        List<sObject> objectList = new List<sObject>();
        
        // sObject sObj = Schema.getGlobalDescribe().get(sObjectApiName).newSObject();
        
        if(childRootElement != '' && SYS_Transformer.isChild) {
            System.debug('individual obj==');

            for(Map<String, Object> obj : childFlatKeyList) {
                sObject sObj = Schema.getGlobalDescribe().get(sObjectApiName).newSObject();

                for(String key : mapOfPaths.keySet()) {

                    FieldSetting__mdt mapping = mapOfPaths.get(key);
                    String fieldObj = mapping.ObjectApiName__c;
                    //sObj.put('SYS_Key__c', '001');
                    System.debug('\n\nRunning for '+mapping.ChildFieldApiName__c+' on:'+sObjectApiName + 'key=='+key);
                    System.debug('child obj=='+obj);
                    
                    if(mapping.FieldApiName__c==null){
                        
                        continue;
                    }
           
                    if(fieldObj == sObjectApiName && SYS_Transformer.isChild) {
                        SObjectType r = ((SObject)(Type.forName('Schema.'+sObjectApiName).newInstance())).getSObjectType();
                        DescribeSObjectResult d = r.getDescribe();
                        System.debug('\n\nField Type for else '+mapping.ChildFieldApiName__c+' obj=='+sObjectApiName);
                        String fieldType = d.fields
                                .getMap()
                                .get(mapping.ChildFieldApiName__c)
                                .getDescribe()
                                .getType()+'';
                        System.debug('\n\n Field Type for '+mapping.ChildFieldApiName__c+' :'+fieldType);
                        System.debug('\n flatmapchild=='+obj.get(key));
                        //TODO add other field types

                        if(fieldType=='DATE'){
                            try{
                                sObj.put(mapping.ChildFieldApiName__c, date.valueOf((String)obj.get(key)));
                            }catch(Exception e){
                                
                            }
                        } else if (fieldType == 'MULTIPICKLIST') { //TODO
                            Object listValues = obj.get(key);
                            if(listValues instanceof List<Object>) {
                                  
                            }
                        } else if (mapping.ChildFieldApiName__c == 'Is_Taxable__c') {
                            sObj.put(mapping.ChildFieldApiName__c, String.valueof(obj.get(key)) == 'TAX' ? true : false);
                        }
                        else if (fieldType == 'STRING') {
                            sObj.put(mapping.ChildFieldApiName__c, String.valueof(obj.get(key)));
                        }
                        else{
                            sObj.put(mapping.ChildFieldApiName__c, obj.get(key));
                        }
                    }
                }
                objectList.add(sObj);
            }
        }
        return objectList;
    }
    /*************************************************** D E P R E C A T E D ] ***************************************************************/
    //

    public static sObject parseJsonToObject(String jsonObj, String sObjectApiName, Map<String, FieldSetting__mdt> mapOfPaths) {
        Map<String, Object> flatKeyMap = makeJsonIntoKeyValuePairs(jsonObj);
        System.debug('SYS_DataCache.sObjectApiName in parseJsonToObject:'+SYS_DataCache.sObjectApiName);
        sObject sObj = Schema.getGlobalDescribe().get(SYS_DataCache.sObjectApiName).newSObject();
        if(SYS_Transformer.isChild){
        	System.debug('\n\n++++++++++++ flatKeyMap: '+flatKeyMap);
            System.debug('\n\n++++++++++++ mapOfPaths: '+mapOfPaths);
 	   }
        
		System.debug('\n\n++++++++++++ B4 sObjectApiName: '+sObjectApiName+' when child process is: '+SYS_Transformer.isChild);
        //We are processing array so identify obj name from flatkeymao
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
        System.debug('\n\n++++++++++++ After sObjectApiName: '+sObjectApiName);
        
        //sObjectApiName is still empty means there are no outbound fields for the object as part of array processing
        if(sObjectApiName=='' || sObjectApiName==null) return null;
        
        
        System.debug('flatKeyMap=='+JSON.serialize(flatKeyMap));
        System.debug('mapofPath=='+JSON.serialize(mapOfPaths));
        for(String key : mapOfPaths.keySet()) {
            
            FieldSetting__mdt mapping = mapOfPaths.get(key);
            String fieldObj = mapping.ObjectApiName__c;
            //sObj.put('SYS_Key__c', '001');
            System.debug('\n\nRunning for '+mapping.FieldApiName__c+' on:'+sObjectApiName + ' '+fieldObj+ 'key=='+key);
            
            if(mapping.FieldApiName__c==null){
                continue;
            }
   
            if(fieldObj == sObjectApiName && !SYS_Transformer.isChild){

                String fieldMappingHandler = 'SYS_ApplicationService';
                if(mapping.Field_Mapping_Handler__c != '' && mapping.Field_Mapping_Handler__c != NULL){
                    fieldMappingHandler = mapping.Field_Mapping_Handler__c;
                }

                SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(fieldMappingHandler).newInstance();
                appService.processFieldMapping(mapping,sObj,flatKeyMap.get(key),sObjectApiName);

                
            } 
            
        }
        return sObj;
    }
    
    public static Map<String, Object> makeJsonIntoKeyValuePairs(String jsonObj) {
        Object result = JSON.deserializeUntyped(jsonObj);
        Map<String, Object> flatKeyMap = new Map<String, Object>();
        System.debug('MS Double check. in makeJsonIntoKeyValuePairs');
        if (result instanceof Map<String, Object>) {
            recursiveJsonParser((Map<String, Object>)result, new List<String>(), flatKeyMap);
        }
        return flatKeyMap;
    }
    
    private static void recursiveJsonParser(Map<String, Object> jsonObject, List<String> parents, Map<String, Object> result) {
        System.debug('MS Double check. jsonObject:'+jsonObject);
        for(String key : jsonObject.keySet()) {
            Object currentObj = jsonObject.get(key);
            System.debug('##key='+key);
            if (currentObj instanceof Map<String, Object>) {
                System.debug('MS Double check. in IF:'+currentObj);
                Map<String, Object> child = (Map<String, Object>)currentObj;
                
                parents.add(key);
                System.debug('MS Double check. Parents:'+parents);
                recursiveJsonParser(child, parents, result);
                parents.remove(parents.size() - 1);
                System.debug('MS Double check. Parents after:'+parents);
           
            } else {
                System.debug('MS Double check. in else:'+currentObj);
                String parentKey = '';
                System.debug('params=='+key+' =='+parents.size()+' res=='+result);
                if(parents.size() > 0) {
                    parentKey = String.join(parents, '.');
                } 
                System.debug('parentkey=='+parentKey + ' @@custom obj is==' +currentObj);
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
                else if (currentObj instanceof List<Object> /*&& SYS_Transformer.isChild && key == childRootElement*/) {
                	List<String> childRecList = new List<String>();
                    //result.clear();
                    if (((List<Object>)currentObj).size() > 0) {
                        for(Object obj:(List<Object>)currentObj){
                            if(obj instanceof Map<String, Object>) {
                                System.debug('obj list inside@@ parent=='+result);
                                // --MS recursiveJsonParser((Map<String, Object>)obj, new List<String>(), result);
                                System.debug('result after=='+result);
                                childFlatKeyList.add(result.clone());
                                System.debug('check**'+childFlatKeyList[0]);
                            }
                            //--MSresult.clear();
                            String objString = JSON.serialize(obj);
                            //-- MS childRecList.add('{\"'+key+'\":'+objString+'}');
                            //-- MS Root element of array is not required. The Resource field on log record
                            // will be used to identify fieldmappings
                            childRecList.add(objString);
                            
                        }
                        System.debug('in else=='+result);
                        System.debug('MS Child Objects to be processed:'+childRecList);
                        
                        //24 jan 2022
                        
                        ID jobID = System.enqueueJob(new SYS_QueueableForInboundChild(SYS_DataCache.log,childRecList,key,SYS_DataCache.INT_TYPE));
                        //System.debug('job id is==='+jobID);
                    }
                }
                
            }
            
        }
        return;
        
    }
    
    
    
    public static List<String> subList(List<String> master, Integer index) {
        List<String> sList = new List<String>();
        for(Integer i = index; i < master.size(); i ++) {
            sList.add(master[i]);
        }
        return sList;
    }
}