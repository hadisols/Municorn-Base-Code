({
    setup: function (component, event, helper) {
        console.info('bootstrap loaded successfully.');
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
                        failure(errors[0].message);
                    } else {
                        if (logApiResponses) {
                            console.log( controllerMethodName +' Callback Response Error: ' );
                            console.table( errors);
                        }
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
        
        component.fireApplicationEvent = function (eventControllerName, message, wrapperObject) {
            var appEvent = component.get('e.c:' + eventControllerName);
            appEvent.setParams({
                "message" : message,
                "selectedproducts":JSON.stringify(wrapperObject)
            });
            if (logApiResponses) { console.log('*** ' + 'sending application event' + ' ***'); }    
            
            appEvent.fire();
        };

        component.displayMessage = function (title, message, type) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "mode": 'sticky',
                "title": title,
                "type": type,
                "message": message
            });
            toastEvent.fire();
        };
    },

    handleApplicationEvent : function (cmp, event) {
        var logApiResponses = true;
        var message = event.getParam("message");
        if (logApiResponses) { console.log('Received Message: ' + message); }
        //Received JSON String
        var selectedproductsString = event.getParam("selectedproducts");
        // set the handler attributes based on event data
        cmp.set("v.messageFromEvent", message);
        cmp.set("v.selectedproductsString", selectedproductsString);
         
        //Json String to JSON Object Conversion
        let productObjectData = JSON.parse(selectedproductsString);
        
        // JSON Object To Map Conversion
        let allSelectedProductsMap = new Map(); 
        for (var value in productObjectData) {
            allSelectedProductsMap.set(value, productObjectData[value])
        }
        cmp.set("v.selectedProductsMap", selectedProductsMap);

        var selectedProductsValues = new Array();
        for (var value in productObjectData) {
            selectedProductsValues.push(productObjectData[value]);
        }
        cmp.set("v.selectedProductsValues", selectedProductsValues);

        if (logApiResponses) { console.log('Received custs: '); }
        if (logApiResponses) { console.table(selectedProductsValues); }

        var selectedProductsMap  = cmp.get("v.selectedProductsMap");

        if (logApiResponses) { console.log('Received Wrapper Object: '); }
        if (logApiResponses) { console.table(selectedProductsMap); }

        
        
        var numEventsHandled = parseInt(cmp.get("v.numEvents")) + 1;
        cmp.set("v.numEvents", numEventsHandled);
        cmp.displayMessage('Success!', message, 'success');
    },

    handleLtngSendMessageEvent : function (cmp, event) {
        var message = event.getParam("message");

        // set the handler attributes based on event data
        cmp.set("v.messageFromEvent", message);
        var numEventsHandled = parseInt(cmp.get("v.numEvents")) + 1;
        cmp.set("v.numEvents", numEventsHandled);
    },
})