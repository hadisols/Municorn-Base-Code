public with sharing class MunicornHomeController {
    
    // @AuraEnabled
    // public static List<ResponseWrapper> getErrorResponse(){
    //     List<ResponseWrapper> result = new List<ResponseWrapper>();
    //     try {
    //         for(SYS_IntegrationLog__c item : [SELECT Name, data0__c, CreatedDate, Status__c FROM SYS_IntegrationLog__c
    //         WHERE Status__c = 'ERROR' ORDER BY Createddate desc LIMIT 20]) {
    //             ResponseWrapper resp = new ResponseWrapper();
    //             resp.Name = item.Name;
    //             resp.StatusCode = String.valueof(item.SYS_Http_Status__c);
    //             resp.Response = item.data0__c;
    //             resp.ErrorDt = item.CreatedDate;
    //             result.add(resp);
    //         }
            
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    //     return result;
    // }

    // @AuraEnabled
    // public static Map<String, String> getFrameUrls(){
    //     Map<String, String> mapUrls = new Map<String, String>();
    //     try {
    //         for(Integration_Metadata__mdt item : Integration_Metadata__mdt.getAll()?.values()) {
    //             mapUrls.put(item.Key__c, item.Value__c);
    //         }
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    //     return mapUrls;
    // }

    // @AuraEnabled
    // public static Boolean getCurrentUserDetails(){
    //     Boolean result = true;
    //     try {
    //         Id profileId = userinfo.getProfileId();
    //         String profileName = [Select Id,Name from Profile where Id=:profileId]?.Name;
    //         Id uerdid = userinfo.getUserId();
    //         List<PermissionSetAssignment> psassignment = [SELECT id FROM PermissionSetAssignment WHERE 
    //         AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'SYS_Municorn_Permission_Set'];
    //         if(psassignment != null && psassignment?.size() > 0 && 'System Administrator'.equalsIgnoreCase(profileName)) {
    //             result = false;
    //         }
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    //     return result;
    // }

    // public class ResponseWrapper {
    //     @AuraEnabled
    //     public String Name {get; set;}
    //     @AuraEnabled
    //     public String StatusCode {get; set;}
    //     @AuraEnabled
    //     public String Response {get; set;}
    //     @AuraEnabled
    //     public DateTime ErrorDt {get; set;}
    // }
}