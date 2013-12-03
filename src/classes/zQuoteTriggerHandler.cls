public with sharing class zQuoteTriggerHandler {
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public List<zqu__Quote__c> quotes {get;set;}
    public Map<String, String> quoteIdToZAccMap = new Map<String, String>();

    String accountId;
    String test;

    public enum triggeredAction {beforeInsert, beforeUpdate, afterInsert, afterUpdate}

    public zQuoteTriggerHandler() {

    }

    public void OnBeforeUpdate(Map<Id, zqu__Quote__c> newMap, Map<Id, zqu__Quote__c> oldMap, zqu__Quote__c[] newQuotes){

        List<String> quoteIds = new List<String>();

        for(zqu__Quote__c q : newQuotes){
            if(newMap.get(q.Id).zqu__Status__c=='Sent to Z-Billing'){
                if(oldMap.get(q.Id).zqu__Status__c=='New'){
                    quoteIds.add(q.Id);
                }
            }
        }

        if(quoteIds.size() > 0) {
            updateAccounts(quoteIds);
        }


    }
    

        //method to update the zuora account custom field
    @Future(callout=true)
    public static void updateAccounts(List<String> quoteIds){

        String testStr;

        List<zqu__Quote__c> uQuotes = [
            SELECT 
                zqu__ZuoraAccountID__c
                , CSR__c
                , CSR_Email__c
                , zqu__Opportunity__r.Account.X2013_Vertical__c
                , zqu__Opportunity__r.Account.Backlot_Account_ID__c
                //, zqu__Opportunity__r.Account.AdditionalBacklotIDs__c
                //, zqu__Opportunity__r.Account.CSM_Owner__C
            FROM 
                zqu__Quote__c 
            WHERE 
                Id IN :quoteIds
            ];

        List<Zuora.zObject> zAccounts = new List<Zuora.zObject>();

        for(zqu__Quote__c uQuote : uQuotes){
            testStr = uQuote.zqu__Opportunity__r.Account.X2013_Vertical__c;
            if(uQuote.zqu__ZuoraAccountID__c!=null){
                Zuora.zObject zAccount = new Zuora.zObject('Account');
                zAccount.setValue('Id', uQuote.zqu__ZuoraAccountID__c);
                zAccount.setValue('Vertical__c', uQuote.zqu__Opportunity__r.Account.X2013_Vertical__c);
                zAccount.setValue('BacklotID__c', uQuote.zqu__Opportunity__r.Account.Backlot_Account_ID__c);
                // zAccount.setValue('AdditionalBacklotIDs__c', uQuote.zqu__Opportunity__r.Account.AdditionalBacklotIDs__c);
                zAccount.setValue('CustomerServiceRepName', uQuote.CSR__C);
                zAccount.setValue('CSR_Email__c', uQuote.CSR_Email__C);
                zAccounts.add(zAccount);
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
                results = zapi.zupdate(zAccounts);
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
        }

    }
}