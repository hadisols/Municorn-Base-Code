//This class is maily used for overriding the methods in the sys application service 
//for inbound processing from webhook 
public class SYS_QB_ApplicationServiceinbound extends SYS_ApplicationService {
    public SYS_QB_ApplicationServiceinbound() {
 }
    //when we removed the root key it not returing the restresorce that path so it not identifying the sobject so thats why 
    //we overriden the get resource method for identifying the ecaxt resource path 

  /**
     * This hook is called from doInbound to identify resource from incoming JSON
     * Arguement: SYS Log record and JSON Body
     * Default is return the root if it exists or the value of falt key mentioned in Flat_Key_for_Resource__c field on log record
     * Override if custom implementation is required for identifying the resoruce for inbound request
     */
    public override  List<sObject> transformJsonToSObject(String jsonBody,String resource,SYS_IntegrationLog__c log) {
        Object responseType = JSON.deserializeUntyped(jsonBody);
       
        Object JSONwithoutrootkey;
        if(SYS_DataCache.log.Parent__c==Null){
        if(responseType instanceof Map<String,Object>){
            JSONwithoutrootkey = (((Map<String, Object>)responseType).values())[0];
           
            //((Map<String, Object>)responseType).get(JSONForUpsert);
            jsonBody = JSON.serialize(JSONwithoutrootkey);
             
        }

    }
  
  
     
      List<sObject> sobjlist=  SYS_Transformer.getSObjectsToUpsert(new List<String>{jsonBody},resource,(log.Type__c=='INBOUND'));
     
     
      
        return sobjlist;
    
    }
    
   }