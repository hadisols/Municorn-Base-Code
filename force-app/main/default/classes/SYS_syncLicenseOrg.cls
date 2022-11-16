public with sharing class SYS_syncLicenseOrg {
    public SYS_syncLicenseOrg() {

    }

    /**
     * invoke this if remotesite setting is deployed
     */
    public static Boolean sendRequest(String endpoint) {
        Boolean result = true;

        Http http = new Http();
        HttpRequest req = new HttpRequest();                            
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setHeader('Content-type', 'application/json');
        req.setBody(getIntSettingRequest());

        HTTPResponse res = http.send(req);
        if (res.getStatusCode() == 200) {
            
            Object obj = JSON.deserializeUntyped(res.getBody());
            Map<String, Object> intSettingMap = new Map<String, Object>();
            Map<String, Object> intMetadataMap = new Map<String, Object>();
            Map<String, String> apiNameMap = new Map<String , String>();
            Map<String, Map<String, Object>> containerMd = new Map<String, Map<String, Object>>();

            List<Object> intMetadataList = new List<Object>();
            intSettingMap = (Map<String, Object>)((Map<String, Object>)obj).get('IntegrationSetting');
            intMetadataList = (List<Object>)((Map<String, Object>)obj).get('IntegrationMetadata');

            apiNameMap.put((String)intSettingMap.get('developername'), 'IntegrationSetting__mdt');
            containerMd.put((String)intSettingMap.get('developername'), (Map<String, Object>)intSettingMap.get('IntMap'));

            for(Object itr : intMetadataList) {
                intMetadataMap = (Map<String, Object>)itr;
                apiNameMap.put((String)intMetadataMap.get('developername'), 'Integration_Metadata__mdt');
                containerMd.put((String)intMetadataMap.get('developername'), (Map<String, Object>)intMetadataMap.get('IntMap'));
            }
            SYS_customMetadataDeploy.requestDeployment(
                apiNameMap, containerMd
            );
            
        } else {
            result = false;
        }
        return result;
    }

    /**
     * check if the remote site setting is available?
     * @return boolean
     */

    public static Boolean IsRemoteSiteSettingAvailable() {
        Boolean result = false;
        String baseurl = URL.getOrgDomainUrl().toExternalForm()+'';
        HttpRequest req = new HttpRequest();                            
        req.setMethod('GET');
        req.setEndpoint(baseurl + '/services/data/v54.0/tooling/query/?q=Select+EndpointUrl,IsActive+from+RemoteProxy');
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());

        Http http = new Http();               
        HTTPResponse res = http.send(req);
        if (res.getStatusCode() == 200) {
            RemoteSiteSettingService respObj = ((RemoteSiteSettingService)JSON.deserialize(res.getBody(), RemoteSiteSettingService.class));
            System.debug(res.getBody());
            List<String> authurls = new List<String>();
            if(respObj?.records != null) {
                for(RemoteSiteSettingService.Records itr : respObj?.records) {
                    if(itr?.IsActive != null && itr?.IsActive && itr?.EndpointUrl != null) {
                        authurls.add(itr?.EndpointUrl);
                    } 
                }
                if(SYS_DataCache.licenseEndpoint != null) {
                    for(String url : authurls) {
                        if(SYS_DataCache.licenseEndpoint.containsIgnoreCase(url)) {
                            return true;
                        } 
                    }
                }
            }
        } else {
            System.debug(res.getBody());
        }
        return result;
    }

    /**
     * Request structure is defined in requestBody.
     */

    public static String getIntSettingRequest() {
        requestBody body = new requestBody();
        body.IntegrationSetting = getIntegrationSetting();
        body.IntegrationMetadata = getIntegrationMetadata();
        body.UserInfo = getUserInfo();
        
        return JSON.serialize(body);
    }

    public class requestBody {
        public Organization OrgInfo{
            get {
                return [SELECT InstanceName, IsSandbox, Name, OrganizationType, Phone  FROM Organization LIMIT 1][0];
            }
        }
        public User UserInfo;
        public IntegrationSetting__mdt IntegrationSetting;
        public List<Integration_Metadata__mdt> IntegrationMetadata;
    }

    public static IntegrationSetting__mdt getIntegrationSetting() {
        return (IntegrationSetting__mdt.getInstance(SYS_DataCache.INT_TYPE));
    }
    public static List<Integration_Metadata__mdt> getIntegrationMetadata() {
        List<Integration_Metadata__mdt> metadata = new List<Integration_Metadata__mdt>();
        for(Integration_Metadata__mdt item : Integration_Metadata__mdt.getAll().values()) {
            if(item.Integration_Setting__r.developername.containsIgnoreCase(SYS_DataCache.INT_TYPE)) {
                metadata.add(item);
            }
        }
        return (metadata);
    }
    public static User getUserInfo() {
        return [SELECT Id, Username, LastName, FirstName, CompanyName, Street, City, 
        State, PostalCode, Country, Latitude, Longitude, Email, Phone, Profile.Name 
        FROM User WHERE Id = : UserInfo.getUserId() ];
    }

    public static Boolean createRemoteSiteSettings(String name, String url) {   
        
        SYS_metadataService.MetadataPort service = createService();
        SYS_metadataService.RemoteSiteSetting remoteSiteSettings = new SYS_metadataService.RemoteSiteSetting();
        remoteSiteSettings.fullName = name;
        remoteSiteSettings.url = url;
        
        remoteSiteSettings.isActive=true;
        remoteSiteSettings.disableProtocolSecurity=false;
        SYS_metadataService.AsyncResult[] results = service.create(new List<SYS_metadataService.Metadata> { remoteSiteSettings });
        SYS_metadataService.AsyncResult[] checkResults = service.checkStatus(new List<string> {string.ValueOf(results[0].Id)});
        
        return checkResults[0].done != null ? checkResults[0].done : false;
    }

    public static SYS_metadataService.MetadataPort createService() {
        SYS_metadataService.MetadataPort service = new SYS_metadataService.MetadataPort();
        service.SessionHeader = new SYS_metadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }
}