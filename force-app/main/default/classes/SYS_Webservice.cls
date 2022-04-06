@RestResource(urlMapping = '/municorn/v1/*')
global  without sharing class SYS_Webservice{

    
    @HttpPost
    global static void postRequest(){

        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.getExtension).newInstance();
        if(appService.doWebhookSignatureCheck()){
            appService.doPost();
        }  
        else {
            insert appService.generateLogForWebhookSigFail('POST','Signature Verification Failed in POST');
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
            insert appService.generateLogForWebhookSigFail('PUT','Signature Verification Failed in PUT');
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
            insert appService.generateLogForWebhookSigFail('GET','Signature Verification Failed in GET');
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
            insert appService.generateLogForWebhookSigFail('DELETE','Signature Verification Failed in DELETE');
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
            insert appService.generateLogForWebhookSigFail('PATCH','Signature Verification Failed in PATCH');
            appService.setErrorHttpResponse('Signature Verification Failed in PATCH');
        }
        
    }
    
}