public with sharing class CasesTriggerHandler  extends fflib_SObjectDomain{
    public CasesTriggerHandler(Case[] caseList) {
        super(caseList);
    }

    public override void onAfterInsert() {
        new CasesService().processCasesStatuses(null);
    }

    public override void onAfterUpdate(Map<Id, SObject> oldMap) {
        new CasesService().processCasesStatuses(oldMap);
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new CasesTriggerHandler(sObjectList);
		}
	}
}