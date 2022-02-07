trigger PMA_ContactTrigger on Contact (Before Insert,After Insert) {
    PMA_ContactTriggerHandler.handleTrigger(Trigger.New, Trigger.operationType);
}