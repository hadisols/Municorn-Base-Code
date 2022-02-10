public class SYS_MockServer implements HttpCalloutMock{

    Map<String, HttpResponse> router;

    public void startServer(){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        
        //TODO - get records from metadata. separate keys based on http method
        this.router = new Map<String,HttpResponse>();
        this.router.put('https://municor-base-org-developer-edition.na163.force.com/services/apexrest/municorn/v1/SFsource?token=9LR99107DF7343549',res);
        
        
        
        this.router.put('callout:Municorn_Destination_NC/services/data/v53.0/sobjects/Custom_Parent__c/Id/NEW123',res);
    }

    public HTTPResponse respond(HTTPRequest req) {

        startServer();
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.debug('MS OB Test - Endpoint:'+req.getEndpoint());
        System.debug('MS OB Test - Method'+req.getMethod());
        //SYS_Webservice.postRequest();

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        
        return res;//router.get(req.getEndpoint());
    }
}
