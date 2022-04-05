({
    setup: function (component, event, helper) {
        console.info('Styles loaded successfully.');
    },
    onInit: function (component, event, helper) {
        var logApiResponses = true;
        component.apiCall = function (controllerMethodName, params, success, failure) {
            var action = component.get('c.' + controllerMethodName);
            action.setParams(params);
            action.setCallback(this, function (data) {
                if (logApiResponses){
                    console.log( controllerMethodName +' Callback Response ErrorsList: ');
                    console.table(data.getError());
                } 
                var errors = data.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    if (failure) {
                        component.displayMessage('Error',  errors[0].message, 'error');
                        failure(errors[0].message);                        
                    } else {
                        if (logApiResponses) {
                            console.log( controllerMethodName +' Callback Response Error: ' );
                            console.table( errors);
                        }
                        component.displayMessage('Error',  controllerMethodName +' Callback Response Error: ', 'error');
                        component.set('v.Loading', false);
                    }
                } else {
                    if (logApiResponses){
                        console.log( controllerMethodName +' Callback Response Success: ');
                        console.table(data.getReturnValue());
                    } 
                    if (success) success(data.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        };
        component.displayMessage = function (title, message, type, mode) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "mode": mode,
                "title": title,
                "type": type,
                "message": message
            });
            toastEvent.fire();
        };
        component.redirectToHome = function () {
            component.displayMessage('Failure', 'POS Invalid or Expired Order..', 'Error','dismissible');
            // component.displayMessage('Error', 'Invalid POS Order Open Tab Redirected to Home', 'Error','dismissible');
            var urlPath = '/'; //Invalid POS Member Open Tab
            $A.get("e.force:navigateToURL").setParams({ 
                "url": urlPath 
             }).fire();   
        };
        const params = new URLSearchParams(location.search);
        var orderUUID = ( ( params.has('order') === true ) && ( params.get('order')!='' ) ) ? params.get('order') : '';
        component.set('v.orderUUID',orderUUID);
        console.log('orderUUID ' + orderUUID);
        if(orderUUID==''){
            component.redirectToHome();
        }

        var action = component.get('c.getOrderDetailsByIdOrUUID');
        action.setParams({
            "orderIdOrUUID" : orderUUID,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('response.getReturnValue()');
               console.log(response.getReturnValue());
           if (state == "SUCCESS") {
               var orderRecord = response.getReturnValue();
               console.log('orderRecord '  + orderRecord);
               console.log('Member__c '  + orderRecord.Member__c);
               component.set('v.memberName' , orderRecord.Member__r.Name);            
               component.set('v.currentMember',orderRecord.Member__c); 
               component.set("v.showChild",true);           
           } else { // if any callback error, display error msg
            component.redirectToHome();
           }
            
        });
        $A.enqueueAction(action);

        
    },
})