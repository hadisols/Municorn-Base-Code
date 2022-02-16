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
        
        component.fireApplicationEventCall = function (eventControllerName, message, wrapperObject) {
            if (logApiResponses) { console.log('***  ***'); }    
            if (logApiResponses) { console.log('***  ***' + eventControllerName); }    
            if (logApiResponses) { console.log(typeof wrapperObject); }    
            if (logApiResponses) { console.table(wrapperObject); }  
            var appEvent = $A.get('e.c:' + eventControllerName);
            var preprocessWrapperObject = Object.fromEntries(wrapperObject);
            appEvent.setParams({
                "message" : message,
                //"selectedproducts":JSON.parse(JSON.stringify(wrapperObject))
                "selectedproducts":JSON.stringify( preprocessWrapperObject)
            });
            if (logApiResponses) { console.log('*** ' + 'Sending application event' + ' ***'); }   
            appEvent.fire();
            if (logApiResponses) { console.log('*** ' + 'Sent application event successfully' + ' ***'); }   
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
               var allProductsMap = response.getReturnValue();
                // set init Map of Id, Products on allProductsMap aura attribute 
                component.set('v.allProductsMap',allProductsMap);
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
        var productData = component.get('v.productData');
        var allProductsMap = new Map( Object.entries( component.get('v.allProductsMap') ) );
        //Log all products
        if (logApiResponses) { console.log('Init allProductsMap '); }
        if (logApiResponses) { console.table(allProductsMap); }
        //Init Map
        var selectedProductsMap = new Map(component.get('v.selectedProductsMap'));

        var selectedItem = event.currentTarget;
        var selectedProdId = selectedItem.dataset.id; // Selected Product Id
        var currentSelectedProductFromDataMap = allProductsMap.get(selectedProdId);
        //var isAlreadyAdded = (currentSelectedProductFromDataMap.product.Id == selectedProdId) ? true : false; 
        var productCartWrapper ; // init Product Wrapper
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
            var singleProductPrice = currentSelectedProductFromDataMap.product.PricebookEntries[0].UnitPrice;
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

        component.fireApplicationEventCall('posCommunicationEvent' , message, selectedProductsMap );
        
    },

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
    }
})