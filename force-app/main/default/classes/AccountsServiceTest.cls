@isTest
public with sharing class AccountsServiceTest {
    @isTest static void processAccountCities(){
        GoogleMapsRestService.googleRestServiceConfig.Result_Number__c = 1;
        Test.setMock(HttpCalloutMock.class, new HttpMockClass());

        Account a = TestDataFactory.getAccountList(1, false)[0];
        a.BillingCity = 'Madrid';

        Test.startTest();
        insert a;
        Test.stopTest();
        update a; //Ignore accounts that already have a supplier created, so 2 different inserts are required

        Assert.areEqual(a.BillingCity, [SELECT Location__City__s FROM Supplier__c].Location__City__s);
    }

    @isTest static void updateAccountsRatings(){
        Test.setMock(HttpCalloutMock.class, new HttpMockClass());

        System.debug(Test.isRunningTest());
        Case[] casesToProcess = new Case[5];
        Account a = TestDataFactory.getAccountList(1, true)[0];
        for(Integer i = 0; i < casesToProcess.size(); i ++){
            casesToProcess[i] = new Case(
                AccountId = a.Id,
                Status = 'Closed',
                Rating__c = (i + 1) + ''
            );
        }

        Test.startTest();
        insert casesToProcess;
        update casesToProcess;
        Test.stopTest();

        a = new AccountsSelector().selectById(new Set<Id>{a.Id})[0];
        Assert.areEqual(3, a.Satisfaction__c);
    }

    public class HttpMockClass implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            GoogleMapsRestService.GoogleResponse responseWrapper = new GoogleMapsRestService.GoogleResponse(new Supplier__c[]{new Supplier__c()});
            HTTPResponse response = new HTTPResponse();
            response.setBody(JSON.serialize(responseWrapper));
            return response;
        }
    }
}