({
    doInit : function(component, event, helper) {
        component.set("v.message", 'Please wait while we fetch the token...');
        var invokeTokenFlowJSaction = component.get("c.invokeTokenFlowJS");
        $A.enqueueAction(invokeTokenFlowJSaction);

    },

    invokeTokenFlowJS : function(component, event, helper){
        
        let action = component.get("c.invokeTokenFlow");
        action.setParams({"oauthConfigId" : component.get("v.recordId")});
        action.setCallback(this,function(response){
            let state = response.getState();
            if(state === 'SUCCESS'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "type":"success",
                    "message": "Token successfully generated."
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
                
            }else{
                component.set("v.message", 'Token could not be generated. Please try after some time');

            }
        });

        $A.enqueueAction(action);
    }
})