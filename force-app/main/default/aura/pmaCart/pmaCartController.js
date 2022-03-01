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
        
        component.fireApplicationEventCall = function (eventControllerName, message, processedObjectToString) {
            var appEvent = $A.get('e.c:' + eventControllerName);
            appEvent.setParams({
                "message" : message,
                "selectedproducts":processedObjectToString
            });
            if (logApiResponses) { console.log('*** ' + 'Sending messagedata' + ' *** ' + processedObjectToString ); }   
            if (logApiResponses) { console.log('*** ' + 'Sending application event' + ' *** ' + eventControllerName ); }   
            appEvent.fire();
            if (logApiResponses) { console.log('*** ' + 'Sent application event successfully' + ' *** ' + eventControllerName); }   
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

    handleProductSelectionEvent : function (cmp, event) {
        var logApiResponses = true;
        var message = event.getParam("message");
        if (logApiResponses) { console.log('Received Message: ' + message); }
        //Received JSON String
        var selectedproductsString = event.getParam("selectedproducts");
        // set the handler attributes based on event data
        cmp.set("v.messageFromEvent", message);
        cmp.set("v.selectedproductsString", selectedproductsString);
         
        //1 Json String to JSON Object Conversion
        let productObjectData = JSON.parse(selectedproductsString);
        console.log('ObjType:: ' + typeof productObjectData);

        // 2 JSON Object To Map Conversion
        let allSelectedProductsMap = new Map(); 
        for (var value in productObjectData) {
            allSelectedProductsMap.set(value, productObjectData[value]);
        }
        //Not able to Assign map to Aura Attribute 
        console.log('ObjType:: ' + typeof allSelectedProductsMap);

        //3 extract valuesfrom map to store in Aura attribute List
        var selectedProductsValues = new Array();
        var chargeAmount = 0;
        for (var value in productObjectData) {
            selectedProductsValues.push(productObjectData[value]);
            chargeAmount = chargeAmount + productObjectData[value].totalProductPrice;
        }
        if (logApiResponses) { console.log('Current chargeAmount: ' + chargeAmount); }
        cmp.set("v.totalChargeAmount", chargeAmount);
        cmp.set("v.selectedProductsValues", selectedProductsValues);


        if (logApiResponses) { console.log('Received Product Values List(Array): '); }
        if (logApiResponses) { console.table(selectedProductsValues); }
       
        
        var numEventsHandled = parseInt(cmp.get("v.numEvents")) + 1;
        cmp.set("v.numEvents", numEventsHandled);
        //cmp.displayMessage('Success!', message, 'success');
    },
    productDeleteHandler: function (cmp, event) {
        var logApiResponses = true;
        var message = 'Product Deleted Successfully';
        var selectedItem = event.currentTarget;
        var selectedProdId = selectedItem.dataset.id; // Selected Product Id
        var selectedproductsString  = cmp.get("v.selectedproductsString");

        //1 Json String to JSON Object Conversion
        let productObjectData = JSON.parse(selectedproductsString);
        // 2 JSON Object To Map Conversion
        let allSelectedProductsMap = new Map();
        for (var value in productObjectData) {
            allSelectedProductsMap.set(value, productObjectData[value]);
        }
        //Not able to Assign map to Aura Attribute 

        //3 extract valuesfrom map to store in Aura attribute List
        var selectedProductsValues = new Array();
        for (var value in productObjectData) {
            selectedProductsValues.push(productObjectData[value]);
        }
        if (logApiResponses) { console.log('Current selectedProductsValues: '); }
        if (logApiResponses) { console.table(selectedProductsValues); }

        // var selectedProductsValues  = cmp.get("v.selectedProductsValues");
        var currentSelectedProductFromDataMap = allSelectedProductsMap.get(selectedProdId);
        if (logApiResponses) { console.log('Current currentSelectedProductFromDataMap: '); }
        if (logApiResponses) { console.table(currentSelectedProductFromDataMap); }

        if(currentSelectedProductFromDataMap.quantity > 1){
            var productQuantity = currentSelectedProductFromDataMap.quantity - 1;
            var singleProductPrice = currentSelectedProductFromDataMap.product.Unit_Price__c;
            var netUnitPrice = singleProductPrice * productQuantity ;
            currentSelectedProductFromDataMap.quantity = productQuantity;
            currentSelectedProductFromDataMap.productPrice = singleProductPrice;
            currentSelectedProductFromDataMap.totalProductPrice = netUnitPrice;
            allSelectedProductsMap.set(selectedProdId , currentSelectedProductFromDataMap);  
        } else{
            allSelectedProductsMap.delete(selectedProdId);
        }
        var selectedProductsValues = [...allSelectedProductsMap.values()];
        if (logApiResponses) { console.table(selectedProductsValues); }
        var preprocessMapToObject = Object.fromEntries(allSelectedProductsMap);
        var processedObjectToString = JSON.stringify(preprocessMapToObject);
        cmp.set('v.selectedproductsString',processedObjectToString);
        cmp.set("v.selectedProductsValues", selectedProductsValues);

        var chargeAmount = 0; 
        for (let allSelectedProductsMapValue of allSelectedProductsMap.values()) {
            chargeAmount = chargeAmount + allSelectedProductsMapValue.totalProductPrice;
        }
        if (logApiResponses) { console.log('Current chargeAmount: ' + chargeAmount); }
        cmp.set("v.totalChargeAmount", chargeAmount);

        cmp.fireApplicationEventCall('cartCommunicationEvent' , message, processedObjectToString );
        if (logApiResponses) { console.log('Called Cart Event Call: '); }

    },
    handleCharge : function(cmp, event) {
        console.log('*** ' + 'handleCharge' + ' ***');
    },
   /*  fireApplicationEventUsingLtngSendMessage : function(cmp, event) {
        var logApiResponses = true;
        var selectedItem = event.currentTarget;
        var selectedProdId = selectedItem.dataset.id;
       if (logApiResponses) { console.log('selectedProdId fireApplicationEvent ' + selectedProdId); }
       // var sendMsgEvent = window.$A.get("e.ltng:sendMessage");
        var sendMsgEvent = $A.get("e.ltng:sendMessage");
        sendMsgEvent.setParams({
            "message": deletedString,
            "channel": "ProductsChannel"
        });
        console.log('*** ' + 'sending ltng:sendMsg event' + ' ***');
        sendMsgEvent.fire();
    }, */
   /*  handleLtngSendMessageEvent : function (cmp, event) {
        var message = event.getParam("message");

        // set the handler attributes based on event data
        cmp.set("v.messageFromEvent", message);
        var numEventsHandled = parseInt(cmp.get("v.numEvents")) + 1;
        cmp.set("v.numEvents", numEventsHandled);
    }, */
})