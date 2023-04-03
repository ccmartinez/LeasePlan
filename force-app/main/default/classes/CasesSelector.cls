public with sharing class CasesSelector extends fflib_SObjectSelector{
    Map<String, Schema.SobjectField> fieldMap;

    public List<Schema.SObjectField> getSObjectFieldList()
    {   
        return new Schema.SObjectField[]{
            Case.AccountId
        };
    }

    public Schema.SObjectType getSObjectType()
    {
        return Case.SObjectType;
    }

    /**
     * @author Carlos Cañizares
     * Generates a map that links every account to the average rating of all the cases of that same account
     */
    public Map<Id, Decimal> getAccountIdToAverageCaseRating(Set<Id> accountIds){
        fflib_QueryFactory queryFactory = newQueryFactory();

        String queryToLaunch = 'SELECT AccountId, AVG(Rating_Value__c) rating FROM ' + getSObjectType() + ' WHERE AccountId IN :accountIds AND Rating_Value__c != null GROUP BY AccountId';
        AggregateResult[] results = Database.query(queryToLaunch);
        Map<Id, Decimal> accountIdToAverageRating = new Map<Id, Decimal>();
        for(AggregateResult result: results){
            accountIdToAverageRating.put((Id)result.get('AccountId'), (Decimal)result.get('rating'));
        }

        return accountIdToAverageRating;
    }

    public class CaseGroup{
        Case[] caseList;
        Decimal averageRating;

        public CaseGroup(Case[] caseList, Decimal averageRating){
            this.caseList = caseList;
            this.averageRating = averageRating;
        }
    }
}