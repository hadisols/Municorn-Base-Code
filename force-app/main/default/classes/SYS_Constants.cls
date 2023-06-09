public without sharing class SYS_Constants {
	public static Integer TEXT_AREA_MAX_SIZE { 
        get {
            return 131072;
        }
    }
    
    public static Integer MAX_DATA_FIELDS {
        get{
            return 10;
        }
    }

    public static Integer MAX_CHILD_NESTING_DEPTH {
        get{
            return 5;
        }
    }

    /**
     * INT_NAME is used to set the default integration name.
     * used @MunicornHome component while enabling the integration.
     */
    // public static String INT_NAME {
    //     get{
    //         return 'SYS_Test_IntegrationSetting';
    //     }
    // }
    
    
}