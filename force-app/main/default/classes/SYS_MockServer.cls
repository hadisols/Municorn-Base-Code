@IsTest
public class SYS_MockServer{

    Map<String, HttpResponse> router;

    public static MultiStaticResourceCalloutMock startServer(){
        MultiStaticResourceCalloutMock multimockServer = new MultiStaticResourceCalloutMock();
        multimockServer.setStaticResource('https://get_large_mock_body.inbound', 'SYS_Test_Inbound_Body_Large');
        multimockServer.setStaticResource('https://get_very_large_mock_body.inbound', 'SYS_Test_Inbound_Body_Very_Large');
        multimockServer.setStaticResource('https://get_mock_body.inbound', 'SYS_Test_Inbound_Body');
        multimockServer.setStaticResource('callout:Municorn_Destination_NC/services/data/v53.0/sobjects/Account', 'SYS_Test_Outbound_Response_Body');
        multimockServer.setStaticResource('callout:Municorn_Destination_NC/services/data/v53.0/sobjects/Account/0015f00000IayMkAAJ', 'SYS_Test_Outbound_Response_Body');
        
        multimockServer.setStaticResource('callout:GCPJWT/token', 'OAuth_Test_Token_Body');
        multimockServer.setStaticResource('callout:OAUTH_NC/token', 'OAuth_Auth_Code_Test_Token_Body');
        multimockServer.setStaticResource(System.Url.getOrgDomainUrl().toExternalForm()+'/services/data/v54.0/tooling/query/?q=Select+EndpointUrl,IsActive+from+RemoteProxy', 'RemoteProxy_test_response');
        SYS_DataCache.INT_TYPE = 'SYS_Test_IntegrationSetting';
        multimockServer.setStaticResource(SYS_DataCache.licenseEndpoint, 'license_org_json');
        multimockServer.setStatusCode(200);
        multimockServer.setHeader('Content-Type', 'application/json');
        return multimockServer;
    }

    public static MultiStaticResourceCalloutMock stopServer(){
        MultiStaticResourceCalloutMock multimockServer = new MultiStaticResourceCalloutMock();
        multimockServer.setStaticResource('callout:Municorn_Destination_NC/services/data/v53.0/sobjects/Account', 'SYS_Test_Outbound_Response_Body');
        multimockServer.setStaticResource('callout:GCPJWT/token', 'OAuth_Test_Token_Body');
        multimockServer.setStaticResource('callout:OAUTH_NC/token', 'OAuth_Auth_Code_Test_Token_Body');

        multimockServer.setStatusCode(500);
        multimockServer.setHeader('Content-Type', 'application/json');
        return multimockServer;
    }
}