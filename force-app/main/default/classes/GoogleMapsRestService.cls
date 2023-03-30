public with sharing class GoogleMapsRestService {
    private static final String API_KEY = 'AIzaSyAPBKH5HC67vSu_aU5Hlo8IfnzUb0B9bKs';//ideally we would use callout:NameOfTheNamedCredential with a named credential created. However, this does not seem to work sometimes, giving a credentials not found error.
    private static final String ENDPOINT = 'https://maps.googleapis.com/maps/api/place/textsearch/json';

    public static GoogleResponse getSuppliers(Account accountToProcess){
        String cityName = accountToProcess.BillingCity;
        if(accountToProcess.BillingCountry != null){
            cityName += ', ' + accountToProcess.BillingCountry;
        }
        
        return getSuppliers(new Map<String, String>{
            'query' => 'vehicle maintenance suppliers near ' + cityName
        });
    }

    public static GoogleResponse getExtendedSuppliers(Account accountToProcess){
        return null;
    }
    
    public static GoogleResponse getSuppliers(Map<String, String> urlParams){
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        String finalEndpoint = ENDPOINT + '?key=' + API_KEY;
        for(String param: urlParams.keySet()){
            finalEndpoint += '&' + param + '=' + EncodingUtil.urlEncode(urlParams.get(param), 'UTF-8'); //parameters do not seem to work in the header, so we have to pass them in the endpoint
        }
        
        req.setEndpoint(finalEndpoint);
        System.debug(finalEndpoint);
        String response = new Http().send(req).getBody();
        System.debug(response);
        return (GoogleResponse)JSON.deserialize(response, GoogleResponse.class);
    }

    public class GoogleResponse{
        @AuraEnabled
        public String next_page_token;
        @AuraEnabled
        public GoogleResult[] results;
        @AuraEnabled
        public Decimal minLat, maxLat, minLong, maxLong;
    }

    public class GoogleResult{
        @AuraEnabled
        public String name;
        @AuraEnabled
        public CityCode plusCode;
        @AuraEnabled
        public Geometry geometry;
    }

    public class Geometry{
        @AuraEnabled
        public Location location;
    }

    public class Location{
        @AuraEnabled
        public Decimal lat, lng;
    }

    public class CityCode{
        @AuraEnabled
        public String compound_code;
    }
}