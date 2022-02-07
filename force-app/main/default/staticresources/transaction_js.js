var j$ = jQuery.noConflict();

var stripe, card, customLabels;

var currencyCodes = {
    'ALL': '&#76;&#101;&#107;',
    'AFN': '&#1547;',
    'ARS': '&#36;',
    'AWG': '&#402;',
    'AUD': '&#36;',
    'AZN': '&#1084;&#1072;&#1085;',
    'BSD': '&#36;',
    'BBD': '&#36;',
    'BYN': '&#66;&#114;',
    'BZD': '&#66;&#90;&#36;',
    'BMD': '&#36;',
    'BOB': '&#36;&#98;',
    'BAM': '&#75;&#77;',
    'BWP': '&#80;',
    'BGN': '&#1083;&#1074;',
    'BRL': '&#82;&#36;',
    'BND': '&#36;',
    'KHR': '&#6107;',
    'CAD': '&#36;',
    'KYD': '&#36;',
    'CLP': '&#36;',
    'CNY': '&#165;',
    'COP': '&#36;',
    'CRC': '&#8353;',
    'HRK': '&#107;&#110;',
    'CUP': '&#8369;',
    'CZK': '&#75;&#269;',
    'DKK': '&#107;&#114;',
    'DOP': '&#82;&#68;&#36;',
    'XCD': '&#36;',
    'EGP': '&#163;',
    'SVC': '&#36;',
    'EUR': '&#8364;',
    'FKP': '&#163;',
    'FJD': '&#36;',
    'GHS': '&#162;',
    'GIP': '&#163;',
    'GTQ': '&#81;',
    'GGP': '&#163;',
    'GYD': '&#36;',
    'HNL': '&#76;',
    'HKD': '&#36;',
    'HUF': '&#70;&#116;',
    'ISK': '&#107;&#114;',
    'INR': '&#8377;',
    'IDR': '&#82;&#112;',
    'IRR': '&#65020;',
    'IMP': '&#163;',
    'ILS': '&#8362;',
    'JMD': '&#74;&#36;',
    'JPY': '&#165;',
    'JEP': '&#163;',
    'KZT': '&#1083;&#1074;',
    'KPW': '&#8361;',
    'KRW': '&#8361;',
    'KGS': '&#1083;&#1074;',
    'LAK': '&#8365;',
    'LBP': '&#163;',
    'LRD': '&#36;',
    'MKD': '&#1076;&#1077;&#1085;',
    'MYR': '&#82;&#77;',
    'MUR': '&#8360;',
    'MXN': '&#36;',
    'MNT': '&#8366;',
    'MZN': '&#77;&#84;',
    'NAD': '&#36;',
    'NPR': '&#8360;',
    'ANG': '&#402;',
    'NZD': '&#36;',
    'NIO': '&#67;&#36;',
    'NGN': '&#8358;',
    'NOK': '&#107;&#114;',
    'OMR': '&#65020;',
    'PKR': '&#8360;',
    'PAB': '&#66;&#47;&#46;',
    'PYG': '&#71;&#115;',
    'PEN': '&#83;&#47;&#46;',
    'PHP': '&#8369;',
    'PLN': '&#122;&#322;',
    'QAR': '&#65020;',
    'RON': '&#108;&#101;&#105;',
    'RUB': '&#1088;&#1091;&#1073;',
    'SHP': '&#163;',
    'SAR': '&#65020;',
    'RSD': '&#1044;&#1080;&#1085;&#46;',
    'SCR': '&#8360;',
    'SGD': '&#36;',
    'SBD': '&#36;',
    'SOS': '&#83;',
    'ZAR': '&#82;',
    'LKR': '&#8360;',
    'SEK': '&#107;&#114;',
    'CHF': '&#67;&#72;&#70;',
    'SRD': '&#36;',
    'SYP': '&#163;',
    'TWD': '&#78;&#84;&#36;',
    'THB': '&#3647;',
    'TTD': '&#84;&#84;&#36;',
    'TRY': '&#;',
    'TVD': '&#36;',
    'UAH': '&#8372;',
    'GBP': '&#163;',
    'USD': '&#36;',
    'UYU': '&#36;&#85;',
    'UZS': '&#1083;&#1074;',
    'VEF': '&#66;&#115;',
    'VND': '&#8363;',
    'YER': '&#65020;',
    'ZWD': '&#90;&#36;'
};

function getCurrencySymbol(code) {
    return currencyCodes[code] ? j$('<div>').html(currencyCodes[code]).text() : code;
}

