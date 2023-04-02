@isTest
public with sharing class SuppliersMapControllerTest {
    @isTest static void getSuppliersData(){
        GoogleMapsRestService.googleRestServiceConfig.Result_Number__c = 0; 
        Test.setMock(HttpCalloutMock.class, new HttpMockClass());

        String cityName = 'Madrid';
        Account accountToTest = TestDataFactory.getAccountList(1, false)[0];
        Decimal latitude = 15, longitude = 30;
        accountToTest.BillingCity = cityName;
        
        Test.startTest();
        insert accountToTest;
        Test.stopTest();

        Supplier__c accountSupplier = new SuppliersSelector().selectByCity(new Set<String>{cityName})[0];
        accountSupplier.Location__Latitude__s = latitude;
        accountSupplier.Location__Longitude__s = longitude;
        update accountSupplier;

        GoogleMapsRestService.GoogleResponse response = SuppliersMapController.getSuppliersData(accountToTest.Id);

        GoogleMapsRestService.Location responseLocation = response.results[0].geometry.location;
        Assert.areEqual(latitude, responseLocation.lat);
        Assert.areEqual(longitude, responseLocation.lng);
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