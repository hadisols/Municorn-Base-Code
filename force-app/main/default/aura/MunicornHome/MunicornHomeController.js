({
    doInit : function(component, event, helper) {
        component.inactiveTab = function() {
            component.set('v.activateHealthCheckTab', false);
            component.set('v.activateSetupTab', false);
            component.set('v.activateTroubleshootTab', false);
            component.set('v.activateFAQTab', false);
            component.set('v.activateSupportTab', false);
        }

        component.set('v.syslogcolumns', [
            {label: 'Log Id', fieldName: 'Name', type: 'text'},
            {label: 'Http Status Code', fieldName: 'StatusCode', type: 'text'},
            {label: 'Response', fieldName: 'Response', type: 'text'},
            {label: 'Date', fieldName: 'ErrorDt', type: 'date'}
        ]);

        component.apiCall = function (controllerMethodName, params, success, failure) {
			component.set('v.Loading', true);
			
            var action = component.get('c.' + controllerMethodName);
            if(params)
                action.setParams(params);
            
            action.setCallback(this, function (data) {
                console.log(data);
                
                var errors = data.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    if (failure) {
                        failure(errors[0].message);
                    } else {
                        
                        alert('Failed to perform action!');
                    }
                } else {
                    if (success) {
						success(data.getReturnValue());
					}
                }
				
            });
            $A.enqueueAction(action);
        };
    },
    handleTabHealthCheck : function(component, event, helper) {
        component.inactiveTab();
        component.set('v.activateHealthCheckTab', true);
    },
    handleTabSetup : function(component, event, helper) {
        component.inactiveTab();
        component.set('v.activateSetupTab', true);
    },
    handleTabTroubleshoot : function(component, event, helper) {
        component.inactiveTab();
        component.set('v.activateTroubleshootTab', true);
    },
    handleTabFAQ : function(component, event, helper) {
        component.inactiveTab();
        component.set('v.activateFAQTab', true);
    },
    handleTabSupport : function(component, event, helper) {
        component.inactiveTab();
        component.set('v.activateSupportTab', true);
    },

    handleFetchErrorMessage : function(component, event, helper) {
        component.set('v.syslogdata', []);
        component.set('v.showTable', false);
        component.apiCall('getErrorResponse', '',
        function(returnVal) {
			component.set('v.syslogdata', returnVal);
            if(returnVal.length > 0) {
                component.set('v.showTable', true);
                component.set('v.tableMessage', 'Recent Error responses');
            } else {
                component.set('v.tableMessage', 'No errors found');
            }
			component.set('v.Loading', false);
		}, function(error){
            console.log(error);
			component.set('v.Loading', false);
		});
    }
})
