({
    myAction: function (component, event, helper) {
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
        var externalidattribute = component.get('v.Externalidfix');
        console.log("getting the attribute " + externalidattribute);
        var action = component.get('c.isExternalcheck');
        console.table("getting the serversidemethod " + action);
        
        action.setCallback(this, function (response) {
            console.log('stringify'+JSON.stringify(action));
            //alert(JSON.stringify(action));
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert('state:::::'+state);
                component.set('v.Externalidfix', response.getReturnValue());
                console.log("Aftersetting" + externalidattribute);
            } else {
                // Failure
                console.log('Error in Retriving Content Document');
            }
        });
        var escapattribute = component.get('v.Escapchrect');
        console.log("getting the attribute " + escapattribute);
        var action1 = component.get('c.Escapcharectercheck');
        console.table("getting the serversidemethod " + action1);
        
        action1.setCallback(this, function (response) {
            console.log('stringify'+JSON.stringify(action1));
            //alert(JSON.stringify(action1));
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert('state:::::'+state);
                component.set('v.Escapchrect', response.getReturnValue());
                console.log("Aftersetting" + escapattribute);
            } else {
                // Failure
                console.log('Error in Retriving Content Document');
            }
            
        });
        var escapattribute = component.get('v.Enablementattr');
        console.log("getting the attribute " + escapattribute);
        var action2 = component.get('c.intEnablement');
        action2.setCallback(this, function (response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert('state:::::'+state);
                var Enablement = response.getReturnValue();
                component.set('v.Enablementattr', Enablement);
                console.log("Aftersetting" + escapattribute);
            } else {
                // Failure
                console.log('Error in Retriving Content Document');
            }
            
        });
        
        var action3 = component.get('c.Notificationpartialcheck');
        console.table("Notificationpartialcheck++---" + action3);
        action3.setCallback(this, function (response) {
            console.log('stringify'+JSON.stringify(action3));
            //alert(JSON.stringify(action2));
            var state = response.getState();
             //alert('state:::::'+state);
            if (state === "SUCCESS") {
               
                var notificationPartial = response.getReturnValue();
                component.set('v.notificationPartial',notificationPartial );
                console.log("notificationPartial " + notificationPartial);
			component.displayMessage('Success!', 'Loaded Notifications : ', 'success','dismissible');

            } else {
                // Failure
                console.log('Error in Retriving Content Document');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.displayMessage('Failure!', 'Failed to Charge Order : '+errors[0].message, 'error','dismissible');
                    }
                }
            }
            
        });
        var action4 = component.get('c.fieldsettingLookupTowayCheck');
         action4.setCallback(this, function (response) {
           var state = response.getState();
            // alert('state'+response.getState());
            if (state === "SUCCESS") {
        var fieldsettingLookup = response.getReturnValue();
                
        component.set('v.Fieldlookup',fieldsettingLookup );  
                } else {
                // Failure
                console.log('Error in Retriving Content Document');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.displayMessage('Failure!', 'Failed to Charge Order : '+errors[0].message, 'error','dismissible');
                    }
                }
            }
        });
        var action5 = component.get('c.flowActiveCheck');
         action5.setCallback(this, function (response) {
           var state = response.getState();
            // alert('state'+response.getState());
            if (state === "SUCCESS") {
        var flowcheckresponse = response.getReturnValue();
                
        component.set('v.flowcheck',flowcheckresponse );  
                } else {
                // Failure
                console.log('Error in Retriving Content Document');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.displayMessage('Failure!', 'Failed to Charge Order : '+errors[0].message, 'error','dismissible');
                    }
                }
            }
        });
        var action6 = component.get('c.NotificationInterfaceCheck');
         action6.setCallback(this, function (response) {
           var state = response.getState();
            // alert('state'+response.getState());
            if (state === "SUCCESS") {
        var Interfaceresponse = response.getReturnValue();
                
        component.set('v.NotificationInterface',Interfaceresponse );  
                } else {
                // Failure
                console.log('Error in Retriving Content Document');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.displayMessage('Failure!', 'Failed to Charge Order : '+errors[0].message, 'error','dismissible');
                    }
                }
            }
        });
        var action7 = component.get('c.ExtensionCheck');
         action7.setCallback(this, function (response) {
           var state = response.getState();
            // alert('state'+response.getState());
            if (state === "SUCCESS") {
        var extensionResponse = response.getReturnValue();
                
        component.set('v.extension',extensionResponse );  
                } else {
                // Failure
                console.log('Error in Retriving Content Document');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.displayMessage('Failure!', 'Failed to Charge Order : '+errors[0].message, 'error','dismissible');
                    }
                }
            }
        });
        var action8 = component.get('c.objectFieldLowercasecheck');
         action8.setCallback(this, function (response) {
           var state = response.getState();
            // alert('state'+response.getState());
            if (state === "SUCCESS") {
        var FieldlowercaseResponse = response.getReturnValue();
                
        component.set('v.Fieldlowercase',FieldlowercaseResponse );  
                } else {
                // Failure
                console.log('Error in Retriving Content Document');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.displayMessage('Failure!', 'Failed to Charge Order : '+errors[0].message, 'error','dismissible');
                    }
                }
            }
        });
        $A.enqueueAction(action);
        $A.enqueueAction(action1);
        $A.enqueueAction(action2);
        $A.enqueueAction(action3);
        $A.enqueueAction(action4);
        $A.enqueueAction(action5);
        $A.enqueueAction(action6);
        $A.enqueueAction(action7);
        $A.enqueueAction(action8);
    },
})