public with sharing class CasesSelector extends fflib_SObjectSelector{
    Map<String, Schema.SobjectField> fieldMap;

    public String[] getFieldList(){
        return new String[]{'AccountId'};
    }

    public List<Schema.SObjectField> getSObjectFieldList()
    {
        if(fieldMap == null){
            fieldMap = Case.SObjectType.getDescribe().fields.getMap();
        }

        String[] fieldList = getFieldList();
        Schema.SObjectField[] listToReturn = new Schema.SObjectField[0];

        for(String field: fieldList){
            listToReturn.add(fieldMap.get(field));
        }

        return listToReturn;
    }

    public Schema.SObjectType getSObjectType()
    {
        return Case.SObjectType;
    }

    public Map<Id, Decimal> getAccountIdToAverageCaseRating(Set<Id> accountIds){
        fflib_QueryFactory queryFactory = newQueryFactory();

        String queryToLaunch = 'SELECT ' + String.join(
            getFieldList(), ', '
        ) + ', AVG(Rating_Value__c) rating FROM ' + getSObjectType() + ' WHERE AccountId IN :accountIds AND Rating_Value__c != null GROUP BY AccountId';
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