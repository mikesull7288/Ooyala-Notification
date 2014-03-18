@isTest
private class zInvoiceTriggerHandlerTest {
/*    
    @isTest static void test_normal_execution() {

        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        insert zacct;
        Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
        insert testInv;
        Zuora__CustomerAccount__c afterInsertACCT = [SELECT Id, isDunning__c FROM Zuora__CustomerAccount__c WHERE Id =: zacct.Id limit 1];
        Zuora__ZInvoice__c afterInsertInv = [SELECT Id, isDunning__c FROM Zuora__ZInvoice__c WHERE Id =: testInv.Id limit 1];

        System.assert(afterInsertACCT.isDunning__c == true, 'Account NOT in dunning!!');
        System.assert(afterInsertInv.isDunning__c == true, 'Inv NOT in dunning!!');

        System.debug('===== MS ===== AFTER INSERT: ['+ [SELECT Bill_To_Email__c, Zuora__Balance2__c, isDunning__c, Zuora__BillingAccount__r.isDunning__c FROM Zuora__ZInvoice__c WHERE Id =: testInv.Id] + ']');
        System.debug('===== MS ===== AFTER INSERT: Zuora Billing Account isDunning: ['+  [SELECT Zuora__BillToWorkEmail__c, isDunning__c, surpressNotifications__c FROM Zuora__CustomerAccount__c WHERE Id = :zacct.id limit 1] +']');

    }

    @isTest static void test_normal_execution_Add_Zero_Dollar() {

        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        insert zacct;
        Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
        insert testInv;
        Zuora__CustomerAccount__c afterInsertACCT = [SELECT Id, isDunning__c FROM Zuora__CustomerAccount__c WHERE Id =: zacct.Id limit 1];
        Zuora__ZInvoice__c afterInsertInv = [SELECT Id, isDunning__c FROM Zuora__ZInvoice__c WHERE Id =: testInv.Id limit 1];

        System.assert(afterInsertACCT.isDunning__c == true, 'Account NOT in dunning!!');
        System.assert(afterInsertInv.isDunning__c == true, 'Inv NOT in dunning!!');

        Zuora__ZInvoice__c zeroDollarInv = Z_TestFactory.makeZInvoice(acct, zacct);
        zeroDollarInv.Zuora__TotalAmount__c = 0;
        zeroDollarInv.Zuora__Balance2__c = 0;
        insert zeroDollarInv;


        Zuora__CustomerAccount__c afterZeroDollarInsertACCT = [SELECT Id, isDunning__c FROM Zuora__CustomerAccount__c WHERE Id =: zacct.Id limit 1];
        Zuora__ZInvoice__c afterZeroDollarInsertTESTInv = [SELECT Id, isDunning__c FROM Zuora__ZInvoice__c WHERE Id =: testInv.Id limit 1];
        Zuora__ZInvoice__c afterZeroDollarInsertZEROInv = [SELECT Id, isDunning__c FROM Zuora__ZInvoice__c WHERE Id =: zeroDollarInv.Id limit 1];


        System.assert(afterZeroDollarInsertACCT.isDunning__c == true, 'Account NOT in dunning!!');
        System.assert(afterZeroDollarInsertTESTInv.isDunning__c == true, 'Test Inv NOT in dunning!!');
        System.assert(afterZeroDollarInsertZEROInv.isDunning__c == false, '$0Inv  in dunning!!');


    }

    @isTest static void test_normal_execution_Add_Open_Invoice() {

        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        insert zacct;
        Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
        insert testInv;
        Zuora__CustomerAccount__c afterInsertACCT = [SELECT Id, isDunning__c FROM Zuora__CustomerAccount__c WHERE Id =: zacct.Id limit 1];
        Zuora__ZInvoice__c afterInsertInv = [SELECT Id, isDunning__c FROM Zuora__ZInvoice__c WHERE Id =: testInv.Id limit 1];

        System.assert(afterInsertACCT.isDunning__c == true, 'Account NOT in dunning!!');
        System.assert(afterInsertInv.isDunning__c == true, 'Inv NOT in dunning!!');

        Zuora__ZInvoice__c openInv = Z_TestFactory.makeZInvoice(acct, zacct);
        openInv.Zuora__TotalAmount__c = 100;
        openInv.Zuora__Balance2__c = 100;
        openInv.Zuora__DueDate__c = date.newInstance(1961, 2, 17);
        insert openInv;


        Zuora__CustomerAccount__c afterACCT = [SELECT Id, isDunning__c FROM Zuora__CustomerAccount__c WHERE Id =: zacct.Id limit 1];
        Zuora__ZInvoice__c afterTESTInv = [SELECT Id, isDunning__c FROM Zuora__ZInvoice__c WHERE Id =: testInv.Id limit 1];
        Zuora__ZInvoice__c afterOPENInv = [SELECT Id, isDunning__c FROM Zuora__ZInvoice__c WHERE Id =: openInv.Id limit 1];


        System.assert(afterACCT.isDunning__c == true, 'Account NOT in dunning!!');
        System.assert(afterTESTInv.isDunning__c == true, 'Test Inv NOT in dunning!!');
        System.assert(afterOPENInv.isDunning__c == false, 'Open Inv  in dunning!!');


    }

    @isTest static void test_normal_execution_Add_Open_Invoice_Pay_Old() {

        // Set up Normal execution
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        insert zacct;
        Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
        insert testInv;
        Zuora__CustomerAccount__c afterInsertACCT = [SELECT Id, isDunning__c FROM Zuora__CustomerAccount__c WHERE Id =: zacct.Id limit 1];
        Zuora__ZInvoice__c afterInsertInv = [SELECT Id, isDunning__c FROM Zuora__ZInvoice__c WHERE Id =: testInv.Id limit 1];

        // assert normal excexution states
        System.assert(afterInsertACCT.isDunning__c == true, 'Account NOT in dunning!!');
        System.assert(afterInsertInv.isDunning__c == true, 'Inv NOT in dunning!!');

        System.debug('===== MS ===== test Invoice inserted testInv[' + testInv + ']');
        System.debug('===== MS ===== test Invoice from query afterInsertInv[' + afterInsertInv + ']');

        // Add open Invoice
        Zuora__ZInvoice__c openInv = Z_TestFactory.makeZInvoice(acct, zacct);
        openInv.Zuora__TotalAmount__c = 100;
        openInv.Zuora__Balance2__c = 100;
        openInv.Zuora__DueDate__c = date.newInstance(1961, 3, 17);
        insert openInv;


        Zuora__CustomerAccount__c afterACCT = [SELECT Id, isDunning__c FROM Zuora__CustomerAccount__c WHERE Id =: zacct.Id limit 1];
        Zuora__ZInvoice__c afterTESTInv = [SELECT Id, isDunning__c FROM Zuora__ZInvoice__c WHERE Id =: testInv.Id limit 1];
        Zuora__ZInvoice__c afterOPENInv = [SELECT Id, isDunning__c FROM Zuora__ZInvoice__c WHERE Id =: openInv.Id limit 1];

        // assert Account and test invoice are still in dunning and new inv is not
        System.assert(afterACCT.isDunning__c == true, 'Account NOT in dunning!!');
        System.assert(afterTESTInv.isDunning__c == true, 'Test Inv NOT in dunning!!');
        System.assert(afterOPENInv.isDunning__c == false, 'Open Inv  in dunning!!');

        // pay open Invoice
        System.debug('===== MS ===== Invoice paid [' + afterTESTInv + ']');
        afterTESTInv.Zuora__Balance2__c = 0;
        update afterTESTInv;

        Zuora__CustomerAccount__c afterPayACCT = [SELECT Id, isDunning__c FROM Zuora__CustomerAccount__c WHERE Id =: zacct.Id limit 1];
        Zuora__ZInvoice__c afterPayTESTInv = [SELECT Id, isDunning__c FROM Zuora__ZInvoice__c WHERE Id =: testInv.Id limit 1];
        Zuora__ZInvoice__c afterPayOPENInv = [SELECT Id, isDunning__c FROM Zuora__ZInvoice__c WHERE Id =: openInv.Id limit 1];

        // assert Account and new invoice are in dunning and test invoice is not
        System.assert(afterPayACCT.isDunning__c == true, 'Account NOT in dunning!!');
        System.assert(afterPayTESTInv.isDunning__c == false, 'Test Inv STILL in dunning!!');
        System.assert(afterPayOPENInv.isDunning__c == true, 'Open Inv NOT in dunning!!');


    }


    
    @isTest static void test_surpressNotifications() {
        // Implement test code
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        insert zacct;
        zacct.surpressNotifications__c = true;
        update zacct;
        Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
        insert testInv;
        
        System.assert(zacct.isDunning__c == false, 'Account in dunning!!');
        System.assert(testInv.isDunning__c == false, 'Inv in dunning!!');
        
        
    }
    
    @isTest static void test_CustomerAccount_isDunning() {
        // Implement test code
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        insert zacct;
        zacct.isDunning__c = true;
        update zacct;
        Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
        insert testInv;
        System.assert(zacct.isDunning__c == true, 'Test Account NOT put in Dunning');
        System.assert(testInv.isDunning__c == false, 'Test Invoice put in Dunning');
//        testInv.Zuora__Balance2__c = 0;
        
        
    }
    
    
        @isTest static void test_Invoice_to_ZeroBalance() {
        // Implement test code
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        insert zacct;
        //update zacct;
        Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
        insert testInv;

        Zuora__ZInvoice__c afterInsertInv = [SELECT Id, isDunning__c FROM Zuora__ZInvoice__c WHERE Id =: testInv.Id limit 1];

        System.assert(afterInsertInv.isDunning__c == true, 'Test Invoice NOT put in Dunning [' + afterInsertInv + ']');

        testInv.Zuora__Balance2__c = 0;
        //testInv.isDunning__c = true;
        update testInv;

        System.assert(testInv.isDunning__c == false, 'Test Invoice STILL in Dunning [' + testInv + ']');
        System.assert(zacct.isDunning__c == false, 'Test Account STILL in Dunning');
        
    }
    
    @isTest static void test_Invoice_ZeroBalance() {
        // Implement test code
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        insert zacct;
        update zacct;
        Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
        testInv.Zuora__Balance2__c = 0;
        //testInv.isDunning__c = true;
        insert testInv;
        
        System.assert(zacct.isDunning__c == false, 'Account STILL in dunning!!');
        System.assert(testInv.isDunning__c == false, 'Inv still dunning!!');
        
    }
    
    @isTest static void test_Volume() {
        // Implement test code
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        insert zacct;
        zacct.isDunning__c = true;
        update zacct;
        List<Zuora__ZInvoice__c> testInvList = new List<Zuora__ZInvoice__c>();
        for(Integer i=0;i<=1000;i++){
            Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
            testInvList.add(testInv);
        }
        insert testInvList;
        
        for(Zuora__ZInvoice__c inv : testInvList){
            
            inv.Zuora__Balance2__c = 0;
            inv.isDunning__c = true;
        }
            
        update testInvList;
        
    }
    //*/
    @isTest static void test_Volume_Acct_Hist() {
        // Implement test code
        List<Account> acctList = new List<Account>();
        List<Zuora__CustomerAccount__c> zacctList = new List<Zuora__CustomerAccount__c>();
        List<Zuora__ZInvoice__c> testInvList = new List<Zuora__ZInvoice__c>();

        for(Integer i=0;i<=200;i++){
            Account testAcc = new Account();
            testAcc.Name = 'my test account';
            testAcc.X2013_Vertical__c = 'test';
            testAcc.Backlot_Account_ID__c = '123';
            acctList.add(testAcc);
            
        }
        insert acctList;

        for(Integer i=0;i<acctList.size();i++){
            Account testAcc = acctList[i];
            Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(testAcc);
            zacctList.add(zacct);
        }
        insert zacctList;

        for(Integer i=0;i<acctList.size();i++){
            Account testAcc = acctList[i];
            Zuora__CustomerAccount__c zacct = zacctList[i];
            Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(testAcc, zacct);
            testInvList.add(testInv);
        }
        insert testInvList;

        for(Zuora__ZInvoice__c inv : testInvList){
            
            inv.Dunning_Status__c = '5 Day Email Sent';
            inv.isDunning__c = true;
        }
            
        update testInvList;
        
    } 



