({
    onInit: function (component, event, helper) {
        // Call helper to set the data for Products Object
        helper.getData(component);
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
        
        component.fireApplicationEventCall = function (eventControllerName, message, wrapperObject) {
            if (logApiResponses) { console.log('***  ***'); }    
            if (logApiResponses) { console.log('***  ***' + eventControllerName); }    
            if (logApiResponses) { console.log('*** '  + wrapperObject); }    
            var appEvent = $A.get('e.c:' + eventControllerName);
            appEvent.setParams({
                "message" : message,
                "selectedproducts":JSON.parse(JSON.stringify(wrapperObject))
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
        
        component.initCartProducts = function() {
            component.apiCall('getselectedProducts', {}, function(selectedproductWrapper) {
               component.set('v.selectedProducts', selectedproductWrapper);
            });
        };
        component.initCartProducts();
    },

    handleLoadMore: function (component, event, helper) {
        if (!(component.get("v.currentCount") >= component.get("v.totalRows"))) {
            //To display the spinner
            event.getSource().set("v.isLoading", true);
            //To handle data returned from Promise function
            helper.loadData(component).then(function (data) {
                var currentData = component.get("v.productData");
                var newData = currentData.concat(data);
                component.set("v.productData", newData);
                //To hide the spinner
                event.getSource().set("v.isLoading", false);
            });
        } else {
            //To stop loading more rows
            component.set("v.enableInfiniteLoading", false);
            event.getSource().set("v.isLoading", false);
            var toastReference = $A.get("e.force:showToast");
            toastReference.setParams({
                "type": "Success",
                "title": "Success",
                "message": "All Products records are loaded",
                "mode": "dismissible"
            });
            toastReference.fire();
        }
    },
    fireApplicationEvent : function(component, event) {
        var logApiResponses = true;
        var message = 'Product Added Successfully';
        var selectedProductWrapper = component.get('v.selectedProducts');
        var selectedItem = event.currentTarget;
        var selectedProdId = selectedItem.dataset.id; // Prodid
        component.apiCall('getselectedProductbyId', {prodId : selectedProdId}, function(selectedproduct) {
            
            if(selectedProductWrapper.length >0){
                var loop=0;
                selectedProductWrapper.forEach(function (selectedProduct) {
                    loop = loop+1;
                    console.log('Loop Count::::: ' + loop + ' :::::::::');
                    var currentprodId = selectedProduct.product.Id;
                    if(currentprodId == selectedProdId){
                        selectedProduct.quantity = selectedProduct.quantity + 1;
                        if (logApiResponses) { console.log('inside already added product selectedProduct '); }
                        if (logApiResponses) { console.table(selectedProduct); }
                    }
                    else
                    {
                        var curprod=selectedproduct;
                        selectedProductWrapper.push(curprod);
                         if (logApiResponses) { console.log('wrapper list not empty inside else new added product selectedProduct '); }
                         if (logApiResponses) { console.table(selectedProduct); }
                    }
                    
                    component.set('v.selectedProducts',selectedProductWrapper);
                    if (logApiResponses) { console.log(' After Processing inside foreach selectedProductWrapper '); }
                    if (logApiResponses) { console.table(selectedProductWrapper); }
                    component.fireApplicationEventCall('posCommunicationEvent' , message, selectedProductWrapper );
                });
            }
            else{
                var curprod=selectedproduct;
                selectedProductWrapper.push(curprod);
                if (logApiResponses) { console.log('empty wrapper list add new inside else selectedProductWrapper ' ); }
                if (logApiResponses) { console.table(selectedProductWrapper); }
                component.set('v.selectedProducts',selectedProductWrapper);
                component.fireApplicationEventCall('posCommunicationEvent' , message, selectedProductWrapper );
            }
            
            

        });
        //component.fireApplicationEvent('posCommunicationEvent' , message, selectedProductWrapper );
        if (logApiResponses) { console.log('selectedProdId fireApplicationEvent ' + selectedProdId); }

        
        if (logApiResponses) { console.log('after get selectedProducts selectedProductWrapper '); }
        if (logApiResponses) { console.table(selectedProductWrapper); }
        if (logApiResponses) { console.log('selectedProductWrapper.length() ' + selectedProductWrapper.length); }
        
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