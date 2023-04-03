public with sharing class GoogleMapsRestService {
    public static Rest_Service_Config__mdt googleRestServiceConfig{
        get{
            if(googleRestServiceConfig == null){
                googleRestServiceConfig = new RestServiceConfigsSelector().selectByDeveloperName(new Set<String>{'Google'})[0];

                if(Test.isRunningTest()){
                    googleRestServiceConfig.Result_Number__c = 0;
                }
            }

            return googleRestServiceConfig;
        }
        set;
    }

    public static GoogleResponse getSuppliersBasedOnCityName(String cityName){ 
        Map<String,String> googleParamList = new Map<String, String>{
            'query' => 'vehicle maintenance suppliers near ' + cityName
        };
        
        GoogleResponse finalResponse = getMultiplePagesOfSuppliers(googleParamList);

        while(finalResponse.results.size() < googleRestServiceConfig.Result_Number__c){
            getMoreSuppliersBasedOnBasedOnMinAndMaxCoordinates(finalResponse);
        }

        return finalResponse;
    }

    private static void addNonDuplicateResultsToResponse(GoogleResponse response, GoogleResult[] results){
        if(response.coordinatesAlreadyPresentInResultList == null){
            response.coordinatesAlreadyPresentInResultList = new Set<String>();
        }

        for(GoogleResult result: results){
            Location resultLocation = result.geometry.location;
            String resultCoordinates = resultLocation.getCoordinates();
            if(!response.coordinatesAlreadyPresentInResultList.contains(resultCoordinates)){
                response.coordinatesAlreadyPresentInResultList.add(resultCoordinates);
                response.results.add(result);
            }
        }
    }

    private static void getMoreSuppliersBasedOnBasedOnMinAndMaxCoordinates(GoogleResponse currentResponse){
        currentResponse.updateCoordinates();

        updateSuppliersBasedOnALocation(currentResponse, currentResponse.minLatLocation);
        updateSuppliersBasedOnALocation(currentResponse, currentResponse.maxLatLocation);
        updateSuppliersBasedOnALocation(currentResponse, currentResponse.minLongLocation);
        updateSuppliersBasedOnALocation(currentResponse, currentResponse.maxLongLocation);
    }

    private static void updateSuppliersBasedOnALocation(GoogleResponse currentResponse, Location location){
        if(currentResponse.coordinatesAlreadyUsedInASearch == null){
            currentResponse.coordinatesAlreadyUsedInASearch = new Set<String>();
        }

        String locationCoordinates = location.getCoordinates();
        if(!currentResponse.coordinatesAlreadyUsedInASearch.contains(locationCoordinates)){
            currentResponse.coordinatesAlreadyUsedInASearch.add(locationCoordinates);
            GoogleResponse suppliersBasedOnALocation = getSuppliersBasedOnALocation(location);
            addNonDuplicateResultsToResponse(currentResponse, suppliersBasedOnALocation.results);
        }
    }

    private static GoogleResponse getSuppliersBasedOnALocation(Location locationToProcess){
        Map<String,String> googleParamList = new Map<String, String>{
            'query' => 'vehicle maintenance suppliers',
            'location' => locationToProcess.lat + ',' + locationToProcess.lng
        };

        return getSuppliers(googleParamList);
    }

    private static GoogleResponse getMultiplePagesOfSuppliers(Map<String, String> googleParamList){
        GoogleResponse response = getSuppliers(googleParamList);
        response.coordinatesAlreadyPresentInResultList = new Set<String>();
        
        for(GoogleResult result: response.results){
            response.coordinatesAlreadyPresentInResultList.add(result.geometry.location.getCoordinates());
        }

        for(Integer i = 0; i < googleRestServiceConfig.Page_Limit__c; i++){
            googleParamList.put('pagetoken', response.next_page_token);
            GoogleResponse nextPageResults = getSuppliers(googleParamList);
            response.next_page_token = nextPageResults.next_page_token;

            addNonDuplicateResultsToResponse(response, nextPageResults.results);
        }

        return response;
    }
    
    private static GoogleResponse getSuppliers(Map<String, String> urlParams){
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        String finalEndpoint = googleRestServiceConfig.Endpoint__c + '?key=' + googleRestServiceConfig.Api_Key__c; //Ideally we would use callout:NameOfTheNamedCredential with a named credential created. However, this does not seem to work sometimes, giving a credentials not found error.
        for(String param: urlParams.keySet()){
            String paramValue = urlParams.get(param);
            if(paramValue != null){
                finalEndpoint += '&' + param + '=' + EncodingUtil.urlEncode(urlParams.get(param), 'UTF-8'); //parameters do not seem to work in the header, so we have to pass them in the endpoint
            }
        }
        
        req.setEndpoint(finalEndpoint);
        String response = new Http().send(req).getBody();
        GoogleResponse parsedResponse = (GoogleResponse)JSON.deserialize(response, GoogleResponse.class);

        return parsedResponse;
    }

    public class GoogleResponse{
        private String next_page_token;
        private Set<String> coordinatesAlreadyPresentInResultList, coordinatesAlreadyUsedInASearch;
        @AuraEnabled
        public GoogleResult[] results;
        private Location minLatLocation, maxLatLocation, minLongLocation, maxLongLocation;

        public GoogleResponse(Supplier__c[] supplierList){
            results = new GoogleResult[0];
            for(Supplier__c supplier: supplierList){
                GoogleResult resultToAdd = new GoogleResult();
                resultToAdd.geometry = new Geometry();
                resultToAdd.geometry.location = new Location();
                resultToAdd.geometry.location.lat = supplier.Location__Latitude__s;
                resultToAdd.geometry.location.lng = supplier.Location__Longitude__s;
                resultToAdd.name = supplier.Name;
                results.add(resultToAdd);
            }
        }

        private void updateCoordinates(){
            Decimal oldMinLat = minLatLocation?.lat; //If no results, amplify search no matter what
            Decimal oldMinLng = minLongLocation?.lng;
            Decimal oldMaxLat = maxLatLocation?.lat;
            Decimal oldMaxLng = maxLatLocation?.lng;

            for(GoogleResult result: results){
                Location resultLocation = result.geometry.location;
                if(minLatLocation == null || resultLocation.lat < minLatLocation.lat){
                    minLatLocation = resultLocation;
                }

                if(maxLatLocation == null || resultLocation.lat > maxLatLocation.lat){
                    maxLatLocation = resultLocation;
                }

                if(minLongLocation == null || resultLocation.lng < minLongLocation.lng){
                    minLongLocation = resultLocation;
                }

                if(maxLongLocation == null || resultLocation.lng > maxLongLocation.lng){
                    maxLongLocation = resultLocation;
                }
            }

            if(minLatLocation?.lat != null && minLatLocation.lat == oldMinLat){
                minLatLocation.lat -= 0.1;
            }
            if(minLongLocation?.lng != null && minLongLocation.lng == oldMinLng){
                minLongLocation.lng -= 0.1;
            }
            if(maxLatLocation?.lat != null && maxLatLocation.lat == oldMaxLat){
                maxLatLocation.lat += 0.1;
            }
            if(maxLongLocation?.lng != null && maxLongLocation.lng == oldMaxLng){
                maxLongLocation.lng += 0.1;
            }

        }
    }

    public class GoogleResult{
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Geometry geometry;

        public GoogleResult(){}

        public Supplier__c createSupplier(String cityName){
            if(name?.length() > 80){
                name = name.substring(0, 80);
            }

            return new Supplier__c(
                Name = name,
                Location__City__s = cityName,
                Location__Latitude__s = geometry.location.lat,
                Location__Longitude__s = geometry.location.lng
            );
        }
    }

    public class Geometry{
        @AuraEnabled
        public Location location;
    }

    public class Location{
        @AuraEnabled
        public Decimal lat, lng;
        private String getCoordinates(){
            return lat + ' ' + lng;
        }
    }
}