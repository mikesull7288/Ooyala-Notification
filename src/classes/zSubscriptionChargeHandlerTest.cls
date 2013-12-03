@isTest(SeeAllData=true)
private class zSubscriptionChargeHandlerTest {

	@isTest	 static void test_updateSubProdCharges(){
			Zuora__SubscriptionProductCharge__c SPC1 = Z_TestFactory.makeSubProdCharge();
			SPC1.Zuora__Zuora_Id__c = '1';
			//SPC1.Zuora__ChargeNumber__c = '5';
        	//SPC1.Number_of_Period__c = null;
        	//SPC1.Zuora__UOM__c = 'Each';
        	//SPC1.Zuora__Quantity__c = 10;
			Zuora__SubscriptionProductCharge__c SPC2 = Z_TestFactory.makeSubProdCharge();
			SPC2.Zuora__Zuora_Id__c = '2';
			//SPC2.Zuora__ChargeNumber__c = '6';
        	//SPC2.Number_of_Period__c = null;
        	//SPC2.Zuora__UOM__c = 'Each';
        	//SPC2.Zuora__Quantity__c = 10;
			Zuora__SubscriptionProductCharge__c SPC3 = Z_TestFactory.makeSubProdCharge();
			SPC3.Zuora__Zuora_Id__c = '3';
			//SPC3.Zuora__ChargeNumber__c = '7';
        	//SPC3.Number_of_Period__c = null;
        	//SPC3.Zuora__UOM__c = 'Each';
        	//SPC3.Zuora__Quantity__c = 10;
			//updateSubProdCharges('1','2','3');
		
			//insert SPC1;
			//insert SPC2;
			//insert SPC3;
			List<Zuora__SubscriptionProductCharge__c> x = new List<Zuora__SubscriptionProductCharge__c>();
			x.add(SPC1);
			x.add(SPC2);
			x.add(SPC3);
			insert x;
			
			//Test.startTest();
			//ApexPages.StandardController stdController = new ApexPages.StandardController(x);
			//zSubscriptionChargeHandler zSCH = new zSubscriptionChargeHandler(stdController);
			//Test.stopTest();
			
			Test.startTest();
			zSubProdChargeUpdateBatchable nlb = new zSubProdChargeUpdateBatchable();
			Database.executeBatch(nlb); 
			Test.stopTest();
		}
}