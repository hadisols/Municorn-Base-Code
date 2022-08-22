public class SampleWrapper implements SYS_NotificationInterface{

	public class Errors {
	}

	public String id;
	public Boolean success;
	public List<Errors> errors;
	public Boolean created;

	/*

	public List<EventNotifications> eventNotifications;

	public class EventNotifications {
		public String realmId;
		public DataChangeEvent dataChangeEvent;
	}

	public class Entity {
		public String name;
		public String id;
		public String operation;
		public String lastUpdated;
	}

	public class DataChangeEvent {
		public List<Entity> entities;
	}
	*/
	
	public static SampleWrapper parse(String json) {
		return (SampleWrapper) System.JSON.deserialize(json, SampleWrapper.class);
	}

	public List<Map<string,String>> getIterator(String json){

		List<Map<string,String>> records = new List<Map<string,String>>();
		SampleWrapper sw = parse(json);
		if(sw!=null){

			Map<String,String> resourceMap = new Map<String,String>();
			resourceMap.put('Id',sw.id);
			records.add(resourceMap);

		}
		return records;
	}
}