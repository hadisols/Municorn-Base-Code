import { api, LightningElement, track } from 'lwc';
import fieldLayout from "c/fieldLayout";

export default class FormJSONTree extends LightningElement {

    _left;


    @track
    fswrapper=[];

    primarysObjectName='';

    @api
    rootObject=false;

    @track
    mergedKeyTypes = {};

    @api 
    set treejson(value) {
        this.treejsonR = value;
    }

    get treejson(){
        return this.treejsonR;
    }

    @track
    treejsonR;

    @track fsObject = {};

    @api
    get nodealign() {
        return this._left;
    }

    set nodealign(value) {
        if(value == 'left' || value == true || value == 'true') {
            this._left = true;
        }
        else if(value == 'right' || value == false || value == 'false') {
            this._left = false;
        } else {
            this._left = true;
        }
    }

    @api
    showTreeForm(obj, mergedKeyTypes) {
        console.log('tree called ',JSON.stringify(obj, null, 2));
        this.mergedKeyTypes = mergedKeyTypes;
        this.treejson = this.traverse(obj,'',[],'');
        console.log('objects ', JSON.stringify(this.treejson, null, 2)); 
    }


    renderedCallback() {

        console.log(` child json ${this.treejson}`);
        // if(this.treejson) {
        //     console.log(JSON.stringify(this.treejson));
        //     // this.traverse(x,this.process);
        // }   
    }

    lookupRecord(event) {
        console.log('selected record ', JSON.stringify(event.detail.selectedRecord, null, 2));
        let selected = event.detail.selectedRecord; 
        this.fsObject = selected;
        try {
            if(selected?.isPrimaryObject && !selected?.isDelete) {
                // TODO Disable lookup not rendering the child component in the tree

                this.treejson = this.traverseList(this.treejson, selected);
                this.primarysObjectName = selected.sObjectApiName;
                    
                console.log('first ',JSON.stringify(this.treejson, null, 2)); 
            } else if(selected?.enableChildLookup && !selected?.isDelete) {

                this.treejson = this.traverseList(this.treejson, selected);

                console.log('second ',JSON.stringify(this.treejson, null, 2));
                
            } else {
                console.log('dispatched event');

                selected.primarySObjectApiName = this.primarysObjectName;
                this.dispatchEvent(new CustomEvent('select', {
                    bubbles: true, 
                    composed: true,
                    detail: selected
                  }));
            }
        } catch(e) {
            console.log('error event ', e.message);
        }
        
    }

    traverseList(o, selected) {
        for(let i in o){
            if(o[i].haschild && selected.rootkey 
                && selected.rootkey == o[i].rootkey) {
                    this.traverseList(o[i].item, selected);
                    // o[i].item = this.traverseList(o[i].item, selected);
            }else if((selected.rootkey 
                && selected.rootkey == o[i].rootkey) || o[i].haschild) {
                    o[i].disable = false;
                    o[i].sobject = selected?.apiname;
            } else if(selected.isPrimaryObject) {
                //invoke the mutation
                o[i].disable = false;
                o[i].sobject = selected?.apiname;
            }
            // o[i] = func(o[i]);
            // if(selected.rootkey && selected.rootkey == o[i].rootkey) {
                
            // }
            // o[i].disable = false;
            // o[i].sobject = selected?.apiname;
        }
        return o;
    }

    changeprperty(obj, selected) {
        for(let i in obj) {
            obj[i].disable = false;
            obj[i].sobject = selected?.apiname;
        }
        return obj;
    }

    traverseNewArray(o, func) {
        for(let i in o){
            if(o[i].haschild) {
                o[i] = func(o[i]);
                this.traverseNewArray(o[i].item, func);
            } else {
                //invoke the mutation
                o[i] = func(o[i]);
            }
        }
        return o;
    }

    
    traverse(o, key='', arr=[], rootkey='') {
        for (let i in o) {
            let obj ={
                    key : key+i,
                    value : o[i],
                    item : [],
                    expand : false,
                    haschild : false,
                    disable: true,
                    sobject:'',
                    flatkey:'',
                    rootkey:rootkey,
                    uuid: this.uuidv4(),
                    direction : this.mergedKeyTypes[key+i] ? this.mergedKeyTypes[key+i] : 'INBOUND'
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
                    obj.haschild = true;
                    obj.rootkey = i;
                    obj.item.push(...this.traverse(o[i][j], '', [], i));  
                    break;  
                }
                
            } else if(o[i] !== null && typeof(o[i])=="object") {
                this.traverse(o[i], `${key}${i}.`,arr, rootkey);
                continue;
            }
            //console.log(obj);
            arr.push(obj);
        }
        return arr;
    }

    uuidv4() {
        return ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, c =>
          (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
        );
      }

    handleModalOpen(e) {
        
        const { target } = e;
        const { id } = target.dataset;
        let obj = Object.assign({},this.fsObject);
        
        console.log('Object to open ', JSON.stringify(obj, null, 2));
        
        fieldLayout.open(
        {
            objectWrapper : obj,
            onsave: (event) => {
                // stop further propagation of the event
                event.stopPropagation();
                this.handleUpdateEvent(event.detail);
              }
        })
        .then(result => {
            console.log('modal after closed ', result);
            this.fsObject = Object.assign({},result);
        })
    }
}

/* handleLookupSearch(event) {
    try {
        let results = [
            {
                id: '1',
                sObjectType: 'Account',
                icon: 'standard:account',
                title: 'Inital selection 1',
                subtitle: 'Not a valid record'
            },
            {
                id: '2',
                sObjectType: 'Account',
                icon: 'standard:account',
                title: 'Inital selection 2',
                subtitle: 'Not a valid record'
            },
            {
                id: '3',
                sObjectType: 'Account',
                icon: 'standard:account',
                title: 'Inital selection 3',
                subtitle: 'Not a valid record'
            }
        ];
        lookupElement.setSearchResults(results);
    } catch(e) {
        console.log('error ',e.message);
    }
    const lookupElement = event.target;
    // Call Apex endpoint to search for records and pass results to the lookup
    

    // search(event.detail)
    //     .then((results) => {
    //         lookupElement.setSearchResults(results);
    //     })
    //     .catch((error) => {
    //         this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
    //         // eslint-disable-next-line no-console
    //         console.error('Lookup error', JSON.stringify(error));
    //         this.errors = [error];
    //     });
}

handleLookupSelectionChange(event) {
    this.checkForErrors();
}

checkForErrors() {
    this.errors = [];
    const selection = this.template.querySelector('c-lookup').getSelection();
    // Custom validation rule
    if (this.isMultiEntry && selection.length > this.maxSelectionSize) {
        this.errors.push({ message: `You may only select up to ${this.maxSelectionSize} items.` });
    }
    // Enforcing required field
    if (selection.length === 0) {
        this.errors.push({ message: 'Please make a selection.' });
    }
} */