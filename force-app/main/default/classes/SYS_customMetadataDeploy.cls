public with sharing class SYS_customMetadataDeploy implements Metadata.DeployCallback{

    public Map<String, String> apiNameMap;
    public Map<String, Map<String, Object>> containerMd;

    public SYS_customMetadataDeploy(Map<String, String> apiNameMap, Map<String, Map<String, Object>> containerMd) {
        this.apiNameMap = apiNameMap;
        this.containerMd = containerMd;
    }

    public void handleResult(Metadata.DeployResult result,
                             Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            // Deployment was successful
            System.debug('successful');
            System.debug(JSON.serialize(result));
            requestDeployment(this.apiNameMap, this.containerMd);
        } else {
            // Deployment was not successful
            System.debug('failed'+JSON.serialize(result));
        }
    }

    public static void getDeploymentStatus(String jobId) {
        String deploymessage = getDeploymentMessage(jobId);
        
        if( deploymessage != 'Pending' || deploymessage != 'InProgress' || deploymessage != 'Canceling') {
            /**
             * Success message 
             */
            
        } else {
            /**
             * failed message
             */
        } 
        
    }

    /**
     * @brief used to check the deployment status from the jobId
     */

    public static String getDeploymentMessage(String jobId){
        String message = '';
        String baseUrl = System.Url.getOrgDomainUrl().toExternalForm() +'/services/data/v50.0/metadata/deployRequest/'+ jobId +'?includeDetails=true';
        System.debug('baseurl ='+baseUrl);
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint(baseUrl);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');

        Http h = new Http();
        HttpResponse res = h.send(req);
        
        if (res.getStatusCode() == 200) {
            SYS_metadataService.DeploymentRequest respObj = ((SYS_metadataService.DeploymentRequest)JSON.deserialize(res.getBody(), SYS_metadataService.DeploymentRequest.class));
            System.debug(res.getBody());
            message = respObj?.deployResult?.status;
            System.debug(message);
            
        } else {
            System.debug(res.getBody());
            
        }

        return message;
    }

    /**
     * @brief used to create metadata container
     * @param1 authconfig name
     * @param2 map of field name and value name
     * @return metadataContainer to be deployed
     */

    private static Metadata.DeployContainer createUpdateMetadata(String fullName, String label, Map<String, Object> fieldWithValuesMap) {
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = SYS_DataCache.namespacePrefix + fullName;
        customMetadata.label = label;

        for(String key : fieldWithValuesMap.keySet()){
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = SYS_DataCache.namespacePrefix + key;
            customField.value = fieldWithValuesMap.get(key); 
            customMetadata.values.add(customField);
        }

        System.debug('SP metadata'+customMetadata);

        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);

        return mdContainer;
    }

    public static String requestDeployment(Map<String, String> apiNameMap, Map<String, Map<String, Object>> containerMd) {
        Id jobId;
        
        if(apiNameMap.isEmpty()) { //TODO - deployment success message

            return jobId;
        }
        String label = apiNameMap.keySet().iterator().next();
        String fullname = apiNameMap.get(label) + '.' + label;
        Map<String, Object> fieldWithValuesMap = containerMd.get(label);

        Metadata.DeployContainer mdContainer = createUpdateMetadata(fullname, label, fieldWithValuesMap);
        apiNameMap.remove(label);
        containerMd.remove(label);
        
        SYS_customMetadataDeploy callback = new SYS_customMetadataDeploy(apiNameMap, containerMd);
        if(!Test.isRunningTest())
            jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);

        System.debug('jobId = '+jobId);
        
        return jobId;
    }
}