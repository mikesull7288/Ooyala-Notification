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
        
        // (1) get existing ZuoraUsages and Billing Accounts
        zuoraIdSet = new Set<String>();
        zuoraIdSet.addAll(getZuoraIds(zuoraAcctIDs));
        zChargeMap = getZuoraChargeMap(zuoraAcctIDs);
        zAccountMap = getZuoraAccountMap(zuoraAcctIDs);
        
        // (2) build ZuoraQuery statements
        List<String> zoqlStatments = setupZOQL(zuoraAcctIDs);
        
        // (3) query Zuora
        zUsageQueryResult = new List<Zuora.zObject>();
        if(zoqlStatments != Null && zoqlStatments[0] != NULL)
        {
            for(String zoql : zoqlStatments) {
                if(zoql != Null && zoql != '' && zoql.length() > 6)
                {
                    if(queryZuora(zoql) != NULL)
                    {
                        zUsageQueryResult.addAll(queryZuora(zoql));
                    }
                }
            }
        }
        
        // (4) process Usage from Zuora
        List<Zuora_Usage__c> zuoraUsagesToInsert = new List<Zuora_Usage__c>();
        zuoraUsagesToInsert = processUsage(zUsageQueryResult);
        
        // (5) insert ZuoraUsages
        System.Debug(' ===== MS =====  Inserting new Usages: ' + zuoraUsagesToInsert);
        insert zuoraUsagesToInsert;
        return zuoraUsagesToInsert;
    }

    private List<String> setupZOQL(List<String> zuoraAcctIDs){
        List<String> zoqlStatments = new List<String>();
        Datetime myDatetime = Datetime.now();
        String myDatetimeStr = myDatetime.format('YYYY-MM-dd');
        String zoql = 'SELECT Id, AccountId, ChargeId, ChargeNumber, Description, Quantity, '
                    + 'StartDateTime, RbeStatus, UOM '
                    + 'FROM Usage '
                    + 'WHERE RbeStatus = \'Processed\''
                    // + ' AND StartDateTime  <= \'2011-12-31T00:00:00-08:00\''.escapeXml()
                    + ' AND AccountId = ';
        //String zoql = zoqlStart.escapeXml();
        //System.Debug('===== MS ===== xml query is: ' + zoql);
     
        if (zuoraAcctIDs.size() == 1) {
             
            
             zoql += '\'' + zuoraAcctIDs[0] + '\'';
             System.Debug('===== MS ===== single query is: ' + zoql);
             
             zoqlStatments.add(zoql);
        } else {
            // list is too big for one zquery need to break it into 2 sub queries
            String zoql1 = zoql;
            for(Integer i = 0; i < zuoraAcctIDs.size()-1; i++){
                zoql1 += '\'' + zuoraAcctIDs[i] + '\' OR AccountId = ';
            }
             zoql1 += '\'' + zuoraAcctIDs[zuoraAcctIDs.size()-1] + '\'';
             System.Debug('===== MS ===== long query is: ' + zoql1);
             zoqlStatments.add(zoql1);

        }
        

        return zoqlStatments;

    }

    private List<Zuora.zObject> queryZuora(String zoql){
        List<Zuora.zObject> queryResult = new List<Zuora.zObject>();
        try {
            Zuora.zApi zuoraApi = new Zuora.zApi();
            if(!Test.isRunningTest()){
                zuoraApi.zLogin();
                queryResult = zuoraApi.zquery(zoql);
            }
            else{
                //make a fake result
                Zuora.zObject testobj = new Zuora.zObject('Usage');
                testobj.setValue('Id', 'test-0123' + String.valueOf(System.currentTimeMillis()) );
                testobj.setValue('ChargeNumber', 'test-123');
                testobj.setValue('RbeStatus' , 'Processed');
                testobj.setValue('AccountId', 'TESTbillAcct-00001');
                queryResult.add(testobj);
            }
        } catch (Zuora.zAPIException e) {
            System.debug('Error in query [' + zoql + '] ' + e);
            return null;
        } catch (Zuora.zRemoteException e) {
            System.debug('Error in query [' + zoql + '] ' + e);
            System.debug( '===== MS ===== SOAP Request = ' + Zuora.zApi.currentLogger.request );
       System.debug( '===== MS ===== SOAP Response = ' + Zuora.zApi.currentLogger.response );
       System.debug( '===== MS ===== logger = ' + Zuora.zApi.currentLogger.toString() );
       System.debug(' ===== MS ===== queryResult size = ' + queryResult.size());
           // return null;
        
        }
        System.debug(' ===== MS ===== queryResult size = ' + queryResult.size());
        if(!Test.isRunningTest()){
            System.debug( '===== MS ===== SOAP Response = ' + Zuora.zApi.currentLogger.response );
        }
        return queryResult;
    }

    private List<Zuora_Usage__c> processUsage(List<Zuora.zObject> usageList){
        List<Zuora_Usage__c> output = new List<Zuora_Usage__c>();
        
        
        if(usageList.size() != 0) {
            
            for(Zuora.zObject usage : usageList) {

                System.debug(' ===== MS ===== Found Usage: ' + usage);
                System.debug(' ===== MS ===== Found Usage ChargeNumber: ' + usage.getValue('ChargeNumber'));
                
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