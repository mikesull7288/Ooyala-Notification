@isTest
private class zCustomerAccountTriggerHandlerTest {
    
    @isTest static void test_update() {
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        insert zacct;
        zacct.vertical__c = 'update';
        update zacct;
    }
    
    @isTest static void test_exception() {
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        insert zacct;
        zacct.vertical__c = 'exception';
        update zacct;
    }

    @isTest static void test_exception1() {
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        insert zacct;
        zacct.vertical__c = 'exception1';
        update zacct;
    }
    
    @isTest static void test_unDunning() {
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        insert zacct;
        Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
        insert testInv;

        zacct.isDunning__c = true;
        update zacct;
        zacct.isDunning__c = false;
        update zacct;
    }
    
}