    /*

    @isTest static void test_Invoice_5_Day_Email_Sent() {
        // Implement test code
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        zacct.isDunning__c = true;
        insert zacct;
        Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
        testInv.Zuora__DueDate__c = Date.today();
        testInv.Zuora__Balance2__c = 10;
        testInv.isDunning__c = true;
        testInv.Dunning_Status__c = 'On Time';
        testInv.Bill_To_Email__c = 'test@test.com';
        testInv.CSM_Owner_Email__c = 'CSM@test.com';
        testInv.Dunning_Status__c = '5 Day Email Sent';
        insert testInv;
        testInv.Dunning_Status__c = '14 Day Email Sent';
        update testInv;
           
    }
    
    @isTest static void test_Invoice_14_Day_Email_Sent() {
        // Implement test code
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        zacct.isDunning__c = true;
        insert zacct;
        Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
        testInv.Zuora__DueDate__c = Date.today();
        testInv.Zuora__Balance2__c = 10;
        testInv.isDunning__c = true;
        testInv.Dunning_Status__c = 'On Time';
        testInv.Bill_To_Email__c = 'test@test.com';
        testInv.CSM_Owner_Email__c = 'CSM@test.com';
        testInv.Dunning_Status__c = '14 Day Email Sent';
        insert testInv;
        testInv.Dunning_Status__c = '21 Day Email Sent';
        update testInv;
           
    }
    
    @isTest static void test_Invoice_21_Day_Email_Sent() {
        // Implement test code
        Account acct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c zacct = Z_TestFactory.makeZAccount(acct);
        zacct.isDunning__c = true;
        insert zacct;
        Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(acct, zacct);
        testInv.Zuora__DueDate__c = Date.today();
        testInv.Zuora__Balance2__c = 10;
        testInv.isDunning__c = true;
        testInv.Dunning_Status__c = 'On Time';
        testInv.Bill_To_Email__c = 'test@test.com';
        testInv.CSM_Owner_Email__c = 'CSM@test.com';
        testInv.Dunning_Status__c = '21 Day Email Sent';
        insert testInv;
        testInv.Dunning_Status__c = '5 Day Email Sent';
        update testInv;
        
    }
//*/    
}