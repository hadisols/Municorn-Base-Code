public class SYS_ParentingQueueable implements Queueable{

    private String parentLog;
    private String integrationSetting;
    private SYS_IntegrationLog__c childLog;

    public SYS_ParentingQueueable(String parentLog,String integrationSetting,SYS_IntegrationLog__c childLog) {
        this.integrationSetting = integrationSetting;
        this.parentLog = parentLog;
        this.childLog = childLog;

    }

    public void execute(QueueableContext context){

        SYS_DataCache.INT_TYPE = integrationSetting;
        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(this.childLog.On_Complete_Handler__c).newInstance();
        appService.fixParent(parentLog,childLog);
        

    }
}