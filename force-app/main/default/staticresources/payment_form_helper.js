// var j$ = jQuery.noConflict();

$(document).ready(function(){
    console.log('ready-state');
    console.log('checkbox ', $('#save-card').prop('checked'))
    console.log(window.location);
    load();
    handlePaymentSourceSelection();
    handlePay();
    console.log('selected payment ',$('.default-source').val());

    $('input.default-source').prop('checked', true);
    $('input[name=payment-source]').on('change', function() {
        console.log('pay source ',$('input[name=payment-source]:checked').val());
    });
});

function chargeComplete() {
    var error = $('#error-panel-input').val();
    var paymentMessage = $('#message-panel').val();
    console.log('error inp ', error );
    if(error) {
        console.log('error');
        $('#error-message-after-submission').text(error);
    } if (paymentMessage) {
        console.log('error paymentMessage ', paymentMessage);
        $('#payment-message').text(paymentMessage);
       
        $('#payment-form-component').hide();
    }
    hideLoading();
}

function hideLoading() {
    $('#spinner').hide();
}

function showLoading() {
    $('#spinner').show();
}

function getType() {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get('type');
}

function getLoginKey() {
    const urlParams = new URLSearchParams(window.location.search);
    var loginKey = urlParams.get('loginKey');
    if (!loginKey) {
        loginKey = $('#api-login-id').val();
    }
    return loginKey;
}

function getPublicKey() {
    const urlParams = new URLSearchParams(window.location.search);
    var publicKey = urlParams.get('publicKey');
    if (!publicKey) {
        publicKey = $('#api-public-key').val();
    }
    return publicKey;
}

function handlePay() {
    $('#pay-button').click( function(){
        console.log('pay clicked');
        var data = getSecureDate();
        showLoading();
        if($('#payment-method').prop('checked')) {
            console.log('method **', $('input[name=payment-source]:checked').val())
            updatePaymentMethod(
                $('input[name=payment-source]:checked').val()
            );
        }
        else if($('#payment-type').prop('checked')) {
            Accept.dispatchData(data, 'responseHandler');
        }
        else {
            updateBankDetails(
                $('#payment-bank-holder-name').val(),
                $('#payment-bank-number').val(),
                $('#payment-bank-routing-number').val(),
                $('#payment-bank-type').val()
            );
        }
    });
}

function paymentMethodCharge() {
    console.log('method charge called ', $('#payment-type').prop('checked'));
    var payload = {};

    
    performCharge(
        null, 
        true, 
        getSavePaymentInformation() ? getSavePaymentInformation() : false, 
        getDefaultSavePaymentInformation() ? getDefaultSavePaymentInformation() : false,
        true
    );
}



function getSecureDate() {
    var secureData = {},
        authData = {},
        bankData = {},
        cardData = {};

    cardData.cardNumber = $('#payment-credit-card-number').val();
    cardData.month = $('#payment-credit-card-expiry-mm').val();
    cardData.year = $('#payment-credit-card-expiry-yy').val();
    cardData.zip = ''; //$('#payment-zip').val();
    cardData.cardCode = $('#payment-credit-card-cvv').val();
    
    bankData.nameOnAccount = $('#payment-bank-holder-name').val();
    bankData.accountNumber = $('#payment-bank-number').val();
    bankData.routingNumber = $('#payment-bank-routing-number').val();
    bankData.accountType = $('#payment-bank-type').val();

    if($('#payment-type').prop('checked')) {
        secureData.cardData = cardData;
    } else {
        secureData.bankData = bankData;
    }
    

    authData.clientKey =  getPublicKey();
    authData.apiLoginID =  getLoginKey();
    secureData.authData = authData;

    console.log('data',secureData);
    return secureData;
}

function responseHandler(response) {
    console.log('response handler');
    if (response.messages.resultCode === 'Error') {
        // hideLoading();
        for (var i = 0; i < response.messages.message.length; i++) {
            console.log(response.messages.message[i].code + ':' + response.messages.message[i].text);
            $("#blob").val(response.messages.message[i].code + ':' + response.messages.message[i].text);
            $('#error-message-after-submission').text(response.messages.message[i].text);
        }
    } else {
        useOpaqueData(response.opaqueData)
    }
}

function useOpaqueData(responseData) {
    console.log(responseData.dataDescriptor);
    console.log(responseData.dataValue);
    sendToLC(responseData.dataValue);
    $("#blob").val(responseData.dataValue);
    performCharge(responseData.dataValue, 
        $('#payment-type').prop('checked'), 
        getSavePaymentInformation() ? getSavePaymentInformation() : false, 
        getDefaultSavePaymentInformation() ? getDefaultSavePaymentInformation() : false,
        false
    );
    
}



