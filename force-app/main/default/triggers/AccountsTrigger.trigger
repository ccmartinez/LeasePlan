trigger AccountsTrigger on Account (after insert, after update) {
    fflib_SObjectDomain.triggerHandler(AccountsTriggerHandler.class);
}