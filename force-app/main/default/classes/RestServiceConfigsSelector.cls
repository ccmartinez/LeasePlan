public with sharing class RestServiceConfigsSelector extends fflib_SObjectSelector{
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            Rest_Service_Config__mdt.Api_Key__c,
            Rest_Service_Config__mdt.Batch_size__c,
            Rest_Service_Config__mdt.Endpoint__c,
            Rest_Service_Config__mdt.Page_Limit__c,
            Rest_Service_Config__mdt.Result_Number__c
        };
    }

    public Schema.SObjectType getSObjectType()
    {
        return Rest_Service_Config__mdt.SObjectType;
    }

    public Rest_Service_Config__mdt[] selectByDeveloperName(Set<String> restServicesNames){
        fflib_QueryFactory queryFactory = newQueryFactory();
        return (Rest_Service_Config__mdt[]) Database.query(queryFactory.setCondition('DeveloperName IN :restServicesNames').toSoql());
    }
}