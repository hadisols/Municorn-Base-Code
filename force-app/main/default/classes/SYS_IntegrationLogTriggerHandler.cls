public class SYS_IntegrationLogTriggerHandler {
    public static void handleAfterInsert() {

        List<Id> newOutboundLogIds = new List<Id>();
        List<Id> newInboundLogIds = new List<Id>();
        for(SYS_IntegrationLog__c log : ((List<SYS_IntegrationLog__c>)Trigger.new)){
            if(log.Type__c == 'OUTBOUND' && log.Status__c == 'NEW'){
                newOutboundLogIds.add(log.Id);
            }

            if(log.Type__c == 'INBOUND' && log.Status__c == 'NEW'){
                newInboundLogIds.add(log.Id);
            }

        }

        if(newOutboundLogIds.size()>0)
            System.enqueueJob(new SYS_IntegrationLogOutboundQueueable(newOutboundLogIds));

        if(newInboundLogIds.size()>0)
            new SYS_IntegrationLogInboundImmediate(newInboundLogIds).execute(); 

    }

    public static void handleAfterUpdate() {
        List<Id> newOutboundLogIds = new List<Id>();
        List<Id> newInboundLogIds = new List<Id>();
        for(SYS_IntegrationLog__c log : ((List<SYS_IntegrationLog__c>)Trigger.new)){
            if(log.Type__c == 'OUTBOUND' && (log.Status__c == 'READY_FOR_PROCESSING')){
                newOutboundLogIds.add(log.Id);
            }

            if(log.Type__c == 'INBOUND' && log.Status__c == 'READY_FOR_PROCESSING'){
                newInboundLogIds.add(log.Id);
            }

        }

        //TODO if Out of Queue Limits update log with exception details
        if(newOutboundLogIds.size()>0)
            System.enqueueJob(new SYS_IntegrationLogOutboundQueueable(newOutboundLogIds));

        if(newInboundLogIds.size()>0)
            new SYS_IntegrationLogInboundImmediate(newInboundLogIds).execute(); 
        
    }

}