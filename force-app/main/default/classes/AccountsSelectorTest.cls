@isTest
public with sharing class AccountsSelectorTest {
    @isTest static void selectById(){
        Account a = TestDataFactory.getAccountList(1, true)[0];

        Test.startTest();
        Account retreivedAccount = new AccountsSelector().selectById(new Set<Id>{a.Id})[0];
        Test.stopTest();

        Assert.areEqual(a.Id, retreivedAccount.Id);
    }
}