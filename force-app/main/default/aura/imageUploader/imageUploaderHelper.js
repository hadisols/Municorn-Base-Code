({
    insertSysTrack: function(component, contentDocumentId, callback) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.createSysTrackRecord");
        console.log('type: ' + file.type);
        action.setParams({
            recordId : recordId,
            contentDocumentId: contentDocumentId
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                callback(a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }, 
    show: function (cmp, event) {
        var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.util.addClass(spinner, "slds-show");
    },
    hide:function (cmp, event) {
        var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, "slds-show");
        $A.util.addClass(spinner, "slds-hide");
    }
})