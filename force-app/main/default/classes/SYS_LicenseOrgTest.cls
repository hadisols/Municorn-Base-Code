@isTest
public class SYS_LicenseOrgTest {

    private class WebServiceMockImpl implements WebServiceMock {
		public void doInvoke(
			Object stub, Object request, Map<String, Object> response,
			String endpoint, String soapAction, String requestName,
			String responseNS, String responseName, String responseType) 
		{
            SYS_metadataService.AsyncResult sync = new SYS_metadataService.AsyncResult();
            sync.Id = '32938JHAUYAS';
            sync.done = true;
			if(request instanceof SYS_metadataService.create_element) {
                SYS_metadataService.createResponse_element respE = new SYS_metadataService.createResponse_element();
                respE.result = new List<SYS_metadataService.AsyncResult> {sync};
                response.put('response_x', respE);
            } else if (request instanceof SYS_metadataService.checkStatus_element) {
                SYS_metadataService.checkStatusResponse_element response_x = new SYS_metadataService.checkStatusResponse_element();
                response_x.result = new List<SYS_metadataService.AsyncResult> {sync};
                
                response.put('response_x', response_x);
            }
			return;
		}
	} 
    
    static User getUser() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        insert u;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SYS_Municorn_Permission_Set'];
        System.debug('user id '+u.id);
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);

        return u;
    }

    @isTest
    static void testScheduleClass() {
		System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());

        System.runAs(getUser()) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, SYS_MockServer.startServer());
            System.schedule('Municorn_License'+ DateTime.now().getTime() , '0 0 22 * * ? *' , new SYS_scheduler('SYS_Test_IntegrationSetting'));
            Test.stopTest();

            //TODO Assert on key fields on log record
            List<CronJobDetail> jobs = [SELECT Id, Name, JobType FROM CronJobDetail where name LIKE 'Municorn_License%'];
            System.assert(jobs.size()>1);
        }
    }
}