@isTest(SeeAllData=true)
public with sharing class zUsageBatchableTest {
    
    private static testmethod void test_zUsageScheduler(){
        
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        String jobId = System.schedule('testBasicScheduledApex', CRON_EXP,new zUsageScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger 
                          WHERE id = :jobId];
        // Verify the expressions are the same 
        System.assertEquals(CRON_EXP, ct.CronExpression);
    }
    
    public static testMethod void test_zUsageBatchable_One_Account(){
        
        // Set up test data
        Account testAcct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c billAcct = Z_TestFactory.makeZAccount(testAcct);
        Zuora__SubscriptionProductCharge__c zCharge = Z_TestFactory.makeSubProdCharge();
        Zuora_Usage__c zUsage = new Zuora_Usage__c();
        zUsage.Charge_Number__c = 'test-123';
        zUsage.Quantity__c = 10;
        zUsage.UOM__c = 'Each';
        zUsage.Status__c = 'Processing';
        zUsage.Zuora_ID__c = 'ZTESTusage-11111111';
        zCharge.Zuora__Zuora_Id__c = 'ZTESTcharge-11111111';
        zCharge.Zuora__ChargeNumber__c = 'test-123';
        zCharge.Number_of_Period__c = null;
        zCharge.Zuora__UOM__c = 'Each';
        zCharge.Zuora__Quantity__c = 10;
        
        insert billAcct;
        insert zCharge;
        insert zUsage;

        // run methods in test mode
        Test.startTest();
        zUsageBatchable nlb = new zUsageBatchable();
        Database.executeBatch(nlb); 
        Test.stopTest();    
        
    }

    public static testMethod void test_zUsageBatchable_150_charges(){
        
        List<Zuora__CustomerAccount__c> billAcctLIst = new List<Zuora__CustomerAccount__c>();
        List<Zuora__SubscriptionProductCharge__c> zChargeList = new List<Zuora__SubscriptionProductCharge__c>();
        List<Zuora_Usage__c> zUsageList = new List<Zuora_Usage__c>();
        
        Account testAcct = Z_TestFactory.makeAccount();


        // Set up test data
        for(Integer i = 0; i < 1500; i++){ 
            Zuora__CustomerAccount__c billAcct = Z_TestFactory.makeZAccount(testAcct);
            billAcct.Zuora__Zuora_Id__c = 'TESTbillAcct-' + String.valueOf(i);
            Zuora__SubscriptionProductCharge__c zCharge = Z_TestFactory.makeSubProdCharge();
            
            zCharge.Zuora__ChargeNumber__c = 'test-00' + String.valueOf(i);
            zCharge.Zuora__Zuora_Id__c = 'ZTESTcharge-'+ String.valueOf(i);
            zCharge.Zuora__ChargeNumber__c = '0';
            zCharge.Number_of_Period__c = null;
            zCharge.Zuora__UOM__c = 'Each';
            zCharge.Zuora__Quantity__c = 10;
            
            Zuora_Usage__c zUsage = new Zuora_Usage__c();
            
            zUsage.Charge_Number__c = zCharge.Zuora__ChargeNumber__c;
            zUsage.Quantity__c = 10;
            zUsage.UOM__c =  zCharge.Zuora__UOM__c;
            zUsage.Status__c = 'Processing';
            zUsage.Zuora_ID__c = 'ZTESTusage-'+ String.valueOf(i);
            
            billAcctLIst.add(billAcct);
            zChargeList.add(zCharge);
            zUsageList.add(zUsage);
        }
        
        insert billAcctLIst;
        insert zUsageList;
        insert zChargeList;

        // run methods in test mode
        
        Test.startTest();
        //insert zChargeList;
        zUsageBatchable nlb = new zUsageBatchable();
        Database.executeBatch(nlb, 1500); 
        Test.stopTest();    
        
    }
}