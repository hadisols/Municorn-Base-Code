@isTest
public with sharing class MunicornHealthCheckControllerTest {
    
    @isTest
    static void test_MunicornHealthCheckControllerTest() {
        System.assert(MunicornHealthCheckController.Escapcharectercheck('SYS_Auth_Integration_Setting') == true);
        System.assert(MunicornHealthCheckController.isExternalcheck('SYS_Auth_Integration_Setting') == true);
        System.assert(MunicornHealthCheckController.intEnablement('SYS_Auth_Integration_Setting') == true);
        System.assert(MunicornHealthCheckController.Notificationpartialcheck('SYS_Auth_Integration_Setting') == true);
        System.assert(MunicornHealthCheckController.fieldsettingLookupTowayCheck('SYS_Auth_Integration_Setting') == true);
        MunicornHealthCheckController.objectFieldLowercasecheck();
        MunicornHealthCheckController.flowActiveCheck();
        System.assert(MunicornHealthCheckController.NotificationInterfaceCheck('SYS_Auth_Integration_Setting') == true);
        System.assert(MunicornHealthCheckController.ExtensionCheck('SYS_Auth_Integration_Setting') == true);
    }
}
