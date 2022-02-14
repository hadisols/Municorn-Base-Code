public with sharing class ProductsController {
    //To return initial account records
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
    }
    //To return initial Empty Cart
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
            get { return (product != null) ? productPrice * quantity : 0; }
        }
        @AuraEnabled
        public String message;
        @AuraEnabled
        public Boolean success;
    }
}