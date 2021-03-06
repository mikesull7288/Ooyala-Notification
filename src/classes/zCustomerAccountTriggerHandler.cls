public class zCustomerAccountTriggerHandler{
 
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public List<zqu__Quote__c> quotes {get;set;}
    public Map<String, String> quoteIdToZAccMap = new Map<String, String>();
    
 
    String accountId;
    String test;
 
    public void OnUpdate(Map<Id, Zuora__CustomerAccount__c> newMap, Map<Id, Zuora__CustomerAccount__c> oldMap, Zuora__CustomerAccount__c[] newAccts){
 
        List<String> zuoraAccountsToUpdate = new List<String>();
        List<String> accountsToCheckDunning = new List<String>();
 
        for(Zuora__CustomerAccount__c acct : newAccts){
            if( (oldMap.get(acct.Id).isDunning__c == TRUE) && (newMap.get(acct.Id).isDunning__c == FALSE)) {
                //Billing Accounts has moved out of dunning, check other Invoices on the Account for dunning
                accountsToCheckDunning.add(acct.Id);
                
            }
            
            if( (newMap.get(acct.Id).Vertical__c != oldMap.get(acct.Id).Vertical__c) ||
                (newMap.get(acct.Id).BacklotID__c != oldMap.get(acct.Id).BacklotID__c) ||
                (newMap.get(acct.Id).Zuora__CustomerServiceRepName__c != oldMap.get(acct.Id).Zuora__CustomerServiceRepName__c) ||
                (newMap.get(acct.Id).Zuora__SalesRepName__c != oldMap.get(acct.Id).Zuora__SalesRepName__c) ){
                    
                    zuoraAccountsToUpdate.add(acct.Id);
            }
        }
 
        if(accountsToCheckDunning.size() > 0) {
            checkInvoicesDunning(accountsToCheckDunning);
        }
 
        if(zuoraAccountsToUpdate.size() > 0) {
            updateAccountsInZuora(zuoraAccountsToUpdate);
        }
 
 
    }
    
    private void checkInvoicesDunning(List<String> accountIdList) {
    
        List<Zuora__ZInvoice__c> invoicesToUpdate = new List<Zuora__ZInvoice__c>();
    
        List<Zuora__ZInvoice__c> invoices = [
             SELECT
                   Zuora__BillingAccount__r.Id 
                 , Zuora__Balance2__c
                 , Days_Past_Due__c   
             FROM
                 Zuora__ZInvoice__c
             WHERE 
                 Zuora__BillingAccount__r.Id IN :accountIdList 
             AND Zuora__Balance2__c > 0
             AND Days_Past_Due__c > 0
             ORDER BY
               Zuora__DueDate__c DESC
        ];

        Map<String, List<Zuora__ZInvoice__c>> acctidInvoiceListMap = new Map<String, List<Zuora__ZInvoice__c>>();

        for(Zuora__ZInvoice__c inv : invoices){
            List<Zuora__ZInvoice__c> acctInvList = acctidInvoiceListMap.get(inv.Zuora__BillingAccount__r.Id);
            if(acctInvList != null && acctInvList.size() > 0 ){
                acctInvList.add(inv);
                acctidInvoiceListMap.put(inv.Zuora__BillingAccount__r.Id, acctInvList);

            } else {
                acctInvList = new LIST<Zuora__ZInvoice__c>();
                acctInvList.add(inv);
                acctidInvoiceListMap.put(inv.Zuora__BillingAccount__r.Id, acctInvList);
            }
        }

        for(String acctId : accountIdList){ 
           List<Zuora__ZInvoice__c> acctInvs = acctidInvoiceListMap.get(acctId);
            if((acctInvs.size() > 0)){
               Zuora__ZInvoice__c dunningInvoice = acctInvs[0];
               dunningInvoice.isDunning__c = TRUE;
                invoicesToUpdate.add(dunningInvoice);
            }
        }
        update invoicesToUpdate;
    }
    
 
        //method to update the zuora account custom field
    @Future(callout=true)
    private static void updateAccountsInZuora(List<String> zCustomerAccountIds){
 
        String testStr;
 
        List<Zuora__CustomerAccount__c> zuoraAccounts = [
            SELECT
                  Zuora__Zuora_ID__c 
                , Vertical__c
                , BacklotID__c
                , Zuora__Account__r.Backlot_Account_ID__c
                , Zuora__Account__r.CSM_Owner__c
                , Zuora__CustomerServiceRepName__c
                , Zuora__SalesRepName__c
            FROM 
                Zuora__CustomerAccount__c 
            WHERE 
                Id IN :zCustomerAccountIds
            ];
 
        // List of Zuora Accounts to update
        List<Zuora.zObject> updateAccounts = new List<Zuora.zObject>(); 
 
        for(Zuora__CustomerAccount__c zuoraAccount : zuoraAccounts){
            testStr = zuoraAccount.Vertical__c;
            if( (zuoraAccount.Zuora__Zuora_ID__c!=null) && (!Test.isRunningTest()) ) {
                Zuora.zObject updateAccount = new Zuora.zObject('Account');
                updateAccount.setValue('Id', zuoraAccount.Zuora__Zuora_ID__c);
                updateAccount.setValue('Vertical__c', zuoraAccount.Vertical__c);
                updateAccount.setValue('BacklotID__c', zuoraAccount.BacklotID__c);
                updateAccount.setValue('CustomerServiceRepName', zuoraAccount.Zuora__Account__r.CSM_Owner__c);
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