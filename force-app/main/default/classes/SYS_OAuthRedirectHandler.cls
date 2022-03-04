@RestResource(urlMapping='/v1/callback/*')
global class SYS_OAuthRedirectHandler {
	@HttpGet
    global static void doGet(){
        
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.addHeader('Access-Control-Allow-Origin', '*');
        String code= RestContext.request.params.get('code');
        String state = RestContext.request.params.get('state');
        
        System.debug('Code:'+code);
        
        List<SYS_OAuthConfig__c> configs = [SELECT 
                                                Id, 
                                                Name,
                                                Scope__c, 
                                                Access_Token__c, 
                                                Authorize_Endpoint__c, 
                                                Client_Secret__c, 
                                                Grant_Type__c, 
                                                Redirect_URL__c, 
                                                Refresh_Token__c, 
                                                Token_Endpoint__c, 
                                                Client_Id__c,
                                                Schedule_Refresh_Token__c,
                                                Token_Expiry_Time__c,
                                                Token_Expiry_Date__c,
                                                Additional_URL_Parameters__c 
                                            FROM SYS_OAuthConfig__c 
                                           	WHERE Id =:state];
        
        If(configs.size()>0){
            Http h = new Http();
    
            HttpRequest req = new HttpRequest();
            req.setEndpoint(configs[0].Token_Endpoint__c);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            
            String clientId = configs[0].Client_Id__c;
            String clientSecret = configs[0].Client_Secret__c;
            String redirect_uri = configs[0].Redirect_URL__c;
            String payload =    'client_id='+EncodingUtil.urlEncode(clientId,'UTF-8')+
                                '&client_secret='+EncodingUtil.urlEncode(clientSecret,'UTF-8')+
                                '&code='+EncodingUtil.urlEncode(code,'UTF-8')+
                                '&state='+EncodingUtil.urlEncode(state,'UTF-8')+
                                '&grant_type=authorization_code'+
                                '&redirect_uri='+EncodingUtil.urlEncode(redirect_uri ,'UTF-8');
            
            req.setBody(payload);
            System.debug('----- Token Request Body:'+req.getBody());
            

            // Send the request, and return a response
            HttpResponse res = h.send(req);

            //TODO - Check status code and process success/error
            
            JSONParser parser = JSON.createParser(res.getBody());
            String access_token='';
            String refresh_token=''; 
            String expiry;
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'access_token')) {
                    
                    parser.nextToken();
                    access_token= parser.getText();
                }

                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'refresh_token')) {
                    
                    parser.nextToken();
                    refresh_token= parser.getText();
                }

                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'expires_in')) {
                    
                    parser.nextToken();
                    expiry = parser.getText();
                }
            }

            configs[0].Access_Token__c =access_token;
            configs[0].Refresh_Token__c = refresh_token;
            configs[0].Token_Expiry_Time__c = expiry;

            Integer day = 86400;
            Integer hour = 3600;
            Integer minute = 60;
            Integer totalSeconds = Integer.valueOf(expiry);
            Integer daysout = Integer.valueOf(Math.floor(totalseconds / day));
            Integer hoursout = Integer.valueOf(Math.floor((totalseconds - daysout * day)/hour));
            Integer minutesout = Integer.valueOf(Math.floor((totalseconds - daysout * day - hoursout * hour)/minute));
            Integer secondsout = Integer.valueOf(totalseconds - daysout * day - hoursout * hour - minutesout * minute);
            String inpputString = System.now().yearGmt()+'-'+System.now().monthGmt()+'-'+(System.now().dayGmt()+daysout)+'T'+(System.now().hourGmt()+hoursout)+':'+(System.now().minuteGmt()+minutesout)+':'+(System.now().secondGmt()+secondsout)+'.'+'000Z';
            System.debug('MS Date time:'+inpputString);
            DateTime resultDateTime = DateTime.valueof(inpputString.replace('T', ' ')); 

            configs[0].Token_Expiry_Date__c = resultDateTime;
            configs[0].Schedule_Refresh_Token__c = true;

            update configs;

            RestContext.response.responseBody = Blob.valueOf('{"data":'+res.getBody()+'}');
            
            /*
            HttpRequest req2 = new HttpRequest();
            req2.setEndpoint('https://drchrono.com/api/patients');
            req2.setMethod('GET');
            req2.setHeader('Content-Type', 'application/json');
            req2.setHeader('Authorization', 'Bearer '+access_token);
            HttpResponse res2 = h.send(req2);
            
            //--RestContext.response.addHeader('Content-type', 'text/html; charset=utf-8');
            RestContext.response.responseBody = Blob.valueOf('{"data":'+res2.getBody()+'}');
            //--RestContext.response.responseBody = Blob.valueOf('<html><head></head><body><h1>Hello World!</h1><hr/><p>WE DID IT!!</p></body></html>');
            */

        }else{
            RestContext.response.responseBody = Blob.valueOf('{"error":'+'Invalid Config Id. Authentication Failed'+'}');
        }
        
    }
}