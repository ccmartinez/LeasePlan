@isTest
public with sharing class TestDataFactory {
    public static Account[] getAccountList(Integer numberOfObjectsToCreate, Boolean doInsert){
        Account[] listToReturn = new Account[numberOfObjectsToCreate];
        for(Integer i = 0; i < numberOfObjectsToCreate; i++){
            listToReturn[i] = new Account(Name = 'Account ' + i);
        }

        if(doInsert){
            insert listToReturn;
        }

        return listToReturn;
    }
}