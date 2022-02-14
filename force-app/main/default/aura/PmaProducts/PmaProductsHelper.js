({
    getData: function (component) {
        // call apex class method
        var action = component.get("c.getProductRecords");
        action.setParams({
            "initialRows": component.get("v.initialRows") //how many rows to load during initialization
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var toastReference = $A.get("e.force:showToast");
            if (state == "SUCCESS") {
                var productWrapper = response.getReturnValue();
                if (productWrapper.success) {
                    // set total rows count from response wrapper
                    component.set("v.totalRows", productWrapper.totalRecords);

                    var productList = productWrapper.productsList;
                    // play a for each loop on list of product and set Product URL in custom 'productName' field
                    productList.forEach(function (product) {
                        product.prodName = '/' + product.Id;
                    });
                    // set the updated response on productData aura attribute  
                    component.set("v.productData", productList);
                    console.table(productList[0].PricebookEntries[0].UnitPrice);
                    // display a success message  
                    toastReference.setParams({
                        "type": "Success",
                        "title": "Success",
                        "message": productWrapper.message,
                        "mode": "dismissible"
                    });
                    toastReference.fire();
                } else { // if any server side error, display error msg from response
                    toastReference.setParams({
                        "type": "Error",
                        "title": "Error",
                        "message": productWrapper.message,
                        "mode": "sticky"
                    });
                    toastReference.fire();
                }
            } else { // if any callback error, display error msg
                toastReference.setParams({
                    "type": "Error",
                    "title": "Error",
                    "message": 'An error occurred during Initialization ' + state,
                    "mode": "sticky"
                });
                toastReference.fire();
            }
        });
        $A.enqueueAction(action);
    },

    loadData: function (component) {
        return new Promise($A.getCallback(function (resolve) {
            var limit = component.get("v.initialRows");
            var offset = component.get("v.currentCount");
            var totalRows = component.get("v.totalRows");
            if (limit + offset > totalRows) {
                limit = totalRows - offset;
            }
            var action = component.get("c.loadProductRecords");
            action.setParams({
                "rowLimit": limit,
                "rowOffset": offset
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                var newData = response.getReturnValue();
                // play a for each loop on list of new Products and set Product URL in custom 'productName' field
                newData.forEach(function (product) {
                    product.prodName = '/' + product.Id;
                });
                resolve(newData);
                var currentCount = component.get("v.currentCount");
                currentCount += component.get("v.initialRows");
                // set the current count with number of records loaded 
                component.set("v.currentCount", currentCount);
            });
            $A.enqueueAction(action);
        }));
    }
})