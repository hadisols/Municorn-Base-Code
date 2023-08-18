import { api, track, wire} from 'lwc';
import LightningModal from 'lightning/modal';

import getPicklistValues from '@salesforce/apex/SYS_FieldMapperController.getPicklistValues';

export default class FieldLayout extends LightningModal {
    @api objectWrapper;
    @track activeSections = ["G","I","O"];
    @track directionOptions = [];
    @track levelOptions = [];
    @track dateTimeOptions = [];

    developername ;
    label ;
    Direction ;
    FieldApiName ;
    Field_Mapping_Handler ;
    Is_Active ;
    Key ;
    ObjectApiName ;
    ObjectSetting ;
    Skip_Field_Setting ;
    StaticValue ;

    Key_For_Events ;
    RestResource ;
    Is_External_Field ;
    Is_Lookup ;
    Lookup_Object_API_Name ;
    Datetime_Conversion_Format ;
    Get_value_from_Log ;
    Log_API_for_field_mapping ;
    Lookup_External_Key ;

    Mapping_is_for ;
    Level ;
    Send_Blanks_as_Empty_String ;
    ChildRootElement ;
    ParentField ;


    fieldSettingApiName = 'FieldSetting__mdt';
    directionFieldApiName = 'Direction__c';
    levelFieldApiName = 'Level__c';
    dateTimeFieldApiName = 'Datetime_Conversion_Format__c';

    @wire(getPicklistValues, { objectName : '$fieldSettingApiName', fieldName : '$directionFieldApiName' })
    directionPicklistValues({ data, error }) {
        if(data) {
            this.directionOptions = data.map((value) => ({
                label: value,
                value: value
            }));
            console.log('picklist ', JSON.stringify(this.directionOptions));
        } else if (error) {
            console.log('error while fetching picklist ', error);
        }
    }

    @wire(getPicklistValues, { objectName : '$fieldSettingApiName', fieldName : '$levelFieldApiName' })
    levelPicklistValues({ data, error }) {
        if(data) {
            this.levelOptions = data.map((value) => ({
                label: value,
                value: value
            }));
            console.log('levelOptions picklist ', JSON.stringify(this.levelOptions));
        } else if (error) {
            console.log('error while fetching picklist ', error);
        }
    }

    @wire(getPicklistValues, { objectName : '$fieldSettingApiName', fieldName : '$dateTimeFieldApiName' })
    dateTimePicklistValues({ data, error }) {
        if(data) {
            this.dateTimeOptions = data.map((value) => ({
                label: value,
                value: value
            }));
            console.log('picklist directionOptions ', JSON.stringify(this.directionOptions));
        } else if (error) {
            console.log('error while fetching picklist ', error);
        }
    }

    connectedCallback() {
        if(this.objectWrapper) {
            this.developername = this.objectWrapper.developername;
            this.label = this.objectWrapper.label;
            this.Direction = this.objectWrapper.Direction;
            this.FieldApiName = this.objectWrapper.FieldApiName;
            this.Field_Mapping_Handler = this.objectWrapper.Field_Mapping_Handler;
            this.Is_Active = this.objectWrapper.Is_Active;
            console.log('Is_Active ',this.Is_Active);
            this.Key = this.objectWrapper.Key;
            this.ObjectApiName = this.objectWrapper.ObjectApiName;
            this.ObjectSetting = this.objectWrapper.ObjectSetting;
            this.Skip_Field_Setting = this.objectWrapper.Skip_Field_Setting;
            this.StaticValue = this.objectWrapper.StaticValue;
            this.Key_For_Events = this.objectWrapper.Key_For_Events;
            this.RestResource = this.objectWrapper.RestResource;
            this.Is_External_Field = this.objectWrapper.Is_External_Field;
            this.Is_Lookup = this.objectWrapper.Is_Lookup;
            this.Lookup_Object_API_Name = this.objectWrapper.Lookup_Object_API_Name;
            this.Datetime_Conversion_Format = this.objectWrapper.Datetime_Conversion_Format;
            this.Get_value_from_Log = this.objectWrapper.Get_value_from_Log;
            this.Log_API_for_field_mapping = this.objectWrapper.Log_API_for_field_mapping;
            this.Lookup_External_Key = this.objectWrapper.Lookup_External_Key;
            this.Mapping_is_for = this.objectWrapper.Mapping_is_for;
            this.Level = this.objectWrapper.Level;
            this.Send_Blanks_as_Empty_String = this.objectWrapper.Send_Blanks_as_Empty_String;
            this.ChildRootElement = this.objectWrapper.ChildRootElement;
            this.ParentField = this.objectWrapper.ParentField;
        }
    }

    handleLabelChange(event) {
        this.label = event.detail.value;
        try{
            this.objectWrapper = {...this.objectWrapper, label : this.label};
        } catch(e) {
            console.log(' error ', e);
        }
    }

    handleDirectionChange() {
        this.Direction = event.detail.value;
        this.objectWrapper = {...this.objectWrapper, Direction : this.Direction};
    }

