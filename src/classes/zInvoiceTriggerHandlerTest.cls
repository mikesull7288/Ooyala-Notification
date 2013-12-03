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
        
        
    }//*/
    
    @isTest static void test_CustomerAccount_isDunning() {
        // Implement test code
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        insert zacct;
        zacct.isDunning__c = true;
        update zacct;
        Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
        insert testInv;
        
        
    }
    
    @isTest static void test_Invoice_ZeroBalance() {
        // Implement test code
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        insert zacct;
        update zacct;
        Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
        testInv.Zuora__Balance2__c = 0;
        testInv.isDunning__c = true;
        insert testInv;
        
        
    }
    
}