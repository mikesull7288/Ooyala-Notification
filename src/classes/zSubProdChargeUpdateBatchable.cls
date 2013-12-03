global with sharing class zSubProdChargeUpdateBatchable implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global zSubProdChargeUpdateBatchable() {
        
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('===== MS =====: zSubProdChargeUpdateBatchable.start()');

        String soql = 'SELECT Id, Number_of_Period__c, Total_Included_Units__c, Zuora__ChargeNumber__c, Zuora__Quantity__c, Zuora__Subscription__c, Zuora__Zuora_Id__c, Zuora__Type__c '
                + 'FROM Zuora__SubscriptionProductCharge__c '
                + 'WHERE Zuora__Type__c = \'Usage\' AND (Number_of_Period__c = null OR Total_Included_Units__c = null)';

        if(Test.isRunningTest()){
            soql += 'AND Zuora__ChargeNumber__c LIKE \'test-%\' ';
        }

        System.debug('===== MS =====: Zuora__SubscriptionProductCharge__c query = ' + soql);
        
        return Database.getQueryLocator(soql);

    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.debug('===== MS =====: zSubProdChargeUpdateBatchable.execute()');
        System.debug('===== MS =====: scope size ['+ scope.size() +']');

        zSubscriptionChargeHandler chargeHandler = new zSubscriptionChargeHandler();
        List<String> zRatePlanChargesToQuery = new List<String>();

        for(Sobject s : scope) {
            Zuora__SubscriptionProductCharge__c zSubCharge = (Zuora__SubscriptionProductCharge__c) s;
            //System.debug('===== MS =====: zSubCharge: ' + zSubCharge);
            if(zSubCharge.Number_of_Period__c == null || zSubCharge.Total_Included_Units__c == null ){
                zRatePlanChargesToQuery.add(zSubCharge.Zuora__ChargeNumber__c);
                System.debug('===== MS =====: zSubCharge added to zRatePlanChargesToQuery: ' + zSubCharge.Zuora__ChargeNumber__c);
            }
        }
        if(zRatePlanChargesToQuery[0] != Null  && zRatePlanChargesToQuery != NULL && zRatePlanChargesToQuery[0] != '')
        {
            chargeHandler.updateSubProdCharges(zRatePlanChargesToQuery);
        } else {
        	System.debug('===== MS =====: Error, null zRatePlanChargesToQuery');
        }

    }

    global void finish(Database.BatchableContext BC){
        System.debug('===== MS =====: zSubProdChargeUpdateBatchable.finish()');
   }
}