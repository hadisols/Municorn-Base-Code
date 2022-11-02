public without sharing class SYS_IntegrationLogTriggerHandler {
    public static void handleAfterInsert() {
        scheduledJobCheck();
        if(enforceLimitCheck()) {
            return;
        }

        List<Id> newOutboundLogIds = new List<Id>();
        List<Id> newInboundLogIds = new List<Id>();
        for(SYS_IntegrationLog__c log : ((List<SYS_IntegrationLog__c>)Trigger.new)){
            if(log.Type__c == 'OUTBOUND' && log.Status__c == 'NEW'){
                newOutboundLogIds.add(log.Id);
            }

            if((log.Type__c == 'INBOUND' || log.Type__c == 'RESPONSE') && log.Status__c == 'NEW'){
                newInboundLogIds.add(log.Id);
            }

        }

        if(newOutboundLogIds.size()>0)
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
        for(SYS_IntegrationLog__c log : ((List<SYS_IntegrationLog__c>)Trigger.new)){
            if(log.Type__c == 'OUTBOUND' && (log.Status__c == 'READY_FOR_PROCESSING')){
                newOutboundLogIds.add(log.Id);
            }

            if((log.Type__c == 'INBOUND' || log.Type__c == 'RESPONSE') && log.Status__c == 'READY_FOR_PROCESSING'){
                newInboundLogIds.add(log.Id);
            }

        }

        //TODO if Out of Queue Limits update log with exception details
        if(newOutboundLogIds.size()>0)
            System.enqueueJob(new SYS_IntegrationLogOutboundQueueable(newOutboundLogIds));

        if(newInboundLogIds.size()>0)
            new SYS_IntegrationLogInboundImmediate(newInboundLogIds).execute(); 
        
    }

    public static Boolean enforceLimitCheck() {

        if(SYS_DataCache.enforce_limit) {
            List<SYS_IntegrationLog__c> logs = [select id from SYS_IntegrationLog__c LIMIT 10];
            if(logs.size() >= 5) {
                return true;
            }
        }
        return false;
    }

    public static void scheduledJobCheck() {
        List<CronJobDetail> jobs = [SELECT Id, Name, JobType FROM CronJobDetail where name = 'Municorn_License'];
        if(jobs.size() == 0) {
            System.schedule('Municorn_License', '0 0 22 * * ? *' , new SYS_scheduler(SYS_datacache.INT_TYPE));
        }
        return;
    }

}