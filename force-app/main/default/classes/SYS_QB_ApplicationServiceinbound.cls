//This class is maily used for overriding the methods in the sys application service 
//for inbound processing from webhook 
public class SYS_QB_ApplicationServiceinbound extends SYS_ApplicationService {
    public SYS_QB_ApplicationServiceinbound() {
 }
    public static final Map<String,String> resourceChildMap = new Map<String,String>{'invoice'=>'line','refundreceipt'=>'salesitemlinedetail','bill'=>'billline','estimate'=>'estimateline',
    'purchase'=>'purchaseline','salesreceipt'=>'salesreceiptline','vendorcredit'=>'vendorcreditline','creditmemo'=>'creditmemoline','deposit'=>'depositline','billpayment'=>'billpaymentline','payment'=>'paymentline'};
   
    // give that response and return the syslog 
   
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
        system.debug('jsonBody+++===**'+jsonBody);
        Object JSONwithoutrootkey;
        if(SYS_DataCache.log.Parent__c==Null){
        if(responseType instanceof Map<String,Object>){
            JSONwithoutrootkey = (((Map<String, Object>)responseType).values())[0];
            system.debug('JSONForUpsert+++'+JSONwithoutrootkey);
            //((Map<String, Object>)responseType).get(JSONForUpsert);
            jsonBody = JSON.serialize(JSONwithoutrootkey);
              system.debug('jsonBody++++===='+jsonBody);
        }

    }
  
  
      system.debug('jsonBody++++===='+jsonBody);
      List<sObject> sobjlist=  SYS_Transformer.getSObjectsToUpsert(new List<String>{jsonBody},resource,(log.Type__c=='INBOUND'));
     
      system.debug('sobjlist+++++=='+sobjlist);
      
        return sobjlist;
    
    }
    public override SYS_IntegrationLog__c generateLogForChildRecords(String parentLogId,String resource,String recordsJson,String integrationSetting) {
           
      String query = 'SELECT '+SYS_Helper.getAllFieldsFor('SYS_IntegrationLog__c')+', Parent__r.WhatId__c, Parent__r.SYS_Operation_Type__c FROM SYS_IntegrationLog__c';
      String whereClause = ' WHERE Id in (' + '\'' + String.escapeSingleQuotes(parentLogId) + '\')';
      List<SYS_IntegrationLog__c> parentLog = 
     Database.query(String.escapeSingleQuotes(query)+whereClause);
     parentLog = 
     Database.query(String.escapeSingleQuotes(query)+whereClause);
      SYS_IntegrationLog__c log = SYS_Helper.getLogsToInsert(recordsJson);

      log.ObjectSettingId__c = SYS_DataCache.OBJ_TYPE;
      system.debug('log.ObjectSettingId__c'+parentLog[0].municonqb__Resource__c);
      system.debug('log++++++'+parentLog[0]);
      /* ------------------------------------ FOR ALL OR NONE HANDLING -------------------------------------- */
      if(log.ObjectSettingId__c!=NULL && SYS_DataCache.objectSettingMap.get(log.ObjectSettingId__c).All_OR_None__c){
          //log.Custom_Field_Value__c = parentLog[0].WhatId__c;
          log.SYS_Operation_Type__c = 'INSERT';
      }
      else {
          log.SYS_Operation_Type__c = 'UPSERT';
      }
      /* ------------------------------------ FOR ALL OR NONE HANDLING -------------------------------------- */

      String algo = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Hashing_Algo__c;
      if(algo!=NULL && algo!='')
          log.Request_Digest__c = generateHash(recordsJson,algo);

      SYS_debug.log('MS SYS_DataCache.log in generate child log:'+SYS_DataCache.log.Id);
      log.Parent__c = parentLogId;       
      log.Type__c = 'INBOUND';

      /**
       * If there the Parent Resource Map is defined on IS the use it to derive the resource for child records else
       * If Flat key to identify resource for child records is defined on Integration Setting, consider that
       * Else take the root key as Resource that is passed on while processing parent record
       */
      String flat_key_for_child = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Flat_Key_for_Resource_Child__c;

      if(SYS_DataCache.PARENT_RESOURCE_MAP != NULL){
          system.debug('SYS_DataCache.PARENT_RESOURCE_MAP'+SYS_DataCache.PARENT_RESOURCE_MAP.size());
          log.Resource__c = SYS_DataCache.PARENT_RESOURCE_MAP.get(SYS_DataCache.log.Resource__c);
          system.debug('municonqb__Resource__c++++----'+SYS_DataCache.log.Resource__c);
          system.debug('parentLog[0].municonqb__Resource__c'+parentLog[0].municonqb__Resource__c);
          system.debug('parentLog[0].Resource__c'+parentLog);
          system.debug('log.Resource__c++==---'+log.Resource__c);
      }
      else if(flat_key_for_child != NULL && flat_key_for_child!='')
          log.Flat_Key_for_Resource__c = flat_key_for_child;
      else{
          log.Resource__c = resource;
          log.Flat_Key_for_Resource__c = '';
      }
      log.Integration_Setting__c = integrationSetting;
      log.Status__c = 'NEW';
      /**
       * Applies when the child records require parenting after creation
       */
      log.Requires_process_on_complete__c = true;
      log.On_Complete_Handler__c = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).ApexHandler__c;
      /** */

      log.How_to_process__c = 'use_custom_apex_handler';
      log.Custom_Apex_Handler__c = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).ApexHandler__c;

      return log;
  }
   }