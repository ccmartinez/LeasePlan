public with sharing class AccountsSelector extends fflib_SObjectSelector{
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            Account.BillingCity
        };
    }

    public Schema.SObjectType getSObjectType()
    {
        return Account.SObjectType;
    }

    public Account[] selectById(Set<Id> accountIdSet){
        return selectSObjectsById(accountIdSet);
    }

    public Account[] getAccountsUsedForThreadSync(){
        return Database.query('SELECT Id FROM Account LIMIT 1 FOR UPDATE');
    }
}