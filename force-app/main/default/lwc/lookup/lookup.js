import { LightningElement,api,wire, track} from 'lwc';
// import apex method from salesforce module 
import getSearchResult from '@salesforce/apex/SYS_FieldMapperController.getSearchResult';
import fetchDefaultRecord from '@salesforce/apex/SYS_FieldMapperController.fetchDefaultRecord';
const DELAY = 1000; // dealy apex callout timing in miliseconds  

export default class CustomLookupLwc extends LightningElement {
    // public properties with initial default values 
    @api label = '';
    @api placeholder = 'search...'; 
    @api iconName = 'standard:account';
    @api sObjectApiName = '';
    @api defaultRecordId = '';
    @api isObjectLookup = false;
    @api disabled = false;
    @api treeuuid;
    @api rootkey;
    @api flatkey;

    //sObject api name for merge fields
    sObjectOne = '';
    sObjectTwo = '';
    sObjectThree = '';
    sObjectFour = '';
    
    // private properties 
    @track lstResult = []; // to store list of returned records   
    hasRecords = true; 
    searchKey=''; // to store input field value    
    isSearchLoading = false; // to control loading spinner  
    delayTimeout;
    @track selectedRecord = {}; 
    @track fieldApiName = '';

    get readOnlyField() {
        return !this.selectedRecord.expand;
    }
    
    // to store selected lookup record in object formate 
   // initial function to populate default selected lookup record if defaultRecordId provided  
    connectedCallback(){
         if(this.defaultRecordId != ''){
            fetchDefaultRecord({ recordId: this.defaultRecordId , 'sObjectApiName' : this.sObjectApiName })
            .then((result) => {
                if(result != null){
                    this.selectedRecord = result;
                    this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
                }
            })
            .catch((error) => {
                this.error = error;
                this.selectedRecord = {};
            });
         }
    }
    // wire function property to fetch search record based on user input
    @wire(getSearchResult, 
        { 
            searchKey: '$searchKey' , 
            sObjectApiName : '$sObjectApiName' , 
            isObjectLookup: '$isObjectLookup' ,
            selected : '$selectedRecord'
        })
     searchResult(value) {
        const { data, error } = value; // destructure the provisioned value
        this.isSearchLoading = false;
        if (data) {
             this.hasRecords = data.length == 0 ? false : true; 
             this.lstResult = JSON.parse(JSON.stringify(data)); 
         }
        else if (error) {
            console.log('(error---> ' + JSON.stringify(error));
         }
    };
       
