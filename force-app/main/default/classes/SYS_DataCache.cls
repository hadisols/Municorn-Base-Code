public class SYS_DataCache {
	private static Map<Id, sObject> oldObjMap = new Map<Id, sObject>();
    private static Map<Id, sObject> newObjMap = new Map<Id, sObject>();
    //TODO - create a map of child mapping that are under eaach parent mapping
    private static Map<String, List<FieldSetting__mdt>> objectFieldSettingMap;
    private static Map<String, Map<String, List<FieldSetting__mdt>>> childFieldSettingMap;
    private static List<FieldSetting__mdt> mappings;

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
                String intSettingFromUrl = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
                INT_TYPE = intSettingFromUrl;

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
    
    private static Map<String, String> external_key;
    public static Map<String, String> externalKeyByResourceMap {
        get {
            if(external_key == null) {
                external_key = new Map<String, String>();
                for(FieldSetting__mdt fs : FieldMappingOutbound){
                    if(fs.Is_External_Field__c)
                        external_key.put(fs.RestResource__c.toLowerCase(),fs.FieldApiName__c);
                }
            }
            return external_key;
        }
    }

    /******* NEW VARIABLES END*********/
	
    //TODO - add a method checkAndLoad , called from every getter, single query on grand child and get 
    //all meta data records from 
    //grand-parents, parents and do the maps.
    
    public static List<sObject> sObjList = new List<sObject>();
    public static List<sObject> contextSet{
        set{
            sObjList = value;
            if(sObjList!=NULL && sObjList.size()>0){
                SObjectType objectType = sObjList[0].getSObjectType();
                context = JSON.serialize(objectType.getDescribe().getName()).replace('\"','');
            }
        }
    }
    
    
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
            if(integrationSetting == null){
                intMap = new Map<String,IntegrationSetting__mdt>();
                for(IntegrationSetting__mdt is : [SELECT Id,OAuth_Config_Record_Id__c,Hashing_Algo__c,ApexHandler__c,webhookToken__c, DeveloperName, Label, UpdateMethod__c, DebugCheck__c,
                                     AuthenticationType__c, BaseAPIEndPoint__c, 
                                     QualifiedApiName, EscapeCharacter__c FROM IntegrationSetting__mdt 
                                     LIMIT 100]){

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

    //CONSIDERS OUTBOUND FIELDS ONLY
    public static List<FieldSetting__mdt> AllFieldSettingMappings{
        get{
            if(mappings == null){
                mappings = new List<FieldSetting__mdt>();
                System.debug('Field Settings #### 1:'+mappings);
                mappings = [Select Id,developername, Order_Number__c,Log_API_for_field_mapping__c, Lookup_External_Key__c, Lookup_Object_API_Name__c,Is_External_Field__c,Is_Lookup__c, Get_value_from_Log__c,ChildFieldApiName__c,ObjectSetting__r.DeveloperName,masterlabel,Field_Mapping_Handler__c, ObjectSetting__r.masterlabel , StaticValue__c,IsChild__c, ObjectSetting__r.ObjectApiName__c, ObjectApiName__c, FieldApiName__c , Key__c, RestResource__c, Direction__c, ParentField__c, ChildRootElement__c,
                            ObjectSetting__r.Direction__c,ObjectSetting__r.Trigger_Condition__c,ObjectSetting__r.TriggerEvents__c, ObjectSetting__r.ResourcePath__c,ObjectSetting__r.url_params__c , ObjectSetting__r.ApexHandler__c 
                            from FieldSetting__mdt /*where Is_Active__c=true where FieldApiName__c != null*/
                            WHERE ObjectSetting__r.IntegrationType__r.developername = : SYS_DataCache.INT_TYPE AND Direction__c != 'INBOUND'
                            ORDER BY Order_Number__c ASC];
                System.debug('Field Settings #### 2:'+mappings);
                for(FieldSetting__mdt item : mappings) {
                    System.debug('Field Settings #### 3:'+item);
                    item.FieldApiName__c = item.FieldApiName__c != null ? item.FieldApiName__c.replace(SYS_DataCache.ESCAPE_CHAR, SYS_DataCache.namespacePrefix) :item.FieldApiName__c ;
                    item.ObjectApiName__c = item.ObjectApiName__c != null ? item.ObjectApiName__c.replace(SYS_DataCache.ESCAPE_CHAR, SYS_DataCache.namespacePrefix) :item.ObjectApiName__c ;
                } 
                System.debug('Field Settings #### 4:');
            }
            System.debug('Field Settings ####:'+mappings);
            return mappings;
        }
        
    }
    private static List<FieldSetting__mdt> mappingOut; 
    public static List<FieldSetting__mdt> FieldMappingOutbound { 
        get {
            if(mappingOut == null) { 
                mappingOut = new List<FieldSetting__mdt>();
                String intType = SYS_DataCache.INT_TYPE;
                // mappingOut = [SELECT Id, ChildFieldApiName__c, FieldApiName__c, ObjectApiName__c,Key__c, RestResource__c, Direction__c, ChildRootElement__c,
                //             ObjectSetting__r.Object__r.QualifiedApiName , ObjectSetting__r.Direction__c, ObjectSetting__r.ResourcePath__c,ObjectSetting__r.url_params__c , ObjectSetting__r.ApexHandler__c 
                //             from FieldSetting__mdt /*where Is_Active__c=true where FieldApiName__c != null*/
                //             WHERE ObjectSetting__r.IntegrationType__r.developername = : SYS_DataCache.INT_TYPE AND Direction__c != 'OUTBOUND'];
                String query = 'SELECT Id,developername,Order_Number__c,StaticValue__c,Log_API_for_field_mapping__c, Lookup_External_Key__c, Lookup_Object_API_Name__c,Is_External_Field__c,Is_Lookup__c, Get_value_from_Log__c, ObjectSetting__r.DeveloperName,ChildFieldApiName__c,Field_Mapping_Handler__c, FieldApiName__c, ObjectApiName__c,Key__c, RestResource__c, Direction__c, ChildRootElement__c,' +                
                ' ObjectSetting__r.Object__r.QualifiedApiName , ObjectSetting__r.Direction__c, ObjectSetting__r.ResourcePath__c,ObjectSetting__r.url_params__c , ObjectSetting__r.ApexHandler__c ' + 
                ' from FieldSetting__mdt '+
                ' WHERE ObjectSetting__r.IntegrationType__r.developername =\''+SYS_DataCache.INT_TYPE+'\' AND Direction__c != \'OUTBOUND\' '; 
                
                System.debug('----WS FieldMappingOutbound Query:'+query);
                mappingOut = Database.query(query);
                for(FieldSetting__mdt item : mappingOut) {
                    // system.debug('before replace==='+item.FieldApiName__c);
                    item.FieldApiName__c = item.FieldApiName__c != null ? item.FieldApiName__c.replace(SYS_DataCache.ESCAPE_CHAR, SYS_DataCache.namespacePrefix) :item.FieldApiName__c ;
                    item.ObjectApiName__c = item.ObjectApiName__c != null ? item.ObjectApiName__c.replace(SYS_DataCache.ESCAPE_CHAR, SYS_DataCache.namespacePrefix) :item.ObjectApiName__c ;
                    // system.debug('fapiname==='+item.FieldApiName__c);
                } 
            }
            for(FieldSetting__mdt item : mappingOut) {
                system.debug('cache== value==' + item.FieldApiName__c +' obj=='+item.ObjectApiName__c);
            }
            return mappingOut;
        }
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
            if(objectFieldSettingMap == null){
                objectFieldSettingMap = new Map<String, List<FieldSetting__mdt>>();
                SYS_debug.log('\n\n+++++++++++ objectFieldSettingMap:'+objectFieldSettingMap);
                for(FieldSetting__mdt fs : SYS_DataCache.AllFieldSettingMappings){
                    SYS_debug.log('\n\n+++++++++++ fs:'+fs);
                    if(objectFieldSettingMap.containsKey(fs.ObjectSetting__r.ObjectApiName__c)){
                        objectFieldSettingMap.get(fs.ObjectSetting__r.ObjectApiName__c).add(fs);
                        SYS_debug.log('Object=='+fs.ObjectSetting__r.ObjectApiName__c+' Field=='+fs.FieldApiName__c);
                    }
                    else{
                        objectFieldSettingMap.put(fs.ObjectSetting__r.ObjectApiName__c,new List<FieldSetting__mdt>{fs});
                    }
                }
            }
            SYS_debug.log('\n\n+++++++++++ Map for context:'+context+':'+objectFieldSettingMap);
            SYS_debug.log('\n\n+++++++++++ for context:'+context+':'+objectFieldSettingMap.get(context));
            return objectFieldSettingMap.get(context);
        }
    }
    */

    //CONSIDERS OUTBOUND FIELDS ONLY
    public static List<FieldSetting__mdt> fieldSettingMappingUsingObjSetting {
        get {
            if(objectFieldSettingMap == null) {
                objectFieldSettingMap = new Map<String, List<FieldSetting__mdt>>();
                for(FieldSetting__mdt fs : SYS_DataCache.AllFieldSettingMappings){
                    if(objectFieldSettingMap.containsKey(fs.ObjectSetting__r.DeveloperName)){
                        objectFieldSettingMap.get(fs.ObjectSetting__r.DeveloperName).add(fs);
                        SYS_debug.log('Object=='+fs.ObjectSetting__r.DeveloperName+' Field=='+fs.FieldApiName__c);
                    }
                    else{
                        objectFieldSettingMap.put(fs.ObjectSetting__r.DeveloperName,new List<FieldSetting__mdt>{fs});
                    }
                }
            }
            //System.debug('Object=='+SYS_Constants.OBJ_TYPE+'--'+objectFieldSettingMap.get(SYS_Constants.OBJ_TYPE));
            return objectFieldSettingMap.get(SYS_DataCache.OBJ_TYPE);
        }
    }
    
    //NOT USED
    /*
    public static void load(String primaryObj,List<sObject> objsList) {
            //String primaryObj; //TODO-fix this
            if(objectFieldSettingMap == null || objectFieldSettingMap.keySet().size() == 0) {
                List<FieldSetting__mdt> mappings = [Select Id,Log_API_for_field_mapping__c, Lookup_External_Key__c, Lookup_Object_API_Name__c, Get_value_from_Log__c,IsChild__c, Field_Mapping_Handler__c,ObjectApiName__c, FieldApiName__c , Key__c, RestResource__c, Direction__c, ParentField__c, 
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
        List<IntegrationSetting__mdt> listObjSetting = [SELECT EscapeCharacter__c, BaseAPIEndPoint__c, ApexHandler__c, NamedCredential__c, 
                                                   UpdateMethod__c, AuthenticationType__c,
                                                   MasterLabel, DeveloperName, Id, QualifiedApiName 
                                                   FROM IntegrationSetting__mdt LIMIT 100];
        for(IntegrationSetting__mdt val:listObjSetting){
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
                // objMap = [SELECT masterlabel, DeveloperName,ExternalFieldApi__c,Id,IntegrationType__r.developername , QueryClause__c,
                //                     ObjectApiName__c,Object__c,QualifiedApiName,ResourcePath__c FROM ObjectSetting__mdt LIMIT 10000];
                objMap = ObjectSetting__mdt.getAll().values();
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
                objMap = ObjectSetting__mdt.getAll().values();
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
                objMap = ObjectSetting__mdt.getAll().values();
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
            if( objectSettingInit.isEmpty()) {
                List<ObjectSetting__mdt> objMap = [SELECT DeveloperName,BypassOrder__c, ApexHandler__c,BypassTrigger__c, ExternalFieldApi__c,Id,IntegrationType__r.developername , QueryClause__c,
                                    ObjectApiName__c,Object__c,QualifiedApiName,ResourcePath__c,url_params__c FROM ObjectSetting__mdt LIMIT 10000];
                
                for(ObjectSetting__mdt obj : objMap) {
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

    public static List<IntegrationEnablement__mdt> enableIntList = new List<IntegrationEnablement__mdt>();

    public static Map<String, Boolean> checkMap = new Map<String, Boolean>();
    public static Map<String, Boolean> enableCheck {
        get{
            if(enableIntList.isEmpty()) {
                enableIntList = [SELECT Id,Integration_Setting__r.DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Enable__c, ExpiryDate__c 
                                    FROM IntegrationEnablement__mdt];
                System.debug('\n\n MS enableIntList:'+enableIntList);
                for(IntegrationEnablement__mdt iter : enableIntList) {
                    System.debug('\n\n MS enableIntList in loop:'+iter.Integration_Setting__r.DeveloperName.toUpperCase()+'='+iter.Enable__c);

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