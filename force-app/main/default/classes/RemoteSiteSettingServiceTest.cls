@IsTest
public class RemoteSiteSettingServiceTest {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{'+
		'  \"size\" : 8,'+
		'  \"totalSize\" : 8,'+
		'  \"done\" : true,'+
		'  \"queryLocator\" : null,'+
		'  \"entityTypeName\" : \"RemoteProxy\",'+
		'  \"records\" : [ {'+
		'    \"attributes\" : {'+
		'      \"type\" : \"RemoteProxy\",'+
		'      \"url\" : \"/services/data/v54.0/tooling/sobjects/RemoteProxy/0rp5i000000TSHNAA4\"'+
		'    },'+
		'    \"EndpointUrl\" : \"https://drchrono.com\",'+
		'    \"IsActive\" : true'+
		'  }, {'+
		'    \"attributes\" : {'+
		'      \"type\" : \"RemoteProxy\",'+
		'      \"url\" : \"/services/data/v54.0/tooling/sobjects/RemoteProxy/0rp5i000000TSHOAA4\"'+
		'    },'+
		'    \"EndpointUrl\" : \"https://oauth2.googleapis.com\",'+
		'    \"IsActive\" : true'+
		'  }, {'+
		'    \"attributes\" : {'+
		'      \"type\" : \"RemoteProxy\",'+
		'      \"url\" : \"/services/data/v54.0/tooling/sobjects/RemoteProxy/0rp5i000000TTnyAAG\"'+
		'    },'+
		'    \"EndpointUrl\" : \"https://self-5cb-dev-ed.my.salesforce.com\",'+
		'    \"IsActive\" : true'+
		'  }, {'+
		'    \"attributes\" : {'+
		'      \"type\" : \"RemoteProxy\",'+
		'      \"url\" : \"/services/data/v54.0/tooling/sobjects/RemoteProxy/0rp5i000000TToDAAW\"'+
		'    },'+
		'    \"EndpointUrl\" : \"https://self-5cb-dev-ed--adisolshl7.visualforce.com\",'+
		'    \"IsActive\" : true'+
		'  }, {'+
		'    \"attributes\" : {'+
		'      \"type\" : \"RemoteProxy\",'+
		'      \"url\" : \"/services/data/v54.0/tooling/sobjects/RemoteProxy/0rp5i000000TXo0AAG\"'+
		'    },'+
		'    \"EndpointUrl\" : \"https://us-central1-hl7convertersandbox.cloudfunctions.net\",'+
		'    \"IsActive\" : true'+
		'  }, {'+
		'    \"attributes\" : {'+
		'      \"type\" : \"RemoteProxy\",'+
		'      \"url\" : \"/services/data/v54.0/tooling/sobjects/RemoteProxy/0rp5i000000TXohAAG\"'+
		'    },'+
		'    \"EndpointUrl\" : \"https://oauth2.googleapis.com\",'+
		'    \"IsActive\" : true'+
		'  }, {'+
		'    \"attributes\" : {'+
		'      \"type\" : \"RemoteProxy\",'+
		'      \"url\" : \"/services/data/v54.0/tooling/sobjects/RemoteProxy/0rp5i0000016ONWAA2\"'+
		'    },'+
		'    \"EndpointUrl\" : \"http://www.apexdevnet.com\",'+
		'    \"IsActive\" : true'+
		'  }, {'+
		'    \"attributes\" : {'+
		'      \"type\" : \"RemoteProxy\",'+
		'      \"url\" : \"/services/data/v54.0/tooling/sobjects/RemoteProxy/0rp5i000000TTo3AAG\"'+
		'    },'+
		'    \"EndpointUrl\" : \"https://self-5cb-dev-ed.lightning.force.com\",'+
		'    \"IsActive\" : true'+
		'  } ]'+
		'}';
		RemoteSiteSettingService r = RemoteSiteSettingService.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RemoteSiteSettingService objRemoteSiteSettingService = new RemoteSiteSettingService(System.JSON.createParser(json));
		System.assert(objRemoteSiteSettingService != null);
		System.assert(objRemoteSiteSettingService.size == null);
		System.assert(objRemoteSiteSettingService.totalSize == null);
		System.assert(objRemoteSiteSettingService.done == null);
		System.assert(objRemoteSiteSettingService.queryLocator == null);
		System.assert(objRemoteSiteSettingService.entityTypeName == null);
		System.assert(objRemoteSiteSettingService.records == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RemoteSiteSettingService.Attributes objAttributes = new RemoteSiteSettingService.Attributes(System.JSON.createParser(json));
		System.assert(objAttributes != null);
		System.assert(objAttributes.type == null);
		System.assert(objAttributes.url == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RemoteSiteSettingService.Records objRecords = new RemoteSiteSettingService.Records(System.JSON.createParser(json));
		System.assert(objRecords != null);
		System.assert(objRecords.attributes == null);
		System.assert(objRecords.EndpointUrl == null);
		System.assert(objRecords.IsActive == null);
	}
}