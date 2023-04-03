public with sharing class SuppliersMapController {
    @AuraEnabled
    public static GoogleMapsRestService.GoogleResponse getSuppliersData(Id accountId){
        Account accountToProcess = new AccountsSelector().selectById(new Set<Id>{accountId})[0];
        Supplier__c[] suppliers; 
        if(accountToProcess.BillingCity == null){
            suppliers = new Supplier__c[0];
        }
        else{
            suppliers = new SuppliersSelector().selectByCity(new Set<String>{accountToProcess.BillingCity.toUpperCase()});
        }

        System.debug(suppliers);
        return new GoogleMapsRestService.GoogleResponse(suppliers);
    }
}