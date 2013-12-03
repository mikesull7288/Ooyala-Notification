public class zInvoiceListComponentController {
public String     AttributeZuoraAccount    {get; set;}

  public List<Zuora__ZInvoice__c> getInvoiceList() {
  
      Date today = Date.today();
  
    return [
      SELECT Name, Zuora__Balance2__c, Zuora__DueDate__c, Zuora__InvoiceDate__c, Zuora__PaymentTerm__c, Days_Past_Due__c
      FROM Zuora__ZInvoice__c
      WHERE Zuora__BillingAccount__r.Id = :this.AttributeZuoraAccount AND Zuora__Balance2__c > 0
    ];
  }

}