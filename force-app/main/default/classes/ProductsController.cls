public with sharing class ProductsController {
    //To return initial account records
    @AuraEnabled
    public static ProductWrapper getProductRecords(Integer initialRows) {
        ProductWrapper productWrapper = new ProductWrapper();
        try {
            productWrapper.productsList = [SELECT Id, Name, ProductCode, Description, IsActive, DisplayUrl, Family, QuantityUnitOfMeasure, StockKeepingUnit, ExternalDataSourceId, ExternalId FROM Product2 ORDER BY Name ASC LIMIT: initialRows OFFSET 0];
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
        return [SELECT Id, Name, ProductCode, Description, IsActive, DisplayUrl, Family, QuantityUnitOfMeasure, StockKeepingUnit, ExternalDataSourceId, ExternalId FROM Product2 ORDER BY Name ASC LIMIT: rowLimit OFFSET: rowOffset];
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
}