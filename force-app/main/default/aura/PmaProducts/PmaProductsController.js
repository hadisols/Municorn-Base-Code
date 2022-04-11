({
    onInit: function (component, event, helper) {
        var logApiResponses = true;

        component.redirectToHome = function () {
            component.displayMessage('Failure', 'POS Invalid or Expired Order..', 'Error','dismissible');
            var urlPath = '/'; //Invalid POS Member Open Tab
            $A.get("e.force:navigateToURL").setParams({ 
                "url": urlPath 
             }).fire();   
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
            component.displayMessage('Error', 'An error occurred during Initialization ' + state, 'Error','dismissible');
           }
       });
       $A.enqueueAction(action);

    },

    productClickHandler : function(component, event) {
        var logApiResponses = true;
        var message = 'Product Added Successfully';
        
        var orderUUID = component.get("v.orderUUID");
        var action = component.get('c.getOrderDetails');
        action.setParams({
            "orderIdOrUUID" : orderUUID,
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state== 'SUCCESS'){
                var orderRecordData = response.getReturnValue();
            }else{
                console.log('Failed  getOrderDetails action ');
                component.redirectToHome();
            }
        });
        $A.enqueueAction(action);

        var selectedproductsString= component.get("v.selectedproductsString");
        //Init Products newMap.get(selectedProdId)
        var allProductsMap = new Map( Object.entries( component.get('v.allProductsMap') ) );
        //Log all products
        if (logApiResponses) { console.log('Init allProductsMap '); }
        if (logApiResponses) { console.table(allProductsMap); }
        if (logApiResponses) { console.log('Onclick selectedProductsMap' ); }
        if (logApiResponses) { console.log( component.get("v.selectedProductsMap") ); }
        if (logApiResponses) { console.log('Onclick selectedproductsString' ); }
        if (logApiResponses) { console.log( component.get("v.selectedproductsString") ); }
        
        //Init Map
        var selectedProductsMap = new Map(component.get('v.selectedProductsMap'));
        var selectedItem = event.currentTarget;
        var selectedProdId = selectedItem.dataset.id; // Selected Product Id
        var currentSelectedProductFromDataMap = allProductsMap.get(selectedProdId);
        // Log Selected Products Data
        if (logApiResponses) { console.log('Init selectedProdId ' + selectedProdId); }
        if (logApiResponses) { console.table(currentSelectedProductFromDataMap); }

        if(selectedProductsMap.has(selectedProdId) ){
            var previousSelectedProductFromDataMap = selectedProductsMap.get(selectedProdId);
            var productQuantity = previousSelectedProductFromDataMap.quantity + 1;
            var singleProductPrice = previousSelectedProductFromDataMap.product.Unit_Price__c;
            var netUnitPrice = singleProductPrice * productQuantity ;
            currentSelectedProductFromDataMap.quantity = productQuantity;
            currentSelectedProductFromDataMap.productPrice = singleProductPrice;
            currentSelectedProductFromDataMap.totalProductPrice = netUnitPrice;

                selectedProductsMap.set(selectedProdId, currentSelectedProductFromDataMap ); 
                if (logApiResponses) { console.log('Inside else if has exist in cart selectedProductsMap '); }
                if (logApiResponses) { console.log(selectedProductsMap); }
        }
        else{
            var productQuantity = 1;
            var singleProductPrice = currentSelectedProductFromDataMap.product.Unit_Price__c;
            var netUnitPrice = singleProductPrice * productQuantity ;
            currentSelectedProductFromDataMap.quantity = productQuantity;
            currentSelectedProductFromDataMap.productPrice = singleProductPrice;
            currentSelectedProductFromDataMap.totalProductPrice = netUnitPrice;
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
        if (logApiResponses) { console.log('Received selectedproductsString' ); }
        if (logApiResponses) { console.log(selectedproductsString); }
        // set the handler attributes based on event data
        cmp.set("v.messageFromEvent", message);
        //cmp.set("v.selectedproductsString", selectedproductsString);
        if((selectedproductsString !== '') && (selectedproductsString !== null) && (selectedproductsString !== undefined) ){
             //1 Json String to JSON Object Conversion
            let productObjectData = JSON.parse(selectedproductsString);
            console.log('ObjType:: ' + typeof productObjectData);

            // 2 JSON Object To Map Conversion
            let allSelectedProductsMap = new Map(); 
            for (var value in productObjectData) {
                allSelectedProductsMap.set(value, productObjectData[value]);
            }
            if (logApiResponses) { console.log('Received allSelectedProductsMap' ); }
            if (logApiResponses) { console.log(allSelectedProductsMap); }
            //Not able to Assign map to Aura Attribute 
            console.log('ObjType:: ' + typeof allSelectedProductsMap);
            cmp.set("v.selectedProductsMap", allSelectedProductsMap);
            cmp.set("v.selectedproductsString", selectedproductsString);
            if (logApiResponses) { console.log('No Resetted Cart' ); }
         } else{
            //Reset Selected Products quantity after Add to Cart
            if (logApiResponses) { console.log('Received selectedProductsMap' ); }
            if (logApiResponses) { console.log( cmp.get("v.selectedProductsMap") ); }
            if (logApiResponses) { console.log('Received selectedproductsString' ); }
            if (logApiResponses) { console.log( cmp.get("v.selectedproductsString") ); }
            cmp.set("v.selectedProductsMap", new Map()); 
            cmp.set("v.selectedproductsString", '');
            var allProductsMap = new Map( Object.entries( cmp.get('v.allProductsMap') ) );
            for (let [key, value] of  allProductsMap.entries()) {
                value.quantity = 1;
                console.log('Map Iterate '+ key + " = " + value.quantity);
                //console.table(value);
                allProductsMap.set(key, value);
                console.table(allProductsMap.get(key));
            }
            if (logApiResponses) { console.log('Resetted selectedProductsMap' ); }
            if (logApiResponses) { console.log( cmp.get("v.selectedProductsMap") ); }
            if (logApiResponses) { console.log('Resetted selectedproductsString' ); }
            if (logApiResponses) { console.log( cmp.get("v.selectedproductsString") ); }
            if (logApiResponses) { console.log('Resetted allProductsMap' ); }
            if (logApiResponses) { console.log( cmp.get("v.allProductsMap") ); }
         }
       
        
        if (logApiResponses) { console.log('Received selectedProductsMap: '); }
        if (logApiResponses) { console.table( cmp.get("v.selectedProductsMap") ); }
        
        var numEventsHandled = parseInt(cmp.get("v.numEvents")) + 1;
        cmp.set("v.numEvents", numEventsHandled);
        //cmp.displayMessage('Success!', message, 'success');
    },
})