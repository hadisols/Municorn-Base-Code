import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'
export default class OrderItemKanbanCard extends NavigationMixin(LightningElement) {
    @api stage
    @api record

    get isSameStage(){
        console.log(this.stage === this.record.StageName);
        return this.stage === this.record.Item_Status__c
    }
    navigateMemberHandler(event){
        event.preventDefault()
        this.navigateHandler(event.target.dataset.id, 'Contact')
    }
    navigateOrderHandler(event){
        event.preventDefault()
        this.navigateHandler(event.target.dataset.id, 'Order__c')
    }
    navigateOrderItemHandler(event){
        event.preventDefault()
        this.navigateHandler(event.target.dataset.id, 'Order_Item__c')
    }
    navigateProductHandler(event){
        event.preventDefault()
        this.navigateHandler(event.target.dataset.id, 'Product__c')
    }
    navigateHandler(Id, apiName) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: Id,
                objectApiName: apiName,
                actionName: 'view',
            },
        });
    }
    itemDragStart(){
        const event = new CustomEvent('itemdrag', {
            detail: this.record.Id
        })
        this.dispatchEvent(event)
    }
}