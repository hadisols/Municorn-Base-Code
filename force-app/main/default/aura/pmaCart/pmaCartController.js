({
    setup: function (component, event, helper) {
        console.info('bootstrap loaded successfully.');
    },

    onInit: function (component, event, helper) {
        var logApiResponses = true;
        component.redirectToHome = function (status,message) {
            if (message != '') {
                if (status == true) {
                    component.displayMessage('Success', message, 'Success', 'dismissible');
                } else {
                    component.displayMessage('Failure', message, 'Error', 'dismissible');
                }
            }
            var urlPath = '/'; //Invalid POS Member Open Tab
            $A.get("e.force:navigateToURL").setParams({ 
                "url": urlPath 
             }).fire();   
        };
        component.fireApplicationEventCall = function (eventControllerName, params) {
            var appEvent = $A.get('e.c:' + eventControllerName);
            appEvent.setParams(params);
            if (logApiResponses) { console.log('*** ' + 'Sending messagedata' + ' *** ' + params ); }   
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
        var orderUUID = component.get("v.orderUUID");
        var action = component.get('c.getOrderDetails');
        action.setParams({
            "orderIdOrUUID" : orderUUID,
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state== 'SUCCESS'){
                var orderRecordData = response.getReturnValue();
                component.set('v.orderRecord',orderRecordData);
                console.log('orderRecord '+orderRecordData);

                component.set('v.orderItemRecord',orderRecordData.Order_Items__r);
                console.log('Order_Items__r '+orderRecordData.Order_Items__r);
                console.table(orderRecordData);
            }else{
                console.log('Failed  getOrderDetails action ');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.displayMessage('Failure!', 'Failed to Fetch Order Details: '+errors[0].message, 'error','dismissible');
                    }
                }
                else{
                    component.displayMessage('Failure!', 'Failed to Fetch Order Details: Unknown error', 'error','dismissible');
                }
            }
        });
        $A.enqueueAction(action);
        var orderRecord = component.get("v.orderRecord");
       
    },

    handleProductSelectionEvent : function (cmp, event) {
        var logApiResponses = true;
        var orderUUID = cmp.get("v.orderUUID");
        var action = cmp.get('c.getOrderDetails');
        action.setParams({
            "orderIdOrUUID" : orderUUID,
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state== 'SUCCESS'){
                var orderRecordData = response.getReturnValue();
                cmp.set('v.orderRecord',orderRecordData);
                console.log('orderRecord '+orderRecordData);

                cmp.set('v.orderItemRecord',orderRecordData.Order_Items__r);
                console.log('Order_Items__r '+orderRecordData.Order_Items__r);
                console.table(orderRecordData);
            }else{
                console.log('Failed  getOrderDetails action ');
                cmp.redirectToHome(false, 'POS Invalid or Expired Order..');
            }
        });
        $A.enqueueAction(action);

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
        console.log('selectedProductsValues ');
        console.log(selectedProductsValues );
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

        cmp.fireApplicationEventCall('cartCommunicationEvent' , { message : message,selectedproducts:processedObjectToString } );
        if (logApiResponses) { console.log('Called Cart Event Call: '); }

    },
    handleFinialize : function(cmp, event, helper) {
        console.log('*** ' + 'handleFinialize' + ' ***');
        var currentOrderRecord = cmp.get('v.orderRecord');
        var selectedProductsValues  = JSON.stringify(cmp.get("v.selectedProductsValues"));
        cmp.fireApplicationEventCall('componentCommunicationEvent' , { message : 'Adding to Order Please Wait...', isLoading:true , eventMessage:'' } );
        console.log('selectedProductsValues ObjType:: ' + typeof selectedProductsValues);

        var action = cmp.get('c.createOrderItems');
        action.setParams({
            "orderId" : currentOrderRecord.Id,
            "selectedProductsValues" : selectedProductsValues,
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state== 'SUCCESS'){
                cmp.set("v.selectedProductsValues", [] );
                var orderRecordData = response.getReturnValue();
                cmp.set('v.orderRecord',orderRecordData);
                console.log('orderRecord '+orderRecordData);
                cmp.set('v.orderItemRecord',orderRecordData.Order_Items__r);
                cmp.set('v.selectedproductsString','');
                console.log('Order_Items__r '+orderRecordData.Order_Items__r);
                console.table( cmp.get('v.orderItemRecord') );
                var message = 'Product Selection Deleted Successfully';
                cmp.fireApplicationEventCall('cartCommunicationEvent' ,{ message : message,selectedproducts:'' } );
                cmp.fireApplicationEventCall('componentCommunicationEvent' , { message : '', isLoading:false , eventMessage:'' } );

                console.log('Called Products component and Cleared Selected Products Event Call: ');
                cmp.redirectToHome(true , 'Added to Order Successfully..');
            }else{
                console.log('Failed to Add Order Item action ');
                cmp.fireApplicationEventCall('componentCommunicationEvent' , { message : '', isLoading:false , eventMessage:'' } );

                cmp.redirectToHome(false , 'POS Invalid or Expired Order..');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        cmp.displayMessage('Failure!', 'Failed to Add Order Item: '+errors[0].message, 'error','dismissible');
                    }
                }
                else{
                    cmp.displayMessage('Failure!', 'Failed to Add Order Item: Unknown error', 'error','dismissible');
                }
                
            }
        });
        $A.enqueueAction(action);

    },
    handleCharge : function(cmp, event, helper) {
        console.log('*** ' + 'handleCharge' + ' ***');
        cmp.fireApplicationEventCall('componentCommunicationEvent' , { message : 'Closing Tab Please Wait...', isLoading:true , eventMessage:'' } );

        var currentOrderRecord = cmp.get('v.orderRecord');
        
        var action = cmp.get('c.createPaymentRecords');
        action.setParams({
            "orderId" : currentOrderRecord.Id,
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state== 'SUCCESS'){
                var transactionId = response.getReturnValue();
                console.log('transactionId ASYNC Init '+ transactionId);
                console.log('transactionId ASYNC Init '+ transactionId.length);
                if( (transactionId.length > 0)){
                    cmp.set('v.transactionId', transactionId);
                    helper.pollApex(cmp, event, helper);
                }else{
                    cmp.fireApplicationEventCall('componentCommunicationEvent' , { message : '', isLoading:false , eventMessage:'' } );

                    console.log('Failed to Charge for Order Invalid Transaction Referrence ');
                    cmp.displayMessage('Failure!', 'Failed to Charge Order : Invalid Transaction Referrence', 'error','dismissible');
                }

            }else{
                console.log('Failed to Charge for Order ');
                cmp.fireApplicationEventCall('componentCommunicationEvent' , { message : '', isLoading:false , eventMessage:'' } );
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        cmp.displayMessage('Failure!', 'Failed to Charge Order : '+errors[0].message, 'error','dismissible');
                    }
                }
                else{
                    cmp.displayMessage('Failure!', 'Failed to Charge Order : Unknown error', 'error','dismissible');
                }
                
            }
        });
        $A.enqueueAction(action);

    },
    returnBacktoSearch : function (component, event) {
        component.redirectToHome(true, '');
    },
})