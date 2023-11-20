import { api, LightningElement, track } from 'lwc';

import deploy from '@salesforce/apex/SYS_FieldMapperController.deploy';
import getsObjectApiName from '@salesforce/apex/SYS_FieldMapperController.getsObjectApiName';
import getSavedJson from '@salesforce/apex/SYS_FieldMapperController.getSavedJson';

import fieldLayout from "c/fieldLayout";

import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } 
    from 'lightning/empApi';

export default class FormMapper extends LightningElement {
    @api
    treeJSON = {};
    // {
    //     name: "FirstName",
    //     title: "Enter your first name:",
    //     type: "text",
    //     address : {
    //         city : "NY"
    //     },
    //     item :[
    //         { 
    //             name1 : 'x1',
    //             addr : 'addr'
    //         },
    //         { 
    //             name2 : 'x2',
    //             pick :['12','23','34']
    //         }
    //     ]
    // };
    @track mergedKeyTypes = {};

    @track
    selectedConfig = [];
    @track objectJson;
    @track currentStep = "2";
    @track hasError = false;

    // Deployment related messages
    // @track progress = 0;
    @track loading = false;
    @track showErrorMessage = false;
    @track totalQueued = 0;
    @track remainedInQueue = 0;
    @track deploymentMessage = '';
    channelName = '/event/SYS_EventLog__e';
    subscription = {};

    get progress() {
        let result = 0;
        console.log('progress ',result, this.remainedInQueue);
        if(this.totalQueued > 0 && this.remainedInQueue >= 0) {
            if ( this.totalQueued < this.remainedInQueue ) {
                this.totalQueued = this.remainedInQueue;
            }
            result = Math.floor( (((this.totalQueued - this.remainedInQueue)/this.totalQueued)*100) );
            console.log('progress ',result, this.remainedInQueue);
        }
        return result;
    }

    get showSuccess() {
        return this.progress == 100;
    }




    _recordId;
    _sObjectApiName;

    @api set recordId(value) {
        this._recordId = value;
        console.log('_recordId ', this._recordId);
        this.loading = true;
        //TODO currently specific to demo org
        getsObjectApiName({ recordId: this._recordId })
        .then((result) => {
            this.sObjectApiName = result;
        })
        .catch((error) => {
            console.log('error fetching objectapiname', error);
        });
        
        getSavedJson({ recordId: this._recordId })
        .then((result) => {
            console.log(' retrived ', result);
            this.treeJSON = this.extractResponseFromMetadata(JSON.parse(result));
            // this.treeJSON = result;
            console.log('modified treejson', JSON.stringify(this.treeJSON, null, 2));
            this.loading = false;
            if(this.template.querySelector(".tree-form") && this.treeJSON)
                this.template.querySelector(".tree-form").showTreeForm(this.treeJSON, this.mergedKeyTypes); 
        })
        .catch((error) => {
            console.log('error fetching saved json ', error);
            this.loading = false;
        });
    }

    get recordId() {
        return this._recordId;
    }

    set sObjectApiName(value) {
        this._sObjectApiName = value;
    }

    get widthPercentage() {
        return `width:${this.progress}%;opacity: 1`;
    }

    get screenOne() {
        return this.currentStep == 1 || this.currentStep == '1';
    }

    get screenTwo() {
        return this.currentStep == 2 || this.currentStep == '2';
    }

    get screenThree() {
        return this.currentStep == 3 || this.currentStep == '3';
    }

    connectedCallback() {
        this.handleSubscribe();
        this.registerErrorListener();
        // this.increment()
        
    }

    // increment() {
    //     setTimeout(() => {
    //         this.progress += Math.floor(Math.random() * 8);
    //         if(this.progress < 100)
    //             this.increment();
    //     }, 1000);
    // }

