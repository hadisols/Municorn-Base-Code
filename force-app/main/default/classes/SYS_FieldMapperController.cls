public with sharing class SYS_FieldMapperController {
    public static integer MAX = 120;
    public static string int_setting = 'Form';

    public SYS_FieldMapperController() {
        List<SYS_FieldMapperController.FieldWrapper> reqFields = new List<SYS_FieldMapperController.FieldWrapper>();
    }

    public class SYS_FieldMapperControllerException extends Exception {}

    @AuraEnabled(cacheable = true)
    public static string getsObjectApiName(Id recordId) {
        String sObjectApiName;
        try {
            sObjectApiName = recordId.getSObjectType().getDescribe().getName();
        } catch (Exception e) {
            throw new SYS_FieldMapperControllerException(e.getMessage());
        }
        return sObjectApiName;
    }

    @AuraEnabled(cacheable = true)
    public static string getSavedJson(Id recordId) {
        String result;
        SYS_FieldMapperService fieldmapper;
        try {
            String objectApiName = SYS_Helper.getsObjectApiName(recordId);
            fieldmapper = SYS_Helper.getMapperService(objectApiName);
            result = fieldmapper.getSavedJson(recordId);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<String> getPicklistValues(String objectName, String fieldName) {
        List<String> picklistValues;
        try {   
            picklistValues = SYS_Helper.getPicklistEntryFor(objectName, fieldName);
        } catch (Exception e) {
            System.debug('Error while fetching picklist values'+e.getStackTraceString()+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return picklistValues;
    }

    @AuraEnabled
    public static Integer deploy(String request, Id recordId) {
        SYS_FieldMapperService fieldmapper;
        Integer count = 0;
        try{
            System.debug('body '+ request);
            String objectApiName = SYS_Helper.getsObjectApiName(recordId);
            fieldmapper = SYS_Helper.getMapperService(objectApiName);

            count = fieldmapper.deployRequest(recordId, request);
            
        } catch(Exception e) {
            System.debug('Error '+e.getStackTraceString()+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return count;
    }

    @AuraEnabled(cacheable=true)
    public static List<SYS_FieldMapperController.FieldWrapper> getSearchResult(String sObjectApiName, 
        String searchKey, Boolean isObjectLookup, SYS_FieldMapperController.FieldWrapper selected) {

        List<SYS_FieldMapperController.FieldWrapper> reqFields = new List<SYS_FieldMapperController.FieldWrapper>();
        String jsonStr;
        try {
            integer size = 0;
            System.debug('bool SP'+isObjectLookup+' : '+sObjectApiName);
            if (isObjectLookup && !String.isBlank(sObjectApiName)) {
                reqFields = getObjectDetails(sObjectApiName, searchkey);
            }
            else if (isObjectLookup) {
                reqFields = getAllObjects(searchKey);
            } else {
                String referenceFieldPrefix = '';
                if(selected != NULL && selected?.parentSObject != NULL) {
                    sObjectApiName = selected?.parentSObject;
                    referenceFieldPrefix = selected?.apiname;
                }
                System.debug('sObjectApiName '+sObjectApiName + 'selected '+JSON.serializePretty(selected));
                if(searchkey?.contains('.')) {
                    searchkey = searchkey.substringAfterLast('.');
                }
                for(SYS_FieldMapperController.FieldWrapper item:getFields(sObjectApiName) ) {
                    if(size >= MAX ) break;
                    else if(item.apiname.containsIgnorecase(searchkey) || 
                                item.label.containsIgnorecase(searchkey) ){
                        item.apiname = referenceFieldPrefix + item.apiname;
                        item.FieldApiName = referenceFieldPrefix + item.FieldApiName; 
                        reqFields.add(item);
                        size++;
                    }
                }
            }
            
            // reqFields.addAll(getFields(sObjectApiName));
            
        } catch (Exception e) {
            System.debug('Error '+e.getStackTraceString()+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return reqFields;
    }
    /**
     * TODO - to be implemented for framework
     * need to use this method for setting outbound FS
     */
    public static String getObjectApiname(String objectName, String fieldName) {
        String result;
        Schema.DescribeFieldResult f = Schema.getGlobalDescribe()
            .get(objectName)
            .getDescribe()
            .fields
            .getMap()
            .get(fieldName)
            .getDescribe();

        for(Schema.SObjectType reference : f.getReferenceTo()) {
            System.debug('Lookup reference object name: ' + reference.getDescribe().getName());
            result = reference.getDescribe().getName();
            break;
        }
        return result;
    }

    public static List<SYS_FieldMapperController.FieldWrapper> getFieldspoc(String objectApiName) {
        List<SYS_FieldMapperController.FieldWrapper> reqFields = new List<SYS_FieldMapperController.FieldWrapper>();

        Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(objectApiName);
        Schema.DescribeSObjectResult r = sobjType.getDescribe();
        Map<String, Schema.SObjectField> MapofField = r.fields.getMap();
        
        String names = r.getAssociateParentEntity();
        System.debug('parent '+names);

        for(String fieldName : MapofField.keySet()) {
            Schema.SObjectField field = MapofField.get(fieldName);
            Schema.DescribeFieldResult F = field.getDescribe();
            if(F.isCreateable()) {
                SYS_FieldMapperController.FieldWrapper  fieldObj = new SYS_FieldMapperController.FieldWrapper();
                fieldObj.key = String.valueOf(field);
                fieldObj.value = String.valueOf(field);
                fieldObj.uuid = SYS_Helper.getUUID();
                fieldObj.apiname = F.getName();
                fieldObj.label = F.getLabel();
                fieldObj.item = new List<SYS_FieldMapperController.FieldWrapper>();
                fieldObj.expand = false;
                fieldObj.type = String.valueOf(F.getType());
                fieldObj.sObjectApiName = objectApiName;
                fieldObj.sObjectLabel = r.getLabel();
                fieldObj.FieldApiName = F.getName();
                fieldObj.fieldLabel = F.getLabel(); 
                System.debug('SP '+field+' : '+F.getType()+' : '+F.getReferenceTo()+' : '+F.isNamePointing());
                reqFields.add(fieldObj);
            }
        }
        System.debug(reqFields);
        return reqFields;
    }


    public static List<SYS_FieldMapperController.FieldWrapper> getAllObjects( String searchKey){
        List<SYS_FieldMapperController.FieldWrapper> reqFields = new List<SYS_FieldMapperController.FieldWrapper>();
        
        integer size = 0;
        for(EntityDefinition item:[SELECT  QualifiedApiName , IsEverCreatable, masterlabel,
        IsSearchable, IsCustomSetting, IsApexTriggerable, IsCustomizable, IsDeprecatedAndHidden,
        IsSearchLayoutable FROM EntityDefinition where IsApexTriggerable= true and 
        IsCustomizable=true and IsDeprecatedAndHidden = false and IsIdEnabled= true and 
        IsSearchLayoutable=true
        order by QualifiedApiName ] ) {
            if(size >= MAX ) break;
            else if(item.QualifiedApiName.containsIgnorecase(searchkey) || 
                        item.masterlabel.containsIgnorecase(searchkey) ){
                SYS_FieldMapperController.FieldWrapper objectWrap = new SYS_FieldMapperController.FieldWrapper();
                objectWrap.key = item.QualifiedApiName;
                objectWrap.value = item.QualifiedApiName;
                objectWrap.uuid = SYS_Helper.getUUID();
                objectWrap.apiname = item.QualifiedApiName;
                objectWrap.label = item.masterlabel;
                objectWrap.item = new List<SYS_FieldMapperController.FieldWrapper>();
                objectWrap.type = item.QualifiedApiName?.containsIgnorecase('__c') ? 'Custom Object' : 'Standard Object';
                objectWrap.sObjectApiName = item.QualifiedApiName;
                objectWrap.sObjectLabel = item.masterlabel;
                reqFields.add(objectWrap);
                size++; 
            }
        }   
       
        return reqFields;
    }


    @AuraEnabled(cacheable=true)
    public static List<SYS_FieldMapperController.FieldWrapper> getObjectDetails(String objectApiName, String searchkey){
        List<SYS_FieldMapperController.FieldWrapper> reqFields = new List<SYS_FieldMapperController.FieldWrapper>();
        String jsonStr;
        try {
            
            Map<string,string> objectRelationshipMap = new Map<string,string>();

            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            for(String ss1: schemaMap.keyset()){
                Schema.SObjectType objToken=schemaMap.get(ss1);
                if(ss1.equalsignorecase(objectApiName)){
                    //find details about sobject
                    integer size = 0;
                    Schema.DescribeSObjectResult objDescribe=objToken.getdescribe();
                    List<Schema.ChildRelationship> childRelationshipList = objDescribe.getChildRelationships();
                    for(Schema.ChildRelationship ss:childRelationshipList){
                        Schema.SObjectType st = ss.getChildSObject();
                        Schema.DescribeSObjectResult d = st.getDescribe();
                        
                        if(size >= MAX ) break; 
                        
                        else if((d.getName().containsIgnorecase(searchkey) || 
                        d.getLabel().containsIgnorecase(searchkey) )) {
                            
                            if( (d.isCustom() && !d.isCustomSetting()) || 
                            ( d.isCreateable() && d.isMruEnabled() &&
                             d.isUpdateable() && d.isDeletable() && d.isSearchable()) ) {
                                
    
                                SYS_FieldMapperController.FieldWrapper  fieldObj = new SYS_FieldMapperController.FieldWrapper();
                                fieldObj.key = String.valueOf(ss.getChildSObject());
                                fieldObj.value = String.valueOf(ss.getField());
                                fieldObj.uuid = SYS_Helper.getUUID();
                                fieldObj.apiname = String.valueOf(ss.getChildSObject());
                                fieldObj.label = d.getLabel();
                                // fieldObj.item = getFields(String.valueOf(ss.getChildSObject()));
                                fieldObj.expand = false;
                                fieldObj.type = 'List';
                                fieldObj.sObjectApiName = d.getName();
                                fieldObj.sObjectLabel = d.getLabel();
                                // fieldObj.fieldApiName = ;
                                // fieldObj.fieldLabel = F.getLabel(); 
                                reqFields.add(fieldObj);
                                size++;
                            }
                        }
                        
                        
                    }
                    break;
                }
            }
            System.debug('reqFields '+ JSON.serialize(reqFields));
            // jsonStr = JSON.serialize(reqFields);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return reqFields;
    }

    public static List<SYS_FieldMapperController.FieldWrapper> getFields(String objectApiName) {
        List<SYS_FieldMapperController.FieldWrapper> reqFields = new List<SYS_FieldMapperController.FieldWrapper>();

        Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(objectApiName);
        Schema.DescribeSObjectResult r = sobjType.getDescribe();
        Map<String, Schema.SObjectField> MapofField = r.fields.getMap();
        
        for(String fieldName : MapofField.keySet()) {
            Schema.SObjectField field = MapofField.get(fieldName);
            Schema.DescribeFieldResult F = field.getDescribe();
            if(F.isCreateable()) {
                SYS_FieldMapperController.FieldWrapper  fieldObj = new SYS_FieldMapperController.FieldWrapper();
                fieldObj.key = String.valueOf(field);
                fieldObj.value = String.valueOf(field);
                fieldObj.uuid = SYS_Helper.getUUID();
                fieldObj.apiname = F.getName();
                fieldObj.label = F.getLabel();
                fieldObj.item = new List<SYS_FieldMapperController.FieldWrapper>();
                fieldObj.expand = false;
                fieldObj.type = String.valueOf(F.getType());
                fieldObj.sObjectApiName = objectApiName;
                fieldObj.sObjectLabel = r.getLabel();
                fieldObj.FieldApiName = F.getName();
                fieldObj.fieldLabel = F.getLabel(); 
                System.debug('SP '+field+' : '+F.getType()+' : '+F.getReferenceTo()+' : '+F.isNamePointing());
                reqFields.add(fieldObj);

                String referencedObjectApiName = '';
                // Custom Lookup field
                if (F.getType() == Schema.DisplayType.REFERENCE && F.isCustom()) {
                    List<Schema.SObjectType> referencedSObjects = F.getReferenceTo();
                    if (!referencedSObjects.isEmpty()) {
                        referencedObjectApiName = referencedSObjects[0].getDescribe().getName();
                        System.debug('Referenced sObject API Name: ' + referencedObjectApiName);
                    }
                    String apiname = String.valueof(F.getName()).removeEndIgnoreCase('__c') + '__r.';

                    fieldObj = new SYS_FieldMapperController.FieldWrapper();
                    fieldObj.key = String.valueOf(field);
                    fieldObj.value = String.valueOf(field);
                    fieldObj.uuid = SYS_Helper.getUUID();
                    fieldObj.apiname = apiname;
                    fieldObj.label = F.getLabel();
                    fieldObj.item = new List<SYS_FieldMapperController.FieldWrapper>();
                    fieldObj.expand = true;
                    fieldObj.type = String.valueOf(F.getType());
                    fieldObj.sObjectApiName = objectApiName;
                    fieldObj.sObjectLabel = r.getLabel();
                    fieldObj.FieldApiName = apiname;
                    fieldObj.fieldLabel = F.getLabel();
                    fieldObj.parentSObject = referencedObjectApiName;
                    System.debug('SP '+field+' : '+F.getType()+' : '+F.getReferenceTo()+' : '+F.isNamePointing());
                    reqFields.add(fieldObj);
                } 
                // Standard Lookup
                else if (F.getType() == Schema.DisplayType.REFERENCE ) {
                    List<Schema.SObjectType> referencedSObjects = F.getReferenceTo();
                    if (!referencedSObjects.isEmpty()) {
                        referencedObjectApiName = referencedSObjects[0].getDescribe().getName();
                        System.debug('Referenced sObject API Name: ' + referencedObjectApiName);
                    }
                    String apiname = String.valueof(F.getName()).removeEndIgnoreCase('id') +'.';
                    fieldObj = new SYS_FieldMapperController.FieldWrapper();
                    fieldObj.key = String.valueOf(field);
                    fieldObj.value = String.valueOf(field);
                    fieldObj.uuid = SYS_Helper.getUUID();
                    fieldObj.apiname = apiname;
                    fieldObj.label = F.getLabel();
                    fieldObj.item = new List<SYS_FieldMapperController.FieldWrapper>();
                    fieldObj.expand = true;
                    fieldObj.type = String.valueOf(F.getType());
                    fieldObj.sObjectApiName = objectApiName;
                    fieldObj.sObjectLabel = r.getLabel();
                    fieldObj.FieldApiName = apiname;
                    fieldObj.fieldLabel = F.getLabel(); 
                    fieldObj.parentSObject = referencedObjectApiName;
                    System.debug('SP '+field+' : '+F.getType()+' : '+F.getReferenceTo()+' : '+F.isNamePointing());
                    reqFields.add(fieldObj);
                }
            }
        }
        System.debug(reqFields);
        return reqFields;
    }

    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName) {    
        List < sObject > returnList = new List < sObject > ();
        string sWildCardText = '%' + searchKey + '%';
        string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Name Like : sWildCardText order by createdDate DESC LIMIT 5';
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    // Method to fetch lookup default value 
    @AuraEnabled
    public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
        string sRecId = recordId;    
        string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
        for (sObject obj: database.query(sQuery)) {
            return obj;
        }
        return null;
    }

    
    public class FieldWrapper {
        // @AuraEnabled
        // public String key { get; set; }
        @AuraEnabled
        public String value { get; set; }
        @AuraEnabled
        public String uuid { get; set; }
        @AuraEnabled
        public String apiname { get; set; }
        // @AuraEnabled
        // public String label { get; set; }
        @AuraEnabled
        public List<FieldWrapper> item { get; set; }
        @AuraEnabled
        public Boolean expand { get; set; }
        @AuraEnabled
        public String sObjectApiName { get; set; }
        @AuraEnabled
        public String sObjectLabel { get; set; }
        // @AuraEnabled
        // public String fieldApiName { get; set; }
        @AuraEnabled
        public String fieldLabel { get; set; }
        @AuraEnabled
        public String type { get; set; }
        @AuraEnabled
        public String flatkey { get; set; }
        @AuraEnabled
        public String rootkey { get; set; }
        @AuraEnabled
        public String parentSObject { get; set; }
        @AuraEnabled
        public FieldSetting fieldSetting { get; set; }
        @AuraEnabled
        public String primarySObjectApiName { get; set; }

        @AuraEnabled
        public String developername;
        @AuraEnabled
        public String label;
        
        
        @AuraEnabled
        public String Direction;
        @AuraEnabled
        public String FieldApiName;
        @AuraEnabled
        public String Field_Mapping_Handler;
        @AuraEnabled
        public Boolean Is_Active;
        @AuraEnabled
        public String Key;
        @AuraEnabled
        public String ObjectApiName;
        @AuraEnabled
        public String ObjectSetting;
        @AuraEnabled
        public Boolean Skip_Field_Setting;
        @AuraEnabled
        public String StaticValue;

        @AuraEnabled
        public String Key_For_Events;
        @AuraEnabled
        public String RestResource;
        @AuraEnabled
        public Boolean Is_External_Field;
        @AuraEnabled
        public Boolean Is_Lookup;
        @AuraEnabled
        public String Lookup_Object_API_Name;
        @AuraEnabled
        public String Datetime_Conversion_Format;
        @AuraEnabled
        public Boolean Get_value_from_Log;
        @AuraEnabled
        public String Log_API_for_field_mapping;
        @AuraEnabled
        public String Lookup_External_Key;

        @AuraEnabled
        public String Mapping_is_for;
        @AuraEnabled
        public String Level;
        @AuraEnabled
        public Boolean Send_Blanks_as_Empty_String;
        @AuraEnabled
        public String ChildRootElement;
        @AuraEnabled
        public String ParentField;
    }

    public class FieldSetting {
        @AuraEnabled
        public String developername;
        @AuraEnabled
        public String label;
        
        
        @AuraEnabled
        public String Direction;
        @AuraEnabled
        public String FieldApiName;
        @AuraEnabled
        public String Field_Mapping_Handler;
        @AuraEnabled
        public Boolean Is_Active;
        @AuraEnabled
        public String Key;
        @AuraEnabled
        public String ObjectApiName;
        @AuraEnabled
        public String ObjectSetting;
        @AuraEnabled
        public Boolean Skip_Field_Setting;
        @AuraEnabled
        public String StaticValue;

        @AuraEnabled
        public String Key_For_Events;
        @AuraEnabled
        public String RestResource;
        @AuraEnabled
        public Boolean Is_External_Field;
        @AuraEnabled
        public Boolean Is_Lookup;
        @AuraEnabled
        public String Lookup_Object_API_Name;
        @AuraEnabled
        public String Datetime_Conversion_Format;
        @AuraEnabled
        public Boolean Get_value_from_Log;
        @AuraEnabled
        public String Log_API_for_field_mapping;
        @AuraEnabled
        public String Lookup_External_Key;

        @AuraEnabled
        public String Mapping_is_for;
        @AuraEnabled
        public String Level;
        @AuraEnabled
        public Boolean Send_Blanks_as_Empty_String;
        @AuraEnabled
        public String ChildRootElement;
        @AuraEnabled
        public String ParentField;

    }

    public class ObjectSetting {

    }
}

/**
 * 
//FS

// fieldWithValuesMap.put('ChildFieldApiName__c',);
// fieldWithValuesMap.put('ChildRootElement__c',);
// fieldWithValuesMap.put('Datetime_Conversion_Format__c',);
// fieldWithValuesMap.put('Get_value_from_Log__c', );
// fieldWithValuesMap.put('IsChild__c',);
// fieldWithValuesMap.put('Is_External_Field__c',);
// fieldWithValuesMap.put('Is_Lookup__c',);
// fieldWithValuesMap.put('Key_For_Events__c',);
// fieldWithValuesMap.put('Log_API_for_field_mapping__c',);
// fieldWithValuesMap.put('Lookup_External_Key__c',);
// fieldWithValuesMap.put('Lookup_Object_API_Name__c',);
// fieldWithValuesMap.put('Mapping_is_for__c',);
// fieldWithValuesMap.put('ParentField__c',);
// fieldWithValuesMap.put('RestResource__c',);
// fieldWithValuesMap.put('Send_Blanks_as_Empty_String__c',);
// fieldWithValuesMap.put('StaticValue__c',);

// OS

// fieldWithValuesMap.put('Always_Ignore_Response__c', '');
// fieldWithValuesMap.put('BypassTrigger__c', '');
// fieldWithValuesMap.put('Created_Source_FieldApiName__c', '');
// fieldWithValuesMap.put('DELETE_URL_Pattern__c', '');
// fieldWithValuesMap.put('ExternalFieldApi__c', '');
// fieldWithValuesMap.put('GET_URL_Pattern__c', '');
// fieldWithValuesMap.put('isInboundList__c', '');
// fieldWithValuesMap.put('Modified_Source_FieldApiName__c', '');
// fieldWithValuesMap.put('PATCH_URL_Pattern__c', '');
// fieldWithValuesMap.put('POST_URL_Pattern__c', '');
// fieldWithValuesMap.put('All_OR_None__c', '');
// fieldWithValuesMap.put('PUT_URL_Pattern__c', '');
// fieldWithValuesMap.put('QueryClause__c', '');
// fieldWithValuesMap.put('Resource_Name__c', '');
// fieldWithValuesMap.put('ResourcePath__c', '');
 */