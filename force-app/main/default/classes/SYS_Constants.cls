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

    public static String OUTBOUND {
        get {
            return 'OUTBOUND';
        }
    }

    public static String NEW_STATUS {
        get {
            return 'NEW';
        }
    }

    public static String FAIL {
        get {
            return 'FAIL';
        }
    }

    public static String INBOUND {
        get {
            return 'INBOUND';
        }
    }

    public static String RESPONSE {
        get {
            return 'RESPONSE';
        }
    }

    public static String PENDING_PARTITIONED_LOOKUP {
        get {
            return 'PENDING_PARTITIONED_LOOKUP';
        }
    }

    public static String READY_FOR_PROCESSING {
        get {
            return 'READY_FOR_PROCESSING';
        }
    }

    public static String POST {
        get {
            return 'POST';
        }
    }

    public static String PUT {
        get {
            return 'PUT';
        }
    }

    public static String GET {
        get {
            return 'GET';
        }
    }

    public static String DELETE_SERVICE {
        get {
            return 'DELETE';
        }
    }

    public static String PATCH {
        get {
            return 'PATCH';
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