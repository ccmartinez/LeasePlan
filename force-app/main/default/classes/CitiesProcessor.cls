public with sharing class CitiesProcessor implements Queueable{
    Set<String> citiesToProcess;

    public CitiesProcessor(Set<String> citiesToProcess){
        this.citiesToProcess = citiesToProcess;
    }
    public void execute(QueueableContext qc) {
        processCities(citiesToProcess);
    }

    @future(Callout=true)
    public static void processCities(Set<String> citiesToProcess){
        System.debug('CITIES TO PROCESS:' + citiesToProcess);
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Supplier__c.SObjectType
            }
        );
        
        Set<String> processedCities = new Set<String>();
        for(String cityName: citiesToProcess){
            System.debug('INITIAL CITY:' + cityName);
            GoogleMapsRestService.GoogleResponse response = GoogleMapsRestService.getSuppliersBasedOnCityName(cityName);
            for(GoogleMapsRestService.GoogleResult result: response.results){
                Supplier__c supplierToCreate = result.createSupplier(cityName);
                System.debug('supplier name: ' + supplierToCreate.Name);
                uow.registerNew(supplierToCreate);
            }
            
            processedCities.add(cityName);   
            if(processedCities.size() >= GoogleMapsRestService.googleRestServiceConfig.Batch_size__c){ //avoid governor limits, since we will get a supplier list for every city, and that requires multiple callouts, because google maps does not support a city list, and it can only retreive 20 results per callout, this translates in having to do multiple callouts for a single record. Every record not processed here will be enqueued to be processed in the future
                break;
            }
        }

        uow.commitWork();
        citiesToProcess.removeAll(processedCities);
        enqueueNextBatch(citiesToProcess);
    }

    public static void enqueueNextBatch(Set<String> citiesToProcess){
        if(!citiesToProcess.isEmpty()){
            System.enqueueJob(new CitiesProcessor(citiesToProcess));
        }
    }
}