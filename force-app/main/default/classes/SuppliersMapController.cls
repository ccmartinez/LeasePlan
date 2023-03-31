public with sharing class SuppliersMapController {
    @AuraEnabled
    public static GoogleMapsRestService.GoogleResponse getSuppliersData(String accountId){
        Account accountToProcess = [SELECT BillingCity FROM Account WHERE Id = :accountId]; //TODO: move this into a selector class, there is a selectbyid selector default method

        return GoogleMapsRestService.getSuppliersBasedOnCityName(accountToProcess.BillingCity);
    }
}