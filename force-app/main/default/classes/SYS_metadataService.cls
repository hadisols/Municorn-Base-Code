public class SYS_metadataService {

    public class RemoteSiteSetting extends Metadata {
        public String type = 'RemoteSiteSetting';
        public String fullName;
        public String description;
        public Boolean disableProtocolSecurity;
        public Boolean isActive;
        public String url;
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] fullName_type_info = new String[]{'fullName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] description_type_info = new String[]{'description','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] disableProtocolSecurity_type_info = new String[]{'disableProtocolSecurity','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] isActive_type_info = new String[]{'isActive','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] url_type_info = new String[]{'url','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'fullName','description','disableProtocolSecurity','isActive','url'};
    }
     
   
    public class createResponse_element {
        public SYS_metadataService.AsyncResult[] result;
        private String[] result_type_info = new String[]{'result','http://soap.sforce.com/2006/04/metadata','AsyncResult','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
           
    public class MetadataPort {
        public String endpoint_x;
        {
            // Workaround to platform bug (?) where the following method returns a none HTTPS URL in a Batch Apex context
            URL baseUrl = URL.getSalesforceBaseUrl();
            System.debug('Protocol is ' + baseUrl.getProtocol());
            if(baseUrl.getProtocol() == 'http')
                baseUrl = new URL('https', baseUrl.getHost(), baseUrl.getPort(), baseUrl.getFile()); // Switch to https protocol
            endpoint_x = baseUrl.toExternalForm() + '/services/Soap/m/27.0';
        }
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        public SYS_metadataService.SessionHeader_element SessionHeader;
        public SYS_metadataService.DebuggingInfo_element DebuggingInfo;
        public SYS_metadataService.CallOptions_element CallOptions;
        public SYS_metadataService.DebuggingHeader_element DebuggingHeader;
        private String SessionHeader_hns = 'SessionHeader=http://soap.sforce.com/2006/04/metadata';
        private String DebuggingInfo_hns = 'DebuggingInfo=http://soap.sforce.com/2006/04/metadata';
        private String CallOptions_hns = 'CallOptions=http://soap.sforce.com/2006/04/metadata';
        private String DebuggingHeader_hns = 'DebuggingHeader=http://soap.sforce.com/2006/04/metadata';
        private String[] ns_map_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata', 'SYS_metadataService'};
               
        
        public SYS_metadataService.AsyncResult[] create(SYS_metadataService.Metadata[] metadata) {
            SYS_metadataService.create_element request_x = new SYS_metadataService.create_element();
            SYS_metadataService.createResponse_element response_x;
            request_x.metadata = metadata;
            Map<String, SYS_metadataService.createResponse_element> response_map_x = new Map<String, SYS_metadataService.createResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soap.sforce.com/2006/04/metadata',
              'create',
              'http://soap.sforce.com/2006/04/metadata',
              'createResponse',
              'SYS_metadataService.createResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            system.debug('respo' + response_x.result);
            return response_x.result;
        }
       
        public SYS_metadataService.AsyncResult[] checkStatus(String[] asyncProcessId) {
            SYS_metadataService.checkStatus_element request_x = new SYS_metadataService.checkStatus_element();
            SYS_metadataService.checkStatusResponse_element response_x;
            request_x.asyncProcessId = asyncProcessId;
            Map<String, SYS_metadataService.checkStatusResponse_element> response_map_x = new Map<String, SYS_metadataService.checkStatusResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soap.sforce.com/2006/04/metadata',
              'checkStatus',
              'http://soap.sforce.com/2006/04/metadata',
              'checkStatusResponse',
              'SYS_metadataService.checkStatusResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            System.debug('SP resp'+response_x);
            return response_x.result;
        }
   
    }
    
    
    public class AsyncResult {
        public Boolean checkOnly;
        public Boolean done;
        public String id;
        public String message;
        public Integer numberComponentErrors;
        public Integer numberComponentsDeployed;
        public Integer numberComponentsTotal;
        public Integer numberTestErrors;
        public Integer numberTestsCompleted;
        public Integer numberTestsTotal;
        public String state;
        public String stateDetail;
        public DateTime stateDetailLastModifiedDate;
        public String statusCode;
        private String[] checkOnly_type_info = new String[]{'checkOnly','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] done_type_info = new String[]{'done','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] id_type_info = new String[]{'id','http://soap.sforce.com/2006/04/metadata','ID','1','1','false'};
        private String[] message_type_info = new String[]{'message','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] numberComponentErrors_type_info = new String[]{'numberComponentErrors','http://www.w3.org/2001/XMLSchema','int','0','1','false'};
        private String[] numberComponentsDeployed_type_info = new String[]{'numberComponentsDeployed','http://www.w3.org/2001/XMLSchema','int','0','1','false'};
        private String[] numberComponentsTotal_type_info = new String[]{'numberComponentsTotal','http://www.w3.org/2001/XMLSchema','int','0','1','false'};
        private String[] numberTestErrors_type_info = new String[]{'numberTestErrors','http://www.w3.org/2001/XMLSchema','int','0','1','false'};
        private String[] numberTestsCompleted_type_info = new String[]{'numberTestsCompleted','http://www.w3.org/2001/XMLSchema','int','0','1','false'};
        private String[] numberTestsTotal_type_info = new String[]{'numberTestsTotal','http://www.w3.org/2001/XMLSchema','int','0','1','false'};
        private String[] state_type_info = new String[]{'state','http://soap.sforce.com/2006/04/metadata','AsyncRequestState','1','1','false'};
        private String[] stateDetail_type_info = new String[]{'stateDetail','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] stateDetailLastModifiedDate_type_info = new String[]{'stateDetailLastModifiedDate','http://www.w3.org/2001/XMLSchema','dateTime','0','1','false'};
        private String[] statusCode_type_info = new String[]{'statusCode','http://soap.sforce.com/2006/04/metadata','StatusCode','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'checkOnly','done','id','message','numberComponentErrors','numberComponentsDeployed','numberComponentsTotal','numberTestErrors','numberTestsCompleted','numberTestsTotal','state','stateDetail','stateDetailLastModifiedDate','statusCode'};
    }    
    
    public class checkStatus_element {
        public String[] asyncProcessId;
        private String[] asyncProcessId_type_info = new String[]{'asyncProcessId','http://soap.sforce.com/2006/04/metadata','ID','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'asyncProcessId'};
    }
    
    public class checkStatusResponse_element {
        public SYS_metadataService.AsyncResult[] result;
        private String[] result_type_info = new String[]{'result','http://soap.sforce.com/2006/04/metadata','AsyncResult','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class PackageTypeMembers {
        public String[] members;
        public String name;
        private String[] members_type_info = new String[]{'members','http://www.w3.org/2001/XMLSchema','string','0','-1','false'};
        private String[] name_type_info = new String[]{'name','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'members','name'};
    }
    public class DebuggingHeader_element {
        public SYS_metadataService.LogInfo[] categories;
        public String debugLevel;
        private String[] categories_type_info = new String[]{'categories','http://soap.sforce.com/2006/04/metadata','LogInfo','0','-1','false'};
        private String[] debugLevel_type_info = new String[]{'debugLevel','http://soap.sforce.com/2006/04/metadata','LogType','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'categories','debugLevel'};
    }
    public class LogInfo {
        public String category;
        public String level;
        private String[] category_type_info = new String[]{'category','http://soap.sforce.com/2006/04/metadata','LogCategory','1','1','false'};
        private String[] level_type_info = new String[]{'level','http://soap.sforce.com/2006/04/metadata','LogCategoryLevel','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'category','level'};
    }
    
    public virtual class Metadata {
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'fullName'};
    }
    
    public class SessionHeader_element {
        public String sessionId;
        private String[] sessionId_type_info = new String[]{'sessionId','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'sessionId'};
    }
    
   
    public class retrieveResponse_element {
        public SYS_metadataService.AsyncResult result;
        private String[] result_type_info = new String[]{'result','http://soap.sforce.com/2006/04/metadata','AsyncResult','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
 
    public class DebuggingInfo_element {
        public String debugLog;
        private String[] debugLog_type_info = new String[]{'debugLog','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'debugLog'};
    }
    
    public class CallOptions_element {
        public String client;
        private String[] client_type_info = new String[]{'client','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'client'};
    }
    
   
    
    public class checkDeployStatus_element {
        public String asyncProcessId;
        private String[] asyncProcessId_type_info = new String[]{'asyncProcessId','http://soap.sforce.com/2006/04/metadata','ID','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'asyncProcessId'};
    }
    
     public class create_element {
        public SYS_metadataService.Metadata[] metadata;
        private String[] metadata_type_info = new String[]{'metadata','http://soap.sforce.com/2006/04/metadata','Metadata','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'metadata'};
    }
    
    public class DeploymentRequest {
        public DeployResult deployResult;
    }

    public class DeployResult {
		public String id;
		public Object messages;
		public Object retrieveResult;
		public Boolean success;
		public Boolean checkOnly;
		public Boolean ignoreWarnings;
		public Boolean rollbackOnError;
		public String status;
		public Object errorMessage;
		
	}
}