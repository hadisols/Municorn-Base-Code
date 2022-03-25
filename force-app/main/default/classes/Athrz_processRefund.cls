global with sharing class Athrz_processRefund {
    
    global class MyInvocableVariable {
        @InvocableVariable(label='Intent record' required=true)  
        global Payment_Intent__c intent;
    
        @InvocableVariable(label='Refund amount' required=true)  
        global Decimal amount;

        @InvocableVariable(label='Card number' required=true)
        global String cardNumber;

        @InvocableVariable(label='Transaction Id' required=true)
        global String transactionId;

        @InvocableVariable(label='Gateway Id' required=true)
        global String gatewayId;
    }

    @InvocableMethod(label='Process refund' callout=true)
    global static List<String> processRefund(List<Athrz_processRefund.MyInvocableVariable> records) {
        SYS_DataCache.INT_TYPE = 'Authorize';
        SYS_DataCache.OBJ_TYPE = 'Refund_Payment_Intent';
        String gatewayId;
        List<sObject> newList = new List<sObject>();
        
        for(Athrz_processRefund.MyInvocableVariable item : records) {
            System.debug(item.intent);
            System.debug(item.amount);
            System.debug(item.cardNumber);
            Athrz_utility.amount = item.amount;
            Athrz_utility.cardNumber = item.cardNumber;
            Athrz_utility.transactionId = item.transactionId;
            gatewayId = item.gatewayId;

            newList.add(item.intent);
        }

        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ApexHandler__c).newInstance();
        Map<Id, String> jsonListForOutbound = appService.transformSObjectToJson(newList);
        
        if(jsonListForOutbound.values().size() > 0){
            for(Id jsonRecordId:jsonListForOutbound.keyset()){
                //callout for refund
                Athrz_utility.refund(jsonListForOutbound.get(jsonRecordId), gatewayId);
            }
        }
        return new List<String>{Athrz_utility.error};
    }
}
