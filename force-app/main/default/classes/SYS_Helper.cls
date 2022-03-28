global class SYS_Helper {

    /* ------------------------------------------------------------------------ */

    global static Datetime secondsToDatetime(String expiry){
        return secondsToDatetime(Integer.valueOf(expiry));
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
        System.debug('MS Date time:'+inpputString);
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
    global static String getAllFieldsFor(String objName){

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

    global static String getDataFrom(SYS_IntegrationLog__c log){
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


    /* ------------------------------------------------------------------------ */

    global static List<String> getJSONChunckedValues(String body){
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

    global static void logException(SYS_IntegrationLog__c log,String stackTrace){
        //log.Type__c = 'EXCEPTION';

        flagLogForRetry(log.Id);
        
        log.Status__c = 'FAIL';
        log.Message__c = stackTrace;
        
        upsert log;
    }

    @future
    global static void flagLogForRetry(Id logId){
        if(logId!=NULL){
            SYS_IntegrationLog__c log = new SYS_IntegrationLog__c(Id=logId);
            log.retry__c = true;
            update log;
        }else{
            //TODO - How to update the log record?
        }
    }

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
        open = open.replace('_', SYS_DataCache.FLAT_KEY_SEPERATOR);
        close = close.trim();
        System.debug('*********** open:'+open+' '+'close:'+close);

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
                    parentKey = String.join(parents, SYS_DataCache.FLAT_KEY_SEPERATOR);
                }

                String resultKey = String.isBlank(parentKey) ? key : parentkey + open + key + close;

                if(pattern == 'A[B]'){
                    for(Integer i=0; i < parentKey.countMatches(SYS_DataCache.FLAT_KEY_SEPERATOR); i++){
                        resultKey+= close;
                    }
    
                    resultKey = resultKey.replace(SYS_DataCache.FLAT_KEY_SEPERATOR, open);
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
                            /*
                            parents.add(key+'[]');
                            recursiveJsonParser(new Map<String, Object>{key+'[]'=>childArray[i]}, parents, result,pattern);
                            parents.remove(parents.size() - 1);
                            */
                            //TODO Handle keys of type "key": ["value1", "value2"];
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
}