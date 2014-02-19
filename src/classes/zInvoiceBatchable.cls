global with sharing class zInvoiceBatchable implements Database.Batchable<sObject>, Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext BC){
    
        // Poll Invoices moving into Dunning
        String soql = 'SELECT Zuora__Balance2__c, Zuora__Account__c, Zuora__BillingAccount__r.isDunning__c, Zuora__DueDate__c, Zuora__Zuora_Id__c, isDunning__c '
                + 'FROM Zuora__ZInvoice__c '
                + 'WHERE Zuora__Balance2__c > 0';
        if(Test.isRunningTest()){
            soql += ' AND Zuora__Zuora_Id__c like \'TESTzInv-%\'';
        }

        System.debug('***** query = ' + soql);
        
        return Database.getQueryLocator(soql);
    
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Zuora__ZInvoice__c> invoiceListToUpdate = scope;
        update scope;
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('===== MS =====: ZInvoiceBatchable.finish();');
   }

}