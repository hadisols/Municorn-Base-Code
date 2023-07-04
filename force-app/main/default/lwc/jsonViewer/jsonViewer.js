import { LightningElement, track } from "lwc";

export default class JsonViewer extends LightningElement {
    @track formattedJson;
    @track mergedKeyTypes = {};
    @track error;
    @track jsonIn;
    @track jsonOut;

    get showJson() {
        return !(this.error) ? true : false;
    }

    handleNextClick() {
        this.dispatchEvent(new CustomEvent('paste', {
                bubbles: true, 
                composed: true,
                detail: {
                    formattedJson : this.formattedJson,
                    mergedKeyTypes : this.mergedKeyTypes
                }
              }));
    }

    handleInputChangeIn(event) {
        const inputJson = event.target.value;
        try {
            const parsedJson = JSON.parse(inputJson);
            this.jsonIn = parsedJson;
            if(this.jsonOut) {
                this.merge(this.jsonIn, this.jsonOut);
            }
            else
                this.formattedJson = JSON.stringify(parsedJson, null, 2);
            this.error = '';
            //this.formattedJson = JSON.stringify(parsedJson, null, 2);
            // this.dispatchEvent(new CustomEvent('paste', {
            //     bubbles: true, 
            //     composed: true,
            //     detail: this.formattedJson
            //   }));
        } catch (error) {
            console.log('error ',JSON.stringify(error, null, 2));
            this.error = "Invalid JSON";
        }
    }

    handleInputChangeOut(event) {
        const inputJson = event.target.value;
        try {
            const parsedJson = JSON.parse(inputJson);
            this.jsonOut = parsedJson;
            if(this.jsonIn) {
                this.merge(this.jsonIn, this.jsonOut);
            }
            else
                this.formattedJson = JSON.stringify(parsedJson, null, 2);
            this.error = '';
            // this.dispatchEvent(new CustomEvent('paste', {
            //     bubbles: true, 
            //     composed: true,
            //     detail: this.formattedJson
            //   }));
        } catch (error) {
            console.log('error ', JSON.stringify(error, null, 2));
            this.error = "Invalid JSON";
        }
    }

    merge(jsonIn, jsonOut) {
        this.reset();

        const mergedData = {};
        const mergedKeys = [];
        console.log('jsonIn ',JSON.stringify(jsonIn, null, 2));
        console.log('jsonOut ',JSON.stringify(jsonOut, null, 2));

        const inboundKeys = this.getFlatKeys(jsonIn);
        const outboundKeys = this.getFlatKeys(jsonOut);
        console.log('inboundKeys ',JSON.stringify(inboundKeys, null, 2));
        console.log('outboundKeys ',JSON.stringify(outboundKeys, null, 2));

        const combinedList = [ ...inboundKeys, ...outboundKeys ];
        console.log('combinedList ',JSON.stringify(combinedList, null, 2));

        // Convert merged object to JSON string
        const mergedJson = this.mergeObjects(jsonIn, jsonOut);
        console.log('mergedJson ', JSON.stringify(mergedJson , null, 2));
        this.formattedJson = JSON.stringify(mergedJson , null, 2);
    
        // combinedList = [1,2,3,3,2,3,3,4];
        // mergedKeys = this.removeDuplicates([1,2,2,3]);
        // console.log(' mergedKeys ', JSON.stringify(mergedKeys, null, 2));  
        //TODO - Unable to remove duplicates


        for (let key of combinedList) {
            console.log(`Key '${key}' `);
            let obj = {};
            if (inboundKeys.includes(key) && outboundKeys.includes(key)) {
                console.log(`Key '${key}' belongs to both inbound and outbound JSON.`);
                obj[key] = 'TWOWAY';
            } else if (inboundKeys.includes(key)) {
                console.log(`Key '${key}' belongs to inbound JSON.`);
                
                obj[key] = 'INBOUND';
            } else if (outboundKeys.includes(key)){
                console.log(`Key '${key}' belongs to outbound JSON.`);

                obj[key] = 'OUTBOUND';
            }
            if (!this.isObjectEmpty(obj)) {
                this.mergedKeyTypes = Object.assign({}, this.mergedKeyTypes, obj);
            }
        }

        console.log('this.mergedKeyTypes ', JSON.stringify(this.mergedKeyTypes, null, 2));
    }

    removeDuplicates(arr) {
        // return arr.filter((item,
        //     index) => arr.indexOf(item) === index);
        return [ ...new Set(arr) ];
    }

    reset() {
        this.formattedJson = {};
    }

    getFlatKeys(obj, prefix = '') {
        let keys = [];
      
        for (let key in obj) {
            if (obj.hasOwnProperty(key)) {
                const prefixedKey = prefix ? `${prefix}.${key}` : key;
            
                if (typeof obj[key] === 'object' && !Array.isArray(obj[key])) {
                    const nestedKeys = getFlatKeys(obj[key], prefixedKey);
                    keys = [...keys, ...nestedKeys];
                } else {
                    keys.push(prefixedKey);
                }
            }
        }
      
        return keys;
    }

    mergeObjects(obj1, obj2) {
        for (let key in obj2) {
            if (obj2.hasOwnProperty(key)) {
                if (obj1.hasOwnProperty(key) && typeof obj1[key] === 'object' && typeof obj2[key] === 'object') {
                    mergeObjects(obj1[key], obj2[key]); // Recursively merge nested objects
                } else {
                    obj1[key] = obj2[key]; // Merge non-nested properties
                }
            }
        }
        return obj1;
    }
            

    isObjectEmpty(obj) {
        return Object.keys(obj).length === 0;
    }
}