import { LightningElement, api } from 'lwc';

export default class OrderItemKanbanList extends LightningElement {
    @api records
    @api stage
    handleItemDrag(evt){
        const event = new CustomEvent('listitemdrag', {
            detail: evt.detail
        })
        this.dispatchEvent(event)
    }
    handleDragOver(evt){
        evt.preventDefault()
    }
    handleDrop(evt){
        const event = new CustomEvent('itemdrop', {
            detail: this.stage
        })
        this.dispatchEvent(event)
    }
}