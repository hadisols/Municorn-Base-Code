({
    doInit: function(c, e, h) {
        c.refreshDatainUI = function (c,e,h) {
            // does whatever you need it to actually do - probably signs them out or stops polling the server for info
            console.log('Do Pooling');
            var inprogressAction = c.get("v.userInteraction");
            console.log('Pooling Status' + inprogressAction);
            if(inprogressAction == false){
                console.log('Pooling Status getOrderItems' + inprogressAction);
                c.getOrderItems(c,e,h);
            }else{
                console.log('Pooling Status resetTimer' + inprogressAction);
                c.resetTimer(c,e,h);
            }
            console.log('Done refreshApex');
        }
        c.resetTimer = function (c,e,h) {
            // console.log('resetTimer'); 
            var setIntervalId = c.get("v.setIntervalId");
            window.clearInterval(setIntervalId);
            c.startTimer(c,e,h);
        }
        c.startTimer = function (c,e,h) { 
            console.log('startTimer');
            console.log(c.get("v.timeoutInMiliseconds"));
            var timeoutInMiliseconds = c.get("v.timeoutInMiliseconds");
            // window.setTimeout returns an Id that can be used to start and stop a timer
            var timeoutId =  window.setInterval(
                                $A.getCallback(function() { 
                                    c.refreshDatainUI(c,e,h);
                                }), timeoutInMiliseconds
                            );
            c.set("v.setIntervalId" , timeoutId);
        }	
        window.setTimeout(
            $A.getCallback(function() { 
                c.startTimer(c,e,h);
            }), 5000
        ); 
        var action = c.get("c.getKanbanWrapperDetails_Apex");
        action.setParams({
            "sObjectName":c.get("v.sObjectName"),
            "sObjectFields":c.get("v.sObjectFields"),
            "sObjectPickListValue":c.get("v.sObjectPickListValue")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state:: ' + state);
            if (state === "SUCCESS") {
                console.dir(response.getReturnValue());
                c.set("v.sObjectRecordList", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        //Polling Functions
        c.getOrderItems = function (c,e,h) {
            var actiongetOrerItems = c.get("c.getKanbanWrapperDetails_Apex");
            actiongetOrerItems.setParams({
                "sObjectName":c.get("v.sObjectName"),
                "sObjectFields":c.get("v.sObjectFields"),
                "sObjectPickListValue":c.get("v.sObjectPickListValue")
            });
            actiongetOrerItems.setCallback(this, function(response){
                var state = response.getState();
                console.log('state:: ' + state);
                if (state === "SUCCESS") {
                    console.dir(response.getReturnValue());
                    c.set("v.sObjectRecordList", response.getReturnValue());
                }
            });
            $A.enqueueAction(actiongetOrerItems);
        }
        
    },
    doView: function(c, e, h) {
        var editRecordEvent = $A.get("e.force:navigateToSObject");
        editRecordEvent.setParams({
            "recordId": e.target.id
        });
        editRecordEvent.fire();
    },
    allowDrop: function(c, e, h) {
        e.preventDefault();
    },
    
    drag: function (c, e, h) {
        c.set("v.dragid", e.currentTarget.dataset.dragId);
        c.set("v.userInteraction", true);
        e.dataTransfer.setData("text", e.currentTarget.dataset.dragId);
    },
    
    drop: function (c, e, h) {
        e.preventDefault();
        var data = e.dataTransfer.getData("text");
        c.set("v.userInteraction", true);
        const currentdraggedElement = document.querySelector('[data-drag-id="'+data+'"]');
        var tar = e.currentTarget;
        while(tar.tagName != 'ul' && tar.tagName != 'UL') {
            tar = tar.parentElement;
        }
        tar.appendChild(currentdraggedElement);
        currentdraggedElement.style.backgroundColor = "#ffb75d";
        h.getUpdatePickListValue_helper(c, data, c.get("v.sObjectPickListValue"), tar.getAttribute('data-Pick-Val'));
    },
    itemTouchNextStage: function (c, e, h) {
        var parentUlElement;
        var tar = e.currentTarget;
        var currentRecordId = tar.dataset.recordId;
        var newStage;
        var allstages = c.get("v.sObjectRecordList.pickVals");
        const currentdraggedElement = document.querySelector('[data-drag-id="'+currentRecordId+'"]');
        var parentUlElement= currentdraggedElement;
        while(parentUlElement.tagName != 'ul' && parentUlElement.tagName != 'UL') {
            parentUlElement = parentUlElement.parentElement;
        }
        var currentStage = parentUlElement.dataset.pickVal;
        allstages.forEach((value, index) => {
            if ((index !== allstages.length) && (currentStage == value)) {
                newStage = allstages[++index];
            }
        });

        const targetStageUl = document.querySelector('[data-Pick-Val="'+newStage+'"]');
        targetStageUl.appendChild(currentdraggedElement);

        currentdraggedElement.style.backgroundColor = "#ffb75d";
        
        h.getUpdatePickListValue_helper(c, currentRecordId, c.get("v.sObjectPickListValue"), newStage);
    }
})