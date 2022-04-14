({
    onInit: function (component, event, helper) {
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
        var action = component.get("c.getSysTrackRecordDocumentId");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                    var documentId = a.getReturnValue();
                    // Success
                    component.set("v.contentDocumentId", documentId);
                    $A.get('e.force:refreshView').fire();
            }
            else{
                // Failure
                console.log('Error in Retriving Content Document');
            }
        });
        $A.enqueueAction(action);

    },
    handleUploadFinished: function (component, event, helper) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        console.log("Files Uploaded : " + uploadedFiles.length);
       
        // Get the File Name and ContentDocument Id
        var i = 0;
        uploadedFiles.forEach(file => {
            if(i == 0 ){
                component.set("v.contentDocumentId", file.documentId);
                component.set("v.fileName", file.name);
                console.log('File Name: '+ file.name + ' ContentDocument Id: ' + file.documentId);

                var recordId = component.get("v.recordId");
                var action = component.get("c.createSysTrackRecord");
                action.setParams({
                    recordId : recordId,
                    contentDocumentId: file.documentId
                });
                action.setCallback(this, function(a) {
                    var state = a.getState();
                    if (state === "SUCCESS") {
                         // Success
                        component.displayMessage('Success!', 'Image Uploaded Successfully!', 'success');
                        $A.get('e.force:refreshView').fire();
                    }
                    else{
                        // Failure
                        component.displayMessage('Error', 'An error occurred during Uploading Image ', 'Error');
                    }
                });
                $A.enqueueAction(action);
            }
            i++;
        });
    }
})