public with sharing class CitiesProcessor implements Schedulable{
    Set<String> citiesToProcess;

    public CitiesProcessor(Set<String> citiesToProcess){
        this.citiesToProcess = citiesToProcess;
    }
    public void execute(SchedulableContext sc) {
        processCities(citiesToProcess);
    }

    @future(Callout=true)
    private static void processCities(Set<String> citiesToProcess){
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
        scheduleNextBatch(citiesToProcess);
    }

    public static void scheduleNextBatch(Set<String> citiesToProcess){
        if(!citiesToProcess.isEmpty()){
            Account[] accs = new AccountsSelector().getAccountsUsedForThreadSync();
            Datetime nextJobDt = getNextJobDt();

            System.debug('next job dt: ' + nextJobDt);
            String cron = nextJobDt.second() + ' ' + nextJobDt.minute() +' '+ nextJobDt.hour() +' ' + nextJobDt.day() + ' ' + nextJobDt.month() + ' ? ' + nextJobDt.year();
            System.schedule('CitiesProcessor execution time #' + JSON.serialize(nextJobDt), cron, new CitiesProcessor(citiesToProcess));
        }
    }

    private static Datetime getNextJobDt(){
        Integer timeDifference = Integer.valueOf(GoogleMapsRestService.googleRestServiceConfig.Time_difference__c);
        Datetime now = Datetime.now();
        Datetime nextExecutionTimeWithNoPreviousJobsTakenIntoAccount = now.addSeconds(20);
        Datetime nextJobDt;
        CronTrigger[] lastExecutedJob = new CronTriggersSelector().getLastJobContainingProvidedName('CitiesProcessor execution');

        if(lastExecutedJob.isEmpty()){
            System.debug('next execution time: ' + nextExecutionTimeWithNoPreviousJobsTakenIntoAccount);
            return nextExecutionTimeWithNoPreviousJobsTakenIntoAccount;
        }
        else{
            System.debug('last executed job: ' + lastExecutedJob[0]);
            Datetime lastJobDt = lastExecutedJob[0].NextFireTime == null ? lastExecutedJob[0].PreviousFireTime : lastExecutedJob[0].NextFireTime;
            System.debug('last job dt: ' + lastJobDt);
            Datetime lastJobWithTimeDiff = lastJobDt.addSeconds(timeDifference);
            if(lastJobWithTimeDiff > now){
                return lastJobWithTimeDiff;
            }
            
            return nextExecutionTimeWithNoPreviousJobsTakenIntoAccount;
        }
    }
}