public with sharing class ZInvoiceTriggerHandler {
    public static Set<ID> firstRun = null;
    /*
     *Default Constructor
     */

    public ZInvoiceTriggerHandler() {
        
    }

    /*
     * SetField
     *      To ensure that only one Invoice on each account has an active notification schedule at any time, 
     *      a trigger will be created to handle any Invoices that are updated or inserted. For each committed 
     *      invoice, this trigger will first check to see if an invoice has a positive balance. 
     *
     *      If there is a positive balance, and the billing account associated to the invoice is not currently 
     *      engaged in a notification schedule, then the Billing Account and Invoice will be flagged as isDunning, 
     *      to indicate that they are actively sending notifications.

     *      If the balance is zero, and the invoice is currently engaged in a dunning process, the isDunning flag 
     *      on the invoice is set to False. If another invoice on the billing account is unpaid, that invoice will 
     *      be flagged, and become the new target of the notifications. If no other invoices on the account are unpaid, 
     *      then the dunning flag will be disabled at the Account level.
     *
     */

    public void SetFileds(MAP<Id,Zuora__ZInvoice__c> newMap, MAP<Id,Zuora__ZInvoice__c> oldMap, LIST<Zuora__ZInvoice__c> newInvoices){
//*
        if (firstRun == newMap.keySet()) {
            System.debug('Already ran!');
            return;            
        } else {

            firstRun = newMap.keySet();
        }
//*/
        Boolean processed = false;

        Set<Zuora__ZInvoice__c> invoicesToUpdate = new Set<Zuora__ZInvoice__c>{};

        List<Zuora__CustomerAccount__c> acctountsToUpdate = new List<Zuora__CustomerAccount__c>{};

        List<Zuora__ZInvoice__c> invoicesFromTrigger = [SELECT Bill_To_Email__c, Zuora__Balance2__c, isDunning__c, Zuora__BillingAccount__r.isDunning__c FROM Zuora__ZInvoice__c WHERE Id IN :newMap.keySet()];
        
        System.debug('===== MS ===== invoicesFromTrigger : [' + invoicesFromTrigger +']');
        
        //For each committed invoice,
        for(Zuora__ZInvoice__c inv : invoicesFromTrigger){


            // ToDo Need to bulkify
            List<Zuora__CustomerAccount__c> accts = [SELECT Zuora__BillToWorkEmail__c, isDunning__c, surpressNotifications__c FROM Zuora__CustomerAccount__c WHERE Id = :inv.Zuora__BillingAccount__r.id limit 1];
            Zuora__CustomerAccount__c billAcct = accts[0];

            System.debug('===== MS ===== BEFORE LOGIC: Invoice Balance: ['+inv.Zuora__Balance2__c+'], Bill To Email: ['+ inv.Bill_To_Email__c +'], Account isDunning: ['+inv.Zuora__BillingAccount__r.isDunning__c+']');

            if(billAcct.surpressNotifications__c){
                // Do not send notifications
                return;
            }

            // first check to see if an invoice has a positive balance.
            if(inv.Zuora__Balance2__c > 0){
                // If there is a positive balance, 
                
                if( !inv.Zuora__BillingAccount__r.isDunning__c ){
                    // and the billing account associated to the invoice is not currently engaged in a notification schedule, 
                    
                    // then the Billing Account and Invoice will be flagged as isDunning, 
                    // to indicate that they are actively sending notifications.

                    inv.isDunning__c = true;
                    billAcct.isDunning__c = true;
                    if(!addAccountToUpdate(billAcct, acctountsToUpdate)){
                        acctountsToUpdate.add(billAcct);
                    }
                    
                    // invoicesToUpdate.add(inv);
                    processed = true;
                    
                    
                } /*else { // Account is already in dunning

                    inv.isDunning__c = false;
                    // invoicesToUpdate.add(inv);
                    processed = true;
                }   */

            } else if(inv.Zuora__Balance2__c == 0){
                // If the balance is zero, 

                if(inv.isDunning__c == true){
                    // and the invoice is currently engaged in a dunning process,
                    inv.isDunning__c = false; // the isDunning flag on the invoice is set to False.
                    billAcct.isDunning__c = false; // take the Account out of dunning
                    if(!addAccountToUpdate(billAcct, acctountsToUpdate)){
                        acctountsToUpdate.add(billAcct);
                    }
                    // invoicesToUpdate.add(inv);
                    processed = true;
                }

            }

            // If the bill to email is not set, set it from the Billing Account BillTo Work Email

            if(inv.Bill_To_Email__c == null){
                inv.Bill_To_Email__c = billAcct.Zuora__BillToWorkEmail__c;
                // invoicesToUpdate.add(inv);
                processed = true;
            }
            
            if(processed) {
                invoicesToUpdate.add(inv);
                processed = false;
            }

            System.debug('===== MS ===== AFTER LOGIC: Invoice Balance: ['+inv.Zuora__Balance2__c+'], Bill To Email: ['+ inv.Bill_To_Email__c +'], isDunning: ['+inv.isDunning__c+']');
            System.debug('===== MS ===== AFTER LOGIC: Account isDunning: [' + inv.Zuora__BillingAccount__r.isDunning__c + ']');

        }       

        List<Zuora__ZInvoice__c> invoiceList = new List<Zuora__ZInvoice__c>{};
        
        invoiceList.addAll(invoicesToUpdate);
        System.debug('===== MS ===== AFTER LOGIC: invoicesToUpdate size: [' + invoiceList + ']');    
        update invoiceList; 
        System.debug('===== MS ===== AFTER UPDATE: invoicesToUpdate size: [' + [SELECT Bill_To_Email__c, Zuora__Balance2__c, isDunning__c, Zuora__BillingAccount__r.isDunning__c FROM Zuora__ZInvoice__c WHERE Id IN :newMap.keySet()] + ']');    


        System.debug('===== MS ===== AFTER LOGIC: acctountsToUpdate size: [' + acctountsToUpdate + ']');    

        update acctountsToUpdate;

        System.debug('===== MS ===== AFTER UPDATE: acctountsToUpdate size: [' + acctountsToUpdate + ']');    
    }
    
    private Boolean addAccountToUpdate(Zuora__CustomerAccount__c account, List<Zuora__CustomerAccount__c> acctList) {
    
        return (new Set<Zuora__CustomerAccount__c>(acctList)).contains(account);
    
    }
}