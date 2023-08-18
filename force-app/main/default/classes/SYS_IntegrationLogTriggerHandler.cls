public without sharing class SYS_IntegrationLogTriggerHandler {
    public static void handleAfterInsert() {
        scheduledJobCheck();
        if(enforceLimitCheck()) {
            return;
        }

        List<Id> newOutboundLogIds = new List<Id>();
        List<Id> newInboundLogIds = new List<Id>();

        Set<String> parentUuids = new Set<String>();
        Set<String> childIds = new Set<String>();
        for(SYS_IntegrationLog__c log : ((List<SYS_IntegrationLog__c>)Trigger.new)){
            if(log.Type__c == SYS_Constants.OUTBOUND && log.Status__c == SYS_Constants.NEW_STATUS){
                newOutboundLogIds.add(log.Id);
            }

            if((log.Type__c == SYS_Constants.INBOUND || log.Type__c == SYS_Constants.RESPONSE) && log.Status__c == SYS_Constants.NEW_STATUS){
                newInboundLogIds.add(log.Id);
            }

            if(log.Parent_UUID__c != NULL && log.Root_Log__c == NULL && log.Order__c != NULL && log.Status__c == SYS_Constants.PENDING_PARTITIONED_LOOKUP) {
                parentUuids.add(log.Parent_UUID__c);
                childIds.add(log.Id);
            }
        }
        if(parentUuids.size() > 0 && childIds.size() > 0)
            SYS_Helper.updateRootLogLookUp(parentUuids, childIds);

        if(newOutboundLogIds.size()>0 && (Limits.getQueueableJobs() <= Limits.getLimitQueueableJobs() - 1) )
            System.enqueueJob(new SYS_IntegrationLogOutboundQueueable(newOutboundLogIds));

        if(newInboundLogIds.size()>0)
            new SYS_IntegrationLogInboundImmediate(newInboundLogIds).execute(); 

    }

    public static void handleAfterUpdate() {
        
        if(enforceLimitCheck()) {
            return;
        }

        List<Id> newOutboundLogIds = new List<Id>();
        List<Id> newInboundLogIds = new List<Id>();

        Set<String> parentUuids = new Set<String>();
        Set<String> childIds = new Set<String>();
        for(SYS_IntegrationLog__c log : ((List<SYS_IntegrationLog__c>)Trigger.new)){
            if(log.Type__c == SYS_Constants.OUTBOUND && (log.Status__c == SYS_Constants.READY_FOR_PROCESSING)){
                newOutboundLogIds.add(log.Id);
            }

            if((log.Type__c == SYS_Constants.INBOUND || log.Type__c == SYS_Constants.RESPONSE) && log.Status__c == SYS_Constants.READY_FOR_PROCESSING){
                newInboundLogIds.add(log.Id);
            }

            if(log.Parent_UUID__c != NULL && log.Root_Log__c == NULL && log.Order__c != NULL && log.Status__c == SYS_Constants.PENDING_PARTITIONED_LOOKUP) {
                parentUuids.add(log.Parent_UUID__c);
                childIds.add(log.Id);
            }
        }
    
        if(parentUuids.size() > 0 && childIds.size() > 0)
            SYS_Helper.updateRootLogLookUp(parentUuids, childIds);

        //TODO if Out of Queue Limits update log with exception details
        if(newOutboundLogIds.size()>0 && (Limits.getQueueableJobs() < Limits.getLimitQueueableJobs() - 1))
            System.enqueueJob(new SYS_IntegrationLogOutboundQueueable(newOutboundLogIds));

        if(newInboundLogIds.size()>0)
            new SYS_IntegrationLogInboundImmediate(newInboundLogIds).execute(); 
        
    }

    public static Boolean enforceLimitCheck() { //TODO aggregate query

        if(SYS_DataCache.enforce_limit) {
            List<SYS_IntegrationLog__c> logs = [select id from SYS_IntegrationLog__c LIMIT 10];
            if(logs.size() >= 5) {
                return true;
            }
        }
        return false;
    }

    public static void scheduledJobCheck() {
        // List<CronJobDetail> jobs = [SELECT Id, Name, JobType FROM CronJobDetail where name = 'Municorn_License'];
        // if(jobs.size() == 0) {
        //     System.schedule('Municorn_License', '0 0 22 * * ? *' , new SYS_scheduler(SYS_datacache.INT_TYPE));
        // }
        return;
    }

}