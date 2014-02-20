public with sharing class ZInvoiceTriggerHandler {
    public static Set<ID> firstRun = null;
    

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

        Set<String> billingAcctountsToDun = new Set<String>{};
        Set<String> billingAcctountsToUnDun = new Set<String>{};

        List<Zuora__ZInvoice__c> invoicesFromTrigger = [
            SELECT
                  Zuora__Account__r.CSM_Owner__r.Email
                , CSM_Owner_Email__c, Bill_To_Email__c
                , Zuora__Balance2__c
                , CSM_Owner__c
                , isDunning__c
                , Zuora__BillingAccount__r.surpressNotifications__c
                , Zuora__BillingAccount__r.isDunning__c
                , Zuora__BillingAccount__r.Zuora__Balance__c
                , Zuora__BillingAccount__r.Zuora__Currency__c
                , Zuora__BillingAccount__r.Zuora__Account__r.Id
                , Zuora__BillingAccount__r.name
                , Zuora__BillingAccount__r.Zuora__BillToWorkEmail__c
                , Zuora__DueDate__c
                , Days_Past_Due__c
                , Dunning_Status__c 
            FROM
                 Zuora__ZInvoice__c 
            WHERE
                 Id IN :newMap.keySet()
            ORDER BY
                   Zuora__DueDate__c ASC
                 , Zuora__Balance2__c ASC
            ]; 
        
        
        //For each committed invoice,
        for(Zuora__ZInvoice__c inv : invoicesFromTrigger){
            System.debug('===== MS ===== BEFORE LOGIC: Invoice Balance: ['+inv.Zuora__Balance2__c+'], Bill To Email: ['+ inv.Bill_To_Email__c +'], Account isDunning: ['+inv.Zuora__BillingAccount__r.isDunning__c+'] Dunning Ststus: [' + inv.Dunning_Status__c + ']' );

            if(inv.Zuora__BillingAccount__r.surpressNotifications__c){
                // Do not send notifications
                return;
            }
/**** START Dunning Check *****/
            // first check to see if an invoice has a positive balance.
            if(inv.Zuora__Balance2__c > 0  && inv.Days_Past_Due__c > 0){
                // If there is a positive balance, 
                
                if( !inv.Zuora__BillingAccount__r.isDunning__c){
                    // and the billing account associated to the invoice is not currently engaged in a notification schedule, 
                    
                    // then the Billing Account and Invoice will be flagged as isDunning, 
                    // to indicate that they are actively sending notifications.
                    
                    if(!billingAcctountsToDun.contains(inv.Zuora__BillingAccount__c)){
                        inv.isDunning__c = true;
                        processed = true;
                        billingAcctountsToDun.add(inv.Zuora__BillingAccount__c);
                    }
                    
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
                    // take the Account out of dunning
                    if(!billingAcctountsToUnDun.contains(inv.Zuora__BillingAccount__c)){
                        billingAcctountsToUnDun.add(inv.Zuora__BillingAccount__c);
                    }
                    // invoicesToUpdate.add(inv);
                    processed = true;
                }

            }
            
/**** END Dunning Check *****/

/**** START Check Dunning Status for Actvivty History *****/
            
            DateTime today = DateTime.now();
            String todayStr = today.format('MM/DD/YYYY');
            
            if ( (oldMap != null) && (oldMap.get(inv.id) != null) ){
            
                if((oldMap.get(inv.id).Dunning_Status__c != '5 Day Email Sent' && newMap.get(inv.id).Dunning_Status__c == '5 Day Email Sent')){
                    // create 5 Day Notice task for Activiy History
    
                    List<Task> tasks = new List<Task>();
                    tasks.add(new Task(
                        ActivityDate = Date.today(),
                        Subject='Your Invoice is 5 days past due',
                        WhatId = inv.Zuora__BillingAccount__r.Zuora__Account__r.Id,
                        OwnerId = UserInfo.getUserId(),
                        Description = 'Dear Sir/Madam,\nThis is an automated reminder about the outstanding balance of'+ inv.Zuora__BillingAccount__r.Zuora__Balance__c + ' ' + inv.Zuora__BillingAccount__r.Zuora__Currency__c +' on your account as of ' + todayStr +'. Please see the chart below for a summary of the past due invoices for ' + inv.Zuora__BillingAccount__r.name + ' and please remit payment as soon as possible.\n'
                                    + getInvoiceTable(inv.Zuora__BillingAccount__r.Id)
                                    + '\n\nKindly send your remittance to the following:\nACH/Wire Transfer Instructions\nSilicon Valley Bank \n3003 Tasman Drive Santa Clara, CA 95054 USA\nRouting & Transit #: 121140399 \nAccount #: 3300816316 \nSWIFT Code: SVBKUS6S\nMake Checks Payable To\nOoyala, Inc. Dept LA \n23905 Pasadena, CA 91185 - 3905 \nUSA\nThank you for your business.\nSincerely,\nOoyala Billing Team',
                        Status='Completed'));
                        
                    System.debug('===== MS ===== insterting tasks [' + tasks + ']');  
    
                    insert tasks;
    
                }
                
                if((oldMap.get(inv.id).Dunning_Status__c != '14 Day Email Sent' && newMap.get(inv.id).Dunning_Status__c == '14 Day Email Sent')){
                    // create 5 Day Notice task for Activiy History
    
                    List<Task> tasks = new List<Task>();
                    tasks.add(new Task(
                        ActivityDate = Date.today(),
                        Subject='Your Invoice is 14 days past due',
                        WhatId = inv.Zuora__BillingAccount__r.Zuora__Account__r.Id,
                        OwnerId = UserInfo.getUserId(),
                        Description = 'Dear Sir/Madam,\nThis is an automated reminder about the outstanding balance of on your account as of ' + todayStr + '. Please see the chart below for a summary of the past due invoices for and please remit payment as soon as possible.If we do not receive payment on your open balance, your account may be disabled due to payment delinquency.'
                                    + getInvoiceTable(inv.Zuora__BillingAccount__r.Id)
                                    + '\n\nKindly send your remittance to the following:\nACH/Wire Transfer Instructions\nSilicon Valley Bank \n3003 Tasman Drive Santa Clara, CA 95054 USA\nRouting & Transit #: 121140399 \nAccount #: 3300816316 \nSWIFT Code: SVBKUS6S\nMake Checks Payable To\nOoyala, Inc. Dept LA \n23905 Pasadena, CA 91185 - 3905 \nUSA\nThank you for your business.\nSincerely,\nOoyala Billing Team',
                        Status='Completed'));
                        
                    System.debug('===== MS ===== insterting tasks [' + tasks + ']');  
    
                    insert tasks;
    
                }
                
                if((oldMap.get(inv.id).Dunning_Status__c != '21 Day Email Sent' && newMap.get(inv.id).Dunning_Status__c == '21 Day Email Sent')){
                    // create 5 Day Notice task for Activiy History
    
                    List<Task> tasks = new List<Task>();
                    tasks.add(new Task(
                        ActivityDate = Date.today(),
                        Subject='Your Invoice is 21 days past due',
                        WhatId = inv.Zuora__BillingAccount__r.Zuora__Account__r.Id,
                        OwnerId = UserInfo.getUserId(),
                        Description = 'Dear Sir/Madam,\nThis is an automated reminder about the outstanding balance of on your account as of ' + todayStr + '. If we do not receive payment on your open balance, your account will be disabled once your invoice is 30 days past due.'
                                    + getInvoiceTable(inv.Zuora__BillingAccount__r.Id)
                                    + '\n\nKindly send your remittance to the following:\nACH/Wire Transfer Instructions\nSilicon Valley Bank \n3003 Tasman Drive Santa Clara, CA 95054 USA\nRouting & Transit #: 121140399 \nAccount #: 3300816316 \nSWIFT Code: SVBKUS6S\nMake Checks Payable To\nOoyala, Inc. Dept LA \n23905 Pasadena, CA 91185 - 3905 \nUSA\nThank you for your business.\nSincerely,\nOoyala Billing Team',
                        Status='Completed'));
                        
                    System.debug('===== MS ===== insterting tasks [' + tasks + ']');  
    
                    insert tasks;
    
                }
            } else {
            
                if((newMap.get(inv.id).Dunning_Status__c == '5 Day Email Sent')){
                    // create 5 Day Notice task for Activiy History
    
                    List<Task> tasks = new List<Task>();
                    tasks.add(new Task(
                        ActivityDate = Date.today(),
                        Subject='Your Invoice is 5 days past due',
                        WhatId = inv.Zuora__BillingAccount__r.Zuora__Account__r.Id,
                        OwnerId = UserInfo.getUserId(),
                        Description = 'Dear Sir/Madam,\nThis is an automated reminder about the outstanding balance of'+ inv.Zuora__BillingAccount__r.Zuora__Balance__c + ' ' + inv.Zuora__BillingAccount__r.Zuora__Currency__c +' on your account as of ' + todayStr +'. Please see the chart below for a summary of the past due invoices for ' + inv.Zuora__BillingAccount__r.name + ' and please remit payment as soon as possible.\n'
                                    + getInvoiceTable(inv.Zuora__BillingAccount__r.Id)
                                    + '\n\nKindly send your remittance to the following:\nACH/Wire Transfer Instructions\nSilicon Valley Bank \n3003 Tasman Drive Santa Clara, CA 95054 USA\nRouting & Transit #: 121140399 \nAccount #: 3300816316 \nSWIFT Code: SVBKUS6S\nMake Checks Payable To\nOoyala, Inc. Dept LA \n23905 Pasadena, CA 91185 - 3905 \nUSA\nThank you for your business.\nSincerely,\nOoyala Billing Team',
                        Status='Completed'));
                        
                    System.debug('===== MS ===== insterting tasks [' + tasks + ']');  
    
                    insert tasks;
    
                }
                
                if((newMap.get(inv.id).Dunning_Status__c == '14 Day Email Sent')){
                    // create 5 Day Notice task for Activiy History
    
                    List<Task> tasks = new List<Task>();
                    tasks.add(new Task(
                        ActivityDate = Date.today(),
                        Subject='Your Invoice is 14 days past due',
                        WhatId = inv.Zuora__BillingAccount__r.Zuora__Account__r.Id,
                        OwnerId = UserInfo.getUserId(),
                        Description = 'Dear Sir/Madam,\nThis is an automated reminder about the outstanding balance of on your account as of ' + todayStr + '. Please see the chart below for a summary of the past due invoices for and please remit payment as soon as possible.If we do not receive payment on your open balance, your account may be disabled due to payment delinquency.'
                                    + getInvoiceTable(inv.Zuora__BillingAccount__r.Id)
                                    + '\n\nKindly send your remittance to the following:\nACH/Wire Transfer Instructions\nSilicon Valley Bank \n3003 Tasman Drive Santa Clara, CA 95054 USA\nRouting & Transit #: 121140399 \nAccount #: 3300816316 \nSWIFT Code: SVBKUS6S\nMake Checks Payable To\nOoyala, Inc. Dept LA \n23905 Pasadena, CA 91185 - 3905 \nUSA\nThank you for your business.\nSincerely,\nOoyala Billing Team',
                        Status='Completed'));
                        
                    System.debug('===== MS ===== insterting tasks [' + tasks + ']');  
    
                    insert tasks;
    
                }
                
                if((newMap.get(inv.id).Dunning_Status__c == '21 Day Email Sent')){
                    // create 5 Day Notice task for Activiy History
    
                    List<Task> tasks = new List<Task>();
                    tasks.add(new Task(
                        ActivityDate = Date.today(),
                        Subject='Your Invoice is 21 days past due',
                        WhatId = inv.Zuora__BillingAccount__r.Zuora__Account__r.Id,
                        OwnerId = UserInfo.getUserId(),
                        Description = 'Dear Sir/Madam,\nThis is an automated reminder about the outstanding balance of on your account as of ' + todayStr + '. If we do not receive payment on your open balance, your account will be disabled once your invoice is 30 days past due.'
                                    + getInvoiceTable(inv.Zuora__BillingAccount__r.Id)
                                    + '\n\nKindly send your remittance to the following:\nACH/Wire Transfer Instructions\nSilicon Valley Bank \n3003 Tasman Drive Santa Clara, CA 95054 USA\nRouting & Transit #: 121140399 \nAccount #: 3300816316 \nSWIFT Code: SVBKUS6S\nMake Checks Payable To\nOoyala, Inc. Dept LA \n23905 Pasadena, CA 91185 - 3905 \nUSA\nThank you for your business.\nSincerely,\nOoyala Billing Team',
                        Status='Completed'));
                        
                    System.debug('===== MS ===== insterting tasks [' + tasks + ']');  
    
                    insert tasks;
    
                }
            }
            
/**** END Check Dunning Status *****/

             // If the bill to email is not set, set it from the Billing Account BillTo Work Email

            if(inv.Bill_To_Email__c == null){
                inv.Bill_To_Email__c = inv.Zuora__BillingAccount__r.Zuora__BillToWorkEmail__c;
                // invoicesToUpdate.add(inv);
                processed = true;
            }
            
            if( inv.CSM_Owner_Email__c == null ){
                inv.CSM_Owner_Email__c = inv.Zuora__Account__r.CSM_Owner__r.Email;
                processed = true;
            }
            
            if(processed) {
                invoicesToUpdate.add(inv);
                processed = false;
            }

            System.debug('===== MS ===== AFTER LOGIC: Invoice Balance: ['+inv.Zuora__Balance2__c+'], Bill To Email: ['+ inv.Bill_To_Email__c +'], isDunning: ['+inv.isDunning__c+']');

        }       

        List<Zuora__ZInvoice__c> invoiceList = new List<Zuora__ZInvoice__c>{};
        
        invoiceList.addAll(invoicesToUpdate);
        System.debug('===== MS ===== AFTER LOGIC: invoicesToUpdate size: [' + invoiceList + ']');    
        update invoiceList; 
        System.debug('===== MS ===== AFTER UPDATE: invoicesToUpdate size: [' + [SELECT Bill_To_Email__c, Zuora__Balance2__c, isDunning__c, Zuora__BillingAccount__r.isDunning__c FROM Zuora__ZInvoice__c WHERE Id IN :newMap.keySet()] + ']');    


/****** Update Accounts *******/

        System.debug('===== MS ===== AFTER LOGIC: Accounts to dunn: [' + billingAcctountsToDun.size() + ']');

        List<Zuora__CustomerAccount__c> dunningUpdateList = [
            SELECT
                  Zuora__Account__c
                  , Zuora__Account__r.CSM_Owner__c
                  , Zuora__CustomerServiceRepName__c
                  , Zuora__Account__r.Id
                  , Zuora__Balance__c
                  , Zuora__Currency__c
                  , Zuora__BillToWorkEmail__c
                  , isDunning__c
                  , name
                  , surpressNotifications__c 
            FROM
                 Zuora__CustomerAccount__c 
            WHERE
                 Id = :billingAcctountsToDun 
            ];

        for(Zuora__CustomerAccount__c acct : dunningUpdateList){

            acct.isDunning__c = true;

            System.debug('===== MS ===== AFTER LOGIC: Account to update isDunning: [' + acct.name + ']');

        }

        update dunningUpdateList;


        System.debug('===== MS ===== AFTER LOGIC: Accounts to dunn: [' + billingAcctountsToUnDun.size() + ']');        

        List<Zuora__CustomerAccount__c> undunningUpdateList = [
            SELECT
                  Zuora__Account__c
                  , Zuora__Account__r.CSM_Owner__c
                  , Zuora__CustomerServiceRepName__c
                  , Zuora__Account__r.Id
                  , Zuora__Balance__c
                  , Zuora__Currency__c
                  , Zuora__BillToWorkEmail__c
                  , isDunning__c
                  , name
                  , surpressNotifications__c 
            FROM
                 Zuora__CustomerAccount__c 
            WHERE
                 Id = :billingAcctountsToUnDun
            ];

        for(Zuora__CustomerAccount__c acct : undunningUpdateList){

            acct.isDunning__c = false;

            System.debug('===== MS ===== AFTER LOGIC: Account to update NOT isDunning: [' + acct.name + ']');

        }

        update undunningUpdateList;
                
    }


     private String getInvoiceTable (String billingAccountID) {

        String invtable = '\n\nInvoice Number     Invoice Balance     Invoice Date     Payment Terms     Invoice Due Date     Days Past Due\n';

      List<Zuora__ZInvoice__c> invList = [
          SELECT Name, Zuora__Balance2__c, Zuora__DueDate__c, Zuora__InvoiceDate__c, Zuora__PaymentTerm__c, Days_Past_Due__c
          FROM Zuora__ZInvoice__c
          WHERE Zuora__BillingAccount__r.Id = :billingAccountID AND Zuora__Balance2__c > 0
        ];

        for(Zuora__ZInvoice__c inv : invList) {
            invtable += inv.Name + '     ' + inv.Zuora__Balance2__c + '     ' + inv.Zuora__InvoiceDate__c + '     ' + inv.Zuora__PaymentTerm__c + '     ' + inv.Zuora__DueDate__c + '     ' + inv.Days_Past_Due__c + '\n';
        }

        return invtable;
    }
}