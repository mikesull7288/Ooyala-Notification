@isTest(SeeAllData=true)
private class zSubProdChargeUpdateBatchableTest {
    
    @isTest static void test_zSubProdChargeUpdateScheduler(){
        
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        String jobId = System.schedule('testBasicScheduledApex', CRON_EXP,new zSubProdChargeUpdateScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger 
                          WHERE id = :jobId];
        // Verify the expressions are the same 
        System.assertEquals(CRON_EXP, ct.CronExpression);
    }
    
    @isTest static void test_zSubProdChargeUpdateBatchable() {
        // Implement test code

        Zuora__SubscriptionProductCharge__c zCharge = Z_TestFactory.makeSubProdCharge();
        zCharge.Number_of_Period__c = null;
        zCharge.Zuora__ChargeNumber__c = 'test-999999';
        insert zCharge;

        // run methods in test mode
        
        Test.startTest();
        zSubProdChargeUpdateBatchable nlb = new zSubProdChargeUpdateBatchable();
        Database.executeBatch(nlb); 
        Test.stopTest();    
    }
    
    @isTest static void test_zSubProdChargeUpdateBatchable_Annual() {
        // Implement test code

        Zuora__SubscriptionProductCharge__c zCharge = Z_TestFactory.makeSubProdCharge();
        zCharge.Zuora__RatePlanName__c = 'Annual';
        zCharge.Zuora__ChargeNumber__c = 'test-AnnualCharge';
        zCharge.Number_of_Period__c = null;
        insert zCharge;

        // run methods in test mode
        
        Test.startTest();
        zSubProdChargeUpdateBatchable nlb = new zSubProdChargeUpdateBatchable();
        Database.executeBatch(nlb); 
        Test.stopTest();    
    }

    @isTest static void test_zSubProdChargeUpdateBatchable_Quarter() {
        // Implement test code

        Zuora__SubscriptionProductCharge__c zCharge = Z_TestFactory.makeSubProdCharge();
        zCharge.Zuora__RatePlanName__c = 'Quarter';
        zCharge.Zuora__ChargeNumber__c = 'test-QuarterlyCharge';
        zCharge.Number_of_Period__c = null;
        insert zCharge;

        // run methods in test mode
        
        Test.startTest();
        zSubProdChargeUpdateBatchable nlb = new zSubProdChargeUpdateBatchable();
        Database.executeBatch(nlb); 
        Test.stopTest();    
    }

    @isTest static void test_zSubProdChargeUpdateBatchable_99_charges() {
        // Implement test code
        List<Zuora__SubscriptionProductCharge__c> zChargeList = new List<Zuora__SubscriptionProductCharge__c>();
        

        // Set up test data
        for(Integer i = 0; i < 99; i++){
            Zuora__SubscriptionProductCharge__c zCharge = Z_TestFactory.makeSubProdCharge();
	        zCharge.Zuora__ChargeNumber__c = 'test-99x' + String.valueOf(i);
			zCharge.Number_of_Period__c = null;
	        zChargeList.add(zCharge);
        } 
        insert zChargeList;

        // run methods in test mode
        
        Test.startTest();
        zSubProdChargeUpdateBatchable nlb = new zSubProdChargeUpdateBatchable();
        Database.executeBatch(nlb); 
        Test.stopTest();    
    }

    @isTest static void test_zSubProdChargeUpdateBatchable_150_charges() {
        // Implement test code
        List<Zuora__SubscriptionProductCharge__c> zChargeList = new List<Zuora__SubscriptionProductCharge__c>();

        // Set up test data
        for(Integer i = 0; i < 150; i++){
            Zuora__SubscriptionProductCharge__c zCharge = Z_TestFactory.makeSubProdCharge();
	        zCharge.Zuora__ChargeNumber__c = 'test-150x' + String.valueOf(i);
			zCharge.Number_of_Period__c = null;
	        zChargeList.add(zCharge);
        } 
        insert zChargeList; 

        // run methods in test mode
        
        Test.startTest();
        zSubProdChargeUpdateBatchable nlb = new zSubProdChargeUpdateBatchable();
        Database.executeBatch(nlb); 
        Test.stopTest();    
    }

}