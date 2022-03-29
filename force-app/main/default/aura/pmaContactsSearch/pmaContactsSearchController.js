({
    doInit: function (component, event, helper) {
        var logApiResponses = true;
        component.displayMessage = function (title, message, type) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "mode": 'sticky',
                "title": title,
                "type": type,
                "message": message
            });
            toastEvent.fire();
        };
        var action = component.get('c.getOpenTabMembers');
        action.setCallback(this, function (response) {
            var state = response.getState();
           if (state == "SUCCESS") {
               var allopenTabs = response.getReturnValue();
                //component.set('v.searchResult',allopenTabs);
                //For Aura attribute Iterate for UI
                component.set('v.openTabMembers',allopenTabs);

                if (logApiResponses) { console.log('Init allopenTabs'); }
                if (logApiResponses) { console.table(allopenTabs); }
              
           } else { // if any callback error, display error msg
            component.displayMessage('Error', 'An error occurred during Initialization ' + state, 'Error');
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
                 var sectionDiv = component.find(sectionAuraId).getElement();

                //  $A.enqueueAction(component.get('c.controllerMethod'));
                //  var resultssection = cmp.find("searchResultSection");
                sectionDiv.click();
                 if (logApiResponses) { console.log('Keyword searchResults'); }
                 if (logApiResponses) { console.table(searchResults); }
               
            } else { // if any callback error, display error msg
             component.displayMessage('Error', 'An error occurred during Searching ' + state, 'Error');
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
        
        // -1 if 'slds-is-open' class is missing...then set 'slds-is-open' class else set slds-is-close class to element
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }
    },
    navigate : function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var selectedMemberId = selectedItem.dataset.memberid;

        var nagigateLightning = component.find('navigate');
        var pageReference = {
            type: 'standard__namedPage',
            attributes: {
                pageName: 'pos-selection'
            },
            state: {
                recordd: selectedMemberId
            } 
        };
        nagigateLightning.navigate(pageReference);
    }
});