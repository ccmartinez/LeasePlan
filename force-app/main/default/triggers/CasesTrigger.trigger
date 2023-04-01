trigger CasesTrigger on Case (after insert, after update) {
    fflib_SObjectDomain.triggerHandler(CasesTriggerHandler.class);
}