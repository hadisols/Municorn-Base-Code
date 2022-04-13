({
    pollApex : function(component, event, helper) { 
        helper.callApexMethod(component,helper);
        
        //execute callApexMethod() again after 5 sec each
        window.setInterval(
            $A.getCallback(function() { 
                helper.callApexMethod(component,helper);
            }), 5000
        );      
    },
    callApexMethod : function (component,helper){    
        var action = component.get('c.getTransactionDetails');
        var transactionId = component.get('v.transactionId');
        action.setParams({
            "txId" : transactionId,
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('getTransactionDetails ASYNC Init '+ state);
            if(state== 'SUCCESS'){
                var transactionrec = response.getReturnValue();
                console.log('transactionrec ');
                console.table(transactionrec);
                console.log('transactionrec status '+ transactionrec.Status__c);
                if(transactionrec.Status__c == 'succeeded'){
                    component.fireApplicationEventCall('componentCommunicationEvent' , { message : '', isLoading:false , eventMessage:'' } );
                    component.redirectToHome(true , 'Successfully Charged Order..');    
                }else{
                    console.log('Poll Again  '); 
                }
                
            }else{
                console.log('Failed to Fetch Transaction ');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.displayMessage('Failure!', 'Failed to Fetch Transaction : '+errors[0].message, 'error','dismissible');
                    }
                }
                else{
                    component.displayMessage('Failure!', 'Failed to Fetch Transaction : Unknown error', 'error','dismissible');
                }
            }
        });
        $A.enqueueAction(action);

    } 
})