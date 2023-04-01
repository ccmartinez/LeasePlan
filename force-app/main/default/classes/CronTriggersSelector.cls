public with sharing class CronTriggersSelector extends fflib_SObjectSelector{
    private static Map<String, Schema.SObjectField> fieldMap;

    public String[] getFieldList(){
        return new String[]{
            'NextFireTime',
            'PreviousFireTime'
        };
    }

    public Schema.SObjectField[] getSObjectFieldList()
    {
        if(fieldMap == null){
            fieldMap = CronTrigger.SObjectType.getDescribe().fields.getMap();
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
        return Crontrigger.SObjectType;
    }

    public CronTrigger[] getLastJobContainingProvidedName(String jobName){
        fflib_QueryFactory queryFactory = newQueryFactory();
        String query = 'SELECT ' + String.join(getFieldList(), ', ') + ' FROM ' + getSObjectType() + ' WHERE CronJobDetail.Name LIKE \'%' + jobName + '%\' ORDER BY PreviousFireTime DESC, NextFireTime DESC LIMIT 1';
        System.debug('query to launch: ' + query);
        return (CronTrigger[]) Database.query(query);
    }
}