    // update searchKey property on input field change  
    handleKeyChange(event) {
        // Debouncing this method: Do not update the reactive property as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        // if(!this.isObjectLookup) {
        //     this.toggleResult(event);
        // }
        this.isSearchLoading = true;
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.searchKey = searchKey;
        }, DELAY);
    }

    handleKeyChangeInField(event) {
        this.isSearchLoading = true;
        this.toggleResult(event);
        window.clearTimeout(this.delayTimeout);
        const fullSearchKey = event.target.value;
        // let searchKey = fullSearchKey.split(".").pop();
        console.log('key changed ', event.target.value, ' search key ',fullSearchKey);
        console.log('selected record ', this.selectedRecord);
        // this.fieldApiName = fullSearchKey;
        // this.searchKey = fullSearchKey;

        this.delayTimeout = setTimeout(() => {
            this.searchKey = fullSearchKey;
        }, DELAY);
    }

    // method to toggle lookup result section on UI 
    toggleResult(event){
        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        const clsList = lookupInputContainer.classList;
        const whichEvent = event.target.getAttribute('data-source');
        console.log('whichEvent ', whichEvent );
        switch(whichEvent) {
            case 'searchInputField':
                clsList.add('slds-is-open');
                break;
            case 'lookupContainer':
                clsList.remove('slds-is-open');    
                break;                    
           }
    }

   // method to clear selected lookup record  
   handleRemove(){
        this.searchKey = '';    
        this.selectedRecord = {};
        this.lookupUpdatehandler(undefined); // update value on parent component as well from helper function 
        
        // remove selected pill and display input field again 
        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        searchBoxWrapper.classList.remove('slds-hide');
        searchBoxWrapper.classList.add('slds-show');
        const pillDiv = this.template.querySelector('.pillDiv');
        pillDiv.classList.remove('slds-show');
        pillDiv.classList.add('slds-hide');
    }

    // method to update selected record from search result 
    handelSelectedRecord(event){   
        var objId = event.target.getAttribute('data-recid'); // get selected record Id 
        this.selectedRecord = this.lstResult.find(data => data.uuid === objId); // find selected record from list 
        this.fieldApiName = this.selectedRecord.fieldApiName;
        // if(!this.isObjectLookup) {
        //     this.searchKey = this.selectedRecord.fieldApiName;
        //     const inputField = this.template.querySelector('.lookup-field-main');
        //     if(inputField)
        //         inputField.focus();
        // }

        //set primary sObject and send it to parent component
        let info = {};
        let fsObject = {};
        if(this.sObjectApiName === "" && this.isObjectLookup) { 
            info = {
                isDelete: false,
                isPrimaryObject: true,
                treeuuid: this.treeuuid,
                rootkey: this.rootkey,
                flatkey: this.flatkey,
            }
            
        } else if(this.isObjectLookup) {
            info = {
                isDelete: false,
                enableChildLookup: true,
                treeuuid: this.treeuuid,
                rootkey: this.rootkey,
                flatkey: this.flatkey,
            }

            
        } else {    
            info = {
                isDelete: false,
                isPrimaryObject: false,
                treeuuid: this.treeuuid,
                rootkey: this.rootkey,
                flatkey: this.flatkey,
            }
        }
        
        fsObject = {
            developername : this.treeuuid,
            label : 'FS_'+this.selectedRecord.apiname+'_IN',
    
            Direction : 'INBOUND',
            FieldApiName : this.selectedRecord.fieldApiName,
            Field_Mapping_Handler : 'SYS_ApplicationService',
            Is_Active : true,
            Key : this.flatkey, 
            ObjectApiName : this.sObjectApiName,
            ObjectSetting : '',
            Skip_Field_Setting : false,
            StaticValue : '',
    
            Key_For_Events : '',
            RestResource : '',
            Is_External_Field : false,
            Is_Lookup : false,
            Lookup_Object_API_Name : '',
            Datetime_Conversion_Format : '',
            Get_value_from_Log : false,
            Log_API_for_field_mapping : '',
            Lookup_External_Key : '',
    
            Mapping_is_for : '',
            Level : '',
            Send_Blanks_as_Empty_String : false,
            ChildRootElement : '',
            ParentField : ''
        }

        console.log('pushed ', JSON.stringify({...this.selectedRecord, ...info, ...fsObject}));
        this.lookupUpdatehandler({...this.selectedRecord, ...info, ...fsObject});
        
        // if(this.isObjectLookup)
            this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
        // else 
        //     this.handleLookUpOpen();
    }

    renderedCallback() {
        this.handleInputFieldFocus();
    }

    handleInputFieldFocus() {
        const inputField = this.template.querySelector('.combobox-id-field');
        if(inputField)
            inputField.focus();
        console.log('on focus', inputField);
    }

    /*COMMON HELPER METHOD STARTED*/
    handelSelectRecordHelper(){
        this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        searchBoxWrapper.classList.remove('slds-show');
        searchBoxWrapper.classList.add('slds-hide');
        const pillDiv = this.template.querySelector('.pillDiv');
        pillDiv.classList.remove('slds-hide');
        pillDiv.classList.add('slds-show');     

        
    }

    handleLookUpOpen() {
        this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
        
    }
    
    // send selected lookup record to parent component using custom event
    lookupUpdatehandler(value){    
            const oEvent = new CustomEvent('lookupupdate',
            {
                'detail': {selectedRecord: value}
            }
            );
            this.dispatchEvent(oEvent);
    }
}