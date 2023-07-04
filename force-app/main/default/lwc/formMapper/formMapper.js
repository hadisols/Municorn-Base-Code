import { api, LightningElement, track } from 'lwc';

import deploy from '@salesforce/apex/SYS_FieldMapperController.deploy';

import fieldLayout from "c/fieldLayout";

export default class FormMapper extends LightningElement {
    @api
    treeJSON ={
        name: "FirstName",
        title: "Enter your first name:",
        type: "text",
        address : {
            city : "NY"
        },
        item :[
            { 
                name1 : 'x1',
                addr : 'addr'
            },
            { 
                name2 : 'x2',
                pick :['12','23','34']
            }
        ]
    };
    @track mergedKeyTypes = [];

    @track
    selectedConfig = [];
    @track objectJson;
    @track currentStep = "2";
    @track hasError = false;

    @api
    recordId;

    get screenOne() {
        return this.currentStep == 1 || this.currentStep == '1';
    }

    get screenTwo() {
        return this.currentStep == 2 || this.currentStep == '2';
    }

    get screenThree() {
        return this.currentStep == 3 || this.currentStep == '3';
    }

    renderedCallback() {
        // const canvasEle = this.template.querySelector('canvas');/* document.getElementById('drawContainer'); */
        // console.log('canvasEle' ,canvasEle);
        // const context = canvasEle.getContext('2d');
        // let startPosition = {x: 0, y: 0};
        // let lineCoordinates = {x: 0, y: 0};
        // let isDrawStart = false;
        
        // const getClientOffset = (event) => {
        //     const {pageX, pageY} = event.touches ? event.touches[0] : event;
        //     console.log('page ordinate ',pageX, pageY);
        //     const x = pageX - canvasEle.offsetLeft;
        //     const y = pageY - canvasEle.offsetTop - 150;
        
        //     return {
        //        x,
        //        y
        //     } 
        // }
        
        // const drawLine = () => {
        //    context.beginPath();
        //    context.moveTo(startPosition.x, startPosition.y);
        //    context.lineTo(lineCoordinates.x, lineCoordinates.y);
        //    context.stroke();
        // }
        
        // const mouseDownListener = (event) => {
        //    startPosition = getClientOffset(event);
        //    isDrawStart = true;
        // }
        
        // const mouseMoveListener = (event) => {
        //   if(!isDrawStart) return;
          
        //   lineCoordinates = getClientOffset(event);
        //   clearCanvas();
        //   drawLine();
        // }
        
        // const mouseupListener = (event) => {
        //   isDrawStart = false;
        // }
        
        // const clearCanvas = () => {
        //    context.clearRect(0, 0, canvasEle.width, canvasEle.height);
        // }
        
        // canvasEle.addEventListener('mousedown', mouseDownListener);
        // canvasEle.addEventListener('mousemove', mouseMoveListener);
        // canvasEle.addEventListener('mouseup', mouseupListener);
        
        // canvasEle.addEventListener('touchstart', mouseDownListener);
        // canvasEle.addEventListener('touchmove', mouseMoveListener);
        // canvasEle.addEventListener('touchend', mouseupListener);
    }

    handleSelectEvent(event) {
        let selected = event.detail;
        console.log('parent selected ',JSON.stringify(selected, null, 2));
        if(selected)
            this.selectedConfig.push(selected);

        console.log('all selectedConfig ', JSON.stringify(this.selectedConfig, null, 2));
    }

    renderedCallback() {
        console.log('Rendered');
        if(this.template.querySelector(".tree-form") && this.treeJSON)
            this.template.querySelector(".tree-form").showTreeForm(this.treeJSON, this.mergedKeyTypes); 
    }

    handlePasteEvent(event) {
        let selected = event.detail.formattedJson;
        let mergedKeyTypes = event.detail.mergedKeyTypes;
        console.log('parent selected ',JSON.stringify(selected, null, 2));
        if(selected) {
            this.treeJSON = JSON.parse(selected);
            this.mergedKeyTypes = mergedKeyTypes;
            this.currentStep = "2";

            if(this.template.querySelector(".tree-form"))
                this.template.querySelector(".tree-form").showTreeForm(this.treeJSON, this.mergedKeyTypes); 
            // this.template.querySelector(".tree-form").showTreeForm(this.treeJSON);
        }
    }

    // handleModalOpen() {
    //     fieldLayout.open(
    //     {
    //         objectWrapper : {name : 'Dennis'},
    //         onsave: (event) => {
    //             // stop further propagation of the event
    //             event.stopPropagation();
    //             this.handleUpdateEvent(event.detail);
    //           }
    //     })
    //     .then(result => {
    //         console.log('modal after closed ', result);
    //     })
    // }

    handleUpdateEvent(detail) {
        console.log('details ',detail);
    }

    handleBackClick() {
        this.currentStep = "1";
    }

    handleDeploy() {
        deploy({ request: JSON.stringify(this.selectedConfig, null, 2) })
        .then((result) => {
            console.log('result ', result);
        })
        .catch((error) => {
            console.log('deploy error ', error);
        });
    }

    handleClick() {
        try {
            // console.log('init',JSON.stringify(this.treeJSON));

            // this.modifiedJSON = this.traverse(this.treeJSON);

            this.template.querySelector(".tree-form").showTreeForm(this.treeJSON, this.mergedKeyTypes);
            
            // getObjectDetails({ objectApiName : 'Survey__c'})
            // .then((result) => {
            //     console.log('obj ',result);
            //     this.objectJson = JSON.parse(result);
            // })
            // .catch((error) => {
            //     console.log('error callout ', JSON.stringify(error));
            // });
            // console.log('modified json',JSON.stringify(this.modifiedJSON));
        } catch(e) {
            console.log('error ',e.message);
        }
    }

    traverse(o) {
        let arr =[];
        for (let i in o) {
            let obj ={
                    key : i,
                    value : o[i],
                    item : [],
                    expand : false
                };
            // console.log(i, o[i]); 
            if (o[i] !== null && typeof(o[i])=="object" 
            && Array.isArray(o[i])) {
                
                for(let j in o[i]) {
                    if(typeof(o[i][j]) == "string" ||
                    typeof(o[i][j]) == "number" ||
                    typeof(o[i][j]) == "boolean") {
                        obj.value = obj.value.join(',');
                        break;
                    }
                    obj.value = "";
                    obj.expand = true;
                    obj.item.push(...this.traverse(o[i][j]));  
                    break;  
                }
            }
            //console.log(obj);
            arr.push(obj);
        }
        return arr;
    }

    /* ={
        name: "FirstName",
        title: "Enter your first name:",
        type: "text",
        item :[
            { name : 'x1'},
            { name : 'x2'}
        ]
    } */
    /* = [
        { key: 'name', value: 'FirstName', item: [], expand: false },
        {
          key: 'title',
          value: 'Enter your first name:',
          item: [],
          expand: false
        },
        { key: 'type', value: 'text', item: [], expand: false },
        { key: 'item', value: '', item: [ 
            {
                "key": "name1",
                "value": "x1",
                "item": [],
                "expand": false
            },
            {
                "key": "name2",
                "value": "x2",
                "item": [],
                "expand": false
            }
         ], expand: true }
      ]; */

}