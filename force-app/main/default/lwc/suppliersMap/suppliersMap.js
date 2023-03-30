import { LightningElement, track, api} from 'lwc';
import getSuppliersData from '@salesforce/apex/SuppliersMapController.getSuppliersData';

export default class SuppliersMap extends LightningElement {
    _recordId;

    @api set recordId(value) {
        this._recordId = value;
        this.retreiveData();
        // do your thing right here with this.recordId / value
    }
    @track suppliersMarkers = [];
    @track showSpinner = true;

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
                this.showSpinner = false;
            })
            let test = 1;
        });
    }
}