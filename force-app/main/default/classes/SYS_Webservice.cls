@RestResource(urlMapping = '/municorn/v1/*')
global without sharing class SYS_Webservice{

    
    @HttpPost
    global static void postRequest(){
        SYS_ApplicationService appService;
        try {
            appService = (SYS_ApplicationService)Type.forName(SYS_DataCacheFactory.getHandler).newInstance();
            if(appService.doWebhookSignatureCheck()){
                appService.doPost();
            }  
            else {
                SYS_Helper.insertLog(appService.generateLogForWebhookSigFail('POST','Signature Verification Failed in POST'));
                appService.setErrorHttpResponse('Signature Verification Failed in POST');
            }
        } catch(Exception e) {
            RestContext.response.responseBody = Blob.valueOf(e.getMessage());
            SYS_Helper.insertErrorLog(SYS_Constants.POST, e.getMessage());
            return ;
        }
        
    }

    
    @HttpPut
    global static void putRequest(){
        SYS_ApplicationService appService;
        try {
            appService = (SYS_ApplicationService)Type.forName(SYS_DataCacheFactory.getHandler).newInstance();
            if(appService.doWebhookSignatureCheck()){
                appService.doPut();
            }  
            else {
                SYS_Helper.insertLog(appService.generateLogForWebhookSigFail('PUT','Signature Verification Failed in PUT'));
                appService.setErrorHttpResponse('Signature Verification Failed in PUT');
            }
        } catch(Exception e) {
            RestContext.response.responseBody = Blob.valueOf(e.getMessage());
            SYS_Helper.insertErrorLog(SYS_Constants.PUT, e.getMessage());
            return ;
        }
        
        
    }

    
    @HttpGet
    global static void getRequest(){

       
        SYS_ApplicationService appService;
        try {
            appService = (SYS_ApplicationService)Type.forName(SYS_DataCacheFactory.getHandler).newInstance();
            if(appService.doWebhookSignatureCheck()){
                appService.doGet();
            }  
            else {
                SYS_Helper.insertLog(appService.generateLogForWebhookSigFail('GET','Signature Verification Failed in GET'));
                appService.setErrorHttpResponse('Signature Verification Failed in GET');
            }
        } catch(Exception e) {
            RestContext.response.responseBody = Blob.valueOf(e.getMessage());
            SYS_Helper.insertErrorLog(SYS_Constants.GET, e.getMessage());
            return ;
        }
    }
    
    
    @HttpDelete
    global static void deleteRequest(){
        
        SYS_ApplicationService appService;
        try {
            appService = (SYS_ApplicationService)Type.forName(SYS_DataCacheFactory.getHandler).newInstance();
            if(appService.doWebhookSignatureCheck()){
                appService.doDelete();
            }  
            else {
                SYS_Helper.insertLog(appService.generateLogForWebhookSigFail('DELETE','Signature Verification Failed in DELETE'));
                appService.setErrorHttpResponse('Signature Verification Failed in DELETE');
            }
        } catch(Exception e) {
            RestContext.response.responseBody = Blob.valueOf(e.getMessage());
            SYS_Helper.insertErrorLog(SYS_Constants.DELETE_SERVICE, e.getMessage());
            return ;
        }
        
        
    }

    @HttpPatch
    global static void patchRequest(){
        
        SYS_ApplicationService appService;
        try {
            appService = (SYS_ApplicationService)Type.forName(SYS_DataCacheFactory.getHandler).newInstance();
            if(appService.doWebhookSignatureCheck()){
                appService.doPatch();
            }  
            else{
                SYS_Helper.insertLog(appService.generateLogForWebhookSigFail('PATCH','Signature Verification Failed in PATCH'));
                appService.setErrorHttpResponse('Signature Verification Failed in PATCH');
            }
        } catch(Exception e) {
            RestContext.response.responseBody = Blob.valueOf(e.getMessage());
            SYS_Helper.insertErrorLog(SYS_Constants.PATCH, e.getMessage());
            return ;
        }
        
        
    }
    
}