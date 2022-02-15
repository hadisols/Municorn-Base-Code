@isTest
public class SYS_InboundTest {
    @TestSetup
    static void makeData(){
        List<Custom_Parent__c> parents = new List<Custom_Parent__c>();
        for(Integer i=0;i<1;i++){
            Custom_Parent__c parent = new Custom_Parent__c(Text_Field__c='Custom Parent Test record'+i,SYS_Key__c='a015f00000KOYkRAAX');
            parents.add(parent); 
        }
        insert parents;

        
    }

    @IsTest
    static void testSingleRecord(){
        
        //Test.setMock(HttpCalloutMock.class, new SYS_MockServer());
        String body = '{\"attributes\":{\"type\":\"Account\",\"url\":\"/services/data/v53.0/sobjects/Account/a015f00000Jfa4jAAB\"},\"LastModifiedDate\":\"2022-01-13T14:17:42.000+0000\",\"IsDeleted\":false,\"OwnerId\":\"0055f000007trpAAAQ\",\"CreatedById\":\"0055f000007trpAAAQ\",\"Name\":\"Municorn Test Account - Inbound with contacts\",\"CreatedDate\":\"2022-01-13T13:57:25.000+0000\",\"Id\":\"a015f00000KOYkRAAX\",\"LastModifiedById\":\"0055f000007trpAAAQ\",\"SystemModstamp\":\"2022-01-13T14:17:42.000+0000\",\"Contact\":[{\"LastName\":\"Municorn Test Contact 1\",\"key\":\"EXTCHILDKEY1\"},{\"LastName\":\"Municorn Test Contact 2\",\"key\":\"EXTCHILDKEY2\"},{\"LastName\":\"Municorn Test Contact 3\",\"key\":\"EXTCHILDKEY3\"}]}';
      
        RestRequest request = new RestRequest();
        RestResponse actualres = new RestResponse();
        request.requestURI = '/municorn/v1/SFsource';
        request.addParameter('token', '9LR99107DF7343549');
        request.requestBody = Blob.valueOf(body);
        request.httpMethod = 'PUT';
        RestContext.request = request;

        Test.startTest();
        SYS_Webservice.postRequest();
        Test.stopTest();

        List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
        System.assert(log.size()>0);
        
    }

}
