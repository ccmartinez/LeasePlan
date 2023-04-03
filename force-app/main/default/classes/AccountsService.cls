public with sharing class AccountsService {
    public void processAccountCities(){
        Set<String> accountCitiesThatDontHaveASupplier = getAccountCitiesThatDontHaveASupplier();
        
        CitiesProcessor.enqueueNextBatch(accountCitiesThatDontHaveASupplier);//cant do callouts from trigger so it is necessary to initiate another flow
    }

    private Set<String> getAccountCitiesThatDontHaveASupplier(){
        Set<String> changedAccountCitiesThatMayHaveASupplier = new Set<String>();
        for(Account acc: (Account[])Trigger.new){
            if(acc.BillingCity != null){
                changedAccountCitiesThatMayHaveASupplier.add(acc.BillingCity.toUpperCase());
            }
        }

        Set<String> accountCitiesThatDontHaveASupplier = changedAccountCitiesThatMayHaveASupplier.clone();
        Supplier__c[] suppliersOfAccountCities = new SuppliersSelector().selectByCity(changedAccountCitiesThatMayHaveASupplier);
        for(Supplier__c supplier: suppliersOfAccountCities){
            accountCitiesThatDontHaveASupplier.remove(supplier.Location__City__s);
        }

        return accountCitiesThatDontHaveASupplier;
    }

    public void updateAccountsRatings(Case[] closedCases){
        if(closedCases != null && !closedCases.isEmpty()){
            Account[] accountsToUpdate = new Account[0];
            Set<Id> accountIds = new Set<Id>();
            for(Case c: closedCases){
                accountIds.add(c.AccountId);
            }

            Map<Id, Decimal> accountIdToAverageRating = new CasesSelector().getAccountIdToAverageCaseRating(accountIds);

            for(Id accountId: accountIdToAverageRating.keySet()){
                accountsToUpdate.add(new Account(Id = accountId, Satisfaction__c = accountIdToAverageRating.get(accountId)));
            }

            update accountsToUpdate;
        }
    }
}