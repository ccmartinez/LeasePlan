@isTest
public with sharing class SuppliersMapControllerTest implements Queueable{
    String cityName;
    Decimal latitude, longitude;
    Id accountId;

    public SuppliersMapControllerTest(String cityName, Decimal latitude, Decimal longitude, Id accountId){
        this.cityName = cityName;
        this.latitude = latitude;
        this.longitude = longitude;
        this.accountId = accountId;
    }

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

        System.enqueueJob(new SuppliersMapControllerTest(cityName, latitude, longitude, accountToTest.Id)); //Wait until suppliers have been created
    }

    
    public void execute(QueueableContext qc){ //Wait until future methods finish executing
        Supplier__c accountSupplier = new SuppliersSelector().selectByCity(new Set<String>{cityName})[0];
        accountSupplier.Location__Latitude__s = latitude;
        accountSupplier.Location__Longitude__s = longitude;
        update accountSupplier;

        GoogleMapsRestService.GoogleResponse response = SuppliersMapController.getSuppliersData(accountId);

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