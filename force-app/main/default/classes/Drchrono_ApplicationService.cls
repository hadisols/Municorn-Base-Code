public class Drchrono_ApplicationService extends SYS_ApplicationService {
    Public static final map < string, string > mapEvent = new map < string, string > {
        'PATIENT_CREATE' => '/api/patients',
        'PATIENT_ALLERGY_CREATE' => '/api/allergies',
        'PATIENT_MEDICATION_CREATE' => '/api/medications',
        'PATIENT_PROBLEM_CREATE' => '/api/problems',
         'PATIENT_ALLERGY_MODIFY'=>'/api/allergies',
          'PATIENT_MODIFY' => '/api/patients',
        'PATIENT_MEDICATION_MODIFY' => '/api/medications',
        'PATIENT_PROBLEM_MODIFY' => '/api/problems'
    };
   

    public override SYS_IntegrationLog__c generateLogForWebhookReq(String method) {
        String requestBody = RestContext.request.requestBody.toString();
        String headerName = RestContext.request.headers.get('X-drchrono-event');
        system.debug('headerName--' + headerName);
        //JSON Without any Chunking to subJOSN
      
        Map < String, Object > jsonResp = (Map < String, Object > ) JSON.deserializeUntyped(requestBody);
        String JsonrequestBody = JSON.serialize(jsonResp.get('object'));
        SYS_IntegrationLog__c log = SYS_Helper.getLogsToInsert(JsonrequestBody);
        String algo = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Hashing_Algo__c;
        system.debug('JsonrequestBody--' + JsonrequestBody);
        system.debug('int1');
        if (algo != NULL && algo != '')
            log.Request_Digest__c = generateHash(requestBody, algo);
        log.Type__c = 'INBOUND';
        log.SYS_Operation_Type__c = getOperationTypeFor(method);
        log.Flat_Key_for_Resource__c = 'attributes.type';
        log.SYS_IntegrationSettings__c = SYS_DataCache.INT_TYPE;
        log.Status__c = 'NEW';
        //log.External_Id_Field_API_Name__c = 'SYS_Key__c';
        log.How_to_process__c = 'use_custom_apex_handler';
        log.Custom_Apex_Handler__c = 'Drchrono_ApplicationService';

        log.Resource__c = mapEvent.get(headerName);
        system.debug('Resource__c--' + log.Resource__c);
        return log;
    }
  
    public override void doGet() {
        String message = RestContext.request.params.get('msg');
        System.debug('message : ' + message);
        String token = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).webhookToken__c;
        Blob key = Blob.valueOf(token);

        String secret_token = encodingUtil.convertToHex(Crypto.generateMac('hmacSHA256', Blob.valueof(message), key));

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('secret_token', secret_token);
        gen.writeEndObject();
        system.debug('secret_token--' + gen.getAsString());
        RestContext.response.responseBody = Blob.valueOf(gen.getAsString());
        RestContext.response.statuscode = 200;
    }
    public override sObject processFieldMapping(FieldSetting__mdt mapping, sObject sObj, Object value, String sObjectApiName) {

        System.debug(mapping.FieldApiName__c + ' +MS+ ' + value);
        if (mapping.Get_value_from_Log__c)
            value = SYS_DataCache.log.get(mapping.Log_API_for_field_mapping__c);

        if (mapping.Is_Lookup__c && mapping.Lookup_External_Key__c != NULL && mapping.Lookup_Object_API_Name__c != NULL) {
            value = getIdFromExternalKey(mapping.Lookup_Object_API_Name__c, mapping.Lookup_External_Key__c, String.valueOf(value));
        }

        if (mapping.StaticValue__c != NULL)
            value = mapping.StaticValue__c;


        if (value == NULL) return sObj;


        SObjectType r = ((SObject)(Type.forName('Schema.' + sObjectApiName).newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();

        String fieldType = d.fields
            .getMap()
            .get(mapping.FieldApiName__c)
            .getDescribe()
            .getType() + '';


        //TODO add other field types
        if (mapping.FieldApiName__c == 'External_Id__c' && value != null) {
            system.debug('Test Record create');
            sObj.put(mapping.FieldApiName__c, String.valueof(value));
        } else if (fieldType == 'DATE') {
            sObj.put(mapping.FieldApiName__c, date.valueOf((String) value));
        } else if (fieldType == 'STRING') {
            sObj.put(mapping.FieldApiName__c, String.valueof(value));
        } else if (fieldType == 'BOOLEAN') {
            sObj.put(mapping.FieldApiName__c, Boolean.valueof(value));
        } else {
            sObj.put(mapping.FieldApiName__c, value);
        }

        SYS_debug.log('MS FINAL SOBJ:' + sObj);
        return sObj;
    }
}