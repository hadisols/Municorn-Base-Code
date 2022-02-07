public class SYS_QueueableForInboundChild implements Queueable {
    private List<String> childRecList;
    private String key;
    private String integrationSetting;
    private SYS_IntegrationLog__c parentLog;

    private static Integer childRecordsCount;
    public static Integer totalChildRecords{
        get{
            if(childRecordsCount==NULL)childRecordsCount = -1;
            return childRecordsCount;
        }
        set{
            childRecordsCount = value;
        }
    }
    
    public SYS_QueueableForInboundChild(SYS_IntegrationLog__c log, List<String> childRecList,String key,String integrationSetting){
        this.childRecList = childRecList;
        this.key = key;
        this.integrationSetting = integrationSetting;
        this.parentLog = log;
        SYS_debug.log('MS SYS_DataCache.log in Inbound child:'+this.parentLog);
    }
    
    public void execute(QueueableContext context){
        
        //TODO Make Dynamic - DONE
        totalChildRecords = childRecList.size();
        SYS_DataCache.INT_TYPE = integrationSetting;
        
        System.debug('Inbound for Child:'+SYS_DataCache.INT_TYPE);
        System.debug('Apex Handler:'+SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).ApexHandler__c);
        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).ApexHandler__c).newInstance();

        List<String> pendingChildRecords = new List<String>();
        List<SYS_IntegrationLog__c> childRecordsToInsert = new List<SYS_IntegrationLog__c>();
        
        for(String singleChildJSON : childRecList){
            if(Limits.getDmlStatements() < Limits.getLimitDmlStatements() - 1){
                //appService.insertWebhookLog(appService.generateLogForChildRecords(this.parentLog.Id,this.key,singleChildJSON,integrationSetting));
                childRecordsToInsert.add(appService.generateLogForChildRecords(this.parentLog.Id,this.key,singleChildJSON,integrationSetting));
            }
            else{
                pendingChildRecords.add(singleChildJSON);
            }
        }

        System.debug('MS pendingChildRecords:'+pendingChildRecords);
        System.debug('MS childRecordsToInsert:'+childRecordsToInsert);
        if(!childRecordsToInsert.isEmpty()){
            appService.doDML(childRecordsToInsert, 'INSERT', '');
        }

        /**
         * If there are still some records pending for process after exhausting the callout limits 
         * then chain the queueable
        **/ 
        if(pendingChildRecords.size()>0){
            System.enqueueJob(new SYS_QueueableForInboundChild(SYS_DataCache.log,pendingChildRecords,key,integrationSetting));
        }
        

    }
}