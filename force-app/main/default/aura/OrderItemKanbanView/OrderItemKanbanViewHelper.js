({
    getUpdatePickListValue_helper : function(c, recordId, sObjectPickListValue, pickListUpdatedValue) {
        var action = c.get("c.getUpdatePickListValue_Apex");
        action.setParams({
            "recordId" : recordId,
            "sObjectPickListValue" : sObjectPickListValue,
            "pickListUpdatedValue" : pickListUpdatedValue
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                const currentdraggedElement = document.querySelector('[data-drag-id="'+recordId+'"]');
                currentdraggedElement.style.backgroundColor = "#04844b";
                setTimeout(function () {
                    currentdraggedElement.style.backgroundColor = "";
                    c.set("v.userInteraction", false);
                }, 300);
            }
        });
        $A.enqueueAction(action);
    }
})