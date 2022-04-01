({
    doInit: function (component, event, helper) {
        var logApiResponses = true;
        component.displayMessage = function (title, message, type , mode ) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "mode": mode,
                "title": title,
                "type": type,
                "message": message
            });
            toastEvent.fire();
        };
        component.navigateToPOSOrderSelection = function ( orderUUID ) {
            var nagigateLightning = component.find('navigate');
            var pageReference = {
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'pos-selection'
                },
                state: {
                    order: orderUUID
                } 
            };
                nagigateLightning.navigate(pageReference);
        };
        var action = component.get('c.getOpenTabMembers');
        action.setCallback(this, function (response) {
            var state = response.getState();
           if (state == "SUCCESS") {
               var allopenTabs = response.getReturnValue();
                //For Aura attribute Iterate for UI
                component.set('v.openTabMembers',allopenTabs);

                if (logApiResponses) { console.log('Init allopenTabs'); }
                if (logApiResponses) { console.table(allopenTabs); }
              
           } else { // if any callback error, display error msg
            component.displayMessage('Error', 'An error occurred during Initialization ' + state, 'Error','dismissible');
           }
            
        });
        $A.enqueueAction(action);
        
    },
    onEnterText: function (component, event, helper) {
        var logApiResponses = true;
        var action = component.get('c.searchActiveMembers');
        component.set('v.searchText',event.target.value);
        action.setParams({
            keyword: component.get('v.searchText')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var searchResults = response.getReturnValue();
                 component.set('v.searchResult',searchResults);
                // get section Div element using aura:id
                var sectionDiv = component.find("searchResultSection").getElement();
                $A.util.addClass(sectionDiv, 'slds-is-open'); 
                
                 if (logApiResponses) { console.log('Keyword searchResults'); }
                 if (logApiResponses) { console.table(searchResults); }
               
            } else { // if any callback error, display error msg
             component.displayMessage('Error', 'An error occurred during Searching ' + state, 'Error','dismissible');
            }
        });
        $A.enqueueAction(action);
    },
    // common reusable function for toggle sections
    toggleSection : function(component, event, helper) {
        // dynamically get aura:id name from 'data-auraId' attribute
        var sectionAuraId = event.target.getAttribute("data-auraId");
        // get section Div element using aura:id
        var sectionDiv = component.find(sectionAuraId).getElement();
        /* The search() method searches for 'slds-is-open' class, and returns the position of the match.
         * This method returns -1 if no match is found.
        */
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        $A.util.toggleClass(sectionDiv, 'slds-is-open');
    },
    openPOSOrderScreen : function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var selectedOrderUUID = selectedItem.dataset.orderuuid;
        component.navigateToPOSOrderSelection(selectedOrderUUID);
    },
    CreateOrder : function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var selectedMemberId = selectedItem.dataset.memberid;
        var action = component.get('c.createDraftOrderRecord');
        action.setParams({
            "memberId" : selectedMemberId,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log(' response.getReturnValue()');
               console.log(response.getReturnValue());
           if (state == "SUCCESS") {
               var orderUUID = response.getReturnValue();
               console.log('Init orderUUID');
               console.log(orderUUID);
               component.navigateToPOSOrderSelection(orderUUID.UUID__c);              
           } else { // if any callback error, display error msg
            component.displayMessage('Error', 'An error occurred during order Creation ' + state, 'Error','dismissible');
           }
            
        });
        $A.enqueueAction(action);
    }
});