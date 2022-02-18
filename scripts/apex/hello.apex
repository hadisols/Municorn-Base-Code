// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);

SYS_IntegrationLog__c  newSysLog = SYS_Helper.getLogsToInsert('{\"Text_Field__c\":\"OB Async 2\"}');
newSysLog.Status__c = 'NEW';
newSysLog.Type__c = 'OUTBOUND';
newSysLog.SYS_IntegrationSettings__c = 'SFsource';
newSysLog.SYS_Operation_Type__c = 'INSERT';
newSysLog.whatid__c = 'a005f000007K9hlAAC';
newSysLog.ObjectSettingId__c = 'Custom_Parent_Object_Setting';
newSysLog.How_to_process__c = 'use_object_setting';
new SYS_IntegrationLogOutboundImmediate(new List<SYS_IntegrationLog__c>{newSysLog}).execute(); 


System.debug(System.now());
System.debug('========'+dateTime.now().getTime());
