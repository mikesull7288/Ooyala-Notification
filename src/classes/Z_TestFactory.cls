@isTest
public class Z_TestFactory {

    /**
     * Insert a test account in the db
     */
    public static Account makeAccount() {
        
        Account testAcc = new Account();
        
        testAcc.Name = 'my test account';
        testAcc.X2013_Vertical__c = 'test';
        testAcc.Backlot_Account_ID__c = '123';
        // testAcc.AdditionalBacklotIDs__c = '456';
        // testAcc.Zuora__CustomerServiceRepName__c = 'Mr. Nice Guy';
        // testAcc.Zuora__SalesRepName__c = 'Sir Salesalot';
        
        insert testAcc;
        return testAcc;
    }
    
    
    /**
     * Insert a test contact associated with an account in the db
     */
    public static Contact makeContact(Account testAcc) {
        
        Contact testContact = new Contact();
        
        testContact.FirstName = 'firstname';
        testContact.LastName = 'lastname';
        testContact.Email = 'email@mail.me';
        testContact.Phone = '(555) 101-1000';
        
        testContact.AccountId = testAcc.Id;
        
        insert testContact;
        return testContact;
    }
    
    
    /**
     * Insert a test opportunity associated with an account
     */
    public static Opportunity makeOpportunity(Account testAcc) {
        
        Opportunity testOpp = new Opportunity();
        
        testOpp.Name = 'my test opportunity';
        testOpp.StageName = 'Closed Won';
        testOpp.CloseDate = System.today();
        
        testOpp.AccountId = testAcc.Id;
        
        /*
         * Ooyala Custom Fields
         */
        testOpp.Est_Monthly_Revenue__c = 100.00;
        testOpp.CMRR_Technical_Support__c = 100.00;
        
        insert testOpp;
        return testOpp;
    }
    
    
    /**
     * Insert a test quote based on an opportunity in the db
     */
    public static zqu__Quote__c makeQuote(Opportunity testOpp) {
        
        zqu__Quote__c testQuote = new zqu__Quote__c();
        
        testQuote.Name = 'my test quote';
        testQuote.zqu__ZuoraAccountID__c = 'Zuora-000123';
        
        testQuote.zqu__Opportunity__c = testOpp.Id;
        
        insert testQuote;
        return testQuote;
    }
    
    
    /**
     *  Insert a Zuora billing account
     */
    public static Zuora__CustomerAccount__c makeZAccount(Account acc) {
        
        Zuora__CustomerAccount__c zacc = new Zuora__CustomerAccount__c();
        
        zacc.Zuora__Account__c = acc.Id;
        zacc.Zuora__AccountNumber__c = 'Zuora-000123';
        zacc.Zuora__BillToId__c = '1234567890';
        zacc.Zuora__SoldToId__c = '2345678901';
        zacc.Zuora__Zuora_Id__c = 'TESTbillAcct-00001';
        zacc.Zuora__Status__c = 'Active';

//      zacc.test__c = acc.test__c;
        zacc.Vertical__c = acc.X2013_Vertical__c;
        zacc.BacklotID__c = acc.Backlot_Account_ID__c;
        
        //insert zacc;
        return zacc;
    }
    
    /**
     * create a Invocie
     */
    public static Zuora__ZInvoice__c makeZInvoice(Account acc, Zuora__CustomerAccount__c billAcc) {
        Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();

        inv.Zuora__Account__c = acc.Id;
        inv.Zuora__BillingAccount__c = billAcc.Id;
        inv.Zuora__Balance2__c = 100.00;
        inv.Zuora__DueDate__c = date.newInstance(1960, 2, 17);

        // insert inv
        return inv;
    }
    
    
    /**
     * Create a test Zuora__SubscriptionProductCharge__c
     */
    public static Zuora__SubscriptionProductCharge__c makeSubProdCharge() {

        Zuora__SubscriptionProductCharge__c charge = new Zuora__SubscriptionProductCharge__c();
        //Number_of_Period__c, Total_Included_Units__c, Zuora__ChargeNumber__c, Zuora__Quantity__c, Zuora__Subscription__c, Zuora__Zuora_Id__c, Zuora__Type__c
        charge.Number_of_Period__c = null;
        charge.Total_Included_Units__c = null;
        charge.Zuora__Type__c = 'Usage';
        charge.Zuora__ChargeNumber__c = 'test-123';
        charge.Zuora__RatePlanName__c = 'Month';
        charge.Zuora__Zuora_Id__c = 'ZTESTcharge-11111111';

        return charge;

    }

}