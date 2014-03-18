@isTest(SeeAllData=false)
public with sharing class zInvoiceBatchableTest {
    
    private static testmethod void test_ZInvoiceScheduler(){
        
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        String jobId = System.schedule('testBasicScheduledApex', CRON_EXP,new zInvoiceScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger 
                          WHERE id = :jobId];
        // Verify the expressions are the same 
        System.assertEquals(CRON_EXP, ct.CronExpression);
    }
    
    public static testmethod void test_normal_execution() {

        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        zacct.isDunning__c = false;
        insert zacct;
        Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
        testInv.Zuora__DueDate__c = date.today();
        testInv.Zuora__Zuora_Id__c = 'TESTzInv-0001';
        insert testInv;
        
        Test.startTest();
        zInvoiceBatchable nlb = new zInvoiceBatchable();
        Database.executeBatch(nlb); 
        Test.stopTest();

    }    
    
}