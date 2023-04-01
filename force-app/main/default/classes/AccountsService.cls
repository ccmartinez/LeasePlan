public with sharing class AccountsService {
    public void processAccountCities(){
        Set<String> accountCitiesThatDontHaveASupplier = getAccountCitiesThatDontHaveASupplier();
        System.debug('accountCitiesThatDontHaveASupplier:' + accountCitiesThatDontHaveASupplier);
        
        CitiesProcessor.scheduleNextBatch(accountCitiesThatDontHaveASupplier);//cant do callouts from trigger so it is necessary to initiate another flow
    }

    private Set<String> getAccountCitiesThatDontHaveASupplier(){
        Set<String> changedAccountCitiesThatMayHaveASupplier = new Set<String>();
        for(Account acc: (Account[])Trigger.new){
            if(acc.BillingCity != null){
                changedAccountCitiesThatMayHaveASupplier.add(acc.BillingCity);
            }
        }
        System.debug('changedAccountCitiesThatMayHaveASupplier:' + changedAccountCitiesThatMayHaveASupplier);

        Set<String> accountCitiesThatDontHaveASupplier = changedAccountCitiesThatMayHaveASupplier.clone();
        Supplier__c[] suppliersOfAccountCities = new SuppliersSelector().selectByCity(changedAccountCitiesThatMayHaveASupplier);
        for(Supplier__c supplier: suppliersOfAccountCities){
            accountCitiesThatDontHaveASupplier.remove(supplier.Location__City__s);
        }

        System.debug('changedAccountCitiesThatMayHaveASupplier:' + changedAccountCitiesThatMayHaveASupplier);
        return accountCitiesThatDontHaveASupplier;
    }
}