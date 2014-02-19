@isTest
private class zAccountTriggerHandlerTest {
    
    @isTest static void test_update() {
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        insert zacct;
        acct.X2013_Vertical__c = 'update';
        update acct;
    }
    
    @isTest static void test_exception() {
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        insert zacct;
        acct.X2013_Vertical__c = 'exception';
        update acct;
    }

    @isTest static void test_exception1() {
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        insert zacct;
        acct.X2013_Vertical__c = 'exception1';
        update acct;
    }
}