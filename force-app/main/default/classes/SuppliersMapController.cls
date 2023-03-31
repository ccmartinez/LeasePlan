public with sharing class SuppliersMapController {
    @AuraEnabled
    public static GoogleMapsRestService.GoogleResponse getSuppliersData(Id accountId){
        Account accountToProcess = new AccountsSelector().selectById(new Set<Id>{accountId})[0];

        return GoogleMapsRestService.getSuppliersBasedOnCityName(accountToProcess.BillingCity);
    }
}