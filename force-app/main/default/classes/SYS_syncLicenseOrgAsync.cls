public class SYS_syncLicenseOrgAsync implements Queueable, Database.AllowsCallouts {

    public String int_type;
    public Integer retryCount;

    public SYS_syncLicenseOrgAsync(String int_type, Integer retryCount) {
        this.int_type = int_type;
        this.retryCount = retryCount;
    }


    public void execute(QueueableContext context) {
        Boolean followup = false, deployed = false;
        SYS_DataCache.INT_TYPE = this.int_type;

        System.debug('SP url'+SYS_DataCache.licenseEndpoint+' int '+SYS_DataCache.INT_TYPE+int_type);
        if(!SYS_syncLicenseOrg.IsRemoteSiteSettingAvailable()) {
            deployed = SYS_syncLicenseOrg.createRemoteSiteSettings('Municorn_Licensing', SYS_DataCache.licenseEndpoint);
        } else {
            deployed = true;
        }
        System.debug('SP test '+SYS_DataCache.licenseEndpoint + ' ' + deployed);
        if(SYS_DataCache.licenseEndpoint != null && deployed) {
            
            followup = !(SYS_syncLicenseOrg.sendRequest(SYS_DataCache.licenseEndpoint));
        }

        if(followup && retryCount > 0 && (Limits.getQueueableJobs() < Limits.getLimitQueueableJobs())) {
            System.enqueueJob(new SYS_syncLicenseOrgAsync(SYS_DataCache.INT_TYPE, retryCount--));
        }
    }
}