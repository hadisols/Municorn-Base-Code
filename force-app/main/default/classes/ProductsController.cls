public with sharing class ProductsController {
    //To return initial records
    @AuraEnabled
    public static Map <Id, SelectedProductWrapper > getAllProductRecords() {
        List < Product2 > productsList = new List < Product2 >();
        Map <Id, SelectedProductWrapper > mapProductsList = new Map <Id, SelectedProductWrapper >();
        try {
            //TODO  - change query from PBE instead of product
            productsList = [SELECT Id, Name, ProductCode, Description, IsActive, DisplayUrl, Family, QuantityUnitOfMeasure, StockKeepingUnit, ExternalDataSourceId, ExternalId,(SELECT id, UnitPrice FROM PricebookEntries order by createddate DESC LIMIT 1) FROM Product2 ORDER BY Name ASC];
            for( Product2 prod: productsList){
                SelectedProductWrapper selectedproduct = new SelectedProductWrapper();
                selectedproduct.product=prod;
                selectedproduct.quantity=1;
                mapProductsList.put(prod.Id, selectedproduct);
            }
        } catch (Exception e) {
            //TODO add  to wrapper to pmaexception wrapper(class,method ,exception) and insert into log
            System.debug('Got Exception: ' + e.getMessage());
        }
        return mapProductsList;
    }
/* 
    @AuraEnabled
    public static ProductWrapper getProductRecords(Integer initialRows) {
        ProductWrapper productWrapper = new ProductWrapper();
        try {
            productWrapper.productsList = [SELECT Id, Name, ProductCode, Description, IsActive, DisplayUrl, Family, QuantityUnitOfMeasure, StockKeepingUnit, ExternalDataSourceId, ExternalId,(SELECT id, UnitPrice FROM PricebookEntries order by createddate DESC LIMIT 1) FROM Product2 ORDER BY Name ASC LIMIT: initialRows OFFSET 0];
            productWrapper.totalRecords = [SELECT COUNT() FROM Product2];
            productWrapper.message = 'Product records are loaded';
            productWrapper.success = true;
        } catch (Exception e) {
            productWrapper.message = e.getMessage();
            productWrapper.success = false;
        }
        return productWrapper;
    }

    //To return additional records based on offset
    @AuraEnabled
    public static List < Product2 > loadProductRecords(Integer rowLimit, Integer rowOffset) {
        return [SELECT Id, Name, ProductCode, Description, IsActive, DisplayUrl, Family, QuantityUnitOfMeasure, StockKeepingUnit, ExternalDataSourceId, ExternalId,(SELECT id, UnitPrice FROM PricebookEntries order by createddate DESC LIMIT 1) FROM Product2 ORDER BY Name ASC LIMIT: rowLimit OFFSET: rowOffset];
    } */
    //To return initial Empty Cart
    /*
    @AuraEnabled
    public static Map <Id, SelectedProductWrapper > getselectedProductsMap() {
        Map <Id, SelectedProductWrapper > selectedproductWrapperMap = new Map <Id, SelectedProductWrapper >();
        return selectedproductWrapperMap;
    }
    @AuraEnabled
    public static Map <Id, SelectedProductWrapper > getselectedProductbyIdMap(Id prodId) {
        Map <Id, SelectedProductWrapper > selectedproductWrapperMap = new Map <Id, SelectedProductWrapper >();
        SelectedProductWrapper selectedproduct = new SelectedProductWrapper();
        selectedproduct.product=[SELECT Id, Name, ProductCode, Description, IsActive, DisplayUrl, Family, QuantityUnitOfMeasure, StockKeepingUnit, ExternalDataSourceId, ExternalId,(SELECT id, UnitPrice FROM PricebookEntries order by createddate DESC LIMIT 1) FROM Product2 WHERE Id =: prodId];
        selectedproduct.quantity=1;
        Double pp = selectedproduct.productPrice;
        Double ptp = selectedproduct.totalProductPrice;
        selectedproductWrapperMap.put(prodId, selectedproduct);
        System.debug('selectedproduct: '+ selectedproduct);
        System.debug('selectedproductWrapperMap.keySet(): '+ selectedproductWrapperMap.keySet());
        System.debug('selectedproductWrapperMap: '+ selectedproductWrapperMap);
        System.debug('selectedproductWrapperMap.selectedproduct.product: '+ selectedproduct.product.PricebookEntries[0].UnitPrice);
        System.debug('selectedproductWrapperMap.Id: '+ selectedproductWrapperMap.get(prodId));
        return selectedproductWrapperMap;
    }

    @AuraEnabled
    public static List < SelectedProductWrapper > getselectedProducts() {
        List < SelectedProductWrapper > selectedproductWrapper = new List < SelectedProductWrapper >();
        return selectedproductWrapper;
    }
    @AuraEnabled
    public static SelectedProductWrapper getselectedProductbyId(Id prodId) {
        SelectedProductWrapper selectedproduct = new SelectedProductWrapper();
        selectedproduct.product=[SELECT Id, Name, ProductCode, Description, IsActive, DisplayUrl, Family, QuantityUnitOfMeasure, StockKeepingUnit, ExternalDataSourceId, ExternalId,(SELECT id, UnitPrice FROM PricebookEntries order by createddate DESC LIMIT 1) FROM Product2 WHERE Id =: prodId];
        selectedproduct.quantity=1;
        return selectedproduct;
    }
   
    // wrapper class
    public class ProductWrapper {
        @AuraEnabled
        public Integer totalRecords = 0;
        @AuraEnabled
        public List < Product2 > productsList = new List < Product2 > ();
        @AuraEnabled 
        public String message;
        @AuraEnabled
        public Boolean success;
    }
     */

    // wrapper class selectedProduct.PricebookEntries[0].UnitPrice
    public class SelectedProductWrapper {
        @AuraEnabled
        public Integer quantity;
        @AuraEnabled
        public Product2 product = new Product2 ();
        @AuraEnabled
        public Double productPrice{
            get { return (product != null) ? product.PricebookEntries[0].UnitPrice : 0; }
        }
        @AuraEnabled
        public Double totalProductPrice{
            get { return (productPrice != null) ? productPrice * quantity : 0; }
        }
    }
}