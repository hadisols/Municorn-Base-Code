public with sharing class ImageController {
    @AuraEnabled
    public static void createSysTrackRecord(String recordId, String contentDocumentId) { 
        SYS_IntegrationLog__c errorLog = new SYS_IntegrationLog__c();
        List< SYS_Tracker__c > sysTrackerList = new List< SYS_Tracker__c >();
        List <ContentDocumentLink> updateFileList = new List <ContentDocumentLink>();

        List<SYS_Tracker__c> existingSysTracker = [SELECT Id, Name, Type__c, WhatId__c, WhoId__c FROM SYS_Tracker__c WHERE WhatId__c =: recordId  LIMIT 1];
        SYS_Tracker__c sysTracker =(!existingSysTracker.isEmpty())? existingSysTracker[0] : new SYS_Tracker__c();
        sysTracker.Type__c = 'Display Pic';
        sysTracker.WhatId__c = recordId;
        sysTracker.WhoId__c = contentDocumentId;
        //sysTracker.Valid_till__c = Now() + 865; 
        sysTrackerList.add(sysTracker);
        
        //Obtains all Related/Relevant Files for Selected Record
        List <ContentDocumentLink> relatedFiles = [SELECT ContentDocumentId, LinkedEntityId, ShareType, Visibility 
                                                    FROM ContentDocumentLink 
                                                    WHERE LinkedEntityId = :recordId AND Visibility != 'AllUsers']; 

        for  (Integer i = 0; i < relatedFiles.size(); i++) {
            if (relatedFiles[i].ContentDocumentId == contentDocumentId) {
                relatedFiles[i].Visibility = 'AllUsers';
                updateFileList.add(relatedFiles[i]);
            }
        } 

        try {
            upsert sysTracker;
            System.debug('SYS_Tracker Record Created Successfully: ' + sysTracker.Id);
            if (updateFileList.size() > 0) {
                update updateFileList;
            }
            
        } catch (Exception e) {
            System.debug('Error in Storing SYS_Tracker: ' + e.getMessage());
            //Generate a Log record
            errorLog.data0__c = 'Exception Type: ' + e.getTypeName() + ' Exception Message: ' + e.getMessage();
            errorLog.Status__c = 'ERROR';
            errorLog.How_To_Process__c = 'ignore_log';
        }
        if (errorLog != new SYS_IntegrationLog__c()) {
            insert errorLog;
        }

       // return sysTracker.Id;
    }
    @AuraEnabled
    public static String getSysTrackRecordDocumentId(String recordId) { 
        //SYS_Tracker__c sysTracker = Database.query('SELECT '+ SYS_Helper.getAllFieldsFor('SYS_Tracker__c') + '  WHERE WhatId__c =' + '\'' + recordId+'\'' + ' LIMIT 1 ' + '\')');
        SYS_Tracker__c sysTracker = [SELECT Id, Name, Type__c, WhatId__c, WhoId__c FROM SYS_Tracker__c WHERE WhatId__c =: recordId  LIMIT 1];
        return sysTracker.WhoId__c;
    }
    @AuraEnabled
    public static String getSysTrackRecordPictureURL(String recordId) { 
        String pictureURL;
        SYS_Tracker__c sysTracker = new SYS_Tracker__c();
        ContentVersion cvRecord = new ContentVersion();
        //sysTracker = Database.query('SELECT '+ SYS_Helper.getAllFieldsFor('SYS_Tracker__c') + '  WHERE WhatId__c =' + '\'' + recordId+'\'' + ' LIMIT 1 ' + '\')');
        List<SYS_Tracker__c> sysTrackerList = [SELECT Id, Name, Type__c, WhatId__c, WhoId__c FROM SYS_Tracker__c WHERE WhatId__c =: recordId];
        sysTracker = ( sysTrackerList.size()>0) ? sysTrackerList[0] : new SYS_Tracker__c() ;
        System.debug('( sysTracker!=NULL )' + ( sysTracker!=NULL ));
        if( sysTracker.WhoId__c !=NULL ){
            try{
                cvRecord = [SELECT Id, ContentDocumentId from ContentVersion where ContentDocumentId =:sysTracker.WhoId__c LIMIT 1];
            } catch(Exception e){
                cvRecord =new ContentVersion();
            }
            if(cvRecord.Id !=NULL){
                pictureURL='/sfc/servlet.shepherd/version/download/' + cvRecord.Id;
            } else{
                pictureURL = PageReference.forResource('nopicture').getUrl();
            }
            
        } else {
            pictureURL = PageReference.forResource('nopicture').getUrl();
        }        
        return ( String.IsNotBlank(pictureURL) )? pictureURL : PageReference.forResource('nopicture').getUrl();
    }
}
