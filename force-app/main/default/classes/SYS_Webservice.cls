@RestResource(urlMapping = '/municorn/v1/*')
global class SYS_Webservice{

    
    @HttpPost
    global static void postRequest(){

        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.getExtension).newInstance();
        if(appService.doWebhookSignatureCheck()){
            appService.doPost();
        }  
        else {
            appService.setErrorHttpResponse('Signature Verification Failed in POST');
        }
    }

    
    @HttpPut
    global static void putRequest(){
        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.getExtension).newInstance();
        if(appService.doWebhookSignatureCheck()){
            appService.doPut();
        }  
        else {
            appService.setErrorHttpResponse('Signature Verification Failed in PUT');
        }
        
    }

    
    @HttpGet
    global static void getRequest(){

       
        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.getExtension).newInstance();
        if(appService.doWebhookSignatureCheck()){
            appService.doGet();
        }  
        else {
            appService.setErrorHttpResponse('Signature Verification Failed in GET');
        }
        
    }
    
    
    @HttpDelete
    global static void deleteRequest(){
        
        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.getExtension).newInstance();
        if(appService.doWebhookSignatureCheck()){
            appService.doDelete();
        }  
        else {
            appService.setErrorHttpResponse('Signature Verification Failed in DELETE');
        }
        
    }

    @HttpPatch
    global static void patchRequest(){
        
        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.getExtension).newInstance();
        if(appService.doWebhookSignatureCheck()){
            appService.doPatch();
        }  
        else{
            appService.setErrorHttpResponse('Signature Verification Failed in PATCH');
        }
        
    }
    
}