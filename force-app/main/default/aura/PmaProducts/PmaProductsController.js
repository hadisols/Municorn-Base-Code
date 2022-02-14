({
    onInit: function (component, event, helper) {
        // Call helper to set the data for account table
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
        var selectedItem = event.currentTarget;
        var selectedProdId = selectedItem.dataset.id; // Prodid
        var selectedProdObj = JSON.stringify(selectedItem.dataset.prodObj); // Product 
        if (logApiResponses) { console.log('after selectedProdObj ' + JSON.stringify()); }
        if (logApiResponses) { console.table(selectedProdObj.Name); }

        if (logApiResponses) { console.log('selectedProdId fireApplicationEvent ' + selectedProdId); }

        var selectedProductWrapper = [];
        selectedProductWrapper = component.get('v.selectedProducts');
        if (logApiResponses) { console.log('after get selectedProducts selectedProductWrapper '); }
        if (logApiResponses) { console.table(selectedProductWrapper); }
        if (logApiResponses) { console.log('selectedProductWrapper.length() ' + selectedProductWrapper.length); }
        if(selectedProductWrapper.length >0){
            selectedProductWrapper.forEach(function (selectedProduct) {
                var currentprodId = selectedProduct.Id;
                if(currentprodId == selectedProdId){
                    selectedProduct.quantity = selectedProduct.quantity + 1;
                    if (logApiResponses) { console.log('inside already added product selectedProduct.product '); }
                if (logApiResponses) { console.table(selectedProduct.product); }
                }
                else
                {
                    var curprod={'product' : selectedProdObj,'quantity' : 1};
                     selectedProductWrapper.push(curprod);
                     if (logApiResponses) { console.log('inside else new added product selectedProduct.product '); }
                     if (logApiResponses) { console.table(selectedProduct.product); }
                }
                // selectedProduct.product = selectedProdObj;
                // selectedProduct.quantity = selectedProduct.quantity + 1;
                //selectedProduct.productPrice = selectedProduct.PricebookEntries[0].UnitPrice;
                if (logApiResponses) { console.log('inside foreach selectedProduct.product '); }
                if (logApiResponses) { console.table(selectedProduct.product); }
            });
        }
        else{
            var selectedProductWrapper = [];
            var currentPrice= selectedProdObj.PricebookEntries[0].UnitPrice;
            var currentTotalPrice= currentPrice * 1;
            var curprod={'product' : selectedProdObj,'quantity' : 1};
            selectedProductWrapper.push(curprod);
            /* console.table(selectedProductWrapper); ,'productPrice' : currentPrice,'totalProductPrice' : currentTotalPrice
            selectedProductWrapper.push({'product' : selectedProdObj});
            selectedProductWrapper.push({'quantity' : 1});
            selectedProductWrapper.push({'productPrice' : 1});
            selectedProductWrapper.push({'totalProductPrice' : 1}); */
            if (logApiResponses) { console.log('inside else selectedProductWrapper ' ); }
            if (logApiResponses) { console.table(selectedProductWrapper); }
        }
        if (logApiResponses) { console.log('Outside IF selectedProductWrapper ' ); }
            if (logApiResponses) { console.table(selectedProductWrapper); }
        component.set('v.selectedProducts' , selectedProductWrapper);
        selectedProductWrapper = JSON.stringify(selectedProductWrapper);
        if (logApiResponses) { console.log('selectedProductWrapper  ' + selectedProductWrapper); }
        /* for (var i = 0; i < productList.length; i++) {
            var c = productList[i];
            if (c.isSelected) {
                selectedProducts[k] = c;
            }
        } */
        
        
       if (logApiResponses) { console.table( selectedProductWrapper); }
      /*  if(selectedproductWrapper ==null || selectedproductWrapper==undefined || selectedproductWrapper ==''){
        if (logApiResponses) { console.log( 'selectedProdObj ' + selectedProdObj); }
       } */
        component.set('v.selectedProducts',selectedProductWrapper);
        // Get the application event by using the
        // e.<namespace>.<event> syntax
        var appEvent = $A.get("e.c:posCommunicationEvent");
        appEvent.setParams({
            "message" : selectedProdId,
            "selectedproducts":selectedProductWrapper
         });
        if (logApiResponses) { console.log('*** ' + 'sending application event' + ' ***'); }    
        
        appEvent.fire();
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