public with sharing class PMA_ProductsController {
    private static TransactionService txnService = new TransactionService();
    //To create Order Item records
    @AuraEnabled
    public static Order__c createOrderItems(Id orderId, String selectedProductsValues) {
        Order__c checkOrderStatus = PMA_SearchController.getOrderDetailsByIdOrUUID(orderId);
        System.debug('checkOrderStatus  ' + checkOrderStatus);
        List < Order_Item__c > orderItemList = new List < Order_Item__c > ();
        Id productVendorId;
        Integer i = 1;
        System.debug('selectedProductsValues ' + selectedProductsValues);
        List < SelectedProductWrapper > prodWrapperList = (List < SelectedProductWrapper > ) JSON.deserialize(selectedProductsValues, List < SelectedProductWrapper > .class);
        for (SelectedProductWrapper selectedProduct: prodWrapperList) {
            Order_Item__c orderItemNew = new Order_Item__c();
            orderItemNew.Order__c = orderId;
            orderItemNew.Item_Status__c = 'New';
            orderItemNew.Product__c = selectedProduct.product.Id;
            orderItemNew.Quantity__c = selectedProduct.quantity;
            orderItemList.add(orderItemNew);
            if(i == 1){
                productVendorId = selectedProduct.product.Contact__c;    
            }
            i++;
        }
        System.debug('orderItemList  ' + orderItemList);
        insert orderItemList;

        if (( (checkOrderStatus.Vendor__c == null) && (productVendorId != null) ) || (checkOrderStatus.Status__c == 'Draft') ) {
            if ( (checkOrderStatus.Vendor__c == null) && (productVendorId != null) ) {
                checkOrderStatus.Vendor__c = productVendorId;
            }
            if (checkOrderStatus.Status__c == 'Draft') {
                checkOrderStatus.Status__c = 'Active';
            }
            update checkOrderStatus;
        }

        Order__c currentOrder = PMA_SearchController.getOrderDetailsByIdOrUUID(orderId);
        System.debug('currentOrder  ' + currentOrder);
        return currentOrder;
    }
    //To create Payment Intent and Transaction Record
    @AuraEnabled
    public static String createPaymentRecords(Id orderId) {
            Order__c order = new Order__c();
            Payment_Gateway__c pmasandBox = new Payment_Gateway__c();
            Transaction__c gettxn = new Transaction__c();
           
            order = [SELECT Id,Name,Account__c,Account__r.Name,Member__c,Member__r.Name,Member__r.Email,Order_Type__c,Status__c,Vendor__c,Total_Price__c,UUID__c,CreatedDate,LastModifiedDate,OwnerId,
                    (SELECT Id,Name,Line_Total_Price__c,List_Price__c,Order__c,Product__c,Quantity__c,Total_Price__c,CreatedDate,LastModifiedDate FROM Order_Items__r)
                    FROM Order__c
                    WHERE Id =:orderId AND (Order_Type__c = 'POS') AND (Status__c = 'Active' )];
            System.debug('currentOrder  ' + order);       

            pmasandBox = [SELECT Id,Name,Access_Token__c,Gateway_Public_Key__c,Test_Mode__c FROM Payment_Gateway__c LIMIT 1];
            System.debug( 'pmasandBox ' + pmasandBox);

            //Payment Intent Init
            Date firstChargeDate = System.TODAY();
            String frequency = 'single';
            String paymentType = 'immediate';
            Id accountId = order.Account__c;
            Id contactId = order.Member__c;
            Id opportunityId = null;
            Double amount = order.Total_Price__c;
            String email = order.Member__r.Email;
            String paymentName = 'Payment for '+order.Account__r.Name+' Services Rendered by ' + order.Member__r.Name;
            Id paymentGatewayId = pmasandBox.Id;
            Payment_Intent__c payreq = PaymentIntentService.createNewPaymentIntent(paymentName , paymentGatewayId , contactId, accountId, opportunityId, orderId, paymentType, amount, email, frequency, firstChargeDate);
            if (payreq.Id != null) {
                Payment_Intent__c intent = [SELECT Id,Name,
                                Payment_Gateway__c,
                                Payment_Gateway__r.Name,
                                Payment_Gateway__r.Gateway_Public_Key__c,
                                Payment_Gateway__r.Test_Mode__c,
                                Account__c,
                                Account__r.Name,
                                Contact__c,
                                Contact__r.Name,
                                Contact__r.LastName,
                                Contact__r.FirstName,
                                Contact__r.Phone_Number__c,
                                Contact__r.Email,
                                Opportunity__c,
                                Opportunity__r.Name,
                                Order__c,
                                Order__r.Name,
                                Amount__c,
                                Frequency__c,
                                Currency_Code__c,Email__c,First_Charge_Date__c,Payment_Link__c,
                                Payment_Reference_Id__c,Payment_Type__c,Status__c,UUID__c FROM Payment_Intent__c WHERE ( Id =:payreq.Id ) AND (Status__c !='payment_done') ];
                System.debug('Inserted Payment Intent Record ' + intent );
               
                Transaction__c tx = new Transaction__c();
                // tx.UUID__c = SYS_Helper.getUUID();
                tx.Name = intent.Name; 
                tx.Description__c = intent.Account__r.Name + ' Services Rendered';           
                tx.Status__c = 'initiated';
                tx.Amount__c = intent.Amount__c;
                tx.CurrencyCode__c = intent.Currency_Code__c;
                tx.Payment_Intent__c = intent.Id;
                tx.TransactionDate__c = Datetime.now();
                tx.Account__c = intent.Account__c;
                tx.Contact__c = intent.Contact__c;
                
                insert tx;
             return tx.Id;
            }else {
                SYS_IntegrationLog__c errorLog = new SYS_IntegrationLog__c();
                System.debug('DML Error in Creation of Payment Intent: ');
                //Generate a Log record
                errorLog.data0__c = 'PMA_ProductsControlle:-createPaymentRecords() :: Exception Type: Error in Creation of Payment Intent';
                errorLog.Type__c = 'RESPONSE';
                errorLog.Status__c = 'ERROR';
                errorLog.How_To_Process__c = 'ignore_log';
                insert errorLog;
            }
        
       return null;
    }
    //To Return Transaction Details
    @AuraEnabled
    public static Transaction__c getTransactionDetails(Id txId) {
        Transaction__c txn = txnService.getTransaction(txId);
        return txn;
    }

    //To return initial records
    @AuraEnabled
    public static Map <Id, SelectedProductWrapper > getAllProductRecords( String orderIdOrUUID ) {
        List < Product__c > productsList = new List < Product__c >();
        Map <Id, SelectedProductWrapper > mapProductsList = new Map <Id, SelectedProductWrapper >();
        Order__c currentOrder = PMA_SearchController.getOrderDetailsByIdOrUUID( orderIdOrUUID );
        Decimal memberAge = currentOrder.Member__r.Age__c;
        try {
            //TODO  - change query from PBE instead of product
           // productsList = Database.query('SELECT '+ SYS_Helper.getAllFieldsFor('Product__c') + '\')');
           
            productsList = [SELECT Id,Name,Unit_Price__c,Account__c,Account__r.Name,Active__c,Contact__c, Minimum_Age__c, Special_Minimum_Age__c, Special_Status__c,Display_URL__c,External_ID__c,Product_Code__c,Product_Description__c,Product_Family__c,Product_SKU__c,Quantity_Unit_Of_Measure__c,SystemModstamp,OwnerId,CreatedById,CreatedDate,IsDeleted,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate FROM Product__c WHERE Product_Family__c = 'POS' ORDER BY Name ASC];
           
            for( Product__c prod: productsList){
                String recordPictureURL = ImageController.getSysTrackRecordPictureURL(prod.Id);
                System.debug('Prod Name ' + prod.Name + ' recordPictureURL '+ recordPictureURL);
                Decimal prodAge = ( prod.Special_Status__c == true ) ? ( prod.Special_Minimum_Age__c ) :  (prod.Minimum_Age__c);
                Boolean prodVisible = ( ( prodAge == null ) || ( prodAge <= memberAge) ) ? true : false;                
                SelectedProductWrapper selectedproduct = new SelectedProductWrapper();
                selectedproduct.product = prod;
                selectedproduct.quantity = 1;
                selectedproduct.isVisible = prodVisible;
                selectedproduct.prodMinimumAge = prodAge;
                selectedproduct.shortNameCode = ImageController.getShortendImageName(prod.Name);
                selectedproduct.hasPictureURL = (recordPictureURL=='noimage') ? false : true;
                selectedproduct.pictureURL = recordPictureURL;
                mapProductsList.put(prod.Id, selectedproduct);
            }
        } catch (Exception e) {
            //TODO add  to wrapper to pmaexception wrapper(class,method ,exception) and insert into log
            System.debug('Got Exception: ' + e.getMessage());
        }
        return mapProductsList;
    }
    @AuraEnabled
    public static Order__c getOrderDetails( String orderIdOrUUID ){
        Order__c currentOrder = PMA_SearchController.getOrderDetailsByIdOrUUID( orderIdOrUUID );
        return currentOrder;
    }
    @AuraEnabled
    public static User fetchCurrentUser() {
        // query current user information  
        User currentUserRecord = PMA_SearchController.fetchCurrentUser();

        return currentUserRecord;
    }
    // wrapper class selectedProduct.PricebookEntries[0].UnitPrice
    public class SelectedProductWrapper {
        @AuraEnabled
        public Integer quantity = 0;
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
        public Boolean isVisible;
        @AuraEnabled
        public Decimal prodMinimumAge;
        @AuraEnabled
        public String orderNotes;
        @AuraEnabled
        public String shortNameCode;
        @AuraEnabled
        public Boolean hasPictureURL = false;
        @AuraEnabled
        public String pictureURL;
    }
}