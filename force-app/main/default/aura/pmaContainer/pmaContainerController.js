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
        component.redirectToHome = function (status,message) {
            var urlPath = '/'; //Invalid POS Member Open Tab
            if(message!=''){
                if(status==true){
                    component.displayMessage('Success', message, 'Success','dismissible');
                }else{
                    component.displayMessage('Failure', message, 'Error','dismissible');
                }
            }
            var currentuserrec = component.get("v.userInfo");
            console.log('currentuserrec ' + currentuserrec);
            if( (currentuserrec!= undefined) || (currentuserrec != null) ){
                console.log('currentuserrec ' + currentuserrec.Contact.RecordType.Name);
                if( ( currentuserrec.Contact.RecordType.Name == 'Manager' ) ){
                    urlPath = '/search-members'; //Invalid POS Member Open Tab For Manager
                }
            }
            $A.get("e.force:navigateToURL").setParams({ 
                "url": urlPath 
             }).fire();   
        };
        const params = new URLSearchParams(location.search);
        var orderUUID = ( ( params.has('order') === true ) && ( params.get('order')!='' ) ) ? params.get('order') : '';
        component.set('v.orderUUID',orderUUID);
        console.log('orderUUID ' + orderUUID);
        if(orderUUID==''){
            component.redirectToHome(false, 'POS Invalid or Expired Order..');
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
            component.redirectToHome(false, 'POS Invalid or Expired Order..');
           }
            
        });
        $A.enqueueAction(action);
        var fetchUserAction = component.get("c.fetchCurrentUser");
        fetchUserAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
               // set current user information on userInfo attribute
                component.set("v.userInfo", storeResponse);
            } else { // if any callback error, display error msg
            component.displayMessage('Error', 'An error occurred during Initialization ' + state, 'Error','dismissible');
           }
        });
        $A.enqueueAction(fetchUserAction);
    },
    handleComponentCommunicationEvent : function(cmp, event) {
        var message = event.getParam("message");
        var eventMessage = event.getParam("eventMessage");
        var isLoading = event.getParam("isLoading");
        console.log('Message Received message ' + message);
        console.log('Message Received eventMessage ' + eventMessage);
        console.log('Message Received isLoading ' + isLoading);
        // cmp.displayMessage('Alert', message, 'Alert','dismissible');
        cmp.set('v.isLoading',isLoading);
        cmp.set('v.message',message);
        console.log('Message Received in Container Component');
    },
    returnBacktoSearch : function (component, event) {
        component.redirectToHome(true, '');
    },
})