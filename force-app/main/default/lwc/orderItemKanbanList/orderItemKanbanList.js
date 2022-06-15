import { LightningElement, api } from 'lwc';

export default class OrderItemKanbanList extends LightningElement {
    @api records
    @api stage
    @api allstages
    @api touchstage
    @api listSpinnerStatus = false;

    handleItemDrag(evt){
        console.log('handleItemDrag');
        console.log(evt.detail);
        const event = new CustomEvent('listitemdrag', {
            detail: evt.detail
        })
        this.dispatchEvent(event)
    }
    handleDragOver(evt){
        evt.preventDefault()
    }
    handleDrop(evt){
        console.log("handleDrop");
        this.listSpinnerStatus = true;
        const event = new CustomEvent('itemdrop', {
            detail: this.stage
        })
        this.dispatchEvent(event)
        setTimeout(() => {
            console.log('hideSpinner');
            this.listSpinnerStatus = false;
        }, 3000);
    }
    handleTouchDrop(evt) {
        console.log("handleTouchDrop");
        console.log(evt.detail);
        console.log(this.allstages.length);
        this.allstages.forEach((value, index) => {
            if ((index !== this.allstages.length) && (this.stage == value)) {
                console.log("Change Stage" + value);
                this.touchstage = this.allstages[++index];
                console.log("New Stage" + this.touchstage);
            }

        });
        const eventdata = {touchstage: this.touchstage, recordId: evt.detail};
        const event = new CustomEvent('touchitemdrop', {
            detail: eventdata
        })
        this.dispatchEvent(event)
    }
    toggleSpinner() {
        this.listSpinnerStatus = !this.listSpinnerStatus;
    }
 
    showSpinner() {
        this.listSpinnerStatus = true;
    }
 
    hideSpinner() {
        this.listSpinnerStatus = false;
    }
}