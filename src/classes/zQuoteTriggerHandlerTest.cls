@isTest(SeeAllData=TRUE)
private class zQuoteTriggerHandlerTest {
    
    @isTest static void test_method_one() {
        Account acct = Z_TestFactory.makeAccount();
        Contact contc = Z_TestFactory.makeContact(acct);
        Opportunity opp = Z_TestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = Z_TestFactory.makeQuote(opp);

        quote.zqu__Status__c='Sent to Z-Billing';
        update quote;
    }
    
    @isTest static void test_method_two() {
        Account acct = Z_TestFactory.makeAccount();
        Contact contc = Z_TestFactory.makeContact(acct);
        Opportunity opp = Z_TestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = Z_TestFactory.makeQuote(opp);

        quote.zqu__Status__c='Sent to Z-Billing';
        acct.X2013_Vertical__c = 'exception';
        update acct;
        update quote;
    }

    @isTest static void test_method_three() {
        Account acct = Z_TestFactory.makeAccount();
        Contact contc = Z_TestFactory.makeContact(acct);
        Opportunity opp = Z_TestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = Z_TestFactory.makeQuote(opp);

        quote.zqu__Status__c='Sent to Z-Billing';
        acct.X2013_Vertical__c = 'exception1';
        update acct;
        update quote;
    }
    
}