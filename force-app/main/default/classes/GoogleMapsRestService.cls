public with sharing class GoogleMapsRestService {
    private static final String ENDPOINT = 'https://maps.googleapis.com/maps/api/place/textsearch/json', API_KEY = 'AIzaSyAPBKH5HC67vSu_aU5Hlo8IfnzUb0B9bKs';//ideally we would use callout:NameOfTheNamedCredential with a named credential created. However, this does not seem to work sometimes, giving a credentials not found error.
    private static final Integer GOOGLE_PAGE_NUMBER = 2, MIN_RECORD_COUNT_TO_RETURN = 100; //TODO: Move record count to custom setting. The number of tines google is able to show a next page property

    public static GoogleResponse getSuppliersBasedOnCityName(String cityName){ 
        Map<String,String> googleParamList = new Map<String, String>{
            'query' => 'vehicle maintenance suppliers near ' + cityName
        };
        
        GoogleResponse finalResponse = getMultiplePagesOfSuppliers(googleParamList);
        while(finalResponse.results.size() < MIN_RECORD_COUNT_TO_RETURN){
            getMoreSuppliersBasedOnBasedOnMinAndMaxCoordinates(finalResponse);
        }

        return finalResponse;
    }

    private static void addNonDuplicateResultsToResponse(GoogleResponse response, GoogleResult[] results){
        if(response.coordinatesAlreadyPresentInResultList == null){
            response.coordinatesAlreadyPresentInResultList = new Set<String>();
        }

        System.debug('result token:' + response.next_page_token);
        for(GoogleResult result: results){
            Location resultLocation = result.geometry.location;
            String resultCoordinates = resultLocation.getCoordinates();
            System.debug('result coordinates:' + resultCoordinates);
            if(!response.coordinatesAlreadyPresentInResultList.contains(resultCoordinates)){
                System.debug('new coordinates');
                response.coordinatesAlreadyPresentInResultList.add(resultCoordinates);
                System.debug('name to add:' + result.name);
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

    public static GoogleResponse getSuppliersBasedOnALocation(Location locationToProcess){
        Map<String,String> googleParamList = new Map<String, String>{
            'query' => 'vehicle maintenance suppliers',
            'location' => locationToProcess.lat + ',' + locationToProcess.lng
        };

        return getSuppliers(googleParamList);
    }

    public static GoogleResponse getMultiplePagesOfSuppliers(Map<String, String> googleParamList){
        GoogleResponse response = getSuppliers(googleParamList);
        response.coordinatesAlreadyPresentInResultList = new Set<String>();
        
        for(GoogleResult result: response.results){
            response.coordinatesAlreadyPresentInResultList.add(result.geometry.location.getCoordinates());
        }

        for(Integer i = 0; i < GOOGLE_PAGE_NUMBER; i++){
            googleParamList.put('pagetoken', response.next_page_token);
            GoogleResponse nextPageResults = getSuppliers(googleParamList);
            response.next_page_token = nextPageResults.next_page_token;

            addNonDuplicateResultsToResponse(response, nextPageResults.results);
        }

        return response;
    }
    
    public static GoogleResponse getSuppliers(Map<String, String> urlParams){
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        String finalEndpoint = ENDPOINT + '?key=' + API_KEY;
        for(String param: urlParams.keySet()){
            String paramValue = urlParams.get(param);
            if(paramValue != null){
                System.debug('param:' + param + ' | ' + urlParams.get(param));
                finalEndpoint += '&' + param + '=' + EncodingUtil.urlEncode(urlParams.get(param), 'UTF-8'); //parameters do not seem to work in the header, so we have to pass them in the endpoint
            }
        }
        
        System.debug('final endpoint:' + finalEndpoint);
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
                System.debug('name to add:' + resultToAdd.name);
                results.add(resultToAdd);
            }
        }

        public void updateCoordinates(){
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
        }
    }

    public class GoogleResult{
        @AuraEnabled
        public String name;
        @AuraEnabled
        public CityCode plusCode;
        @AuraEnabled
        public Geometry geometry;

        public Supplier__c createSupplier(String cityName){
            System.debug('CITY:' + cityName);
            if(name.length() > 80){
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
        public String getCoordinates(){
            return lat + '' + lng;
        }
    }

    public class CityCode{
        @AuraEnabled
        public String compound_code;
    }
}