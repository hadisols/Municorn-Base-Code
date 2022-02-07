({
    setup : function(component, event, helper) {
            console.info('bootstrap loaded successfully.');
    },
    onInit: function (component, event, helper) {
        //Setting up colum information
        component.set("v.accountColums",
            [{
                    label: 'Name',
                    fieldName: 'prodName',
                    type: 'url',
                    typeAttributes: {
                        label: {
                            fieldName: 'Name'
                        },
                        target: '_blank'
                    }
                },
                {
                    label: 'Product Code',
                    fieldName: 'ProductCode',
                    type: 'text',
                },
                {
                    label: 'Active',
                    fieldName: 'IsActive',
                    type: 'checkbox',
                }
            ]);
        // Call helper to set the data for account table
        helper.getData(component);
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

})