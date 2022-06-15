import { LightningElement, wire, api } from 'lwc';
import { getListUi } from 'lightning/uiListApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import ORDERITEM_OBJECT from '@salesforce/schema/Order_Item__c'
import STAGE_FIELD from '@salesforce/schema/Order_Item__c.Item_Status__c'
import ID_FIELD from '@salesforce/schema/Order_Item__c.Id'
import getOrderItems from '@salesforce/apex/PMA_SearchController.getOrderItemsForFulfillment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class OrderItemKanbanContainer extends LightningElement {
    @api timeoutInMiliseconds = 10000;
    @api timeoutId;
    _wiredOrderItemsData;
    
    records
    pickVals
    recordId
    connectedCallback(){
        this.startTimer();
    }
    /*** fetching Order_Item__c lists ***/
    @wire(getOrderItems,{})
    wiredOrderItems(wireResult){
        const { data, error } = wireResult;
        this._wiredOrderItemsData = wireResult;
        if(data){
            console.log("getOrderItems", data);
            this.records = data.map(item => {
                return { 'Id': item.Id, 'Name': item.Name, 'Product__c': item.Product__c, 'Product_Name__c': item.Product__r.Name, 'Quantity__c': item.Quantity__c, 'Item_Status__c': item.Item_Status__c, 'List_Price__c': item.List_Price__c, 'Total_Price__c': item.Total_Price__c, 'OrderId': item.Order__c, 'OrderName': item.Order__r.Name, 'MemberName': item.Order__r.Member__r.Name, 'MemberId': item.Order__r.MemberId__c, 'Notes': item.Notes__c }
            })
        }
        if(error) {
            console.error(error)
        }
    }

    /** Fetch metadata abaout the opportunity object**/
    @wire(getObjectInfo, {objectApiName:ORDERITEM_OBJECT})
    objectInfo

    /*** fetching Stage Picklist ***/
    @wire(getPicklistValues, {
        recordTypeId:'$objectInfo.data.defaultRecordTypeId',
        fieldApiName:STAGE_FIELD
    })stagePicklistValues({ data, error}){
        if(data){
            this.pickVals = data.values.map(item => item.value)
        }
        if(error){
            console.error(error)
        }
    }


    /****getter to calculate the  width dynamically*/
    get calcWidth(){
        let len = this.pickVals.length +1
        return `width: calc(100vw/ ${len})`
    }

    handleListItemDrag(event){
        this.recordId = event.detail
    }
    handleTouchItemDrop(event){
        let stage = event.detail.touchstage;
        this.recordId = event.detail.recordId;
        this.updateHandler(stage)
    }

    handleItemDrop(event){
        let stage = event.detail
        this.updateHandler(stage)
    }
    updateHandler(stage){
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[STAGE_FIELD.fieldApiName] = stage;
        const recordInput ={fields}
        console.log(recordInput);
        this.resetTimer();
        updateRecord(recordInput)
        .then(()=>{
            this.showToast();
            console.log('UI Refreshed');
            return refreshApex(this._wiredOrderItemsData);
        }).catch(error=>{
            console.error(error)
        })
    }
    showToast(){
        this.dispatchEvent(
            new ShowToastEvent({
                title:'Success',
                message:'Stage updated Successfully',
                variant:'success'
            })
        )
    }
    //Polling Functions
    doInactive() {
        // does whatever you need it to actually do - probably signs them out or stops polling the server for info
        console.log('Do Pooling');
        refreshApex(this.wiredOrderItems);
        return refreshApex(this._wiredOrderItemsData);
    }
    resetTimer() {
        console.log('resetTimer'); 
        window.clearInterval(this.timeoutId)
        this.startTimer();
    }
    startTimer() { 
        console.log('startTimer');
        // window.setTimeout returns an Id that can be used to start and stop a timer
        this.timeoutId = window.setInterval(this.doInactive, this.timeoutInMiliseconds)
    }
     
    
    setupTimers () {
        console.log('setupTimers');
        window.addEventListener('load', resetTimer, false);
        var events = ['mousedown', 'mousemove', 'keypress', 'scroll', 'touchstart','touchmove','click'];
        events.forEach(function(name) {
         document.addEventListener(name, resetTimer, false);
        });
        
    } 
}