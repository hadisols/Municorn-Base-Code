public class SampleWrapper implements SYS_NotificationInterface{

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
	
	public static SampleWrapper parse(String json) {
		return (SampleWrapper) System.JSON.deserialize(json, SampleWrapper.class);
	}

	public List<Map<string,String>> getIterator(String json){

		List<Map<string,String>> records = new List<Map<string,String>>();
		SampleWrapper sw = parse(json);
		if(sw.eventNotifications.size()>0){

			if(sw.eventNotifications[0].dataChangeEvent != NULL){
				if(sw.eventNotifications[0].dataChangeEvent.entities != NULL){
					

					for(Entity e: sw.eventNotifications[0].dataChangeEvent.entities){

						Map<String,String> resourceMap = new Map<String,String>();

						resourceMap.put('realmId',sw.eventNotifications[0].realmId);
						resourceMap.put('resourcePath',e.name.toLowerCase());
						resourceMap.put('id',e.id);

						records.add(resourceMap);

					}

					
				}
			}
		}
		return records;
	}
}