    registerErrorListener() {
        // Invoke onError empApi method
        onError((error) => {
            console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }

    // Handles subscribe button click
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback =  (response) => {
            console.log('New message received: ', JSON.stringify(response, null, 2));
            if(response.data.payload.Success__c == true) {
                this.remainedInQueue = response.data.payload.Remaining__c;
            } else if(response.data.payload.Success__c == false) {
                this.showErrorMessage = true;
                this.deploymentMessage = response.data.payload.Message__c;
            }
            
            console.log('remained changed ', this.remainedInQueue,'progress ', this.progress, 'totalQueued ',this.totalQueued);
            // Response contains the payload of the new message received
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then((response) => {
            // Response contains the subscription information on subscribe call
            console.log(
                'Subscription request sent to: ',
                JSON.stringify(response.channel)
            );
            this.subscription = response;
            
        });
    }

    // renderedCallback() {
    //     // const canvasEle = this.template.querySelector('canvas');/* document.getElementById('drawContainer'); */
    //     // console.log('canvasEle' ,canvasEle);
    //     // const context = canvasEle.getContext('2d');
    //     // let startPosition = {x: 0, y: 0};
    //     // let lineCoordinates = {x: 0, y: 0};
    //     // let isDrawStart = false;
        
    //     // const getClientOffset = (event) => {
    //     //     const {pageX, pageY} = event.touches ? event.touches[0] : event;
    //     //     console.log('page ordinate ',pageX, pageY);
    //     //     const x = pageX - canvasEle.offsetLeft;
    //     //     const y = pageY - canvasEle.offsetTop - 150;
        
    //     //     return {
    //     //        x,
    //     //        y
    //     //     } 
    //     // }
        
    //     // const drawLine = () => {
    //     //    context.beginPath();
    //     //    context.moveTo(startPosition.x, startPosition.y);
    //     //    context.lineTo(lineCoordinates.x, lineCoordinates.y);
    //     //    context.stroke();
    //     // }
        
    //     // const mouseDownListener = (event) => {
    //     //    startPosition = getClientOffset(event);
    //     //    isDrawStart = true;
    //     // }
        
    //     // const mouseMoveListener = (event) => {
    //     //   if(!isDrawStart) return;
          
    //     //   lineCoordinates = getClientOffset(event);
    //     //   clearCanvas();
    //     //   drawLine();
    //     // }
        
    //     // const mouseupListener = (event) => {
    //     //   isDrawStart = false;
    //     // }
        
    //     // const clearCanvas = () => {
    //     //    context.clearRect(0, 0, canvasEle.width, canvasEle.height);
    //     // }
        
    //     // canvasEle.addEventListener('mousedown', mouseDownListener);
    //     // canvasEle.addEventListener('mousemove', mouseMoveListener);
    //     // canvasEle.addEventListener('mouseup', mouseupListener);
        
    //     // canvasEle.addEventListener('touchstart', mouseDownListener);
    //     // canvasEle.addEventListener('touchmove', mouseMoveListener);
    //     // canvasEle.addEventListener('touchend', mouseupListener);
    // }

    extractResponseFromMetadata(treeMetadata) {
        let result = {};
        for (let page of treeMetadata.pages) {
            console.log('inside pages loop',page);
            if (page.elements) {
                this.extractNames(page.elements, result);
            }
        }
            
        return result;
    }

    extractNames(elements, result) {
        console.log('inside extractNames');
        for (let element of elements) {
            if (element.type === "multipletext") {
                let obj = {};
                for (let item of element.items) {
                    obj[item.name] = "";
                }
                result[element.name] = obj;
            }
            else if (element.type !== "panel") {
                result[element.name] = "";
            }
            
            if (element.elements) {
                this.extractNames(element.elements, result);
            }
        }
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
        
        // const progress = this.template.querySelector('.progress-done');     
        // console
        // progress.style.width = 10 + '%';
        // progress.style.opacity = 1;
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
        // this.handleSubscribe();
        this.loading = true;
        deploy({ request: JSON.stringify(this.selectedConfig, null, 2), recordId : this._recordId })
        .then((result) => {
            console.log('result queued', result);
            this.totalQueued = result;
            this.remainedInQueue = result;
            console.log('progress info ', this.progress);
            this.currentStep = "3";
            this.loading = false;
        })
        .catch((error) => {
            console.log('deploy error ', error);
            this.loading = false;
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