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

    public class HttpMockClass implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            GoogleMapsRestService.GoogleResponse responseWrapper = new GoogleMapsRestService.GoogleResponse(new Supplier__c[]{new Supplier__c()});
            HTTPResponse response = new HTTPResponse();
            response.setBody(JSON.serialize(responseWrapper));
            return response;
        }
    }
}