function bankCharge() {
    console.log('bank charge called');
    var payload = {};

    payload.savePayment = getSavePaymentInformation();
    payload.saveAsDefault = getDefaultSavePaymentInformation();
    payload.nameOnAccount = $('#payment-bank-holder-name').val();
    payload.accountNumber = $('#payment-bank-number').val();
    payload.accountRoutingNumber = $('#payment-bank-routing-number').val();
    payload.accountType = $('#payment-bank-type').val();
    performCharge(
        null, 
        $('#payment-type').prop('checked'), 
        getSavePaymentInformation() ? getSavePaymentInformation() : false, 
        getDefaultSavePaymentInformation() ? getDefaultSavePaymentInformation() : false,
        false
    );
}

// function EventListener() {
//     console.log('inside listener');
//     window.addEventListener("message", function(event) {
        
//         // Handle message, generate nonce and send to LC
//         console.log('vf page ',event.data);

//     }, false);
// }

function sendToLC(messageValue) {
    console.log('sent to parent');
    var payload = {};
    var message = messageValue;
    var savePayment = getSavePaymentInformation();
    var saveAsDefault = getDefaultSavePaymentInformation();
    payload.token = message;
    payload.savePayment = savePayment;
    payload.saveAsDefault = saveAsDefault;
    showLoading();
    setTimeout(function (){
        hideLoading();
        console.log('sent to parent now');
        parent.postMessage(payload, "*");
      }, 5000);
    
}

function getSavePaymentInformation() {
    return Boolean($('#save-card').prop('checked')) && Boolean($('#save-bank').prop('checked'));
}

function getDefaultSavePaymentInformation() {
    return Boolean($('#save-card-default').prop('checked')) && Boolean($('#save-bank-default').prop('checked'));
}

function handlePaymentSourceSelection() {
    var amount = $('#amount').val();
    var totalAmount = amount * 1.0399;
    if(getType() == 'card') {
        $('.credit-card-view').show();
        $('.bank-payment-view').hide();
        $('#payment-type').prop('checked', true);
    } else if(getType() == 'bank') {
        $('.credit-card-view').hide();
        $('.bank-payment-view').show();
        $('#payment-type').prop('checked', false);
    }

    $('#saved-button').click(function(){
        $('.saved-payment-view').show();
        $('.bank-payment-view').hide();
        $('.credit-card-view').hide();
        $('.billing-information').hide();

        $('#saved-button').addClass('selected-button');
        $('#credit-card-button').removeClass('selected-button');
        $('#bank-button').removeClass('selected-button');

        $('#payment-type').prop('checked', true);
        $('#payment-method').prop('checked', true);
        $('.cctax').removeClass('text-decoration-line-through');
        $('.totalamount').html(addCommas(totalAmount.toFixed(2)));
    });
    $('#credit-card-button').click(function(){
        $('#credit-card-button').addClass('slds-is-active');
        $('#bank-button').removeClass('slds-is-active');

        

        $('#credit-card-button').addClass('selected-button');
        $('#bank-button').removeClass('selected-button');
        $('#saved-button').removeClass('selected-button');
        $('.saved-payment-view').hide();

        // showLoading();
        $('.cctax').removeClass('text-decoration-line-through');
        $('.totalamount').html(addCommas(totalAmount.toFixed(2)));

        $('.bank-payment-view').hide();
        $('.credit-card-view').show();
        $('.billing-information').show();
        $('#payment-type').prop('checked', true);
        $('#payment-method').prop('checked', false);
    });
    $('#bank-button').click(function(){
        $('#credit-card-button').removeClass('slds-is-active');
        $('#bank-button').addClass('slds-is-active');

        $('.saved-payment-view').hide();
        $('#credit-card-button').removeClass('selected-button');
        // $('#credit-card-button').addClass('slds-button_neutral');
        $('#bank-button').addClass('selected-button');
        $('#saved-button').removeClass('selected-button');
        // $('#bank-button').removeClass('slds-button_neutral');
        // showLoading();
        $('.cctax').addClass('text-decoration-line-through');
        $('.totalamount').html(addCommas(amount));

        $('.credit-card-view').hide();
        $('.bank-payment-view').show();
        $('.billing-information').show();
        $('#payment-type').prop('checked', false);
        $('#payment-method').prop('checked', false);
    });
}

function load() {
    $('#payment-type').prop('checked', true);
    console.log('checkbox ',$('#payment-type').prop('checked'));
    var amount = $('#amount').val();
    var totalAmount = amount * 1.0399;
    var creditfees = totalAmount - amount;

    $('.payableamount').html(addCommas(amount));
    $('.ccamount').html(addCommas(creditfees.toFixed(2)));
    $('.totalamount').html(addCommas(totalAmount.toFixed(2)));
}

var addCommas = function(nStr) {
    nStr += '';
    var x = nStr.split('.');
    var x1 = x[0];
    var x2 = x.length > 1 ? '.' + x[1] : '';
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1)) {
        x1 = x1.replace(rgx, '$1' + ',' + '$2');
    }
    return x1 + x2;
};
//window.addCommas=addCommas;


