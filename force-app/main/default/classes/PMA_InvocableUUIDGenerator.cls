global class PMA_InvocableUUIDGenerator {
    global class flowInputRecords {

        @InvocableVariable(label='Current Value' required=true)
        global sObject newVal;

        @InvocableVariable(label='UUID FieldApi Name' description='Default UUID__c' required=false)
        global String uuidFieldApiName;
        
    } 
    global class RecordstoUpdate {
     
         @InvocableVariable(label='Records to Updated')
         global sObject recordsUpdatable;
 
         // global generateUUID() {this.generatedUUID = SYS_Helper.getUUID();}
         
     } 
    @InvocableMethod(label='Generate UUID For any Record' description='To generate UUID and Return Generated UUID')
    global static List<RecordstoUpdate> getUUID(List<flowInputRecords> listInvocableVariable) {
        List<sObject> newList = new List<sObject>();
        List<RecordstoUpdate> generatedUUIDStrings = new List<RecordstoUpdate>();
        String uuidFieldApiName = (listInvocableVariable.size() > 0) ? ( ( String.isNotEmpty(listInvocableVariable[0].uuidFieldApiName) ) ? (listInvocableVariable[0].uuidFieldApiName) : 'UUID__c' ) : 'UUID__c';
        for(flowInputRecords itr:listInvocableVariable){
            newList.add(itr.newVal);   
        }
        for(sObject newIter: newList){
            if(newIter.Id!=null){
                newIter.put( uuidFieldApiName, SYS_Helper.getUUID());
                RecordstoUpdate generateNewUUID = new RecordstoUpdate();
                generateNewUUID.recordsUpdatable = newIter;
                generatedUUIDStrings.add(generateNewUUID);
            }
            
        }
        return generatedUUIDStrings;
    }
}