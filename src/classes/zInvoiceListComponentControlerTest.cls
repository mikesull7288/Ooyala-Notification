@IsTest(SeeAllData=true)
public class zInvoiceListComponentControlerTest{

    public static testMethod void testgetInvoiceList(){
        Account testAcct = Z_TestFactory.makeAccount();
        Zuora__CustomerAccount__c testZacct = Z_TestFactory.makeZAccount(testAcct);
        Zuora__ZInvoice__c testInv = Z_TestFactory.makeZInvoice(testAcct, testZacct);
        
        zInvoiceListComponentController compContrl = new zInvoiceListComponentController();
        Test.startTest();
        compContrl.getInvoiceList();
        Test.stopTest();
    }
}