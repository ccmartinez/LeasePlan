public with sharing class AccountsTriggerHandler extends fflib_SObjectDomain{
    public AccountsTriggerHandler(Account[] accountList) {
        super(accountList);
    }

    public override void onAfterInsert() {
        new AccountsService().processAccountCities(null);
    }

    public override void onAfterUpdate(Map<Id, SObject> oldMap) {
        new AccountsService().processAccountCities(oldMap);
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new AccountsTriggerHandler(sObjectList);
		}
	}
}