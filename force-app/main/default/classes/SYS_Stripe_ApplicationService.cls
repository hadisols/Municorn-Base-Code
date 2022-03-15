public without sharing class SYS_Stripe_ApplicationService extends SYS_ApplicationService{
    public SYS_Stripe_ApplicationService() {

    }

    public override Boolean doWebhookSignatureCheck(){

        RestRequest req = RestContext.request;
        Blob jsonBlob = req.requestBody;
        String jsonString = jsonBlob.toString();
        jsonString = jsonString.replaceAll('\r', '');

        String sig = req.headers.get('Stripe-Signature');
        
        Map<String,String> sigMap = new Map<String,String>();
        List<String> signatures = sig.split(',');
        for(String kv:signatures){
            sigMap.put(kv.split('=')[0],kv.split('=')[1]);
        }

        String signature_payload = sigMap.get('t')+'.'+jsonString;
        Blob input = Blob.valueOf(signature_payload);
        
        Blob 
        privateKey=Blob.valueOf(SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).webhookToken__c);
        
        Blob hmac = Crypto.generateMac('HmacSHA256',input , privateKey);
        String incomingSignature = sigMap.get('v1');
        
        
        return (incomingSignature==EncodingUtil.convertToHex(hmac));

    }

}
