public with sharing class PMA_ProductsController {
    //To return initial records
    @AuraEnabled
    public static Map <Id, SelectedProductWrapper > getAllProductRecords() {
        List < Product__c > productsList = new List < Product__c >();
        Map <Id, SelectedProductWrapper > mapProductsList = new Map <Id, SelectedProductWrapper >();
        try {
            //TODO  - change query from PBE instead of product
           // productsList = Database.query('SELECT '+ SYS_Helper.getAllFieldsFor('Product__c') + '\')');
           
            productsList = [SELECT Id,Name,Unit_Price__c,Account__c,Account__r.Name,Active__c,Contact__c,Display_URL__c,External_ID__c,Product_Code__c,Product_Description__c,Product_Family__c,Product_SKU__c,Quantity_Unit_Of_Measure__c,SystemModstamp,OwnerId,CreatedById,CreatedDate,IsDeleted,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate FROM Product__c WHERE Product_Family__c = 'POS' ORDER BY Name ASC];
            //productsList = [SELECT Id, Name, Unit_Price__c, Account__c, ProductCode, Description, IsActive, DisplayUrl, Family, QuantityUnitOfMeasure, StockKeepingUnit, ExternalDataSourceId, ExternalId FROM Product2 ORDER BY Name ASC];
           
            for( Product__c prod: productsList){
                String recordPictureURL = ImageController.getSysTrackRecordPictureURL(prod.Id);
                System.debug('Prod Name ' + prod.Name + ' recordPictureURL '+ recordPictureURL);
                SelectedProductWrapper selectedproduct = new SelectedProductWrapper();
                selectedproduct.product=prod;
                selectedproduct.quantity=1;
                selectedproduct.pictureURL=recordPictureURL;
                mapProductsList.put(prod.Id, selectedproduct);
            }
        } catch (Exception e) {
            //TODO add  to wrapper to pmaexception wrapper(class,method ,exception) and insert into log
            System.debug('Got Exception: ' + e.getMessage());
        }
        return mapProductsList;
    }
    // wrapper class selectedProduct.PricebookEntries[0].UnitPrice
    public class SelectedProductWrapper {
        @AuraEnabled
        public Integer quantity;
        @AuraEnabled
        public Product__c product = new Product__c ();
        @AuraEnabled
        public Double productPrice{
            get { return (product != null) ? product.Unit_Price__c : 0; }
        }
        @AuraEnabled
        public Double totalProductPrice{
            get { return (productPrice != null) ? productPrice * quantity : 0; }
        }
        @AuraEnabled
        public String pictureURL;
    }
}