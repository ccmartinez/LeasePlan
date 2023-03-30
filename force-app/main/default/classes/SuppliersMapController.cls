public with sharing class SuppliersMapController {
    @AuraEnabled
    public static GoogleMapsRestService.GoogleResponse getSuppliersData(String accountId){
        Account accountToProcess = [SELECT BillingCity, BillingCountry FROM Account WHERE Id = :accountId];

        return GoogleMapsRestService.getSuppliers(accountToProcess);
    }
}