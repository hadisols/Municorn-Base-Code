trigger SYS_IntegrationLogTrigger on SYS_IntegrationLog__c (after insert,after update) {

    switch on Trigger.operationType{
        when  AFTER_INSERT  {
            SYS_IntegrationLogTriggerHandler.handleAfterInsert();
        }
        when AFTER_UPDATE{
            SYS_IntegrationLogTriggerHandler.handleAfterUpdate();
        }
    }
    

}