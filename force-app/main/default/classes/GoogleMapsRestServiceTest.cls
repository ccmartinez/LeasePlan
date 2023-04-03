@isTest
public with sharing class GoogleMapsRestServiceTest {
    @isTest static void multipleCalloutsTest(){
        GoogleMapsRestService.googleRestServiceConfig.Result_Number__c = 3;
        Test.setMock(HttpCalloutMock.class, new HttpMockClass());

        Test.startTest();
        GoogleMapsRestService.getSuppliersBasedOnCityName('Madrid');
        Test.stopTest();
    }

    @isTest static void createSupplier(){
        GoogleMapsRestService.GoogleResult result = new GoogleMapsRestService.GoogleResult();
        result.geometry = new GoogleMapsRestService.Geometry();
        result.geometry.location = new GoogleMapsRestService.Location();
        String resultName = 'result name';
        while(resultName.length() <= 80){
            resultName += resultName;
        }
        result.name = resultName;
        String cityName = 'city name';
        

        Test.startTest();
        Supplier__c createdSupplier = result.createSupplier(cityName);
        Test.stopTest();

        Assert.areEqual(result.name, createdSupplier.Name);
        Assert.areEqual(cityName, createdSupplier.Location__City__s);
    }

    public class HttpMockClass implements HttpCalloutMock{
        Integer callCount = 0;
        public HTTPResponse respond(HTTPRequest req) {

            Supplier__c[] supplierList = new Supplier__c[]{new Supplier__c(Location__Latitude__s = 1, Location__Longitude__s = 1)};
            if(++callCount > GoogleMapsRestService.googleRestServiceConfig.Page_Limit__c + 1){
                supplierList.add(new Supplier__c(Location__Latitude__s = 2, Location__Longitude__s = 2));
                if(callCount > GoogleMapsRestService.googleRestServiceConfig.Page_Limit__c + 10){
                    supplierList.add(new Supplier__c()); //Increase min and max location coordinates, in order to do so, many calls are needed
                }
            }

            GoogleMapsRestService.GoogleResponse responseWrapper = new GoogleMapsRestService.GoogleResponse(supplierList);
            
            HTTPResponse response = new HTTPResponse();
            response.setBody(JSON.serialize(responseWrapper));
            return response;
        }
    }
}