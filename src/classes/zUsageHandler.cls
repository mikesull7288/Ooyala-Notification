public with sharing class zUsageHandler {
     
    private List<Zuora.zObject> zUsageQueryResult;
    private Set<String> zuoraIdSet;
    private Map<String, Zuora__CustomerAccount__c> zAccountMap;
    Map<String, Zuora__SubscriptionProductCharge__c> zChargeMap;
    
    public zUsageHandler() {
    
        // empty constructor
    }

    /*
     * Get Usage details from Zuora
     * (1) store existing ZuoraUsage Zuora Ids to avoid duplicates later
     * (2) setup Zuora Query string(s)
     * (3) Query Zuora for Usage data
     * (4) Process Usage data to match to Accounts and Subscription Charge
     * (5) Insert ZuoraUsages
     */
    public List<Zuora_Usage__c> pullUsageFromZuora(List<String> zuoraAcctIDs){
    
    System.Debug(logginglevel.DEBUG, '===== MS =====');
    System.debug(logginglevel.INFO, '===== ms =====');
        
        // (1) get existing ZuoraUsages and Billing Accounts
        zuoraIdSet = new Set<String>();
        zuoraIdSet.addAll(getZuoraIds(zuoraAcctIDs));
        zChargeMap = getZuoraChargeMap(zuoraAcctIDs);
        zAccountMap = getZuoraAccountMap(zuoraAcctIDs);
        
        // (2) build ZuoraQuery statements
        String zoqlStatment = setupZOQL();
        
        // (3) query Zuora
        zUsageQueryResult = new List<Zuora.zObject>();
        
        if(zoqlStatment != Null && zoqlStatment != '' && zoqlStatment.length() > 6)
        {
            if(queryZuora(zoqlStatment) != NULL)
            {
                zUsageQueryResult.addAll(queryZuora(zoqlStatment));
            }
        }
        
        // (4) process Usage from Zuora
        List<Zuora_Usage__c> zuoraUsagesToInsert = new List<Zuora_Usage__c>();
        zuoraUsagesToInsert = processUsage(zUsageQueryResult);
        
        // (5) insert ZuoraUsages
        System.debug(' ===== MS =====  Inserting new Usages: ' + zuoraUsagesToInsert);
        insert zuoraUsagesToInsert;
        return zuoraUsagesToInsert;
    }

    private String setupZOQL(){
        
        Date today = Date.today();
        Date lastMonth = Date.newInstance(today.year(), today.month()-1, 01);
        String lastMonthStr = lastMonth.format();
        String zoql = 'SELECT Id, AccountId, ChargeId, ChargeNumber, Description, Quantity, '
                    + 'StartDateTime, RbeStatus, UOM '
                    + 'FROM Usage '
                    + 'WHERE RbeStatus = \'Processed\''
                    + ' AND CreatedDate  >= \'' + lastMonthStr + 'T00:00:00-08:00\'';
        
        System.debug('===== MS ===== zoql query is: ' + zoql);
     
        return zoql;
    }

    private List<Zuora.zObject> queryZuora(String zoql){
        List<Zuora.zObject> queryResultList = new List<Zuora.zObject>();
        
        Zuora.zApi.QueryRequest qr = new Zuora.zApi.QueryRequest();
        Zuora.zApi.QueryOptions qo = new Zuora.zApi.QueryOptions();
        qo.batchSize = 20;
        qo.caseSensitive = false;
        qr.queryOptions = qo;
        qr.zoql = zoql;
        
        Zuora.zApi.QueryResult queryResult;
        
        try {
            Zuora.zApi zuoraApi = new Zuora.zApi();
            Boolean done = false;
            Zuora.zApi.QueryResult queryMoreResult;
            Zuora.zApi.QueryMoreRequest qmr = new Zuora.zApi.QueryMoreRequest();
            if(!Test.isRunningTest()){
                zuoraApi.zLogin();
                queryResult = zuoraApi.zquery(qr);
                queryResultList.addAll(queryResult.records);
                done = queryResult.done;
                // If the result set is not complete, call zqueryMore() to get more records
        
                qmr.queryLocator = queryResult.queryLocator;
                while (!done){
                    queryMoreResult = zuoraApi.zqueryMore(qmr);
                    queryResultList.addAll( queryMoreResult.records);
                    done = queryMoreResult.done;
                    qmr.queryLocator = queryMoreResult.queryLocator;
                }

            }
            else{
                //make a fake result
                Zuora.zObject testobj = new Zuora.zObject('Usage');
                testobj.setValue('Id', 'test-0123' + String.valueOf(System.currentTimeMillis()) );
                testobj.setValue('ChargeNumber', 'test-123');
                testobj.setValue('RbeStatus' , 'Processed');
                testobj.setValue('AccountId', 'TESTbillAcct-00001');
                queryResultList.add(testobj);
            }
        } catch (Zuora.zAPIException e) {
            System.debug('Error in query [' + zoql + '] ' + e);
            return null;
        } catch (Zuora.zRemoteException e) {
            System.debug('Error in query [' + zoql + '] ' + e);
            System.debug( '===== MS ===== SOAP Request = ' + Zuora.zApi.currentLogger.request );
            System.debug( '===== MS ===== SOAP Response = ' + Zuora.zApi.currentLogger.response );
            System.debug( '===== MS ===== logger = ' + Zuora.zApi.currentLogger.toString() );
            //System.debug(' ===== MS ===== queryResult size = ' + queryResult.size);
           return null;
        
        }
        
        if(!Test.isRunningTest()){
            System.debug(' ===== MS ===== queryResult size = ' + queryResult.size);
            System.debug( '===== MS ===== SOAP Response = ' + Zuora.zApi.currentLogger.response );
        }
        return queryResultList;
    }

    private List<Zuora_Usage__c> processUsage(List<Zuora.zObject> usageList){
        List<Zuora_Usage__c> output = new List<Zuora_Usage__c>();
        
        
        if(usageList.size() != 0) {
            
            for(Zuora.zObject usage : usageList) {
                
                if(checkUsageZuoraId((String) usage.getValue('Id')) == false){
                
                Zuora_Usage__c zUsage = new Zuora_Usage__c();
                zUsage.Zuora_Id__c = (String) usage.getValue('Id');
                zUsage.Charge_ID__c = (String) usage.getValue('ChargeId');
                zUsage.Charge_Number__c = (String) usage.getValue('ChargeNumber');
                zUsage.Description__c = (String) usage.getValue('Description');
                zUsage.Start_Date__c = (DateTime) usage.getValue('StartDateTime');
                zUsage.Quantity__c = (Decimal) usage.getValue('Quantity');
                zUsage.Status__c = (String) usage.getValue('RbeStatus');
                zUsage.UOM__c = (String) usage.getValue('UOM');
                
                // Get Account from Billing Account using Usage.AccountId
                Zuora__CustomerAccount__c zAcct = zAccountMap.get((String) usage.getValue('AccountId'));
                if ( zAcct != null ) {
                    zUsage.Account__c = zAcct.Zuora__Account__c;
                    zUsage.Billing_Account__c = zAcct.Id;
                } else {
                    System.debug(' ===== MS ===== No Billing Account found for Zuora__CustomerAccount__c [' + (String) usage.getValue('AccountId') + ']');
                }
                
                // Get Subscription Charge using Usage.ChargeNumber
                Zuora__SubscriptionProductCharge__c charge = zChargeMap.get(zUsage.Charge_Number__c);
                if(charge != null) {
                    
                    zUsage.Zuora_Charge__c = charge.Id;
                    
                } else {
                    System.debug(' ===== MS ===== No Charge found for Zuora__ChargeNumber__c [' + zUsage.Charge_Number__c + ']');
                }
                output.add(zUsage);
                }
            }
        }

        return output;
    }
    
    /*
     * Bulkify query FROM Zuora__SubscriptionProductCharge__c
     *
     */
     private Map<String, Zuora__SubscriptionProductCharge__c> getZuoraChargeMap(List<String> zuoraAcctIDs){
         
         Map<String, Zuora__SubscriptionProductCharge__c> zChargeMap = new Map<String, Zuora__SubscriptionProductCharge__c>();
         
         List<Zuora__SubscriptionProductCharge__c> zCharges = new List<Zuora__SubscriptionProductCharge__c>();
         zCharges = [SELECT ID, Zuora__Account__c, Zuora__ChargeNumber__c FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Type__c = 'Usage' AND Zuora__Subscription__r.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c IN :zuoraAcctIDs];
         
         for(Zuora__SubscriptionProductCharge__c charge : zCharges){
             zChargeMap.put(charge.Zuora__ChargeNumber__c, charge);
         }
         
         return zChargeMap;
         
     }
     
     /*
      * Bulkify query FROM Account
      *
      */
     private Map<String, Zuora__CustomerAccount__c> getZuoraAccountMap(List<String> zuoraAcctIDs){
         
         Map<String, Zuora__CustomerAccount__c> zAccountMap = new Map<String, Zuora__CustomerAccount__c>();
         
         List<Zuora__CustomerAccount__c> zAccounts = new List<Zuora__CustomerAccount__c>();
         zAccounts = [SELECT ID, Zuora__Account__c, Zuora__Zuora_Id__c FROM Zuora__CustomerAccount__c WHERE Zuora__Zuora_Id__c IN :zuoraAcctIDs];
         
         for(Zuora__CustomerAccount__c account : zAccounts){
             zAccountMap.put(account.Zuora__Zuora_Id__c, account);
         }
         
         return zAccountMap;
         
     }

    private List<String> getZuoraIds(List<String> zuoraAcctIDs){
       List<String> ids = new List<String>();
       
       List<Zuora_Usage__c> zuoraUsage = [SELECT Zuora_ID__c FROM Zuora_Usage__c WHERE Billing_Account__r.Zuora__Zuora_Id__c IN :zuoraAcctIDs];
       for(Zuora_Usage__c usage : zuoraUsage){
           ids.add(usage.Zuora_ID__c);
       }
       
       return ids;
    }
    /*
     * Check existing Usage objects for Zuora ID, if found retrun true, else return false
     *
     */
    private Boolean checkUsageZuoraId(String zuoraID){
        Boolean isValid = true;
        
        isValid = zuoraIdSet.contains(zuoraID);
        
        return isValid;
    }
    
     
}