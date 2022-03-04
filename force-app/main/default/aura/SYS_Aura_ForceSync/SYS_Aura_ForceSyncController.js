({
    doInit : function(component, event, helper) {

    },

    invokeFlowJS : function(component, event, helper){
        component.set("v.messageType", "slds-badge");
        component.set("v.message", 'Please wait while we sync the record:'+component.get("v.recordId"));
        
        let action = component.get("c.invokeFlow");
        action.setParams({
                            "recId" : component.get("v.recordId"),
                            "objSetting" : event.target.getAttribute("data-objsetting"),
                            "apexHandler" : event.target.getAttribute("data-handler"),
                            "direction" : event.target.getAttribute("data-direction")
                        });
        
        action.setCallback(this,function(response){
            let state = response.getState();
            if(state === 'SUCCESS'){    
                var sysLogStatus = response.getReturnValue().Status__c;
                console.log('Apex response:',sysLogStatus);

                var toastEvent = $A.get("e.force:showToast");

                if(sysLogStatus.toUpperCase() == 'DONE'){
                    toastEvent.setParams({
                        "title": "",
                        "type":"success",
                        "message": "Record sync successful"
                    });
                }
                else{
                    toastEvent.setParams({
                        "title": "",
                        "type":"error",
                        "message": "Record could not be synced. SYS Log Status: "+sysLogStatus
                    });
                }

                component.set("v.message", '');
                toastEvent.fire();
                //$A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.message", 'Error while creating log record: '+errors[0].message);
                    }
                }
                else{
                    component.set("v.message", 'Error while creating log record: Unknown error');
                }
                component.set("v.messageType", "slds-badge slds-theme_error");

            }
        });

        $A.enqueueAction(action);
    }
})