    handleDevelopernameChange(event) {
        this.developername = event.detail.value;
        this.objectWrapper = {...this.objectWrapper, developername : this.developername};
    }

    handleOSChange(event) {
        this.ObjectSetting = event.detail.value;
        this.objectWrapper = {...this.objectWrapper, ObjectSetting : this.ObjectSetting};
    }

    handleActiveChange(event) {
        this.Is_Active = event.detail.checked;
        this.objectWrapper = {...this.objectWrapper, Is_Active : this.Is_Active};
    }

    handleApexHandlerChange(event) {
        this.Field_Mapping_Handler = event.detail.value;
        this.objectWrapper = {...this.objectWrapper, Field_Mapping_Handler : this.Field_Mapping_Handler};
    }

    handleSkipFSChange(event) {
        this.Skip_Field_Setting = event.detail.checked;
        this.objectWrapper = {...this.objectWrapper, Skip_Field_Setting : this.Skip_Field_Setting};
    }

    handleObjApiNameChange(event) {
        this.ObjectApiName = event.detail.value;
        this.objectWrapper = {...this.objectWrapper, ObjectApiName : this.ObjectApiName};
    }

    handleKeyChange(event) {
        this.Key = event.detail.value;
        this.objectWrapper = {...this.objectWrapper, Key : this.Key};
    }

    handleFieldApiNameChange(event) {
        this.FieldApiName = event.detail.value;
        this.objectWrapper = {...this.objectWrapper, FieldApiName : this.FieldApiName};
    }

    handleStaticValueChange(event) {
        this.StaticValue = event.detail.value;
        this.objectWrapper = {...this.objectWrapper, StaticValue : this.StaticValue};
    }

    handleKeyForEventChange(event) {
        this.Key_For_Events = event.detail.value;
        this.objectWrapper = {...this.objectWrapper, Key_For_Events : this.Key_For_Events};
    }

    handleRestResourceChange(event) {
        this.RestResource = event.detail.value;
        this.objectWrapper = {...this.objectWrapper, RestResource : this.RestResource};
    }

    handleIsExtFieldChange(event) {
        this.Is_External_Field = event.detail.checked;
        this.objectWrapper = {...this.objectWrapper, Is_External_Field : this.Is_External_Field};
    }

    handleIsLookUpChange(event) {
        this.Is_Lookup = event.detail.checked;
        this.objectWrapper = {...this.objectWrapper, Is_Lookup : this.Is_Lookup};
    }

    handleLookUpApiNameChange(event) {
        this.Lookup_Object_API_Name = event.detail.value;
        this.objectWrapper = {...this.objectWrapper, Lookup_Object_API_Name : this.Lookup_Object_API_Name};
    }

    handleDateTimeChange(event) {
        this.Datetime_Conversion_Format = event.detail.value;
        this.objectWrapper = {...this.objectWrapper, Datetime_Conversion_Format : this.Datetime_Conversion_Format};
    }

    handleFromLogChange(event) {
        this.Get_value_from_Log = event.detail.checked;
        this.objectWrapper = {...this.objectWrapper, Get_value_from_Log : this.Get_value_from_Log};
    }

    handleLgApiNameChange(event) {
        this.Log_API_for_field_mapping = event.detail.value;
        this.objectWrapper = {...this.objectWrapper, Log_API_for_field_mapping : this.Log_API_for_field_mapping};
    }

    handleLookUpExtKeyChange(event) {
        this.Lookup_External_Key = event.detail.value;
        this.objectWrapper = {...this.objectWrapper, Lookup_External_Key : this.Lookup_External_Key};
    }

    handleMapForChange(event) {
        this.Mapping_is_for = event.detail.value;
        this.objectWrapper = {...this.objectWrapper, Mapping_is_for : this.Mapping_is_for};
    }

    handleLevelChange(event) {
        this.Level = event.detail.value;
        this.objectWrapper = {...this.objectWrapper, Level : this.Level};   
    }

    handleIsEmptyChange(event) {
        this.Send_Blanks_as_Empty_String = event.detail.checked;
        this.objectWrapper = {...this.objectWrapper, Send_Blanks_as_Empty_String : this.Send_Blanks_as_Empty_String};   
    }

    handleChildRootElementChange(event) {
        this.ChildRootElement = event.detail.value;
        this.objectWrapper = {...this.objectWrapper, ChildRootElement : this.ChildRootElement};   
    }

    handleParentFieldChange(event) {
        this.ParentField = event.detail.value;
        this.objectWrapper = {...this.objectWrapper, ParentField : this.ParentField};   
    }

    handleSave() {
        //event to push to parent
        this.dispatchEvent(new CustomEvent('save', {
            bubbles: true, 
            composed: true,
            detail: this.objectWrapper
          }));
        console.log('close ', JSON.stringify(this.objectWrapper, null, 2));
        this.close(this.objectWrapper);
    }

    handleReset() {
        //reset the object
    }

    
}