global with sharing class zUsageBatchable implements Database.Batchable<sObject>, Database.AllowsCallouts {
    // public zUsageBatchable() {
        
    // }

    global Database.QueryLocator start(Database.BatchableContext BC){

        // Poll Billing Accounts to query Zuora for Usage
        String soql = 'SELECT Id, Zuora__Account__c, Zuora__Status__c, Zuora__Zuora_Id__c '
                + 'FROM Zuora__CustomerAccount__c '
                + 'WHERE Zuora__Status__c = \'Active\'';
        if(Test.isRunningTest()){
            soql += 'AND Zuora__Zuora_Id__c like \'TESTbillAcct-%\'';
        }

        System.debug('***** query = ' + soql);
        
        return Database.getQueryLocator(soql);

    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {

    System.debug('===== MS =====: zUsageBatchable.execute();');

        zUsageHandler usageHandler = new zUsageHandler();

        List<String> zuoraIDs = new List<String>();

        // Add each Zuora__Zuora_Id__c to a list
        for(Sobject s : scope) {
            Zuora__CustomerAccount__c billAcct = (Zuora__CustomerAccount__c) s;
            System.debug('===== MS =====: billAcct: ' + billAcct);
            String zuoraID = billAcct.Zuora__Zuora_Id__c;
            if(billAcct.Zuora__Zuora_Id__c == Null || billAcct.Zuora__Zuora_Id__c == '')
            {
                billAcct.Zuora__Zuora_Id__c = 'TESTbillAcct-#####';
            }
            zuoraIDs.add(zuoraID);

        }
        
        // PGet Usage from Zuora for the list of IDs
        if(zuoraIDs != NULL && zuoraIDs[0] != NULL  && zuoraIDs[0] != '')
        {
            usageHandler.pullUsageFromZuora(zuoraIDs);
        }

    }

    global void finish(Database.BatchableContext BC){

   }

}