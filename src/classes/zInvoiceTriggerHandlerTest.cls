@isTest
private class zInvoiceTriggerHandlerTest {
    
    @isTest static void test_normal_execution() {

        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        insert zacct;
        Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
        insert testInv;

        System.debug('===== MS ===== AFTER INSERT: ['+ [SELECT Bill_To_Email__c, Zuora__Balance2__c, isDunning__c, Zuora__BillingAccount__r.isDunning__c FROM Zuora__ZInvoice__c WHERE Id =: testInv.Id] + ']');
        System.debug('===== MS ===== AFTER INSERT: Zuora Billing Account isDunning: ['+  [SELECT Zuora__BillToWorkEmail__c, isDunning__c, surpressNotifications__c FROM Zuora__CustomerAccount__c WHERE Id = :zacct.id limit 1] +']');

    }
    
    @isTest static void test_surpressNotifications() {
        // Implement test code
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        insert zacct;
        zacct.surpressNotifications__c = true;
        update zacct;
        Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
        insert testInv;
        
        System.assert(zacct.isDunning__c == false, 'Account in dunning!!');
        System.assert(testInv.isDunning__c == false, 'Inv in dunning!!');
        
        
    }
    
    @isTest static void test_CustomerAccount_isDunning() {
        // Implement test code
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        insert zacct;
        zacct.isDunning__c = true;
        update zacct;
        Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
        insert testInv;
        
        System.assert(testInv.isDunning__c == false, 'Test Invoice put in Dunning');
//        testInv.Zuora__Balance2__c = 0;
        
        
    }
    
    
        @isTest static void test_Invoice_to_ZeroBalance() {
        // Implement test code
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        insert zacct;
        //update zacct;
        Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
        insert testInv;
        System.assert(testInv.isDunning__c == true, 'Test Invoice NOT put in Dunning');

        testInv.Zuora__Balance2__c = 0;
        //testInv.isDunning__c = true;
        update testInv;

        System.assert(testInv.isDunning__c == false, 'Test Invoice STILL in Dunning');
        System.assert(zacct.isDunning__c == false, 'Test Account STILL in Dunning');
        
    }
    
    @isTest static void test_Invoice_ZeroBalance() {
        // Implement test code
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        insert zacct;
        update zacct;
        Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
        testInv.Zuora__Balance2__c = 0;
        //testInv.isDunning__c = true;
        insert testInv;
        
        System.assert(zacct.isDunning__c == false, 'Account STILL in dunning!!');
        System.assert(testInv.isDunning__c == false, 'Inv still dunning!!');
        
    }
    
    @isTest static void test_Volume() {
        // Implement test code
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        insert zacct;
        zacct.isDunning__c = true;
        update zacct;
        List<Zuora__ZInvoice__c> testInvList = new List<Zuora__ZInvoice__c>();
        for(Integer i=0;i<=1000;i++){
            Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
            testInvList.add(testInv);
        }
        insert testInvList;
        
        for(Zuora__ZInvoice__c inv : testInvList){
            
            inv.Zuora__Balance2__c = 0;
            inv.isDunning__c = true;
        }
            
        update testInvList;
        
    }
     
    @isTest static void test_Invoice_5_Day_Email_Sent() {
        // Implement test code
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        zacct.isDunning__c = true;
        insert zacct;
        Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
        testInv.Zuora__DueDate__c = Date.today();
        testInv.Zuora__Balance2__c = 10;
        testInv.isDunning__c = true;
        testInv.Dunning_Status__c = 'On Time';
        testInv.Bill_To_Email__c = 'test@test.com';
        testInv.CSM_Owner_Email__c = 'CSM@test.com';
        testInv.Dunning_Status__c = '5 Day Email Sent';
        insert testInv;
        testInv.Dunning_Status__c = '14 Day Email Sent';
        update testInv;
           
    }
    
    @isTest static void test_Invoice_14_Day_Email_Sent() {
        // Implement test code
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        zacct.isDunning__c = true;
        insert zacct;
        Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
        testInv.Zuora__DueDate__c = Date.today();
        testInv.Zuora__Balance2__c = 10;
        testInv.isDunning__c = true;
        testInv.Dunning_Status__c = 'On Time';
        testInv.Bill_To_Email__c = 'test@test.com';
        testInv.CSM_Owner_Email__c = 'CSM@test.com';
        testInv.Dunning_Status__c = '14 Day Email Sent';
        insert testInv;
        testInv.Dunning_Status__c = '21 Day Email Sent';
        update testInv;
           
    }
    
    @isTest static void test_Invoice_21_Day_Email_Sent() {
        // Implement test code
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        zacct.isDunning__c = true;
        insert zacct;
        Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
        testInv.Zuora__DueDate__c = Date.today();
        testInv.Zuora__Balance2__c = 10;
        testInv.isDunning__c = true;
        testInv.Dunning_Status__c = 'On Time';
        testInv.Bill_To_Email__c = 'test@test.com';
        testInv.CSM_Owner_Email__c = 'CSM@test.com';
        testInv.Dunning_Status__c = '21 Day Email Sent';
        insert testInv;
        testInv.Dunning_Status__c = '5 Day Email Sent';
        update testInv;
        
    }
    
}