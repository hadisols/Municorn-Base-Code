({
    onInit: function (component, event, helper) {
        component.set("v.shape", 'square');  
        component.find("select").set("v.value", "square");
        component.displayMessage = function (title, message, type) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "mode": 'dismissible',
                "title": title,
                "type": type,
                "message": message
            });
            toastEvent.fire();
        };

        var recordId = component.get("v.recordId");
        var action = component.get("c.getSysTrackRecordPictureURL");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                    var imageURL = a.getReturnValue();
                    console.log('imageURL ' + imageURL);
                    if(imageURL !== 'noimage'){
                        // Success
                        component.set("v.imageURL", imageURL);    
                        // $A.get('e.force:refreshView').fire();
                    }
            }
            else{
                // Failure
                console.log('Error in Retriving imageURL');
            }
        });
        $A.enqueueAction(action);
        
    },
    changeImageStyle: function (component, evt, helper) {
        var cstyle = component.find('select').get('v.value');  
        component.set("v.shape", cstyle);  
    },
    changeImageWidth: function (component, evt, helper) {
        var imgWidth = component.find('imageWidth').get('v.value');
        console.log('imgWidth'+imgWidth);   
        component.set("v.imgWidth", imgWidth);  
    },
    changeImageHeight: function (component, evt, helper) {
        var imgHeight = component.find('imageHeight').get('v.value');  
        console.log('imgHeight'+imgHeight);   
        component.set("v.imgHeight", imgHeight);  
    }
})