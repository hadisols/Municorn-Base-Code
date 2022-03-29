// var j$ = jQuery.noConflict();

function hideLoading() {
    $('#spinner').hide();
}

function showLoading() {
    $('#spinner').show();
}
function handlePaymentSourceSelection(paymentType) {
    console.log(paymentType + ' clicked');
    var amountach = addCommas($("#selected-amount-ach").val());
    var amount = $("#selected-amount").val();
    var totalAmount = amount * 1.0399;
    
    $("#selected-val").val(paymentType);
    $('.payableamount').html(addCommas(amountach));
    
    if(paymentType=='cc'){
        $('.cctax').removeClass('text-decoration-line-through');
        $('.totalamount').html(addCommas(totalAmount.toFixed(2)));
    }
    else
    {
        $("#selected-amount").val(amountach);
        $('.totalamount').html(addCommas(amountach));
        $('.cctax').addClass('text-decoration-line-through');
    }
    performCharge(paymentType);
}
function registerPaymentPageTabs() {
    if ($('#tabs').length > 0) {
        $("#tabs").tabs({ active: 0 });
        $('#cards-tab-header').click(function(){
            showLoading();
            handlePaymentSourceSelection('cc');
        });
        $('#banks-tab-header').click(function(){
            showLoading();
            handlePaymentSourceSelection('ach');
        });
    }
}
function assignRefreshToken(){
    $("#redirectToken").val($("#inputtoken").val());
    console.log('returned-control');
    $('#chargeCreditCard').click();
    hideLoading();
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
	window.addCommas=addCommas;



$(document).ready(function(){
    console.log('ready-state');
    
    registerPaymentPageTabs();
    handlePaymentSourceSelection('cc');
    load();
    $(".token-tag").hide();
    setTimeout(
        $("#chargeCreditCard").click(function () {
        hideLoading();
        console.log('chargeCreditCard');
        //$("#add_payment").show();
        $("#send_token").attr({ "action": "https://test.authorize.net/payment/payment", "target": 'add_payment' }).submit();
        $(window).scrollTop($('#add_payment').offset().top - 50);
        }), 1000);
    


    window.addEventListener('message', function (event) {
        const data = JSON.stringify(event.data);
        console.log("Recieved event " + JSON.stringify(event));
                console.log("Recieved event 2 " + event.data);
        if(event.data.includes("action=transactResponse&response=")) {
            console.log('resp', event.data.replace("action=transactResponse&response=",""));
            var response = event.data.replace("action=transactResponse&response=","");
            performUpdate(response);
        }

    });
    
});


function load() {
    console.log('token loaded');
    var amount = $("#selected-amount").val();
    $('.payableamount').html(addCommas(amount));
    console.log('amount old = ',amount);
    var totalAmount = amount * 1.0399;
    var creditfees = totalAmount - amount;
    console.log('amount',totalAmount.toFixed(2));
    $("#selected-amount").val(totalAmount.toFixed(2));
    $('.ccamount').html(addCommas(creditfees.toFixed(2)));
    $('.totalamount').html(addCommas(totalAmount.toFixed(2)));
    
}

(function () {
    if (!window.AuthorizeNetIFrame) window.AuthorizeNetIFrame = {};
    AuthorizeNetIFrame.onReceiveCommunication = function (querystr) {
        var params = parseQueryString(querystr);
        console.log('params '+ params);
        switch (params["action"]) {
            case "successfulSave":
                console.log('param action '+ params["action"]);
                break;
            case "cancel":
                console.log('param action '+ params["action"]);
                break;
            case "resizeWindow":
                var w = parseInt(params["width"]);
                var h = parseInt(params["height"]);
                var ifrm = document.getElementById("add_payment");
                ifrm.style.width = w.toString() + "px";
                ifrm.style.height = h.toString() + "px";
                console.log('param action '+ params["action"]);
                break;
            case "transactResponse":
                var paymentResponse = params["response"];
                window.parent.postMessage({
                    "paymentResponse": JSON.stringify(paymentResponse)
                }, '*');
                var ifrm = document.getElementById("add_payment");
               	ifrm.style.display = 'none';
                console.log('param action '+ params["action"]);
                break;

        }
        
    };
    
    function parseQueryString(str) {
        var vars = [];
        var arr = str.split('&');
        var pair;
        for (var i = 0; i < arr.length; i++) {
            pair = arr[i].split('=');
            vars.push(pair[0]);
            vars[pair[0]] = unescape(pair[1]);
        }
        return vars;
    }
}());