function hideLoading() {
    j$('#spinner').hide();
}

function showLoading() {
    j$('#spinner').show();
}

function chargeComplete() {
    hideLoading();
    j$('.payment-form').hide();
    j$('.charge-output').show();
    j$('.payment-button').removeProp("disabled");
    scrollUp();
}

function verificationComplete() {
    hideLoading();
    startup();
}

function verificationComplete() {
    hideLoading();
    startup();
}

function scrollUp() {
    j$(window).scrollTop(0);
    j$('html').scrollTop(0);
    j$('body').scrollTop(0);
}

function payInLightning() {
    var saveCard = j$('#save-card').is(':checked');
    var paymentRequest = {};
    stripe.createToken(card).then(function(result) {
        if (result.error) {
            var errorElement = document.getElementById('card-errors');
            errorElement.textContent = result.error.message;
            hideLoading();
            j$('.payment-button').removeAttr("disabled");
        } else {
            paymentRequest.paymentMethod = 'new-card';
            paymentRequest.stripeToken = result.token.id;
            paymentRequest.saveCard = saveCard;
            window.parent.postMessage({
                "paymentRequest": JSON.stringify(paymentRequest)
            }, '*');
        }
    })
}

function displayErrorMessage(message) {
    alert(message);
}

function getAchToken() {
    var routingNumber = j$('.routing-number').val();
    var accountNumber = j$('.account-number').val();
    var reenterAccountNumber = j$('.reenter-account-number').val();
    if (!routingNumber) {
        displayErrorMessage(customLabels['error_message_ach_registration_routing_number_invalid']);
        return;
    }
    if (!accountNumber) {
        displayErrorMessage(customLabels['error_message_ach_registration_account_number_invalid']);
        return;
    }
    if (!reenterAccountNumber) {
        displayErrorMessage(customLabels['error_message_ach_registration_re_enter_account_number_invalid']);
        return;
    }
    if (accountNumber !== reenterAccountNumber) {
        displayErrorMessage(customLabels['error_message_ach_registration_re_enter_account_number_invalid']);
        return;
    }

    j$('.register-ach-button').prop('disabled', 'disabled');
    showLoading();
    stripe.createToken('bank_account', {
        country: 'US',
        currency: 'usd',
        routing_number: routingNumber,
        account_number: accountNumber,
        account_holder_name: 'Jenny Rosen',
        account_holder_type: 'individual'
    })
    .then(function(result) {
        if (result.token) {
            registerAchPayment(JSON.stringify(result.token));
        }
        if (result.error) {
            hideLoading();
            displayErrorMessage(result.error.message);
            j$('.register-ach-button').removeProp('disabled');
        }
    });
}

function achPaymentRegistered() {
    j$('.register-ach-button').removeProp('disabled');
    hideLoading();
    startup();
}

function pay() {
    j$('.payment-button').prop("disabled", 'disabled');
    showLoading();

    var selectedPaymentSourceId = j$('input[name=payment-source]:checked').val();

    var paymentRequest = {};
    if (selectedPaymentSourceId === 'new') {
        var saveCard = j$('#save-card').is(':checked');
        stripe.createToken(card).then(function(result) {
            if (result.error) {
                var errorElement = document.getElementById('card-errors');
                errorElement.textContent = result.error.message;
                hideLoading();
                j$('.payment-button').removeProp("disabled");
            } else {
                paymentRequest.paymentMethod = 'new-card';
                paymentRequest.stripeToken = result.token.id;
                paymentRequest.saveCard = saveCard;
                performCharge(JSON.stringify(paymentRequest));
            }
        });
    } else {
        paymentRequest.selectedPaymentSource = selectedPaymentSourceId;
        performCharge(JSON.stringify(paymentRequest));
    }
}

function getPublishableKey() {
    const urlParams = new URLSearchParams(window.location.search);
    var stripePublishableKey = urlParams.get('key');
    if (!stripePublishableKey) {
        stripePublishableKey = j$('#stripePublishableKey').val();
    }
    return stripePublishableKey;
}

