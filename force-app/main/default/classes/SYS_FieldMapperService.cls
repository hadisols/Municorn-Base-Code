public virtual inherited sharing class SYS_FieldMapperService {
    public class SYS_FieldMapperServiceException extends Exception {}

    public virtual String getSavedJson(Id recordId) {
        String jsonBody = '{}'; 
        try {
            

        } catch (Exception e) {
            System.debug(e.getStackTraceString() + e.getMessage());
            throw new SYS_FieldMapperServiceException('Some error occured. '+e.getMessage());
        }
        return jsonBody;
    }

    public virtual void deployRequest(Id recordId, String request) {
        try {
            List<SYS_FieldMapperController.FieldWrapper> fslist = 
            (List<SYS_FieldMapperController.FieldWrapper>)JSON.deserialize(request, List<SYS_FieldMapperController.FieldWrapper>.class);
            
            String objectSettingname = '';

            Map<String, String> apiNameMap = new Map<String , String>();
            Map<String, Map<String, Object>> containerMd = new Map<String, Map<String, Object>>();

            //container for Object Setting.
            
            if(fslist.size() > 0) {
                Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
                objectSettingname = 'ObjectSetting_'+fslist[0]?.primarySObjectApiName;

                fieldWithValuesMap.put('ApexHandler__c', 'SYS_ApplicationService');
                fieldWithValuesMap.put('IntegrationType__c', 'Form');
                fieldWithValuesMap.put('ObjectApiName__c', fslist[0]?.primarySObjectApiName);
                fieldWithValuesMap.put('Skip_Keys__c', '');
                fieldWithValuesMap.put('Trigger_Condition__c', '');
                fieldWithValuesMap.put('TriggerEvents__c', '');
                fieldWithValuesMap.put('url_params__c', '');

                apiNameMap.put(objectSettingname, 'ObjectSetting__mdt');
                containerMd.put(objectSettingname, fieldWithValuesMap);
            }

            getFSToDeactivate(objectSettingname, apiNameMap, containerMd);
            // if(recordId != NULL) {
                // Custom_Form__c form = new Custom_Form__c(
                //     Id = recordId,
                //     Object_Setting__c = objectSettingname
                // );
                // update form;
            // }

            //container for field settings
            integer count = 1;
            for(SYS_FieldMapperController.FieldWrapper item:fslist) {
                Map<String, Object> fieldWithValuesMap = new Map<String, Object>();

                // fieldWithValuesMap.put('Direction__c', SYS_Constants.INBOUND);
                // fieldWithValuesMap.put('FieldApiName__c', item.fieldApiName);
                // fieldWithValuesMap.put('Field_Mapping_Handler__c', 'SYS_ApplicationService');
                // fieldWithValuesMap.put('Is_Active__c', true);
                // fieldWithValuesMap.put('Key__c', item.flatkey);
                // fieldWithValuesMap.put('Level__c','0');
                // fieldWithValuesMap.put('ObjectApiName__c', item.sObjectApiName);

                
                fieldWithValuesMap.put('Direction__c', item.Direction);
                fieldWithValuesMap.put('FieldApiName__c', item.FieldApiName);
                fieldWithValuesMap.put('Field_Mapping_Handler__c', item.Field_Mapping_Handler);
                fieldWithValuesMap.put('Is_Active__c', item.Is_Active );
                fieldWithValuesMap.put('Key__c', item.Key);
                fieldWithValuesMap.put('ObjectApiName__c', item.ObjectApiName);
                fieldWithValuesMap.put('ObjectSetting__c', item.ObjectSetting);
                fieldWithValuesMap.put('Skip_Field_Setting__c', item.Skip_Field_Setting);
                fieldWithValuesMap.put('StaticValue__c', item.StaticValue);
                fieldWithValuesMap.put('Key_For_Events__c', item.Key_For_Events);
                fieldWithValuesMap.put('RestResource__c', item.RestResource);
                fieldWithValuesMap.put('Is_External_Field__c', item.Is_External_Field);
                fieldWithValuesMap.put('Is_Lookup__c', item.Is_Lookup);
                fieldWithValuesMap.put('Lookup_Object_API_Name__c', item.Lookup_Object_API_Name);
                fieldWithValuesMap.put('Datetime_Conversion_Format__c', item.Datetime_Conversion_Format);
                fieldWithValuesMap.put('Get_value_from_Log__c', item.Get_value_from_Log);
                fieldWithValuesMap.put('Log_API_for_field_mapping__c', item.Log_API_for_field_mapping);
                fieldWithValuesMap.put('Lookup_External_Key__c', item.Lookup_External_Key);
                fieldWithValuesMap.put('Mapping_is_for__c', item.Mapping_is_for);
                fieldWithValuesMap.put('Level__c', item.Level);
                fieldWithValuesMap.put('Send_Blanks_as_Empty_String__c', item.Send_Blanks_as_Empty_String);
                fieldWithValuesMap.put('ChildRootElement__c', item.ChildRootElement);
                fieldWithValuesMap.put('ParentField__c', item.ParentField);


                //TODO- create object setting after selecting primary object.
                fieldWithValuesMap.put('ObjectSetting__c', objectSettingname);
                

                // apiNameMap.put('FS_' + item.FieldApiName + count, 'FieldSetting__mdt');
                // containerMd.put('FS_' + item.FieldApiName + count, fieldWithValuesMap);

                String developername = 'a'+item.developername.replaceAll('-','_');
                apiNameMap.put(developername, 'FieldSetting__mdt');
                containerMd.put(developername, fieldWithValuesMap);
                count++;
            }

            /**
             * @apiNameMap contains map of developername and cmd apiname
             * @containerMd contains map of developername and field<-->value cmd
             */
            SYS_customMetadataDeploy.requestDeployment(
                apiNameMap, containerMd
            );
        } catch (Exception e) {
            System.debug(e.getStackTraceString() + e.getMessage());
            throw new SYS_FieldMapperServiceException('Some error occured. '+e.getMessage());
        }
    }

    public static void getFSToDeactivate(String objectSettingname, Map<String, String> apiNameMap, Map<String, Map<String, Object>> containerMd) {
        List<FieldSetting__mdt> fieldSetting = [SELECT developername FROM FieldSetting__mdt WHERE ObjectSetting__r.developerName =:objectSettingname and Is_Active__c=true];
        for(FieldSetting__mdt fs:fieldSetting) {
            Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
            fieldWithValuesMap.put('Is_Active__c', false );
            apiNameMap.put(fs.developername, 'FieldSetting__mdt');
            containerMd.put(fs.developername, fieldWithValuesMap);
        }
    }
}