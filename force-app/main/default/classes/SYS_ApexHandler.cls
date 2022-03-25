public virtual class SYS_ApexHandler extends SYS_Transformer {

    public static List<sObject> convertJSONToSObjects(List<String> jsonList, String resource) {
        List<sObject> objects = getSObjectsToUpsert(jsonList , resource);
        return objects;
    }
    /** 
    public static List<sObject> convertJSONToChildSObjects(List<String> jsonList, String resource) {
        List<sObject> objectsToUpsert = new List<sObject>();
        //TODO filters based on INBOUND, OUTBOUND etc
        // List<FieldSetting__mdt> mappings = [Select Id,ChildFieldApiName__c, IsChild__c	, ChildRootElement__c, FieldApiName__c, ObjectApiName__c,Key__c, RestResource__c, Direction__c,
        //                                    ObjectSetting__r.Object__r.QualifiedApiName , ObjectSetting__r.Direction__c, ObjectSetting__r.ResourcePath__c , ObjectSetting__r.ApexHandler__c 
        //                                    from FieldSetting__mdt where RestResource__c = :resource and Direction__c!='OUTBOUND' AND IsChild__c = true];
        List<FieldSetting__mdt> mappings = new List<FieldSetting__mdt>();
        for(FieldSetting__mdt item : SYS_DataCache.FieldMappingOutbound) { 
            if(resource.equals(item.RestResource__c) && item.IsChild__c == true) {
                mappings.add(item);
                String newKey = item.Key__c.replace( SYS_DataCache.ESCAPE_CHAR, '.'); 
                // mapOfPaths.put(newKey, item);
                // SYS_debug.log('mapof name== '+newKey + ' value==' + item.FieldApiName__c +' obj=='+item.ObjectApiName__c);
            }
        }
        Map<String, FieldSetting__mdt> mapOfPaths = new Map<String, FieldSetting__mdt>();
        
        //If the current processing is not for child records the primary object is the Object setting value
        String sObjectApiName = null;
        //--M String sObjectApiName = null;
        SYS_DataCache.load();
        
        //TODO - refactor the below code
        String rootKey;
        for(String jsonObj : jsonList) {
            if(jsonObj != null || jsonObj != ''){
                Map<String, Object> mapDeserialized = (Map<String, Object>)JSON.deserializeUntyped(jsonObj);
            	rootKey = new List<String>(mapDeserialized.keySet())[0];
                break;  
            }
        } 
        for(FieldSetting__mdt mapping : mappings) {
            String newKey = mapping.Key__c;
            if(mapping.ChildRootElement__c != null)
                SYS_Transformer.childRootElement = mapping.ChildRootElement__c;
            mapOfPaths.put(newKey, mapping);
            SYS_debug.log('key==='+ mapping.Key__c + ' value===' + mapping);
            sObjectApiName = mapping.ObjectSetting__r.Object__r.QualifiedAPIName;
        }
        sObjectApiName = 'OpportunityLineItem';
        SYS_Transformer.isChild = true;
        SYS_debug.log('Mychanges');
        for(String jsonObj : jsonList) {
            Map<String, Object> mapDeserialized = (Map<String, Object>)JSON.deserializeUntyped(jsonObj);
            rootKey = new List<String>(mapDeserialized.keySet())[0];
            objectsToUpsert.addAll(parseJsonToChildObject(jsonObj, sObjectApiName, mapOfPaths));
        }
        
        
       	SYS_debug.log('\n\n ########### \n Child objects to upsert:'+objectsToUpsert+'\n ########### \n\n');
        return objectsToUpsert;
    }

    public static List<sObject> getSingleSobjectsToUpsert(String jsonList, String resource) {
        List<sObject> objects = getSObjectsToUpsert(new List<String>{jsonList} , resource);
        system.debug('******* '+objects);
        return objects;
    }

    public static List<sObject> getSobjectsToUpsert_QB(List<String> jsonList, String resource) {
        List<sObject> objects = getSObjectsToUpsert(jsonList , resource);
        return objects;
    }

    public static List<sObject> getSingleSobjectsToUpsert_QB(String jsonList, String resource) {
        List<sObject> objects = getSObjectsToUpsert(new List<String>{jsonList} , resource);
        return objects;
    }
    */

    // public static List<sObject> getSObjectsToUpsertChildQB(List<String> jsonList, String resource) {  
    //     List<sObject> objectsToUpsert = new List<sObject>();
    //     //TODO filters based on INBOUND, OUTBOUND etc
    //     List<FieldSetting__mdt> mappings = [Select Id,ChildFieldApiName__c, IsChild__c	, ChildRootElement__c, FieldApiName__c, ObjectApiName__c,Key__c, RestResource__c, Direction__c,
    //                                        ObjectSetting__r.Object__r.QualifiedApiName , ObjectSetting__r.Direction__c, ObjectSetting__r.ResourcePath__c , ObjectSetting__r.ApexHandler__c 
    //                                        from FieldSetting__mdt where RestResource__c = :resource and Direction__c!='OUTBOUND' AND IsChild__c = true];
        
    //     Map<String, FieldSetting__mdt> mapOfPaths = new Map<String, FieldSetting__mdt>();
        
    //     //If the current processing is not for child records the primary object is the Object setting value
    //     String sObjectApiName = null;
    //     //--M String sObjectApiName = null; 
    //     SYS_DataCache.load();
        
    //     //TODO - refactor the below code
    //     String rootKey;
    //     for(String jsonObj : jsonList) {
    //         if(jsonObj != null || jsonObj != ''){
    //             Map<String, Object> mapDeserialized = (Map<String, Object>)JSON.deserializeUntyped(jsonObj);
    //         	rootKey = new List<String>(mapDeserialized.keySet())[0];
    //             break;
    //         }
    //     }
    //     for(FieldSetting__mdt mapping : mappings) {
    //         String newKey = mapping.Key__c;
    //         if(mapping.ChildRootElement__c != null)
    //             SYS_Transformer.childRootElement = mapping.ChildRootElement__c;
    //         mapOfPaths.put(newKey, mapping);
    //         SYS_debug.log('key==='+ mapping.Key__c + ' value===' + mapping);
    //         if(mapping.IsChild__c) {
    //             sObjectApiName = mapping.ObjectApiName__c; 

    //         }
    //     }
    //     // sObjectApiName = 'SBQQ__QuoteLine__c';
    //     SYS_Transformer.isChild = true;
    //     SYS_debug.log('Mychanges');
    //     for(String jsonObj : jsonList) {
    //         Map<String, Object> mapDeserialized = (Map<String, Object>)JSON.deserializeUntyped(jsonObj);
    //         rootKey = new List<String>(mapDeserialized.keySet())[0];
    //         objectsToUpsert.addAll(parseJsonToChildObject(jsonObj, sObjectApiName, mapOfPaths));
    //     }
        
        
    //    	SYS_debug.log('\n\n ########### \n Child objects to upsert:'+objectsToUpsert+'\n ########### \n\n');
    //     return objectsToUpsert;
    // }
}