public without sharing class SYS_debug {
    public string strLog;

    public static void log(String strLog) {
        if(SYS_DataCache.DEBUG_CHECK) {
            System.debug(strLog);
        }
    }

}