/**
 * constructor will set SYS_DataCache
 * @criteria - if SYS_DataCache.datacache is NULL we will use the old datacache variables
 */

 public without sharing class SYS_DataCacheFactory {
    public String accountId;
    public String integrationType;

    public SYS_DataCacheFactory(List<String> accountIds, String integrationType, 
    String int_type, String obj_type) {
        
        System.debug('SP integrationType '+
         +' : accountIds' +accountIds+ ' obj_type: '+obj_type +' : int_type'+int_type);
        this.integrationType = integrationType;
        this.accountId = accountIds[0];

        SYS_DataCache.INT_TYPE = int_type;
        SYS_DataCache.OBJ_TYPE = obj_type;
        
        if(accountIds != NULL && accountIds.size()>0 && accountIds[0] != NULL) 
            new SYS_DataCache(accountIds);
        if(this.accountId instanceOf Id)
            SYS_DataCache.datacache = SYS_DataCache.getDataCache(this.accountId, this.integrationType);
    }

    public SYS_DataCacheFactory(String accountIds, String integrationType, 
    String int_type, String obj_type) {
        this(new List<String>{accountIds}, integrationType, int_type, obj_type);
    }

    public SYS_DataCacheFactory( String int_type, String obj_type) {
        this(new List<String>{''}, NULL , int_type, obj_type);
    }

    private SYS_DataCacheFactory() {}

    public static Map<String,String> PARENT_RESOURCE_MAP {
        get{
            return SYS_DataCache.datacache != NULL ? SYS_DataCache.datacache.parentResourceMap : SYS_DataCache.PARENT_RESOURCE_MAP;
        }
    }

    public static List<SYS_IntegrationLog__c> childRecordsToInsert = new List<SYS_IntegrationLog__c>();

    public static String FLAT_KEY_SEPERATOR {
        get {
            return SYS_DataCache.datacache != NULL ? SYS_DataCache.datacache.flatKeySeparator : SYS_DataCache.FLAT_KEY_SEPERATOR;
        }
    }

    public static String FLAT_KEY_PATTERN {
        get {
            return SYS_DataCache.datacache != NULL ? SYS_DataCache.datacache.flatKeyPattern : SYS_DataCache.FLAT_KEY_PATTERN;
        }
    }

    public static Map<String, String> externalKeyByResourceMap {
        get {
            return SYS_DataCache.datacache != NULL ? SYS_DataCache.datacache.externalKeyByResourceMap : SYS_DataCache.externalKeyByResourceMap;
        }
    }

    public static Map<String, String> externalKeyByObject {
        get {
            return SYS_DataCache.datacache != NULL ? SYS_DataCache.datacache.externalKeyByObjectMap : SYS_DataCache.externalKeyByObject;
        }
    }

    //datatype change
    public static IntegrationSetting__mdt integrationSetting {
        get {
            // if(SYS_DataCache.datacache != NULL && SYS_DataCache.datacache?.metadata?.get('int-set') != NULL) {
            //     return SYS_DataCache.datacache != NULL ? SYS_DataCache.datacache.integrationSetting : SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE);
            // }
            // throw new SYS_DataCacheFactoryException('\n Integration metadata is missing for the account. Please contact your admin.');
            return SYS_DataCache.datacache != NULL ? SYS_DataCache.datacache.integrationSetting : SYS_DataCache.integrationSetting.get(SYS_DataCacheFactory.INT_TYPE);
        }
    }

    public static List<HttpHeaders__mdt> headerSetting {
        get {
            return SYS_DataCache.datacache != NULL ? SYS_DataCache.datacache.headers : SYS_DataCache.headerSetting;
        }
    }

    public static List<FieldSetting__mdt> FieldMappingInbound {
        get {
            return SYS_DataCache.datacache != NULL ? 
            ((SYS_DataCacheFactory.OBJ_TYPE != NULL) ? SYS_DataCache.datacache.ObjectSettingFieldSettingMap_in.get(SYS_DataCacheFactory.OBJ_TYPE) : SYS_DataCache.datacache.AllFieldSettings_in) : 
            SYS_DataCache.FieldMappingInbound;
        }
    }

    public static List<FieldSetting__mdt> FieldMappingOutbound {
        get {
            return SYS_DataCache.datacache != NULL ? (SYS_DataCache.datacache.ObjectSettingFieldSettingMap_out.containsKey(SYS_DataCacheFactory.OBJ_TYPE) ? SYS_DataCache.datacache.ObjectSettingFieldSettingMap_out.get(SYS_DataCacheFactory.OBJ_TYPE) : SYS_DataCache.FieldMappingOutbound ) : SYS_DataCache.FieldMappingOutbound;
        }
    }

    public static String ESCAPE_CHAR {
        get {
            return SYS_DataCache.datacache != NULL ? 
            SYS_DataCache.datacache.integrationSetting?.EscapeCharacter__c : 
            SYS_DataCache.ESCAPE_CHAR;
        }
    }

    public static String SKIP_KEYS {
        get {
            String skipKeysInIntegrationSetting = '', skipKeysInObjectSetting = '';

            skipKeysInIntegrationSetting = SYS_DataCache.datacache != NULL ? 
            SYS_DataCache.datacache.integrationSetting?.Skip_Keys__c?.toLowerCase() :
            (SYS_DataCacheFactory.INT_TYPE != NULL ? 
            SYS_DataCache.integrationSetting.get(SYS_DataCacheFactory.INT_TYPE).Skip_Keys__c?.toLowerCase() :
            '');

            skipKeysInObjectSetting = SYS_DataCache.datacache != NULL && SYS_DataCacheFactory.OBJ_TYPE != NULL ?
            SYS_DataCache.datacache.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE)?.Skip_Keys__c?.toLowerCase() :
            (SYS_DataCacheFactory.OBJ_TYPE != NULL ?
            SYS_DataCache.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE)?.Skip_Keys__c?.toLowerCase() : 
            '');

            return skipKeysInIntegrationSetting + ',' + skipKeysInObjectSetting;

        }
    }

    public static String namespacePrefix {
        get {
            return SYS_DataCache.namespacePrefix;
            // return SYS_DataCache.datacache != NULL ? 
            // SYS_DataCache.datacache.integrationSetting?.NamespacePrefix : 
            // SYS_DataCache.namespacePrefix;
        }
    }

    public static map<String, ObjectSetting__mdt> objectSettingMap {
        get {
            return SYS_DataCache.datacache != NULL ? 
            SYS_DataCache.datacache.objectSettingMap : 
            SYS_DataCache.objectSettingMap;
        }
    }

    public static boolean DEBUG_CHECK {
        get {
            if(SYS_DataCache.datacache != NULL && SYS_DataCache.datacache?.metadata?.get('int-set') != NULL) {
                return SYS_DataCache.datacache?.isEnabled;
            } 
            return SYS_DataCache.DEBUG_CHECK;
        }
    }

    private static Map<String, String> metadataMap = new Map<String, String>();
    public static Map<String, String> metadata {
        get{
            if(SYS_DataCache.datacache != NULL) {
                return SYS_DataCache.datacache?.metadata;
            } else if(SYS_DataCacheFactory.INT_TYPE != NULL && metadataMap.isEmpty()){
                for(Integration_Metadata__mdt item : Integration_Metadata__mdt.getAll()?.values()) {
                    if(item.Integration_Setting__r.DeveloperName == SYS_DataCacheFactory.INT_TYPE) {
                        metadataMap.put(item.Key__c, item.Value__c);
                    }
                }
                return metadataMap;
            }
            return new Map<String, String>();
        }
    }

    //datatype change
    public static Boolean enableCheck {
        get {
            Boolean enableFlag = SYS_DataCache.datacache != NULL ? 
            SYS_DataCache.datacache.isEnabled : 
            SYS_DataCache.enableCheck.get(SYS_DataCacheFactory.INT_TYPE?.toUpperCase());
            return enableFlag != NULL ? enableFlag : false;
        }
    }

    public static String accountId {
        get{
            if(SYS_DataCache.datacache != NULL && SYS_DataCache.datacache?.metadata?.get('int-set') != NULL) {
                return SYS_DataCache.datacache.accountId;
            } 
            return NULL;
        }
    }

    public static String integrationType {
        get{
            if(SYS_DataCache.datacache != NULL && SYS_DataCache.datacache?.metadata?.get('int-set') != NULL) {
                return SYS_DataCache.datacache?.integrationSetting?.Integration_Type__c;
            } 
            return NULL;
        }
    }

    public static String INT_TYPE {
        set {
            SYS_DataCache.INT_TYPE = value;
        } get {
            return SYS_DataCache.INT_TYPE;
        }
    }

    public static String OBJ_TYPE {
        set {
            SYS_DataCache.OBJ_TYPE = value;
        } get {
            return SYS_DataCache.OBJ_TYPE;
        }
    }

    public static SYS_IntegrationLog__c log {
        set {
            SYS_DataCache.log = value;
        } get {
            return SYS_DataCache.log;
        }
    }

    //TODO - SP temporary fix for forcesync

    public static List<SYS_OAuthConfig__c> authRec {
        get {
            if(SYS_DataCache.datacache != NULL) {
                return SYS_DataCache.datacache.sysAuthRecords;
            } else {
                String authId = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).OAuth_Config_Record_Id__c;
                String query = 'SELECT '+ + SYS_Helper.getAllFieldsFor('SYS_OAuthConfig__c') 
                                +' FROM SYS_OAuthConfig__c WHERE Id =:authId';
                return Database.query(query);
            }
            
        }
    }

    //Webservice
    private static String handler;
    public static String getHandler {
        get {
            if(handler==NULL || handler==''){
                RestRequest req = RestContext.request;
                String intSettingFromUrl = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
                String type = intSettingFromUrl;
                String key = RestContext.request.params.get('key');
                System.debug(type +' : '+key);

                List<Account> account = [SELECT Id FROM Account WHERE UUID__c = :key LIMIT 1]; 
                if(!String.isBlank(key)) {
                    if(account.size() > 0) {
                        String accountId = account[0].Id;
                        System.debug(accountId);
                        SYS_DataCacheFactory init = new SYS_DataCacheFactory(
                            accountId,
                            type,
                            type,
                            NULL);
                    } else {
                        throw new SYS_DataCacheFactoryException('\nInvalid key in the webservice URL');
                    }
                } else {
                    INT_TYPE = type;
                }
                System.debug(SYS_DataCacheFactory.INT_TYPE);
                System.debug(SYS_DataCacheFactory.integrationSetting);
                System.debug(enableCheck);
                String extFromUrl = integrationSetting?.ApexHandler__c;
                if(extFromUrl != '' && extFromUrl != NULL){
                    handler = extFromUrl;
                }
                else{
                    handler = 'SYS_ApplicationService';
                }
            }
            return handler;
        }
    }



    public class SYS_DataCacheFactoryException extends Exception{}
}