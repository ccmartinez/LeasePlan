import { LightningElement, track, api} from 'lwc';
import getSuppliersData from '@salesforce/apex/SuppliersMapController.getSuppliersData';

export default class SuppliersMap extends LightningElement {
    _recordId;

    @api set recordId(value) {
        this._recordId = value;
        this.retreiveData();
    }
    @track suppliersMarkers = [];
    @track showSpinner = true;
    @track showError = false;
    @track supplierListVisibility = "hidden";
    @track showSupplierListButton = false;
    @track errorCode;
    @track errorCodePopulated = false;
    @track errorMessage;

    get recordId() {
        return this._recordId;
    }

    retreiveData(){
        debugger;
        getSuppliersData({accountId: this.recordId}).then(response => {
            try{
                response.results.forEach(result => {
                    let resultLocation = result.geometry.location;
                    this.suppliersMarkers.push({
                        title: result.name,
                        location: {
                            Latitude: parseFloat(resultLocation.lat),
                            Longitude: parseFloat(resultLocation.lng)
                        },
                        description: resultLocation.lat + ', ' + resultLocation.lng
                    })
                });

                this.center  = this.suppliersMarkers[0];
                this.showSpinner = false;
                this.showSupplierListButton = true;
            }catch(error){
                this.processError(error)
            }
        }).catch(error => this.processError(error));
    }

    enableSuppliersVisibility(){
        this.supplierListVisibility = 'visible';
        this.showSupplierListButton = false;
    }

    disableSuppliersVisibility(){
        this.supplierListVisibility = 'hidden'
        this.showSupplierListButton = true;
    }

    processError(error){
        this.showError = true;
        if(error.status == null){
            this.errorMessage = error.message;    
        }
        else{
            this.errorMessage = error.statusText;
            this.setErrorCode(error.status);
        }

        this.showSpinner = false;
    }
}