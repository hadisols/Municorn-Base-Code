trigger PMA_ContactTrigger on Contact (Before Insert,After Insert,Before Update, After Update,Before Delete,After Delete,After Undelete) {
    PMA_ContactTriggerHandler.handle();
}