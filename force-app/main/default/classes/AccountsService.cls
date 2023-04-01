public with sharing class AccountsService {
    public void processAccountCities(Map<Id, SObject> oldMap){
        Set<String> changedAccountCitiesThatDontHaveASupplier = getChangedAccountCitiesThatDontHaveASupplier(oldMap);
        System.debug('changedAccountCitiesThatDontHaveASupplier:' + changedAccountCitiesThatDontHaveASupplier);
        
        CitiesProcessor.scheduleNextBatch(changedAccountCitiesThatDontHaveASupplier);//cant do callouts from trigger so it is necessary to initiate another flow
    }

    private Set<String> getChangedAccountCitiesThatDontHaveASupplier(Map<Id, SObject> oldMap){
        Set<String> changedAccountCitiesThatMayHaveASupplier = new Set<String>();
        for(Account acc: (Account[])Trigger.new){
            if(acc.BillingCity != null){
                changedAccountCitiesThatMayHaveASupplier.add(acc.BillingCity);
            }
        }
        System.debug('changedAccountCitiesThatMayHaveASupplier:' + changedAccountCitiesThatMayHaveASupplier);

        Set<String> changedAccountCitiesThatDontHaveASupplier = changedAccountCitiesThatMayHaveASupplier.clone();
        Supplier__c[] suppliersOfAccountCities = new SuppliersSelector().selectByCity(changedAccountCitiesThatMayHaveASupplier);
        for(Supplier__c supplier: suppliersOfAccountCities){
            changedAccountCitiesThatDontHaveASupplier.remove(supplier.Location__City__s);
        }

        System.debug('changedAccountCitiesThatMayHaveASupplier:' + changedAccountCitiesThatMayHaveASupplier);
        return changedAccountCitiesThatDontHaveASupplier;
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