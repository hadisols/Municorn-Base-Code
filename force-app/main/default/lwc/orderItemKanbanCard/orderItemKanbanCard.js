import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'
export default class OrderItemKanbanCard extends NavigationMixin(LightningElement) {
    @api stage
    @api record
    @api spinnerStatus = false;
    
    get isSameStage(){
        return this.stage === this.record.Item_Status__c
    }
    
    itemDragStart(){
        console.log('itemDragStart');
        console.log(this.record.Id);
        const event = new CustomEvent('itemdrag', {
            detail: this.record.Id
        })
        this.dispatchEvent(event)
    }
    itemTouchNextStage(evt){
        this.spinnerStatus = true;
        console.log('itemTouchNextStage');
        console.log(this.record.Id);
        setTimeout(() => {
            console.log('hideSpinner');
            this.spinnerStatus = false;
        }, 3000);
        const event = new CustomEvent('touchdrop', {
            detail: this.record.Id
        })
        this.dispatchEvent(event)
        
    }
    toggleSpinner() {
        this.spinnerStatus = !this.spinnerStatus;
    }
 
    showSpinner() {
        this.spinnerStatus = true;
    }
 
    hideSpinner() {
        this.spinnerStatus = false;
    }
}