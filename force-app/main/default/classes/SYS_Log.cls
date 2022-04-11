public without sharing class SYS_Log{

    public class SYS_LogException extends Exception{}

    private static SYS_Log thisLog;
    private SYS_IntegrationLog__c log;
    public static SYS_Log getReference(SYS_IntegrationLog__c log){
        if(thisLog==null)
            thisLog = new SYS_Log();

        if(thisLog.log == NULL){
            thisLog.log = log;
        }
        return thisLog;
    }
    
    private Map<String, Schema.sObjectField> fm;
    public Map<String, Schema.sObjectField> fieldMap{

        get{
            
            if(fm == NULL){
                fm = log.getsObjectType().getDescribe().fields.getMap();
                /*#*/SYS_debug.log('\n\n---------------------- fm:'+fm);
            }
            return fm;
        }
    }

    public void setValue(String field,String value){

        Schema.DescribeSObjectResult dsr = SYS_IntegrationLog__c.sObjectType.getDescribe();
        String namespace = dsr.getName().remove(dsr.getLocalName());

        /*#*/SYS_debug.log('\n\n----------------------'+fieldMap.get(namespace+field));


        if(fieldMap.get(namespace+field).getDescribe().isCreateable()){
            log.put(namespace+field,value);
        }
        else{
            throw new SYS_LogException('\nSYS_LogException: Log cannot be created/updated. Field: '+field+' is missing permission');
        }
        

    }
}