public with sharing class RemoteSiteSettingService {

	public Integer size {get;set;} 
	public Integer totalSize {get;set;} 
	public Boolean done {get;set;} 
	public Object queryLocator {get;set;} 
	public String entityTypeName {get;set;} 
	public List<Records> records {get;set;} 

	public RemoteSiteSettingService(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'size') {
						size = parser.getIntegerValue();
					} else if (text == 'totalSize') {
						totalSize = parser.getIntegerValue();
					} else if (text == 'done') {
						done = parser.getBooleanValue();
					} else if (text == 'queryLocator') {
						queryLocator = parser.readValueAs(Object.class);
					} else if (text == 'entityTypeName') {
						entityTypeName = parser.getText();
					} else if (text == 'records') {
						records = arrayOfRecords(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'RemoteSiteSettingService consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Attributes {
		public String type {get;set;} 
		public String url {get;set;} 

		public Attributes(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type = parser.getText();
						} else if (text == 'url') {
							url = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Attributes consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Records {
		public Attributes attributes {get;set;} 
		public String EndpointUrl {get;set;} 
		public Boolean IsActive {get;set;} 

		public Records(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'attributes') {
							attributes = new Attributes(parser);
						} else if (text == 'EndpointUrl') {
							EndpointUrl = parser.getText();
						} else if (text == 'IsActive') {
							IsActive = parser.getBooleanValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Records consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static RemoteSiteSettingService parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new RemoteSiteSettingService(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	
    private static List<Records> arrayOfRecords(System.JSONParser p) {
        List<Records> res = new List<Records>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Records(p));
        }
        return res;
    }
}