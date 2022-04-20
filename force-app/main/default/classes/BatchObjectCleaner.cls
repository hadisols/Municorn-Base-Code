public without sharing class BatchObjectCleaner implements Database.Batchable<sObject>{
    
    private string query;
    private string email;
    public BatchObjectCleaner(String query, String email) {
        this.query = query;
        this.email = email;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    public void execute (Database.BatchableContext bc, List<sObject> scope){
        delete scope;
        Database.emptyRecycleBin(scope);
    }

    public void finish(Database.BatchableContext bc){

        if(email!='' && email!=null){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setToAddresses(new String[] {email});
            mail.setSenderDisplayName('Batch Processing');
            mail.setSubject('Batch Process Completed');
            mail.setPlainTextBody('Batch Process has completed');

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
    }
}