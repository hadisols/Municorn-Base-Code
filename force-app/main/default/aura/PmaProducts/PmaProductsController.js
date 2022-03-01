({
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
        var action = component.get("c.getAllProductRecords");
        action.setCallback(this, function (response) {
            //Init Map
           var state = response.getState();
           if (state == "SUCCESS") {
               // Init() Map of <Id, Wrapper> Onetime Load From Database
               var allProductsMap = response.getReturnValue();
                component.set('v.allProductsMap',allProductsMap);
                //For Aura attribute Iterate for UI
                let productObjectData = Object.values(allProductsMap);
                component.set('v.productData',productObjectData);

                if (logApiResponses) { console.log('Init productData'); }
                if (logApiResponses) { console.table(productObjectData); }
              
           } else { // if any callback error, display error msg
            component.displayMessage('Error', 'An error occurred during Initialization ' + state, 'Error');
           }
       });
       $A.enqueueAction(action);

    },

    productClickHandler : function(component, event) {
        var logApiResponses = true;
        var message = 'Product Added Successfully';
        //Init Products newMap.get(selectedProdId)
        var allProductsMap = new Map( Object.entries( component.get('v.allProductsMap') ) );
        //Log all products
        if (logApiResponses) { console.log('Init allProductsMap '); }
        if (logApiResponses) { console.table(allProductsMap); }
        //Init Map
        var selectedProductsMap = new Map(component.get('v.selectedProductsMap'));

        var selectedItem = event.currentTarget;
        var selectedProdId = selectedItem.dataset.id; // Selected Product Id
        var currentSelectedProductFromDataMap = allProductsMap.get(selectedProdId);
        // Log Selected Products Data
        if (logApiResponses) { console.log('Init selectedProdId ' + selectedProdId); }
        if (logApiResponses) { console.table(currentSelectedProductFromDataMap); }

        if( selectedProductsMap == null ){
            selectedProductsMap.set(selectedProdId, currentSelectedProductFromDataMap); 
            if (logApiResponses) { console.log('Inside If null new product add to selectedProductsMap '); }
            if (logApiResponses) { console.log(selectedProductsMap); }
        }
        else if(selectedProductsMap.has(selectedProdId) ){
            var productQuantity = currentSelectedProductFromDataMap.quantity + 1;
            var singleProductPrice = currentSelectedProductFromDataMap.product.Unit_Price__c;
            var netUnitPrice = singleProductPrice * productQuantity ;
            currentSelectedProductFromDataMap.quantity = productQuantity;
            currentSelectedProductFromDataMap.productPrice = singleProductPrice;
            currentSelectedProductFromDataMap.totalProductPrice = netUnitPrice;

                selectedProductsMap.set(selectedProdId, currentSelectedProductFromDataMap ); 
                if (logApiResponses) { console.log('Inside else if has exist in cart selectedProductsMap '); }
                if (logApiResponses) { console.log(selectedProductsMap); }
        }
        else{
            selectedProductsMap.set(selectedProdId, currentSelectedProductFromDataMap ); 
            if (logApiResponses) { console.log('Inside else new product add to selectedProductsMap '); }
            if (logApiResponses) { console.log(selectedProductsMap); }
        }
        
        component.set('v.selectedProductsMap',selectedProductsMap);
        // Log Selected Products Data
        if (logApiResponses) { console.log('Processed selectedProductsMap '); }
        if (logApiResponses) { console.table( component.get('v.selectedProductsMap') ); }

        var preprocessMapToObject= Object.fromEntries(selectedProductsMap);
        var processedObjectToString = JSON.stringify(preprocessMapToObject);       

        component.fireApplicationEventCall('posCommunicationEvent' , message, processedObjectToString );
        
    },

    handleProductDeletionCartEvent : function (cmp, event) {
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
        cmp.set("v.selectedProductsMap", allSelectedProductsMap);
        //Not able to Assign map to Aura Attribute 
        console.log('ObjType:: ' + typeof allSelectedProductsMap);
        if (logApiResponses) { console.log('Received selectedProductsMap: '); }
        if (logApiResponses) { console.table( cmp.get("v.selectedProductsMap") ); }
        
        var numEventsHandled = parseInt(cmp.get("v.numEvents")) + 1;
        cmp.set("v.numEvents", numEventsHandled);
        //cmp.displayMessage('Success!', message, 'success');
    },
   /*  handleLtngSendMessageEvent : function (cmp, event) {
        var message = event.getParam("message");
        if (logApiResponses) { console.log('Received Message from Cart: '); }
        if (logApiResponses) { console.log(message); }
        // set the handler attributes based on event data
        cmp.set("v.messageFromEvent", message);
        var numEventsHandled = parseInt(cmp.get("v.numEvents")) + 1;
        cmp.set("v.numEvents", numEventsHandled);
    }, */
/* 
    fireApplicationEventUsingLtngSendMessage : function(cmp, event) {
        var logApiResponses = true;
        var selectedItem = event.currentTarget;
        var selectedProdId = selectedItem.dataset.id;
       if (logApiResponses) { console.log('selectedProdId fireApplicationEvent ' + selectedProdId); }
       // var sendMsgEvent = window.$A.get("e.ltng:sendMessage");
        var sendMsgEvent = $A.get("e.ltng:sendMessage");
        sendMsgEvent.setParams({
            "message": selectedProdId,
            "channel": "ProductsChannel"
        });
        console.log('*** ' + 'sending ltng:sendMsg event' + ' ***');
        sendMsgEvent.fire();
    } */
})