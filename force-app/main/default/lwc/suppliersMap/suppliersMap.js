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
    @track supplierListVisibility = "hidden";
    @track showSupplierListButton = true;

    get recordId() {
        return this._recordId;
    }

    retreiveData(){
        debugger;
        getSuppliersData({accountId: this.recordId}).then(response => {
            response.results.forEach(result => {
                let resultLocation = result.geometry.location;
                this.suppliersMarkers.push({
                    title: result.name,
                    location: {
                        Latitude: parseFloat(resultLocation.lat),
                        Longitude: parseFloat(resultLocation.lng)
                    }
                })
            });

            this.center  = this.suppliersMarkers[0];
            this.showSpinner = false;
        });
    }

    toggleSuppliersVisibility(){
        if(this.supplierListVisibility == 'hidden'){
            this.supplierListVisibility = 'visible';
            this.showSupplierListButton = false;
        }
        else{
            this.supplierListVisibility = 'hidden'
            this.showSupplierListButton = true;
        }
    }
}