function registerStripeCardLayout() {
    hideLoading();
    stripe = Stripe(getPublishableKey());
    var elements = stripe.elements();

    var style = {
        base: {
            color: '#32325d',
            fontFamily: '"Helvetica Neue", Helvetica, sans-serif',
            fontSmoothing: 'antialiased',
            fontSize: '16px',
            '::placeholder': {
                color: '#aab7c4'
            }
        },
        invalid: {
            color: '#fa755a',
            iconColor: '#fa755a'
        }
    };

    // Create an instance of the card Element.
    card = elements.create('card', {
        style: style
    });

    // Add an instance of the card Element into the `card-element` <div>.
    card.mount('#card-element');

    // Handle real-time validation errors from the card Element.
    card.addEventListener('change', function(event) {
        var displayError = document.getElementById('card-errors');
        displayError.textContent = event.error ? event.error.message : '';
        if (event.error) {
            hideLoading();
        }
    });

    card.addEventListener('focus', function(event) {
        if (j$('input[name=payment-source]:checked').val() != 'new') {
            j$('input[name=payment-source][value=new]').prop('checked', true);
            handlePaymentSourceSelection();
        }
    });

    j$('input.default-source').prop('checked', true);
    j$('input[name=payment-source]').on('change', function() {
        handlePaymentSourceSelection();
    });

    handlePaymentSourceSelection();

    j$('.charge-output').hide();
}

function handlePaymentSourceSelection() {
    var paymentSource = j$('input[name=payment-source]:checked');
    if (!paymentSource.val()) {
        j$('input[name=payment-source]:first').prop('checked', true);
    }
    j$('.button-container').hide();
    var payOpt = j$('input[name=payment-source]:checked').closest('.payment-option');
    j$('.payment-option').removeClass('selected');
    payOpt.find('.button-container').slideDown("fast");
}

function registerPlaid() {
    if (j$('.plaid-link-button').length > 0) {
        var appMode = j$('#app-mode').val();

        var linkHandler = Plaid.create({
          env: appMode === 'live' ? 'production' : 'sandbox',
          clientName: 'Payment gateway',
          key: j$('#plaid-public-key').val(),
          product: ['transactions'],
          countryCodes: ['US'],
          selectAccount: true,
          onSuccess: function(public_token, metadata) {
            var plaidPaymentRequest = {
                publicToken : public_token,
                accountId : metadata.account_id
            }
            showLoading();
            registerAndPayUsingPlaid(JSON.stringify(plaidPaymentRequest));
          },
          onExit: function(err, metadata) {
            // The user exited the Link flow.
            if (err != null) {
              displayErrorMessage(err);
            }
          },
        });

        // Trigger the Link UI
        j$('.plaid-link-button').click(function() {
           j$('.ach-manual-registration-form').hide();
           linkHandler.open();
        });
    }
}

function initCustomLabels() {
    if (j$('#customLabels').length > 0) {
        customLabels = JSON.parse(j$('#customLabels').val());
        console.log(customLabels);
    }
}

function registerStripePaymentPageTabs() {
    if (j$('#tabs').length > 0) {
       j$("#tabs").tabs();
       j$('#cards-tab-header').click(function(){
            j$('#cards-tab').find('input[name=payment-source]:enabled:first').prop('checked', 'checked');
            handlePaymentSourceSelection();
       });
       j$('#banks-tab-header').click(function(){
            j$('#ach-tab').find('input[name=payment-source]:enabled:first').prop('checked', 'checked');
            handlePaymentSourceSelection();
       });
   }
}

function startup() {
    j$ = jQuery.noConflict();

    j$(document).ready(function() {
       j$('.payment-mode-disabled').attr('disabled', 'disabled');

       registerStripePaymentPageTabs();

       registerStripeCardLayout();

       registerPlaid();

       initCustomLabels();

       j$('.saved-payment-method').click(function() {
           var find = j$(this).find('input[name=payment-source]:enabled');
           if (find.length > 0) {
               find.prop('checked', 'checked');
               handlePaymentSourceSelection();
           }
       });

       j$('.ach-manual-registration').click(function() {
           j$('.ach-manual-registration-form').toggle();
       });

       j$('.verify-ach-button').click(function(){
              var parent = j$(this).closest('.payment-option');
              var bankSourceId = parent.find('input[name=payment-source]').val();
              var amount1 = parent.find('.amount-1').val();
              var amount2 = parent.find('.amount-2').val();

              if (!bankSourceId) {
                displayErrorMessage(customLabels['error_message_ach_verification_select_bank']);
                return;
              }
              if (!amount1) {
                displayErrorMessage(customLabels['error_message_ach_verification_enter_amount_1']);
                return;
              }
              if (!amount2) {
                displayErrorMessage(customLabels['error_message_ach_verification_enter_amount_2']);
                return;
              }

              var request = {
                bankSourceId: bankSourceId,
                customerId: null,
                amount1: amount1,
                amount2: amount2
              }
              showLoading();
              verifyBankAccount(JSON.stringify(request));
       });

       j$('.payment-form-body').show();
    });
}

startup();