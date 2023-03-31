public with sharing class AccountsTriggerHandler extends fflib_SObjectDomain{
    public AccountsTriggerHandler(Account[] accountList) {
        super(accountList);
    }

    public override void onAfterInsert() {
        processAccountCities(null);
    }

    public override void onAfterUpdate(Map<Id, SObject> oldMap) {
        processAccountCities(oldMap);
    }

    private void processAccountCities(Map<Id, SObject> oldMap){
        Set<String> changedAccountCitiesThatDontHaveASupplier = getChangedAccountCitiesThatDontHaveASupplier(oldMap);
        System.debug('changedAccountCitiesThatDontHaveASupplier:' + changedAccountCitiesThatDontHaveASupplier);
        
        CitiesProcessor.scheduleNextBatch(changedAccountCitiesThatDontHaveASupplier);//cant do callouts from trigger so it is necessary to initiate another flow
    }

    private Set<String> getChangedAccountCitiesThatDontHaveASupplier(Map<Id, SObject> oldMap){
        Set<String> changedAccountCitiesThatMayHaveASupplier = new Set<String>();
        for(Account acc: (Account[])Trigger.new){
            String oldBillingCity;

            if(oldMap != null){
                Account oldAcc = (Account)oldMap.get(acc.Id);
                oldBillingCity = oldAcc.BillingCity;
            }
            if(acc.BillingCity != null && 
                (oldBillingCity == null || acc.BillingCity != oldBillingCity) 
            ){
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

    public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new AccountsTriggerHandler(sObjectList);
		}
	}
}