public class SampleClass {
    //,'createTransactionRequest.transactionRequest.transactionType'
    
    public static void method1(){
        List<String> keys = new List<String>{'createTransactionRequest.merchantAuthentication.name',
                                            'createTransactionRequest.merchantAuthentication.transactionKey',
                                            'createTransactionRequest.refId',
            								'createTransactionRequest.transactionRequest.transactionType',
            								'createTransactionRequest.transactionRequest.amount',
            								'createTransactionRequest.transactionRequest.payment.opaqueData.dataDescriptor',
            								'createTransactionRequest.transactionRequest.payment.opaqueData.dataValue',
            								'createTransactionRequest.transactionRequest.billTo.firstName',
            'createTransactionRequest.transactionRequest.billTo.lastName',
            'createTransactionRequest.transactionRequest.billTo.company',
            'createTransactionRequest.transactionRequest.shipTo.firstName',
            'createTransactionRequest.transactionRequest.shipTo.lastName',
            'createTransactionRequest.transactionRequest.shipTo.company',
            'createTransactionRequest.transactionRequest.shipTo.company1.company3',
            'tiny.puny.key','tiny.puny.key2',
            'tiny.puny2.key3'
            };
            JSONGenerator gen = JSON.createGenerator(true);
            for(Integer i = 0; i < keys.size(); i++) {
                
                List<String> splitKeys = keys[i].split('\\.');
                System.debug('len'+keys[i]);
                Boolean endObj = true;
                for(integer ii = 0 ; ii < splitKeys.size(); ii++) {
                    system.debug('loop '+ii);
                    if(i == 0) {
                        if(ii == (splitKeys.size()-1)) {
                            gen.writeStartObject();
                            gen.writeStringField(splitKeys[ii], '84vMVmF6jP');
                            System.debug('gen.writeStartObject');
                            System.debug('gen.writeStringField '+splitKeys[ii]);
                            continue;
                        }
                        gen.writeStartObject();
                        gen.writeFieldName(splitKeys[ii]);
                        System.debug('gen.writeStartObject');
                        System.debug('gen.writeFieldName '+splitKeys[ii]);
                        

                    } else if(keys[i-1].contains(splitKeys[ii])) {
                        continue;
                    } else if(!(keys[i-1].contains(splitKeys[ii]))) {
                        System.debug('diff'+(keys[i-1].split('\\.').size() - ii ));
                        if((keys[i-1].split('\\.').size() - splitKeys.size()) < 0 && (splitKeys.size() - 1) != ii ) {
                            System.debug('current count higher');
                            gen.writeFieldName(splitKeys[ii]);gen.writeStartObject();
                            System.debug('gen.writeFieldName '+splitKeys[ii]);System.debug('gen.writeStartObject');
                        } else {													//if((splitKeys.size() - 1) != ii) {
                            if(endObj) {
                                for(integer itr = 1; itr < (keys[i-1].split('\\.').size() - ii ); itr++) {
                                    gen.writeEndObject();
                                    System.debug('gen.writeEndObject()');
                            	}
                                endObj = false;
                            }
                            if(ii == (splitKeys.size() - 1)) {
                                gen.writeStringField(splitKeys[ii], '84vMVmF6jP');
                        		System.debug('gen.writeStringField '+splitKeys[ii]);
                            } else {
                                gen.writeFieldName(splitKeys[ii]);gen.writeStartObject();
                            	System.debug('gen.writeFieldName '+splitKeys[ii]);System.debug('gen.writeStartObject');
                            }
                        } 
                        
                    }                     
                }
            }
        
        String pretty = gen.getAsString();
		System.debug('test'+pretty);
    }
    
    public static void method(){
        List<String> keys = new List<String>{'createTransactionRequest.merchantAuthentication.name',
                                            'createTransactionRequest.merchantAuthentication.transactionKey',
                                            'createTransactionRequest.refId',
            								'createTransactionRequest.transactionRequest.transactionType',
            								'createTransactionRequest.transactionRequest.amount',
            								'createTransactionRequest.transactionRequest.payment.opaqueData.dataDescriptor',
            								'createTransactionRequest.transactionRequest.payment.opaqueData.dataValue',
            								'createTransactionRequest.transactionRequest.billTo.firstName'};
            JSONGenerator gen = JSON.createGenerator(true);
            for(Integer i = 0; i < keys.size(); i++) {
                
                List<String> splitKeys = keys[i].split('\\.');
                System.debug('len'+keys[i]);
                
                for(integer ii = 0 ; ii < splitKeys.size(); ii++) {
                    
                    system.debug('loop '+ii);
                    if(i == 0) {
                        if(ii == (splitKeys.size()-1)) {
                            gen.writeStartObject();
                            gen.writeStringField(splitKeys[ii], '84vMVmF6jP');
                            System.debug('gen.writeStartObject');
                            System.debug('gen.writeStringField '+splitKeys[ii]);
                            continue;
                        }
                        gen.writeStartObject();
                        gen.writeFieldName(splitKeys[ii]);
                        System.debug('gen.writeStartObject');
                        System.debug('gen.writeFieldName '+splitKeys[ii]);
                        

                    } else if(keys[i-1].contains(splitKeys[ii])) {
                        continue;
                    } else if(!(keys[i-1].contains(splitKeys[ii]))) {
                        System.debug('diff'+(keys[i-1].split('\\.').size() - splitKeys.size()));
                        if ((keys[i-1].split('\\.').size() - splitKeys.size()) > 0) {
                            for(integer itr = 0; itr < (keys[i-1].split('\\.').size() - splitKeys.size()); itr++) {
                                gen.writeEndObject();
                                System.debug('gen.writeEndObject()');
                            }
                            gen.writeStringField(splitKeys[ii], '84vMVmF6jP');
                        	System.debug('gen.writeStringField '+splitKeys[ii]);
                        } else if((keys[i-1].split('\\.').size() - splitKeys.size()) < 0 && (splitKeys.size() - 1) != ii ) {
                            System.debug('current count higher');
                            gen.writeFieldName(splitKeys[ii]);gen.writeStartObject();
                            System.debug('gen.writeFieldName '+splitKeys[ii]);System.debug('gen.writeStartObject');
                        } else {
                            gen.writeStringField(splitKeys[ii], '84vMVmF6jP');
                        	System.debug('gen.writeStringField '+splitKeys[ii]);
                        }
                        
                    }                     
                }
            }
        
        String pretty = gen.getAsString();
		System.debug('test'+pretty);
    }
    
    public static Boolean removeParentkeys(List<String> keys, String key, integer index) {
        
        return true;
    }
}