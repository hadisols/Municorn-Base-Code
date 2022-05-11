import { LightningElement, wire } from 'lwc';
import { getListUi } from 'lightning/uiListApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import ORDERITEM_OBJECT from '@salesforce/schema/Order_Item__c'
import STAGE_FIELD from '@salesforce/schema/Order_Item__c.Item_Status__c'
import ID_FIELD from '@salesforce/schema/Order_Item__c.Id'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class OrderItemKanbanContainer extends LightningElement {
    records
    pickVals
    recordId
    /*** fetching Order_Item__c lists ***/
    @wire(getListUi, {
        objectApiName: ORDERITEM_OBJECT,
        listViewApiName:'All_Active_or_Draft_Order_Items'
    })wiredListView({error, data}){
        if(data){
            console.log("getListUi", data)
            this.records = data.records.records.map(item => {
                let field = item.fields
                let order = field.Order__r.value.fields  
                let product = field.Product__r.value.fields
                return { 'Id': field.Id.value, 'Name': field.Name.value, 'Product__c': product.Id.value, 'Product_Name__c': field.Product_Name__c.value, 'Quantity__c': field.Quantity__c.value, 'Item_Status__c': field.Item_Status__c.value, 'List_Price__c': field.List_Price__c.value, 'Total_Price__c': field.Total_Price__c.value, 'OrderId': order.Id.value, 'OrderName': order.Name.value, 'MemberName': field.Member__c.value, 'MemberId': field.MemberId__c.value }
            })
        }
        if(error){
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
            console.log("Stage Picklist", data)
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

    handleItemDrop(event){
        let stage = event.detail
        // this.records = this.records.map(item=>{
        //     return item.Id === this.recordId ? {...item, StageName:stage}:{...item}
        // })
        this.updateHandler(stage)
    }
    updateHandler(stage){
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[STAGE_FIELD.fieldApiName] = stage;
        const recordInput ={fields}
        updateRecord(recordInput)
        .then(()=>{
            console.log("Updated Successfully")
            this.showToast()
            return refreshApex(this.wiredListView)
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
}