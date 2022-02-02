public with sharing class SYS_QueueableForInboundChild implements Queueable {
    public List<String> childRecList;
    public String key;
    public String integrationSetting;
    public SYS_QueueableForInboundChild(List<String> childRecList,String key,String integrationSetting){
        this.childRecList = childRecList;
        this.key = key;
        this.integrationSetting = integrationSetting;
    }
    
    public void execute(QueueableContext context){
        
        //TODO Make Dynamic - DONE
        SYS_DataCache.INT_TYPE = integrationSetting;
        System.debug('Inbound for Child:'+SYS_DataCache.INT_TYPE);
        System.debug('Apex Handler:'+SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).ApexHandler__c);
        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).ApexHandler__c).newInstance();

        List<String> pendingChildRecords = new List<String>();
        
        for(String singleChildJSON : childRecList){
            if(Limits.getDmlStatements() < Limits.getLimitDmlStatements() - 1){
                appService.insertWebhookLog(appService.generateLogForChildRecords(singleChildJSON,integrationSetting));
            }
            else{
                pendingChildRecords.add(singleChildJSON);
            }
        }

        System.debug('MS pendingChildRecords:'+pendingChildRecords);
        System.debug('MS childRecList:'+childRecList);

        /**
         * If there are still some records pending for process after exhausting the callout limits 
         * then chain the queueable
        **/ 
        if(pendingChildRecords.size()>0){
            System.enqueueJob(new SYS_QueueableForInboundChild(pendingChildRecords,key,integrationSetting));
        }
        

    }
}