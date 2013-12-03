public with sharing class zSubscriptionChargeHandler {

    private Zuora.zApi zuoraApi;
    private Map<String, Zuora__SubscriptionProductCharge__c> zSubProdChargeMap;
    private Map<String, Zuora.zObject> ratePlanChargeOveragePriceMap;
    private Map<String, Zuora.zObject> ratePlanChargeMap;
    

    public zSubscriptionChargeHandler() {
        
    }


    /***********
     *
     *Update Subscription Product Charge records with Number of Periods and Total Included Units
     *
     */

    public List<Zuora__SubscriptionProductCharge__c> updateSubProdCharges(List<String> zSubProdChargeIdList){
        System.debug('===== MS =====: zSubscriptionChargeHandler.updateSubProdCharges()');
        
        /* 
         * Set up Lists and Maps to track changes
         *
         */    
        List<Zuora__SubscriptionProductCharge__c> output = new List<Zuora__SubscriptionProductCharge__c>();

        List<String> zChargeNumberList = new List<String>();    

        List<Zuora.zObject> queryResult = new List<Zuora.zObject>();    

        List<Zuora.zObject> overPriceQueryResult = new List<Zuora.zObject>();        

        zSubProdChargeMap = new Map<String, Zuora__SubscriptionProductCharge__c>();
        
        ratePlanChargeOveragePriceMap = new Map<String, Zuora.zObject>();

        ratePlanChargeMap = new Map<String, Zuora.zObject>();

        if(zSubProdChargeIdList != Null && zSubProdChargeIdList[0] != NULL)
        {
            List<String> zoqlStatments = setupRatePlanChargeZOQL(zSubProdChargeIdList);
            List<String> overagePriceZOQL = setupRatePlanChargeOveragePriceZOQL(zSubProdChargeIdList);
        
            if(zoqlStatments != Null && zoqlStatments[0] != Null)
            {
                for(String zoql : zoqlStatments) {
                    if(zoql != Null && zoql.length() > 6)
                    {
                        if(queryZuoraRatePlanCharge(zoql) != NULL)
                        {
                            queryResult.addAll(queryZuoraRatePlanCharge(zoql));
                        }
                    }
                }    
            }
            if(overagePriceZOQL != NULL && zoqlStatments[0] != Null)
            {
                for(String zoql : overagePriceZOQL) {
                    if(zoql != Null && zoql.length() > 6)
                    {
                        if(queryZuoraRatePlanCharge(zoql) != NULL)
                        {
                            overPriceQueryResult.addAll(queryZuoraRatePlanCharge(zoql));
                        }
                    }
                }     
            }
        }


        List<Zuora__SubscriptionProductCharge__c> charges = [SELECT Id, Number_of_Period__c, Total_Included_Units__c, Zuora__ChargeNumber__c, Zuora__Quantity__c, Zuora__RatePlanName__c, Zuora__Zuora_Id__c
                                                             FROM Zuora__SubscriptionProductCharge__c
                                                             WHERE Zuora__ChargeNumber__c IN : zSubProdChargeIdList ];

        for(Zuora__SubscriptionProductCharge__c charge : charges ){

            String chargeNumber = charge.Zuora__ChargeNumber__c;
            zChargeNumberList.add(chargeNumber);
            zSubProdChargeMap.put(charge.Zuora__ChargeNumber__c, charge);
        }

        

        for(Zuora.zObject z : queryResult) {
            String key = (String) z.getValue('ChargeNumber');
            System.debug('====== MS ====== add to ratePlanChargeMap: [' + key + ', ' + z+ ']');
            ratePlanChargeMap.put((String) z.getValue('ChargeNumber'), z);
        }
        
        for(Zuora.zObject z : overPriceQueryResult) {
            String key = (String) z.getValue('ChargeNumber');
            System.debug('====== MS ====== add to zSubProdChargeOveragePriceMap: [' + key + ', ' + z+ ']');
            ratePlanChargeOveragePriceMap.put((String) z.getValue('ChargeNumber'), z);
        }

        output = processCharges(zChargeNumberList);

        if(!Test.isRunningTest()){ update output; }

        return output;
    }

    private List<String> setupRatePlanChargeZOQL(List<String> zChargeIdList){
        List<String> zoqlStatments = new List<String>();
        String zoql = 'SELECT ChargeNumber, Id, IncludedUnits, BillingPeriod, Description, Quantity, NumberOfPeriods '
                    + 'FROM RatePlanCharge '
                    + 'WHERE ChargeModel = \'Overage Pricing\' '
                    + 'AND ChargeNumber = ';
                    
        if (zChargeIdList.size() == 1) { 
            zoql += '\'' + zChargeIdList[0] + '\'';
             System.Debug('===== MS ===== singular query is: ' + zoql);
            zoqlStatments.add(zoql); 
        } else { //if(zChargeIdList.size() <= 100) {
             
            for(Integer i = 0; i < zChargeIdList.size()-1; i++){
                zoql += '\'' + zChargeIdList[i] + '\' OR ChargeNumber = ';
            }
             zoql += '\'' + zChargeIdList[zChargeIdList.size()-1] + '\'';
             System.Debug('===== MS ===== single query is: ' + zoql);
             zoqlStatments.add(zoql);
        } 

        return zoqlStatments;

    }
    
     private List<String> setupRatePlanChargeOveragePriceZOQL(List<String> zChargeIdList){
        List<String> zoqlStatments = new List<String>();
        String zoql = 'SELECT ChargeNumber, Id, Price '
                    + 'FROM RatePlanCharge '
                    + 'WHERE ChargeModel = \'Overage Pricing\' '
                    + 'AND ChargeNumber = ';
                    
        if (zChargeIdList.size() == 1) { 
            zoql += '\'' + zChargeIdList[0] + '\'';
             System.Debug('===== MS ===== singular OveragePrice query is: ' + zoql);
            zoqlStatments.add(zoql); 
        } else { 
             
            for(Integer i = 0; i < zChargeIdList.size()-1; i++){
                zoql += '\'' + zChargeIdList[i] + '\' OR ChargeNumber = ';
            }
             zoql += '\'' + zChargeIdList[zChargeIdList.size()-1] + '\'';
             System.Debug('===== MS ===== single OveragePrice query is: ' + zoql);
             zoqlStatments.add(zoql);
        } 

        return zoqlStatments;
     }

    private List<Zuora.zObject> queryZuoraRatePlanCharge(String zoql){
        List<Zuora.zObject> queryResult = new List<Zuora.zObject>();
        try {
            if(!Test.isRunningTest()){
                zuoraApi = new Zuora.zApi();
                zuoraApi.zLogin();
                queryResult = zuoraApi.zquery(zoql);
            }
            else{
                //make a fake result
                Zuora.zObject testobj = new Zuora.zObject('RatePlanCharge');
                testobj.setValue('ChargeNumber', 'test-123');
                testobj.setValue('IncludedUnits', 123);
                testobj.setValue('BillingPeriod' , 'Month');
                queryResult.add(testobj);
            }
        } 
        catch (Zuora.zAPIException e) {
            System.debug('Error in query [' + zoql + '] ' + e);
            return null;
        }
        System.debug(' ===== MS ===== queryResult size = ' + queryResult.size());
        return queryResult;
    }

    private List<Zuora__SubscriptionProductCharge__c> processCharges(List<String> chargeList) {

        List<Zuora__SubscriptionProductCharge__c> output = new List<Zuora__SubscriptionProductCharge__c>();
        Zuora__SubscriptionProductCharge__c zSubProdCharge = new Zuora__SubscriptionProductCharge__c();
        Zuora.zObject zuoraRatePlanOverageCharge = new Zuora.zObject('RatePlanCharge');
        Zuora.zObject zuoraRatePlanCharge = new Zuora.zObject('RatePlanCharge');

        for(String chargeId : chargeList){
            System.debug('====== MS ====== looking for chargeId: [' + chargeId + ']');
            try {
                zSubProdCharge = zSubProdChargeMap.get(chargeId);
                System.debug('====== MS ====== processing zSubProdCharge: [' + zSubProdCharge + ']');
                zuoraRatePlanCharge = ratePlanChargeMap.get(chargeId);
                System.debug('====== MS ====== processing zuoraRatePlanCharge: [' + zuoraRatePlanCharge + ']');
                zuoraRatePlanOverageCharge = ratePlanChargeOveragePriceMap.get(chargeId);
                System.debug('====== MS ====== processing zuoraRatePlanOverageCharge: [' + zuoraRatePlanCharge + ']');
            } catch (NullPointerException nullPointerException) {
                System.debug('Exception on: ' + chargeId + ' [' + nullPointerException + ']');
            }
            if(zuoraRatePlanCharge != null ) {
            
                Decimal includedUnits = (Decimal) zuoraRatePlanCharge.getValue('IncludedUnits');
                Decimal numberOfPeriods = (Decimal) zuoraRatePlanCharge.getValue('NumberOfPeriods'); 
                
                if((includedUnits != null) && (numberOfPeriods != null)){
                    zSubProdCharge.Number_of_Period__c = numberOfPeriods;
                    zSubProdCharge.Total_Included_Units__c = zSubProdCharge.Number_of_Period__c * includedUnits;

                    System.debug('====== MS ====== updating zSubProdCharge: [' + zSubProdCharge + ']');
                } else {
                    System.debug('====== MS ====== ERROR setting Total_Included_Units - includedUnits: [' + includedUnits + ']  numberOfPeriods: [' + numberOfPeriods + ']');
                }

                
                zSubProdCharge.Zuora__Price__c = (Decimal) zuoraRatePlanOverageCharge.getValue('Price');

                output.add(zSubProdCharge);
            }
        }


        return output;

    }
}