({
    setup: function (component, event, helper) {
        console.info('bootstrap loaded successfully.');
    },
    handleApplicationEvent : function (cmp, event) {
        var selectedproducts = [];
        var message = event.getParam("message");
        selectedproducts = JSON.deserialize(event.getParam("selectedproducts"));
        // set the handler attributes based on event data
        cmp.set("v.messageFromEvent", message);
        cmp.set("v.selectedproducts", selectedproducts);
        var numEventsHandled = parseInt(cmp.get("v.numEvents")) + 1;
        cmp.set("v.numEvents", numEventsHandled);
    },

    handleLtngSendMessageEvent : function (cmp, event) {
        var message = event.getParam("message");

        // set the handler attributes based on event data
        cmp.set("v.messageFromEvent", message);
        var numEventsHandled = parseInt(cmp.get("v.numEvents")) + 1;
        cmp.set("v.numEvents", numEventsHandled);
    },
})