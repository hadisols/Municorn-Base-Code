({
	doInit: function (component, event, helper) {
		
		window.addEventListener("message", $A.getCallback(function(event) {
            
            console.log('event received', JSON.stringify(event.data));
			console.log('gateway id ', component.get('v.selectedGateway'));
            if(event.data.token != null ) {
                component.paymentRequest(event.data, 'Payment_Intent');
            }
        }), false);

		component.paymentRequest = function(message, objType) {
            var lines = component.get('v.selectedRow');
			component.set('v.CardUILoading', true);
			console.log('line selected ',JSON.stringify(lines));
            message.isCreditCard = component.get('v.isCardActive');
            var accountId = component.get('v.selectedAccount')['Id'];
            if(component.isSubscription()) {
                component.apiCall('createSubscription', {
                    payload : message,
                    chargeRequests : lines
                }, function(returnVal) {
                    console.log('Subscription Id ', returnVal);
                    component.set('v.subscriptionId', returnVal);
                    component.set('v.intentUrl', '/'+returnVal + '');
                    component.apiCall('requestSubscription', {
                        subscriptionId : returnVal,
                        gatewayId : component.get('v.selectedGateway'),
                        obj_type : 'Subscription',
                        payload : message,
                        accountId : accountId,
                        total : component.get('v.totalPaymentAmount')
                    }, function(returnVal) {
                        console.log('Declined error '+ returnVal);
                        if(!returnVal) {
                            console.log('subscription success');
                            component.set('v.paymentCompleted', true);
                            component.displayMessage('Success', 'Subscription is successful!' , 'success');
                            component.set('v.CardUILoading', false);
                            component.set('v.Loading', false);
                        } else {
                            component.set('v.CardUILoading', false);
                            component.set('v.Loading', false);
                            component.displayMessage('Error', returnVal, 'Error');
                        }
                    }, function(error) {
                        console.log('transaction failed');
                        component.set('v.CardUILoading', false);
                        component.displayMessage('Error', error, 'Error');
                        component.set('v.Loading', false);
                    })
                }, function(error) {
                    console.log('transaction failed');
                    component.displayMessage('Error', error, 'Error');
                    component.set('v.CardUILoading', false);
                    component.set('v.Loading', false);
                });
            }
            else if(component.get('v.paymentIntentId')) {
                component.apiCall('createTransaction', {
                    intentId : component.get('v.paymentIntentId'),
                    gatewayId : component.get('v.selectedGateway'),
                    obj_type : objType,
                    payload : message,
                    accountId : accountId,
                    total : component.get('v.totalPaymentAmount')
                }, function(returnVal) {
                    console.log('Declined error '+ returnVal);
                    if(!returnVal) {
                        console.log('transaction success');
                        component.set('v.paymentCompleted', true);
                        component.displayMessage('Success', 'Payment is successful!' , 'success');
                        component.set('v.CardUILoading', false);
                        component.set('v.Loading', false);
                    } else {
                        component.set('v.CardUILoading', false);
                        component.set('v.Loading', false);
                        component.displayMessage('Error', returnVal, 'Error');
                    }
                }, function(error) {
                    console.log('transaction failed');
                    component.set('v.CardUILoading', false);
                    component.displayMessage('Error', error, 'Error');
                    component.set('v.Loading', false);
                })
            } else {
                component.apiCall('createPaymentIntent', {
                    payload : message,
                    chargeRequests : lines
                }, function(returnVal) {
                    console.log('Payment intent Id ', returnVal);
                    component.set('v.paymentIntentId', returnVal);
                    component.set('v.intentUrl', '/'+returnVal + '');
                    component.apiCall('createTransaction', {
                        intentId : returnVal,
                        gatewayId : component.get('v.selectedGateway'),
                        obj_type : objType,
                        payload : message,
                        accountId : accountId,
                        total : component.get('v.totalPaymentAmount')
                    }, function(returnVal) {
                        console.log('Declined error '+ returnVal);
                        if(!returnVal) {
                            console.log('transaction success');
                            component.set('v.paymentCompleted', true);
                            component.displayMessage('Success', 'Payment is successful!' , 'success');
                            component.set('v.CardUILoading', false);
                            component.set('v.Loading', false);
                        } else {
                            component.set('v.CardUILoading', false);
                            component.set('v.Loading', false);
                            component.displayMessage('Error', returnVal, 'Error');
                        }
                    }, function(error) {
                        console.log('transaction failed');
                        component.set('v.CardUILoading', false);
                        component.displayMessage('Error', error, 'Error');
                        component.set('v.Loading', false);
                    })
                }, function(error) {
                    console.log('transaction failed');
                    component.displayMessage('Error', error, 'Error');
                    component.set('v.CardUILoading', false);
                    component.set('v.Loading', false);
                });
            }
			
		}

		component.initData = function() {
			component.set('v.FrequencyOptions', [
				{ 'label': 'One time payment', 'value': 'single'},
				{ 'label': 'Monthly', 'value': 'month' },
				{ 'label': 'Quarterly', 'value': 'quarter' },
				{ 'label': 'Yearly', 'value': 'year' }
			]);

			component.set('v.CheckoutItemsColumns', [
				{label: 'Frequency', fieldName: 'frequencyDisplayName', type: 'text', cellAttributes: { alignment: 'left' }},
				{label: 'Amount', fieldName: 'amount', type: 'currency', editable:'true', cellAttributes: { alignment: 'left' }},
				{label: 'First Charge Date',
					   fieldName: 'firstChargeDate',
					   editable:'true', type: 'date-local',
					   typeAttributes: {
						   day: 'numeric',
						   month: 'short',
						   year: 'numeric'
					   },
					   cellAttributes: { alignment: 'left' }
				},
				{type: 'button', typeAttributes: {name: 'deleteCheckoutItem', iconName: 'utility:delete', label: '', disabled: false, value: 'delete', variant: {fieldName: 'actionButton'}}}
			]);

            if(component.isSubscription())  {
                var table  = [
                    {label: 'Frequency', fieldName: 'frequencyDisplayName', type: 'text', cellAttributes: { alignment: 'left' }},
                    {label: 'Amount', fieldName: 'amount', type: 'currency', editable:'true', cellAttributes: { alignment: 'left' }},
                    {label: 'First Charge Date',
                           fieldName: 'firstChargeDate',
                           editable:'true', type: 'date-local',
                           typeAttributes: {
                               day: 'numeric',
                               month: 'short',
                               year: 'numeric'
                           },
                           cellAttributes: { alignment: 'left' }
                    },
                    {label: 'Occurrence', fieldName: 'occurrence', type: 'number', editable:'true', cellAttributes: { alignment: 'left' }},
                    {type: 'button', typeAttributes: {name: 'deleteCheckoutItem', iconName: 'utility:delete', label: '', disabled: false, value: 'delete', variant: {fieldName: 'actionButton'}}}
                ];
                component.set('v.CheckoutItemsColumns', table);
                console.log('table ', JSON.stringify(component.get('v.CheckoutItemsColumns')));
                component.set('v.SelectedFrequencyDisplay', component.get('v.frequency'));
                var frequencyList = component.get('v.FrequencyOptions');
                for(var i = 0; i < 4 ; i++) {
                    if(frequencyList[i].label == component.get('v.frequency')) {
                        component.set('v.SelectedFrequency', frequencyList[i].value);
                        break;
                    }
                }
            }

			component.apiCall('getObjectDetails', {
                objectId : component.get('v.recordId'),
                accountLookupApiName : component.get('v.accountFieldApiName')
            },
			function(returnVal){
				console.log('Return Value :', returnVal);
                var emailFieldApiName = component.get('v.emailFieldApiName');
                var email = returnVal['record'][emailFieldApiName];
				component.set("v.EmailId", email);
				component.set("v.selectedAccount", returnVal['accountRecord']);
                var accountId = returnVal['accountRecord']['Id'];
                component.set('v.SelectedPaymentSource', returnVal['accountRecord']['Athrz_Default_Payment_Profile_Id__c']);
                
                component.set('v.selectedObject', returnVal['record']);
                component.set('v.PaymentAmount', returnVal['record'][component.get('v.amountFieldApiName')]);
                if(component.isSubscription())
                    component.set('v.PaymentAmount', returnVal['record'][component.get('v.recurringAmountApiName')]);

                component.apiCall('getPaymentGateway',
                {
                    gatewayId : component.get('v.gatewayId')
                },
                function(returnVal) {
                    component.set('v.selectedGateway', returnVal[0].Id);
                    component.set("v.gateways", returnVal);
                    component.loadThirtyPartyPaymentElements();
                    component.syncPaymentMehods(accountId);
                    
                    if(component.get('v.PaymentAmount'))
                        component.initiateCart(component.get('v.PaymentAmount'));
                    if(component.get('v.isAdhoc')) {
                        component.set('v.ShowPaymentOptions', false);
                        component.set('v.ShowDefaultPage', true);
                    } else if(component.isSubscription()) {
                        component.set('v.ShowPaymentOptions', true);
                        component.set('v.ShowDefaultPage', false);
                    } else {
                        component.set('v.ShowPaymentOptions', true);
                        component.set('v.ShowDefaultPage', false);
                    }
                    
                }, function(error) {
                    component.displayMessage('Error', error, 'Error');
                    component.set('v.Loading', false);
                });
			}, 
            function(error) {
                component.displayMessage('Error', error, 'Error');
            });
		}

		component.getPaymentMethods = function() {
            var accountId = component.get('v.selectedAccount')['Id'];
			component.apiCall('getPaymentMethods', {objectId : accountId},
			function(returnVal) {
				console.log('Return Value methods :', returnVal);
				var cardList = [];
				var bankList= [];
				for (var item in returnVal) {
					if(returnVal[item].Card_Number__c) {
						cardList.push(returnVal[item]);
					} else {
						bankList.push(returnVal[item]);
					}
				}
				console.log('cards',cardList, bankList);
				component.set('v.UserCards', cardList);
				component.set('v.UserBankAccounts', bankList);
				component.set('v.PaymentMethodsLoading', false);
				component.set('v.Loading', false);
                var paymentId = component.get('v.SelectedPaymentSource');
                console.log('method active ', paymentId);
                var allPaymentSource = component.get('v.UserCards').concat(component.get('v.UserBankAccounts'));
                for(var i = 0; i < allPaymentSource.length ; i++) {
                    if(paymentId == allPaymentSource[i].Id) {
                        if(allPaymentSource[i].Card_Number__c) {
                            console.log('method active ', paymentId);
                            var total = component.get('v.totalPaymentAmount');
                            total = Number(total) * 1.0399;
                            component.set('v.totalPaymentAmount', total.toFixed(2));
                            component.set('v.isCardActive', true);
                        } else 
                            component.set('v.isCardActive', false);
                        break;
                    }
                }
			}, function(error) {
				component.displayMessage('Error',error, 'Error');
				component.set('v.Loading', false);
			});
		}

        component.reset = function() {
            component.set('v.selectedAccount', null);
            component.set('v.selectedObject', null);
            
            component.set('v.selectedRow', []);
            component.set('v.cardUrl', null);
            component.set('v.bankUrl', null);
            component.set('v.bankUILoading', true);
            component.set('v.paymentCompleted', false);
            component.set('v.PaymentAmount', null);
            component.set('v.selectedAmount', null);
            component.set('v.intentUrl', "");
            component.set('v.activeSections', ['B','C']);
            component.set('v.totalPaymentAmount', null);
            component.set('v.isCardActive', true);
            component.set('v.CardUILoading', true);
            component.set('v.paymentIntentId', null);
            component.set('v.ShowEmailConfirmation', false);
            
            component.set('v.CheckoutItems', []);
            component.set('v.CheckoutItemsColumns', null);
            component.set('v.CheckoutResponses', null);
            component.set('v.PaymentRequestLabel', null);
            component.set('v.FrequencyOptions', null);
            component.set('v.SelectedFrequency', 'single');
            component.set('v.SelectedFrequencyDisplay', 'One time payment');
            component.set('v.FirstChargeDate', null);
            component.set('v.UserCards', []);
            component.set('v.SelectedPaymentSource', null);
            component.set('v.UserBankAccounts', []);
            component.set('v.ShowDefaultPage', component.get('v.isAdhoc'));
            component.set('v.ShowPaymentOptions', false);
            component.set('v.DateToday', null);
            component.set('v.TxnDetailsColumns', null);
            component.set('v.TxnDetailsData', null);
            component.set('v.Txn', null);
            component.set('v.PaymentMethodsLoading', true);
            component.set('v.Loading', true);
            component.set('v.ShowEmail', false);
            component.set('v.EmailId', null);

            component.set('v.showCreditCardUI', false);
            component.set('v.showBankUI', false);
            component.set('v.nameOnAccount', null);
            component.set('v.accountNumber', null);
            component.set('v.accountNumberConfirm', null);
            component.set('v.accountRoutingNumber', null);
            component.set('v.accountType', null);
            component.set('v.saveAccount', true);
            component.set('v.saveAccountAsDefault', true);

        }

		component.load = function() {
			console.log('load called');
			if(component.get('v.sObjectName') == 'Account') {
				var accountId = component.get('v.recordId');
				component.syncPaymentMehods(accountId);

			} else if(component.get('v.sObjectName') == 'Contact') {
				
			} else {
				// component.syncPaymentMehods(accountId);
			}
		}
		
		component.syncPaymentMehods = function(accountId) {
			console.log('apex-1');
			component.apiCall('loadPaymentMethod', {
				accountId : accountId,
				gatewayId : component.get('v.selectedGateway')
			},
			function(resp) {
				component.displayMessage('Success', 'Payment methods updated successfully', 'success');
				component.getPaymentMethods();
				component.set('v.Loading', false);
			}, function(error) {
				component.displayMessage('Error',error, 'Error');
				component.set('v.Loading', false);
			});
		}

		component.uuid4 = function() {
			return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
				var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
				return v.toString(16);
			});
		};

		

		component.displayMessage = function (title, message, type) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "mode": 'pester',
                "title": title,
                "type": type,
                "message": message
            });
            toastEvent.fire();
        };

		component.isValidDate = function(d) {
            var dt = new Date(d);
            dt.setHours(0, 0, 0, 0);
            var today = new Date();
            today.setHours(0, 0, 0, 0);
            return dt > today;
        }

		var logApiResponses = true;

		component.apiCall = function (controllerMethodName, params, success, failure) {
			component.set('v.Loading', true);
			console.log('loading true', controllerMethodName);
            var action = component.get('c.' + controllerMethodName);
            action.setParams(params);
            action.setCallback(this, function (data) {
                if (logApiResponses) console.log(data.getError());
                var errors = data.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    if (failure) {
                        failure(errors[0].message);
                    } else {
                        if (logApiResponses) {
                            console.log(errors);
                        }
                        
                        alert('Failed to perform action!');
                    }
                } else {
                    if (logApiResponses) console.log(data.getReturnValue());
                    if (success) {
						success(data.getReturnValue());
					}
                }
				
            });
            $A.enqueueAction(action);
        };

        component.isSubscription = function() {
            if(component.get('v.recurringAmountApiName') && component.get('v.frequency'))
                return true;
            return false; 
        };
		
		component.initiateCart = function(amount) {
            component.set('v.Loading', true);

            component.set('v.EnableAddToCardButton', false);
            

            var frequency = component.get('v.SelectedFrequency');
            var paymentType = (frequency === 'single') ? 'immediate' : 'subscription'; //frequency
            var firstChargeDate = component.get('v.FirstChargeDate');  //chargedate
            console.log('cart called-2', component.get('v.selectedAccount'));

            firstChargeDate = new Date();
            
            var account = component.get('v.selectedAccount');
            var record = component.get('v.selectedObject');
            var uuid = component.uuid4();
            var gateway = component.get('v.selectedGateway');
            
            var request = {
                id: uuid,
                amount: amount,
                contactName: account.Name,
                accountId: account.Id,
                LookUp: component.get('v.recordId'),
                intentParentApiName: component.get('v.paymentIntentParentFieldApiName'),
                subscriptionParentApiName: component.get('v.subscriptionParentFieldApiName'),
                paymentType: paymentType,
                emailId: component.get("v.EmailId"),
                frequency: component.get('v.SelectedFrequency'),
                firstChargeDate: firstChargeDate,
                frequencyDisplayName: component.get('v.SelectedFrequencyDisplay'),
                gatewayId: gateway,
                intentName: record.Name,
                occurrence: 1
            };
            console.log('inside cart-3', request);

            var checkoutItems = component.get('v.CheckoutItems');
            console.log('items', checkoutItems);
            checkoutItems.push(request);
            var totalPayment = 0.00;
            for(var i = 0; i < checkoutItems.length; i++) {
                totalPayment += Number(checkoutItems[i]['amount']);
            }
            console.log('totalPayment ', totalPayment);
            component.set('v.totalPaymentAmount', totalPayment.toFixed(2));
            component.set('v.CheckoutItems', checkoutItems);
            component.set('v.PaymentAmount', null);
            component.find('CheckoutItemsTable').set("v.selectedRows", [uuid]);
            component.set('v.selectedRow', [request])
            component.set('v.selectedAmount', request.amount);
            

            component.set('v.EnableAddToCardButton', true);
            component.set('v.Loading', false);
        }

		component.getEmail = function () {
            var email = component.get("v.EmailId");
            if (!email || !/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(email)) {
                component.displayMessage('Check', 'Please provide a valid email id', 'warning');
                return;
            }
            return email;
        };

		component.loadThirtyPartyPaymentElements = function () {
            
			// var baseUrl = url.split('.')[0] + '--c.visualforce.com';
			
			var gateway = component.get('v.selectedGateway');
			var gatewayList = component.get('v.gateways');
			var loginKey, publicKey;
			for(var i = 0; i < gatewayList.length ; i++) {
				if(gateway == gatewayList[i].Id) {
					console.log('found');
					loginKey = gatewayList[i].Athrz_Api_Login_Id__c;
					publicKey = gatewayList[i].Athrz_Public_Client_Key__c;
				}
			}
			component.set('v.cardUrl', '/apex/CardUI?loginKey=' +  loginKey +
										'&publicKey=' + publicKey +
										'&type=' + 'card'
										);
			component.set('v.bankUrl', '/apex/CardUI?loginKey=' +  loginKey +
										'&publicKey=' + publicKey +
										'&type=' + 'bank' 
										);
        }


    },
	recordLoaded: function (component, event, helper) {
        console.log('------LOADED------');
		// component.initData();
    },
	handleGatewayChange : function(component, event, helper) {
		console.log('change handler');
		var selected = component.find('payment-gateway').get("v.value");
		console.log(selected);
		console.log(component.get('v.selectedGateway'));
		component.loadThirtyPartyPaymentElements();
	},
	editEmail: function (component, event, helper) {
        component.set('v.ShowEmail', true);
    },
	
	addToCart: function(component, event, helper) {
        if(component.get('v.PaymentAmount'))
            component.initiateCart(component.get('v.PaymentAmount'));
        else 
            component.displayMessage('Error', 'Please enter amount.', 'Error');
    },
	onSendLinkForRecharge: function (component, event, helper) {
        var requests = component.get('v.CheckoutItems');
		component.set('v.Loading', true);
		console.log('send-email');
		component.apiCall('sendCheckoutEmail', 
        {
            chargeRequests: requests
        },
		function(returnVal) {
			component.set('v.ShowDefaultPage', false);
			component.set('v.Loading', false);
            console.log('success ', returnVal);
            component.displayMessage('Success', returnVal, 'success');
            component.set('v.ShowEmailConfirmation', true);
            component.set('v.ShowPaymentOptions', false);
		}, function(error){
			component.displayMessage('Error', error, 'Error');
			component.set('v.Loading', false);
		});
		
    },
	handleInlineEditOfCheckoutItems: function (component, event, helper) {
        var table = component.find("CheckoutItemsTable");
        var updatedRecord = table.get("v.draftValues")[0];
        var id = updatedRecord.id;

		console.log('draft',updatedRecord);
        var checkoutItems = component.get('v.CheckoutItems');
        for (var i = 0; i < checkoutItems.length; i++) {
            if (id == checkoutItems[i].id) {
                if (updatedRecord.amount) {
                    checkoutItems[i].amount = updatedRecord.amount;
                }
                if (updatedRecord.firstChargeDate) {
                    var dt = updatedRecord.firstChargeDate;
                    if (!component.isValidDate(dt)) {
                        component.displayMessage('Info', 'Past dates cannot be used', 'warning');
                        table.set('v.draftValues', []);
						
                        return;
                    }
                    checkoutItems[i].firstChargeDate = dt;
                }
                if(updatedRecord.occurrence) {
                    checkoutItems[i].occurrence = updatedRecord.occurrence;
                }
            }
        }
        var totalPayment = 0.00;
        for(var i = 0; i < checkoutItems.length; i++) {
            totalPayment += Number(checkoutItems[i]['amount']);
        }
        console.log('totalPayment ', totalPayment);
        component.set('v.totalPaymentAmount', totalPayment.toFixed(2));

        component.set('v.CheckoutItems', checkoutItems);
        table.set('v.draftValues', []);
    },
	handlePaymentSummaryAction: function (cmp, event, helper) {
        var row = event.getParam('row');
        var rows = cmp.get('v.CheckoutItems');
        console.log(event, helper);

        var rowIndex = -1;
        for (var i = 0; i < rows.length; i++) {
            var d = rows[i]
            if (d.id === row.id) {
                rowIndex = i;
                break;
            }
        }
        rows.splice(rowIndex, 1);
        var totalPayment = 0.00;
        for(var i = 0; i < rows.length; i++) {
            totalPayment += Number(rows[i]['amount']);
        }
        cmp.set('v.totalPaymentAmount', totalPayment);
        cmp.set('v.CheckoutItems', rows);
    },
	checkoutPayments: function (component, event, helper) {
		var row = component.find('CheckoutItemsTable').getSelectedRows();
		console.log('lines ',JSON.stringify(row));
		if(row.length == 0) {
			component.displayMessage('Error', 'Please select one payment request', 'Error');
			return;
		}
		component.load();
		component.set('v.ShowPaymentOptions', true);
		component.set('v.ShowDefaultPage', false);

	},
	goToDefaultPage: function(component, event, helper) {
		component.set('v.ShowDefaultPage', true);
		component.set('v.ShowTransactionDetails', false);
		component.set('v.ShowEmailConfirmation', false);
		component.set('v.ShowPaymentOptions', false);
	},
	selectPaymentSource: function(component, event, helper) {
        var paymentSourceId = event.target.id;
        var type = event.currentTarget.dataset.card;
        console.log('type ', type);
        var checkoutItems = component.get('v.CheckoutItems');
        var totalPayment = 0.00;
            for(var i = 0; i < checkoutItems.length; i++) {
                totalPayment += Number(checkoutItems[i]['amount']);
            }
        if(type == 'card') {
            totalPayment = (totalPayment * 1.0399);
            console.log('totalPayment ', totalPayment);
            component.set('v.totalPaymentAmount', totalPayment.toFixed(2));
        } else {
            console.log('totalPayment ', totalPayment);
            component.set('v.totalPaymentAmount', totalPayment.toFixed(2));
        }
        component.set('v.SelectedPaymentSource', paymentSourceId);
    },
	CardLoaded: function(component, event, helper) {
		console.log('vf loaded');
		component.set('v.CardUILoading', false);
	},
	BankLoaded: function(component, event, helper) {
		console.log('vf loaded');
		component.set('v.bankUILoading', false);
	},
	handlePaymentMethodCharge: function(component, event, helper) {
		 //we have payment method id and request
		 var lines = component.get('v.selectedRow');
		 lines.map(function(x){
			 let sdsd = {'paymentMethod' : component.get('v.SelectedPaymentSource')};
			 console.log('sd ',sdsd);
			 Object.assign(x, {'paymentMethod' : component.get('v.SelectedPaymentSource')});
		 });
		 console.log('lines modified', JSON.stringify(lines));
		 component.set('v.selectedRow', lines);
         var paymentId = component.get('v.SelectedPaymentSource');
         var message  = {};
         var allPaymentSource = component.get('v.UserCards').concat(component.get('v.UserBankAccounts'));
         for(var i = 0; i < allPaymentSource.length ; i++) {
            if(paymentId == allPaymentSource[i].Id) {
                if(allPaymentSource[i].Card_Number__c) 
                    component.set('v.isCardActive', true);
                else 
                    component.set('v.isCardActive', false);
                break;
            }
         }
         console.log('Active ', component.get('v.isCardActive'));
		 component.paymentRequest(message, 'Payment_Intent_Proile');
	},
	// this was for the table component
	getSelectedName: function(component, event, helper) {
		var lines = component.find('CheckoutItemsTable').getSelectedRows();
		console.log('lines ',JSON.stringify(lines));
		component.set('v.selectedRow', lines);
		component.set('v.selectedAmount', lines[0].amount);
	},
	handleSavedPaymentsActive: function(component, event, helper) {
		component.getPaymentMethods();
         
	},
	openModel: function(component, event, helper) {
		// Set isModalOpen attribute to true
		component.set("v.isModalOpen", true);
        console.log('data ',component.isSubscription());
		component.initData();
        // component.load();
	 },
	
	 closeModel: function(component, event, helper) {
		// Set isModalOpen attribute to false 
        component.reset();
		component.set("v.isModalOpen", false);
        $A.get('e.force:refreshView').fire();
	 },

     handleCardTab: function(component, event, helper) {
         var amount = (component.get('v.totalPaymentAmount') * 1.0399).toFixed(2);
         component.set('v.totalPaymentAmount', amount);
         component.set('v.isCardActive', true);
     },
     handleBankTab: function(component, event, helper) {
        var totalPayment = 0.00;
        var checkoutItems = component.get('v.CheckoutItems');
        for(var i = 0; i < checkoutItems.length; i++) {
            totalPayment += Number(checkoutItems[i]['amount']);
        }
        console.log('totalPayment ', totalPayment);
        component.set('v.totalPaymentAmount', totalPayment.toFixed(2));

        component.set('v.isCardActive', false);
     },
     handleCreditCardUI: function(component, event, helper) {
         component.set('v.showCreditCardUI', component.get('v.showCreditCardUI') ? false : true);
         component.set('v.showBankUI', false);
         if(component.get('v.showCreditCardUI'))
            component.set('v.CardUILoading', true);
        if(component.get('v.showBankUI'))
            component.set('v.bankUILoading', true);
        
        var totalPayment = 0.00;
        var checkoutItems = component.get('v.CheckoutItems');
        for(var i = 0; i < checkoutItems.length; i++) {
            totalPayment += Number(checkoutItems[i]['amount']);
        }
        console.log('totalPayment ', totalPayment);
        component.set('v.totalPaymentAmount', (totalPayment* 1.0399).toFixed(2));
     }, 
     handleBankUI: function(component, event, helper) {
        component.set('v.showBankUI', component.get('v.showBankUI') ? false : true);
        component.set('v.showCreditCardUI',false);
        if(component.get('v.showBankUI'))
            component.set('v.bankUILoading', true);
        if(component.get('v.showCreditCardUI'))
            component.set('v.CardUILoading', true);
        var totalPayment = 0.00;
        var checkoutItems = component.get('v.CheckoutItems');
        for(var i = 0; i < checkoutItems.length; i++) {
            totalPayment += Number(checkoutItems[i]['amount']);
        }
        console.log('totalPayment ', totalPayment);
        component.set('v.totalPaymentAmount', totalPayment.toFixed(2));
     },
     handleBankPay: function(component, event, helper) {
        
        component.set('v.isCardActive', false);

        var accountNumber = component.get("v.accountNumber");
        var accountNumberConfirm = component.get("v.accountNumberConfirm");

        var accNo = component.find('account-number');
        var accNoCnf = component.find('account-number-confirm');
        if(accountNumber != accountNumberConfirm) {
            
            accNo.setCustomValidity('Account number mismatch');
            accNoCnf.setCustomValidity('Account number mismatch');

        } else {
            accNo.setCustomValidity('');
            accNoCnf.setCustomValidity('');

            var payload = {};
            payload.savePayment = component.get('v.saveAccount');
            payload.saveAsDefault = component.get('v.saveAccountAsDefault');
            payload.nameOnAccount = component.get('v.nameOnAccount');
            payload.accountNumber = component.get('v.accountNumber');
            payload.accountRoutingNumber = component.get('v.accountRoutingNumber');
            payload.accountType = component.find('select-acc-type').get('v.value');

            console.log('payload ',payload);
            component.paymentRequest(payload, 'Payment_Intent_Bank');
        }

        accNo.reportValidity();
        accNoCnf.reportValidity();
        
     },
     handleEditLineItems: function(component, event, helper) {
        component.set('v.ShowDefaultPage', true);
		component.set('v.ShowTransactionDetails', false);
		component.set('v.ShowEmailConfirmation', false);
		component.set('v.ShowPaymentOptions', false);
     },
     selectFrequency: function (component, event, helper) {
        console.log('clicked ',event.getSource().get("v.labelWhenOn"));
        component.set('v.SelectedFrequency', event.getSource().get("v.accesskey"));
        component.set('v.SelectedFrequencyDisplay', event.getSource().get("v.labelWhenOn"));
        // console.log('clicked ', component.get('v.SelectedFrequency'));
    }
})