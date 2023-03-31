public with sharing class CitiesProcessor implements Schedulable{
    Set<String> citiesToProcess;
    private static final Integer BATCH_SIZE = 5; //number of records to process in a single execution

    public CitiesProcessor(Set<String> citiesToProcess){
        this.citiesToProcess = citiesToProcess;
    }
    public void execute(SchedulableContext SC) {//TODO: test this with different scheduling times
        processCities(citiesToProcess);
    }

    @future(callout=true)
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
            GoogleMapsRestService.GoogleResponse response = GoogleMapsRestService.getSuppliersBasedOnCityName(cityName);//avoid governor limits, since we will get a supplier list for every city, and that requires multiple callouts, because google maps does not support a city list, and it can only retreive 20 results per callout, every record not processed here will be rescheduled to be processed in the future
            for(GoogleMapsRestService.GoogleResult result: response.results){
                Supplier__c supplierToCreate = result.createSupplier(cityName);
                System.debug('supplier name: ' + supplierToCreate.Name);
                uow.registerNew(supplierToCreate);
            }
            
            processedCities.add(cityName);   
            if(processedCities.size() >= BATCH_SIZE){
                break;
            }
        }

        uow.commitWork();
        citiesToProcess.removeAll(processedCities);
        scheduleNextBatch(citiesToProcess);
    }

    public static void scheduleNextBatch(Set<String> citiesToProcess){
        if(!citiesToProcess.isEmpty()){
            Datetime inAMinute = Datetime.now().addSeconds(5); //TODO: Review this
            String cron = inAMinute.second() + ' ' + inAMinute.minute() +' '+ inAMinute.hour() +' ' + inAMinute.day() + ' ' + inAMinute.month() + ' ? ' + inAMinute.year();
            System.schedule('cities processor execution seed: ' + inAMinute.getTime(), cron, new CitiesProcessor(citiesToProcess));
        }
    }
}