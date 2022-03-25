@IsTest
public class SYS_MockServer{

    Map<String, HttpResponse> router;

    public static MultiStaticResourceCalloutMock startServer(){
        MultiStaticResourceCalloutMock multimockServer = new MultiStaticResourceCalloutMock();
        multimockServer.setStaticResource('https://get_large_mock_body.inbound', 'SYS_Test_Inbound_Body_Large');
        multimockServer.setStaticResource('https://get_mock_body.inbound', 'SYS_Test_Inbound_Body');

        
        multimockServer.setStaticResource('callout:Municorn_Destination_NC/services/data/v53.0/sobjects/Account/', 'SYS_Test_Outbound_Response_Body');
        multimockServer.setStatusCode(200);
        multimockServer.setHeader('Content-Type', 'application/json');
        return multimockServer;
    }

    public static MultiStaticResourceCalloutMock stopServer(){
        MultiStaticResourceCalloutMock multimockServer = new MultiStaticResourceCalloutMock();
        multimockServer.setStaticResource('callout:Municorn_Destination_NC/services/data/v53.0/sobjects/Account/', 'SYS_Test_Outbound_Response_Body');
        multimockServer.setStatusCode(500);
        multimockServer.setHeader('Content-Type', 'application/json');
        return multimockServer;
    }
}