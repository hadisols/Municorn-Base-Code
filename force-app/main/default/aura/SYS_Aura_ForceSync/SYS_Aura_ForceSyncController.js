({
    doInit : function(component, event, helper) {

    },

    invokeFlowJS : function(component, event, helper){
        component.set("v.message", 'Please wait while we sync the record:'+component.get("v.recordId"));
        
        let action = component.get("c.invokeFlow");
        action.setParams({
                            "recId" : component.get("v.recordId"),
                            "objSetting" : component.get("v.objectSetting"),
                            "apexHandler" : component.get("v.apexHandler")
                        });
        //action.setParams({"objSetting" : component.get("v.objectSetting")});
        
        action.setCallback(this,function(response){
            let state = response.getState();
            if(state === 'SUCCESS'){    
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "type":"success",
                    "message": "Record successfully synced"
                });
                component.set("v.message", '');
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
                
            }else{
                component.set("v.message", 'Something went wrong. Please check SYS Logs for more info');

            }
        });

        $A.enqueueAction(action);
    }
})