public with sharing class CasesService {
    public void processCasesStatuses(Map<Id, SObject> oldMap) {
        Case[] casesToProcess = new Case[0];

        for(Case c: (Case[])Trigger.New){
            Case oldCase;
            if(oldMap != null){
                oldCase = (Case)oldMap.get(c.Id);
            }

            if(c.AccountId != null && c.Status == 'Closed' && 
                (oldCase == null || oldCase.Status != c.Status)
            ){
                casesToProcess.add(c);
            }
        }

        new AccountsService().updateAccountsRatings(casesToProcess);
    }
}