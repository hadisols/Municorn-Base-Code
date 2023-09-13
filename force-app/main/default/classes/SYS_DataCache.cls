public class SYS_DataCache {
	private static Map<Id, sObject> oldObjMap = new Map<Id, sObject>();
    private static Map<Id, sObject> newObjMap = new Map<Id, sObject>();
    private static Map<String, List<FieldSetting__mdt>> ObjectSettingToFieldSettingsMap_OB;
    private static Map<String, List<FieldSetting__mdt>> ObjectSettingToFieldSettingsMap_IB;

    private static Map<String, Map<String, List<FieldSetting__mdt>>> childFieldSettingMap; // NOT USED
    private static List<FieldSetting__mdt> AllFieldSettingsList;

    private static SYS_IntegrationLog__c sysLog;
    public static SYS_IntegrationLog__c log{
        get{
            if(sysLog==NULL){
                sysLog = new SYS_IntegrationLog__c();
            }
            return sysLog;
        }
        set{
            sysLog = value;
        }
        
    }

    //NOT USED
    /*
    private static Map<String,ObjectSetting__mdt> objectSettingsMapVar;
    public static Map<String,ObjectSetting__mdt> objectSettingsMap{
        get{
            if(objectSettingsMapVar == NULL){
                objectSettingsMapVar = ObjectSetting__mdt.getAll();
            }
            return objectSettingsMapVar;
        }
 
    }
    */



    //Extension for Webhook extension
    private static String extension;
    public static String getExtension{
        get{
            if(extension==NULL || extension==''){
                RestRequest req = RestContext.request;
                System.debug('uri =='+ req.requestURI);
                String intSettingFromUrl = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
                INT_TYPE = intSettingFromUrl;
                System.debug('MS Stripe extension check:'+integrationSetting);
                String extFromUrl = integrationSetting.get(INT_TYPE).ApexHandler__c;
                System.debug('\nintegrationSetting.get(INT_TYPE):'+integrationSetting.get(INT_TYPE));
                System.debug('\nApexHandler__c:'+integrationSetting.get(INT_TYPE).ApexHandler__c);
                if(extFromUrl != '' && extFromUrl != NULL){
                    extension = extFromUrl;
                }
                else{
                    extension = 'SYS_ApplicationService';
                }
            }
            return extension;
        }
        
    }
    
    //TODO - HB -  Fill the objectsettings 
    private static ObjectSetting__mdt objectSetting;

    
    //TODO - 'Account' is hardcoded
    private static String context;
    
    //NOT USED
    /*
    public static String ObjectContext{ 
        get{ return context;}
        //set{context = value;}
    }
    */

    /******* NEW VARIABLES START*******/

    public static String INT_TYPE;
    public static String OBJ_TYPE;

    public static Map<String,String> PARENT_RESOURCE_MAP{
        get{
            String resourceMapString = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Parent_Resource_Map__c;
            if(resourceMapString != NULL){
                List<String> kvPair = resourceMapString.split('\n');
                Map<String,String> parentResourceMap = new Map<String,String>();
                for(String kv:kvPair){
                        parentResourceMap.put(kv.split(':')[0],kv.split(':')[1]);

                }
                return parentResourceMap;
            }
            else{
                return null;
            }
        }
    }

    public static String FLAT_KEY_SEPERATOR{
        get{
            if(INT_TYPE != NULL){
                return 
                (integrationSetting.get(INT_TYPE).Flat_Key_Separator__c!=NULL)?integrationSetting.get(INT_TYPE).Flat_Key_Separator__c:'.';
            }
            else{
                return '.';
            }
        }

    }

    public static String FLAT_KEY_PATTERN{
        get{
            if(INT_TYPE != NULL){
                return 
                (integrationSetting.get(INT_TYPE).Flat_Key_Pattern__c!=NULL)?integrationSetting.get(INT_TYPE).Flat_Key_Pattern__c:'A_B';
            }
            else{
                return 'A_B';
            }
        }
    }
    
    
    private static Map<String, String> external_key;
    public static Map<String, String> externalKeyByResourceMap {
        get {
            if(external_key == null) {
                external_key = new Map<String, String>();
                for(FieldSetting__mdt fs : FieldMappingInbound){
                    if(fs.Is_External_Field__c) {
                        external_key.put(fs.RestResource__c,fs.FieldApiName__c);
                        external_key.put(fs.RestResource__c.toLowerCase(),fs.FieldApiName__c);
                    }
                }
            }
            return external_key;
        }
    }

    

    private static Map<String, String> external_key_by_obj;
    public static Map<String, String> externalKeyByObject {
        get {
            if(external_key_by_obj == null) {
                external_key_by_obj = new Map<String, String>();
                for(FieldSetting__mdt fs : AllFieldSettingMappings){
                    if(fs.Is_External_Field__c && fs.ObjectSetting__r.DeveloperName == SYS_DataCache.OBJ_TYPE)
                    external_key_by_obj.put(fs.ObjectApiName__c.toLowerCase(),fs.FieldApiName__c.toLowerCase());
                }
            }
            return external_key_by_obj;
        }
    }

    /******* NEW VARIABLES END*********/
	
    //TODO - add a method checkAndLoad , called from every getter, single query on grand child and get 
    //all meta data records from 
    //grand-parents, parents and do the maps.
    
    public static List<sObject> sObjList = new List<sObject>();

    //NOT USED
    /*
    public static List<sObject> contextSet{
        set{
            sObjList = value;
            if(sObjList!=NULL && sObjList.size()>0){
                SObjectType objectType = sObjList[0].getSObjectType();
                context = JSON.serialize(objectType.getDescribe().getName()).replace('\"','');
            }
        }
    }
    */
    
    
     /* NOT USED
    public static Map<Id, sObject> oldMap{
        get{ return oldObjMap;}
        set{
            oldObjMap = value;
            
            if(oldObjMap!=NULL && oldObjMap.size()>0){
                SObjectType objectType = oldObjMap.values()[0].getSObjectType();
                context = JSON.serialize(objectType.getDescribe().getName()).replace('\"','');
            }
            
        }
    }
    */
    
    
    
    /* NOT USED
    public static Map<Id, sObject> newMap{
        get{ return newObjMap;}
        set{
            newObjMap = value;
            
            if(newObjMap!=NULL && newObjMap.size()>0){
                SObjectType objectType = newObjMap.values()[0].getSObjectType();
                context = JSON.serialize(objectType.getDescribe().getName()).replace('\"','');
            }
            
        }
    }
    */
    


    public static Map<String,IntegrationSetting__mdt> intMap;
    public static Map<String,IntegrationSetting__mdt> integrationSetting {
        get{
            if(intMap == null){
                intMap = new Map<String,IntegrationSetting__mdt>();
                for(IntegrationSetting__mdt is : IntegrationSetting__mdt.getAll().values() /*[SELECT Id,OAuth_Config_Record_Id__c,Flat_Key_for_Resource_Child__c,Flat_Key_for_Resource_Response__c, Flat_Key_for_Resource__c,Hashing_Algo__c,ApexHandler__c,webhookToken__c, DeveloperName, Label, UpdateMethod__c, DebugCheck__c,
                                     AuthenticationType__c, BaseAPIEndPoint__c, 
                                     QualifiedApiName, EscapeCharacter__c FROM IntegrationSetting__mdt 
                                     LIMIT 100]*/){

                    intMap.put(is.DeveloperName,is);

                }
            }
            return intMap;
        }
    }
    public static List<HttpHeaders__mdt> headerMetadata;
    public static List<HttpHeaders__mdt> headerSetting{
        get{
            if(headerMetadata == null){
                headerMetadata = new List<HttpHeaders__mdt>();
                headerMetadata = [SELECT Id, MasterLabel, Label, IntegrationType__c, Value__c,header_name__c 
                                    FROM HttpHeaders__mdt 
                                    WHERE IntegrationType__c =:(integrationSetting.get(INT_TYPE)).id];
            }
            System.debug('header=='+ headerMetadata);
            return headerMetadata;
        }
    }
    // TODO - add flatkey map in datacache...
    // public static Map<String, Object> flatKey;
    // public static Map<String, Object> flatKeyMap {
    //     get{
    //         if(flatKey == null) {
    //             // SYS_Transformer_IMS.makeJsonIntoKeyValuePairs()
    //         }
    //     }
    // }

    
    public static List<FieldSetting__mdt> AllFieldSettingMappings{
        get{
            if(AllFieldSettingsList == null){
                AllFieldSettingsList = new List<FieldSetting__mdt>();
                
                AllFieldSettingsList = [Select Id,developerName, Order_Number__c, Datetime_Conversion_Format__c,Send_Blanks_as_Empty_String__c,Mapping_is_for__c,Key_For_Events__c,Level__c,Log_API_for_field_mapping__c, Lookup_External_Key__c, Lookup_Object_API_Name__c,Is_External_Field__c,Is_Lookup__c, Get_value_from_Log__c,ChildFieldApiName__c,ObjectSetting__r.DeveloperName,masterlabel,Field_Mapping_Handler__c, ObjectSetting__r.masterlabel , StaticValue__c,IsChild__c, ObjectSetting__r.ObjectApiName__c, ObjectApiName__c, FieldApiName__c , Key__c, RestResource__c, Direction__c, ParentField__c, ChildRootElement__c,
                            ObjectSetting__r.Direction__c,ObjectSetting__r.Trigger_Condition__c,ObjectSetting__r.TriggerEvents__c, ObjectSetting__r.ResourcePath__c,ObjectSetting__r.url_params__c , ObjectSetting__r.ApexHandler__c, ObjectSetting__r.IntegrationType__r.DeveloperName , Skip_Field_Setting__c,
                            ObjectSetting__r.IntegrationType__r.EscapeCharacter__c
                            from FieldSetting__mdt WHERE Is_Active__c=true ORDER BY Order_Number__c ASC
                           /* AND ObjectSetting__r.IntegrationType__r.developername = : SYS_DataCache.INT_TYPE AND Direction__c != SYS_Constants.INBOUND*/];
                
                for(FieldSetting__mdt item : AllFieldSettingsList) {
                    
                    SYS_Helper.setNamespacePrefix(item);
                } 
                
            }
            
            return AllFieldSettingsList;
        }
        
    }
    
    private static List<FieldSetting__mdt> mappingIn;// NOT REQUIRED

    public static List<FieldSetting__mdt> FieldMappingInbound { 
        get {
            if(ObjectSettingToFieldSettingsMap_IB == null) {
                ObjectSettingToFieldSettingsMap_IB = new Map<String, List<FieldSetting__mdt>>();
                for(FieldSetting__mdt fs : SYS_DataCache.AllFieldSettingMappings){
                    if(fs.Direction__c != 'OUTBOUND'){
                        if(ObjectSettingToFieldSettingsMap_IB.containsKey(fs.ObjectSetting__r.DeveloperName)){
                            ObjectSettingToFieldSettingsMap_IB.get(fs.ObjectSetting__r.DeveloperName).add(fs);
                        }
                        else{
                            ObjectSettingToFieldSettingsMap_IB.put(fs.ObjectSetting__r.DeveloperName,new List<FieldSetting__mdt>{fs});
                        }
                    }
                }
            }

            if(SYS_DataCache.OBJ_TYPE!=NULL){
                return ObjectSettingToFieldSettingsMap_IB.get(SYS_DataCache.OBJ_TYPE);
            }
            else {
                /**
                 *  If Object Settings is still not set it means the Transformer isn't processing records in child context. So FS marked as child should be skipped
                 *  This is to prevent conflict when a resource is confgiured as both individual object setting and child to another object setting
                 */
                List<FieldSetting__mdt> allMappings = new List<FieldSetting__mdt>();
                for(List<FieldSetting__mdt> fsList:ObjectSettingToFieldSettingsMap_IB.values()){
                    for(FieldSetting__mdt fs:fsList){
                        if(fs.Level__c == '0')
                            allMappings.add(fs);
                    }
                }
                return allMappings;
            }
        }
        
        /*get {
            if(mappingIn == null) { 
                mappingIn = new List<FieldSetting__mdt>();
            
                String objSettingFilter = SYS_DataCache.OBJ_TYPE == NULL?'':' AND ObjectSetting__r.DeveloperName = \''+SYS_DataCache.OBJ_TYPE + '\'';

                String query = 'SELECT Id,StaticValue__c,Log_API_for_field_mapping__c, Lookup_External_Key__c, Lookup_Object_API_Name__c,Is_External_Field__c,Is_Lookup__c, Get_value_from_Log__c, ObjectSetting__r.DeveloperName,ChildFieldApiName__c,Field_Mapping_Handler__c, FieldApiName__c, ObjectApiName__c,Key__c, RestResource__c, Direction__c, ChildRootElement__c,' +                
                ' ObjectSetting__r.Object__r.QualifiedApiName , ObjectSetting__r.Direction__c, ObjectSetting__r.ResourcePath__c,ObjectSetting__r.url_params__c , ObjectSetting__r.ApexHandler__c ' + 
                ' from FieldSetting__mdt '+
                ' WHERE ObjectSetting__r.IntegrationType__r.developername =\''+SYS_DataCache.INT_TYPE+'\' AND Direction__c != \'OUTBOUND\' AND Is_Active__c = true' + objSettingFilter; 
                
                System.debug('----WS FieldMappingInbound Query:'+query);
                mappingIn = Database.query(query);
                for(FieldSetting__mdt item : mappingIn) {
                    item.FieldApiName__c = item.FieldApiName__c != null ? item.FieldApiName__c.replace(SYS_DataCache.ESCAPE_CHAR, SYS_DataCache.namespacePrefix) :item.FieldApiName__c ;
                    item.ObjectApiName__c = item.ObjectApiName__c != null ? item.ObjectApiName__c.replace(SYS_DataCache.ESCAPE_CHAR, SYS_DataCache.namespacePrefix) :item.ObjectApiName__c ;
                } 
            }
            for(FieldSetting__mdt item : mappingIn) {
                system.debug('cache== value==' + item.FieldApiName__c +' obj=='+item.ObjectApiName__c);
            }
            return mappingIn;
        }*/
    }
    
    //NOT USED
    /*
    public static Map<String, List<FieldSetting__mdt>> GetChildFieldSettingMap{
        get{
            if(childFieldSettingMap == null){
                childFieldSettingMap = new Map<String, Map<String, List<FieldSetting__mdt>>>();
                
                //
                for(FieldSetting__mdt fs : SYS_DataCache.AllFieldSettingMappings){
                    if(fs.ParentField__c != null) {
                        if(childFieldSettingMap.get(fs.ObjectSetting__r.ObjectApiName__c) == null) {
                            childFieldSettingMap.put(fs.ObjectSetting__r.ObjectApiName__c, new Map<String, List<FieldSetting__mdt>>()); 
                        }
                        Map<String, List<FieldSetting__mdt>> childMappingsMap = childFieldSettingMap.get(fs.ObjectSetting__r.ObjectApiName__c);
                        
                        if(childMappingsMap.get(fs.ObjectApiName__c) == null) {
                            childMappingsMap.put(fs.ObjectApiName__c, new List<FieldSetting__mdt>()); 
                        }
                        childMappingsMap.get(fs.ObjectApiName__c).add(fs);
                        
                    }
                }
                //
            }
            return childFieldSettingMap.get(context);
        }
    }
    */
    
    //NOT USED
    /*
    public static List<FieldSetting__mdt> FieldSettingMappings{
        get{
            if(ObjectSettingToFieldSettingsMap_OB == null){
                ObjectSettingToFieldSettingsMap_OB = new Map<String, List<FieldSetting__mdt>>();
                SYS_debug.log('\n\n+++++++++++ ObjectSettingToFieldSettingsMap_OB:'+ObjectSettingToFieldSettingsMap_OB);
                for(FieldSetting__mdt fs : SYS_DataCache.AllFieldSettingMappings){
                    SYS_debug.log('\n\n+++++++++++ fs:'+fs);
                    if(ObjectSettingToFieldSettingsMap_OB.containsKey(fs.ObjectSetting__r.ObjectApiName__c)){
                        ObjectSettingToFieldSettingsMap_OB.get(fs.ObjectSetting__r.ObjectApiName__c).add(fs);
                        SYS_debug.log('Object=='+fs.ObjectSetting__r.ObjectApiName__c+' Field=='+fs.FieldApiName__c);
                    }
                    else{
                        ObjectSettingToFieldSettingsMap_OB.put(fs.ObjectSetting__r.ObjectApiName__c,new List<FieldSetting__mdt>{fs});
                    }
                }
            }
            SYS_debug.log('\n\n+++++++++++ Map for context:'+context+':'+ObjectSettingToFieldSettingsMap_OB);
            SYS_debug.log('\n\n+++++++++++ for context:'+context+':'+ObjectSettingToFieldSettingsMap_OB.get(context));
            return ObjectSettingToFieldSettingsMap_OB.get(context);
        }
    }
    */

    //CONSIDERS OUTBOUND FIELDS ONLY
    public static List<FieldSetting__mdt> FieldMappingOutbound {
        get {
            if(ObjectSettingToFieldSettingsMap_OB == null) {
                ObjectSettingToFieldSettingsMap_OB = new Map<String, List<FieldSetting__mdt>>();
                for(FieldSetting__mdt fs : SYS_DataCache.AllFieldSettingMappings){
                    if(fs.Direction__c != 'INBOUND'){
                        if(ObjectSettingToFieldSettingsMap_OB.containsKey(fs.ObjectSetting__r.DeveloperName)){
                            ObjectSettingToFieldSettingsMap_OB.get(fs.ObjectSetting__r.DeveloperName).add(fs);
                        }
                        else{
                            ObjectSettingToFieldSettingsMap_OB.put(fs.ObjectSetting__r.DeveloperName,new List<FieldSetting__mdt>{fs});
                        }
                    }
                }
            }
            return ObjectSettingToFieldSettingsMap_OB.get(SYS_DataCache.OBJ_TYPE);
        }
    }
    
    //NOT USED
    /*
    public static void load(String primaryObj,List<sObject> objsList) {
            //String primaryObj; //TODO-fix this
            if(ObjectSettingToFieldSettingsMap_OB == null || ObjectSettingToFieldSettingsMap_OB.keySet().size() == 0) {
                List<FieldSetting__mdt> AllFieldSettingsList = [Select Id,Log_API_for_field_mapping__c, Lookup_External_Key__c, Lookup_Object_API_Name__c, Get_value_from_Log__c,IsChild__c, Field_Mapping_Handler__c,ObjectApiName__c, FieldApiName__c , Key__c, RestResource__c, Direction__c, ParentField__c, 
                                           ObjectSetting__r.Direction__c, ObjectSetting__r.ResourcePath__c,ObjectSetting__r.url_params__c , ObjectSetting__r.ApexHandler__c 
                                           from FieldSetting__mdt where ObjectSetting__r.ObjectApiName__c = :primaryObj and FieldApiName__c != null];
                
            }
    }
    */

    public static Map<String, String> escCharMap = new Map<String, String>(); 
    
    public static String ESCAPE_CHAR{
        get{
                if(escCharMap.isEmpty()) {
                    SYS_debug.log('esc char loop');
                    List<IntegrationSetting__mdt> listObjSetting = [SELECT EscapeCharacter__c, BaseAPIEndPoint__c, ApexHandler__c, NamedCredential__c, 
                                                    UpdateMethod__c, AuthenticationType__c,
                                                    MasterLabel, DeveloperName, Id, QualifiedApiName 
                                                    FROM IntegrationSetting__mdt LIMIT 100];
                for(IntegrationSetting__mdt val:listObjSetting){
                    escCharMap.put(val.DeveloperName , val.EscapeCharacter__c);
                }
            }
            // SYS_debug.log('escape char is==' + escCharMap);
            return escCharMap.get(SYS_DataCache.INT_TYPE);
        }
    }

    public static void load(){ 
        /*List<IntegrationSetting__mdt> listObjSetting = [SELECT EscapeCharacter__c, BaseAPIEndPoint__c, ApexHandler__c, NamedCredential__c, 
                                                   UpdateMethod__c, AuthenticationType__c,
                                                   MasterLabel, DeveloperName, Id, QualifiedApiName 
                                                   FROM IntegrationSetting__mdt LIMIT 100];*/
        for(IntegrationSetting__mdt val: integrationSetting.values() /*listObjSetting*/){
            escCharMap.put(val.DeveloperName , val.EscapeCharacter__c);
        }
    }
    
    /*
    public static Map<String, Id> mapProdkeyToPriceBookEntry = new Map<String, Id>(); 
    public static Map<String, Id> mapPriceBookEntry {
        get {
            if(mapProdkeyToPriceBookEntry.isEmpty()) { 
                String pricebook = SYS_Constants.PRICEBOOK;
                String query = 'SELECT Id,IsActive,Name,Product2.Quickbooks_Id__c FROM PricebookEntry WHERE IsActive = true AND Product2.Quickbooks_Id__c != null AND Pricebook2.name = : pricebook';
                List<PricebookEntry> priceList = Database.query(query);
                if(priceList.size() > 0) {
                    for(PricebookEntry book : priceList) { 
                        mapProdkeyToPriceBookEntry.put(book.Product2.Quickbooks_Id__c, book.Id);
                    }
                    return mapProdkeyToPriceBookEntry;  
                }
            }
            return mapProdkeyToPriceBookEntry;
        }
    }
	*/
    // SYS_debug.log(JSON.serialize(SYS_DataCache.mapPriceBookEntry));

    // String x = SYS_DataCache.priceBookId;

    /* --MS
    public static String bookId;
    public static String priceBookId {
        get {
            if(Test.isRunningTest()) {
                bookId = Test.getStandardPricebookId(); 
                return bookId;
            }
            if(bookId == null) {
                String book = SYS_Constants.PRICEBOOK;
                String query = 'SELECT Id,Name FROM Pricebook2 WHERE Name = :book';
                List<Pricebook2> books = Database.query(query);
                if(books.size() > 0) {
                    bookId = books[0].Id;
                }
                SYS_debug.log(bookId); 
                return bookId;
            }
            return bookId;
        }
    }
    */

    public static string sObjectApiName;

    // ONLY USED IN INVOCABLE HANDLER THAT TOO ONLY ASSIGNMENT
    public static String objectApiName;  
    
    //NOT USED
    /*
    public static List<ObjectSetting__mdt> objMap = new List<ObjectSetting__mdt>();
    public static List<ObjectSetting__mdt> objSettings {
        get{
            if(objMap.size() == 0) {
                objMap = [SELECT masterlabel, DeveloperName,ExternalFieldApi__c,Id,IntegrationType__r.developername , QueryClause__c,
                                    ObjectApiName__c,Object__c,QualifiedApiName,ResourcePath__c,url_params__c FROM ObjectSetting__mdt LIMIT 10000];
            }
            return objMap;
        }
    }
    */

    //NOT USED
    /*
    public static Map<String, Map<String, String>> externalIdmap = new Map<String, Map<String, String>>();
    public static Map<String, Map<String, String>> getExtId {
        get {
            if(externalIdmap.values().size() == 0) {
                objMap = new List<ObjectSetting__mdt>();
                objMap = [SELECT masterlabel, DeveloperName,ExternalFieldApi__c,Id,IntegrationType__r.developername , QueryClause__c,
                                    ObjectApiName__c,Object__c,QualifiedApiName,ResourcePath__c,url_params__c FROM ObjectSetting__mdt LIMIT 10000];
                for(IntegrationSetting__mdt intSetting : [SELECT developername FROM IntegrationSetting__mdt]) {
                    Map<String, String> objToKey = new Map<String, String>();
                    for(ObjectSetting__mdt obj : objMap) {
                        if(obj.IntegrationType__r.developername == intSetting.developername)
                            objToKey.put(obj.ObjectApiName__c, obj.ExternalFieldApi__c);
                    }
                    externalIdmap.put(intSetting.developername, objToKey);
                }
                return externalIdmap;
            }
            return externalIdmap;
        }
    }
    */

    //NOT USED
    /*
    public static Map<String, String> extFieldName = new Map<String, String>();
    public static Map<String, String> objExternalField {
        get{
            if(extFieldName.isEmpty()) {
                objMap = new List<ObjectSetting__mdt>();
                objMap = [SELECT masterlabel, DeveloperName,ExternalFieldApi__c,Id,IntegrationType__r.developername , QueryClause__c,
                                    ObjectApiName__c,Object__c,QualifiedApiName,ResourcePath__c,url_params__c FROM ObjectSetting__mdt LIMIT 10000];
            }
            for(ObjectSetting__mdt obj : objMap) {
                extFieldName.put(obj.DeveloperName, obj.ExternalFieldApi__c);
            }
            return extFieldName;
        }
    }
    */

    public static map<String, ObjectSetting__mdt> objectSettingInit = new Map<String, ObjectSetting__mdt>();
    public static map<String, ObjectSetting__mdt> objectSettingMap {
        get{
            if(objectSettingInit.isEmpty()) {
                /*List<ObjectSetting__mdt> objMap = [SELECT DeveloperName,Resource_Name__c, ApexHandler__c,BypassTrigger__c, ExternalFieldApi__c,Id,IntegrationType__r.developername , QueryClause__c,
                                    ObjectApiName__c,Object__c,QualifiedApiName,ResourcePath__c,url_params__c FROM ObjectSetting__mdt LIMIT 10000];
                */
                for(ObjectSetting__mdt obj : ObjectSetting__mdt.getAll().values()) {
                    objectSettingInit.put(obj.DeveloperName, obj);
                }
            }
            return objectSettingInit;
        } 
    }
    
    /*
    public static String genericQuote;
    public static String QUOTE_ID {
        get {
            if(genericQuote == null) {
                genericQuote = [SELECT Id FROM SBQQ__Quote__c WHERE Quote_Name__c = 'GENERIC QUOTE' LIMIT 1][0].Id;
            }
            return genericQuote;
        }
    }
	*/

    /* --MS
    public static String genericAccount;
    public static String ACC_ID {
        get {
            if(genericAccount == null) {
                genericAccount = [SELECT Id FROM Account WHERE Name = 'GENERIC QUOTE' LIMIT 1][0].Id;
            }
            return genericAccount;
        }
    }

    public static String genericProd; 
    public static String PROD_ID {
        get {
            if(genericProd == null) {
                genericProd = [SELECT Id FROM Product2 WHERE Name = 'GENERIC PRODUCT' LIMIT 1][0].Id;
            }
            return genericProd;
        }
    }
    public static String priceBookEntry;
    public static String PRICEBOOK {
        get {
            if(priceBookEntry == null) {
                priceBookEntry = [SELECT Id,Pricebook2.name,Product2Id FROM PricebookEntry WHERE Product2.name = 'GENERIC PRODUCT' AND Pricebook2.Name = :SYS_Constants.PRICEBOOK LIMIT 1][0].Id;
            }
            System.debug(priceBookEntry);
            return priceBookEntry;
        }
    }
    */

    /*
    public static Map<String, String> mapProduct = new Map<String, String>();
    public static Map<String, String> PRODMAP {
        get {
            if(mapProduct.isEmpty()) {
                List<Product2> productList = [SELECT Id, Quickbooks_Id__c FROM Product2 WHERE IsActive = true LIMIT 50000];
                for(Product2 prod : productList) {
                    mapProduct.put(prod.Quickbooks_Id__c, prod.Id);
                }
            }
            return mapProduct; 
        }
    }

	*/
    
    /*
    public static Map<String, String> mapPrice = new Map<String, String>();
    public static Map<String, String> PRICEMAP {
        get {
            Map<String, String> mapPrice = new Map<String, String>();
            if(mapPrice.isEmpty()) {
                List<PricebookEntry> priceList = [SELECT Id,Pricebook2Id,Product2.Quickbooks_Id__c, UnitPrice FROM PricebookEntry WHERE Pricebook2.Name = :SYS_Constants.PRICEBOOK LIMIT 50000];
                for(PricebookEntry price : priceList) {
                    mapPrice.put(price.Product2.Quickbooks_Id__c, price.Id);
                }
            }
            return mapPrice;
        }
    }

	*/

    public static boolean debug;
    public static boolean DEBUG_CHECK {
        get {
            
            /*
            if(intMap == null || debug == null){
                intMap = new Map<String,IntegrationSetting__mdt>();
                debug = [SELECT Id, DeveloperName, Label, UpdateMethod__c, DebugCheck__c,
                                     AuthenticationType__c, BaseAPIEndPoint__c, 
                                     QualifiedApiName, EscapeCharacter__c FROM IntegrationSetting__mdt 
                                     WHERE developername = :SYS_DataCache.INT_TYPE LIMIT 1][0].DebugCheck__c;
            }
            */
            return integrationSetting.get(SYS_DataCache.INT_TYPE).DebugCheck__c;
            //return true;
        }
    } 

    //public static List<IntegrationEnablement__mdt> enableIntList = new List<IntegrationEnablement__mdt>();

    public static Map<String, Boolean> checkMap;
    public static Map<String, Boolean> enableCheck {
        get{
            if(checkMap == NULL) {
                checkMap = new Map<String, Boolean>();
                /*enableIntList = [SELECT Id,Integration_Setting__r.DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Enable__c, ExpiryDate__c 
                                    FROM IntegrationEnablement__mdt];
                                    */
                for(IntegrationEnablement__mdt iter : IntegrationEnablement__mdt.getAll().values()) {
                    checkMap.put(iter.Integration_Setting__r.DeveloperName.toUpperCase() , iter.Enable__c);
                }
            }
            return checkMap;
        }
    }

    public static String namespace;
    public static String namespacePrefix {
        get {
            if(namespace == null) {
                Schema.DescribeSObjectResult dsr = SYS_IntegrationLog__c.sObjectType.getDescribe();
                namespace = dsr.getName().remove(dsr.getLocalName());
            }
            return namespace; 
        }
    }

    //NOT USED - Need to update. Create map for each INT_TYPE. Same as Enable checkbox
    /*
    public static Date expiry;
    public static Date expiryDate {
        get {
            if(enableIntList.isEmpty()) {
                enableIntList = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Enable__c, ExpiryDate__c 
                                    FROM IntegrationEnablement__mdt];
                expiry =  enableIntList[0].ExpiryDate__c;
            }
            return expiry;
        }
    }
    */


    // NOT USED/REQUIRED. 
    /*
    public static String token = '';
    public static String webhookToken {
        get {
            if(token == '') {
                List<IntegrationSetting__mdt> intSetting = [SELECT Id, developername, webhookToken__c FROM IntegrationSetting__mdt WHERE developername = :SYS_DataCache.INT_TYPE];
                if(intSetting.size() > 0) {
                    token = intSetting[0].webhookToken__c;
                    return token;
                }
            }
            return token;
        }
    }
    */
    
}