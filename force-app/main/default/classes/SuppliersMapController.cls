public with sharing class SuppliersMapController {
    @AuraEnabled
    public static GoogleMapsRestService.GoogleResponse getSuppliersData(Id accountId){
        Account accountToProcess = new AccountsSelector().selectById(new Set<Id>{accountId})[0];
        Supplier__c[] suppliers = new SuppliersSelector().selectByCity(new Set<String>{accountToProcess.BillingCity});

        return new GoogleMapsRestService.GoogleResponse(suppliers);
    }
}