global with sharing class SYS_scheduler implements Schedulable {
    public String int_type;
    global SYS_scheduler(String int_type) {
        this.int_type = int_type;
    }

    global void execute(SchedulableContext SC) {
        // System.enqueueJob(new SYS_syncLicenseOrgAsync(this.int_type, 2));
    }
}