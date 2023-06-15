import { LightningElement, track } from "lwc";

export default class JsonViewer extends LightningElement {
    @track formattedJson;

    handleInputChange(event) {
        const inputJson = event.target.value;
        try {
            const parsedJson = JSON.parse(inputJson);
            this.formattedJson = JSON.stringify(parsedJson, null, 2);
            this.dispatchEvent(new CustomEvent('paste', {
                bubbles: true, 
                composed: true,
                detail: this.formattedJson
              }));
        } catch (error) {
            this.formattedJson = "Invalid JSON";
        }
    }
}
