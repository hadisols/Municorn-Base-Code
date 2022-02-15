public class SYS_Helper {

    /* ------------------------------------------------------------------------ */
    public static String getAllFieldsFor(String objName){

        List<String> fields = new List<String>();
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objName).getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            Schema.DescribefieldResult field = sfield.getDescribe();
            fields.add(field.getname());
        }

        return (String.join(fields,', '));
    }

    public static String getDataFrom(SYS_IntegrationLog__c log){
        String data='';
        for(Integer i=0;i<10;i++){
            if(log.get('data'+i+'__c')!=NULL){
                data+=log.get('data'+i+'__c');
            }
            else{
                break;
            }
            
        }
        return  data;
        
    }


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
    
    public static void recursiveJsonParser(Map<String, Object> jsonObject, List<String> parents, Map<String, Object> result) {
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
}
