public class zAccountTriggerHandler{

    public void OnAfterUpdate(Map<Id, Account> newMap, Map<Id, Account> oldMap, Account[] newAccts){
        
        List<String> acctsToUpdate = new List<String>();
        
        for(Account acct : newAccts){
            
            if( (newMap.get(acct.Id).X2013_Vertical__c != oldMap.get(acct.Id).X2013_Vertical__c) ||
                (newMap.get(acct.Id).Backlot_Account_ID__c != oldMap.get(acct.Id).Backlot_Account_ID__c) ||
                (newMap.get(acct.Id).CSM_Owner__r != oldMap.get(acct.Id).CSM_Owner__r) ) {
                    
                    acctsToUpdate.add(acct.Id);
            }
        }

 
        if(acctsToUpdate.size() > 0) {
            updateAccountsInZuora(acctsToUpdate);
        }
        
    }
    
    //method to update the zuora account custom field
    @Future(callout=true)
    private static void updateAccountsInZuora(List<String> zAccountIds){

        String testStr;
 
        List<Account> acctsList = [
            SELECT
                  Id
                , X2013_Vertical__c
                , Backlot_Account_ID__c
                , CSM_Owner__r.Name
            FROM 
                Account 
            WHERE 
                Id IN :zAccountIds
            ];
            
        List<Zuora__CustomerAccount__c> zBillingAccounts = [
            SELECT 
                  Zuora__Zuora_ID__c
                , Zuora__Account__c
            FROM
               Zuora__CustomerAccount__c
            WHERE
               Zuora__Account__c IN :zAccountIds
            ];
            
        Map<String, Zuora__CustomerAccount__c> zBillingAcctMap = new Map<String, Zuora__CustomerAccount__c>();
        
        for(Zuora__CustomerAccount__c billingAcct : zBillingAccounts){
            
            String key = billingAcct.Zuora__Account__c;
            zBillingAcctMap.put(key, billingAcct);
        
        }
 
        // List of Zuora Accounts to update
        List<Zuora.zObject> updateAccounts = new List<Zuora.zObject>(); 
 
        for(Account acct : acctsList){
            testStr = acct.X2013_Vertical__c;
            String zuoraId = zBillingAcctMap.get(acct.Id).Zuora__Zuora_ID__c;
            if( (zuoraId!=null) && (!Test.isRunningTest()) ) {
                Zuora.zObject updateAccount = new Zuora.zObject('Account');
                updateAccount.setValue('Id', zuoraId);
                updateAccount.setValue('Vertical__c', acct.X2013_Vertical__c);
                updateAccount.setValue('BacklotID__c', acct.Backlot_Account_ID__c);
                updateAccount.setValue('CustomerServiceRepName', acct.CSM_Owner__r.Name);
                updateAccounts.add(updateAccount);
            }
        }
 
        Zuora.zApi zapi = new Zuora.zApi();
        try {
            if(!Test.isRunningTest()){
                zapi.zlogin();
            } else {
                // test is running, test exception catch
                if(testStr == 'exception1') { 
                    throw new Zuora.zRemoteException();
                }
            }
        } catch (Zuora.zRemoteException ex) {
            ex.getMessage();
            return;
        }
 
        try {
            List<Zuora.zApi.SaveResult> results ;
            if(!Test.isRunningTest()){
                results = zapi.zupdate(updateAccounts);
            } else {
                results = new List<Zuora.zApi.SaveResult>();
                if(testStr == 'exception') { 
                    throw new Zuora.zRemoteException();
                }   
            }
            //Display Results
            for (Zuora.zApi.SaveResult result : results) {
                if (result.Success){
                    //Success
                } else { /*
                    Zuora.zObject[] errors = result.errors;
                    for (Zuora.zObject error : errors) {
                        //Failure
                    } 
                    // */
                }
            }
        } catch (Zuora.zRemoteException ex) {
            ex.getMessage();
            return;
        }

    }
}