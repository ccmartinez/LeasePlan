public with sharing class SuppliersSelector extends fflib_SObjectSelector{
    public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
            Supplier__c.Name,
			Supplier__c.Location__City__s,
            Supplier__c.Location__Latitude__s,
            Supplier__c.Location__Longitude__s
		};
	}

    public Schema.SObjectType getSObjectType()
	{
		return Supplier__c.SObjectType;
	}

    public Supplier__c[] selectByCity(Set<String> supplierCities){
        fflib_QueryFactory queryFactory = newQueryFactory();
        return (Supplier__c[]) Database.query(queryFactory.setCondition('Location__City__s IN :supplierCities').toSoql());
    }
}