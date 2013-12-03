public with sharing class NewQuoteController {
  
    public final zqu__Quote__c quote          {get;set;}
    public final Opportunity   opp            {get;set;}
    public final List<Contact> contacts       {get;set;}  //contacts for selection
    public List<selectOption> acctcontacts       {get;set;}  //contacts for selection
    public Contact defaultcontact       {get;set;}  //contacts for selection
    public final  String  billingAccountID    {get; set;}
    public final  String  existSubscriptionID {get; set;}
    public final  String  quoteType           {get; set;}
    public Boolean initFailed                 {get; private set;}
    
    private final ApexPages.StandardController controller;
    private final Zuora.zApi api = new Zuora.zApi();
    
    public NewQuoteController(ApexPages.StandardController stdcontroller) {
        this.initFailed = true;
        this.controller = stdcontroller;
        this.quote = (zqu__Quote__c)stdcontroller.getRecord();
        if (null != quote.id) 
            throw new zqu.ZQException('Should Not specify id in the url.');

        if (this.quote.zqu__Currency__c == Null)
            this.quote.zqu__Currency__c = 'USD';
        if (this.quote.zqu__PaymentTerm__c == Null)
            this.quote.zqu__PaymentTerm__c = 'Net 30';
        this.quote.zqu__AutoRenew__c = true;
        
        this.quoteType = 'New';
                
        final String oppId = this.getParameter('oppid');
        if ('' == oppId) 
            throw new zqu.ZQException('Need to specify the oppid in the url.');
        final List<Opportunity> oppIdList = [select Id, Name, Account.Id, Account.Name from Opportunity where Id =:oppId limit 1];
        if (oppIdList.size() != 1) 
            throw new zqu.ZQException('Invalid oppid.');
        this.opp = oppIdList[0];
        this.quote.zqu__Opportunity__r = this.opp;
        this.quote.zqu__Opportunity__c = this.opp.Id;
        this.quote.Name = 'Sample Quote Name';
        Schema.DescribeSObjectResult dsr = Schema.SObjectType.zqu__Quote__c;
        if('New' == this.quoteType){
            this.quote.zqu__SubscriptionType__c = 'New Subscription';
            Schema.RecordTypeInfo defaultrtinfo = dsr.getRecordTypeInfosByName().get('Default');
            this.quote.RecordtypeId = defaultrtinfo.getRecordTypeId();
        }
        this.contacts = [SELECT Id, FirstName, LastName FROM Contact WHERE AccountId = :opp.Account.Id];       
        this.acctcontacts = new List<selectOption>();
        this.acctcontacts.add(new selectOption('', '- None -'));
        for (Contact contact : [SELECT Id, FirstName, LastName FROM Contact where AccountId = :opp.Account.Id ORDER BY LastName, FirstName DESC]) { 
            this.acctcontacts.add(new selectOption(contact.id, contact.FirstName + ' ' + contact.LastName)); 
        }
        // this.defaultcontact = this.contacts[0];
        this.initFailed = false;
    }

    public PageReference save(){
        final System.Savepoint quoteSavePoint = Database.setSavepoint();
        try {
            Database.upsert(this.quote);
            PageReference quoteDetailPage = new PageReference('https://zqu.na5.visual.force.com/apex/ZuoraProductSelector?id=' + this.quote.id);
            quoteDetailPage.setRedirect(true);
            return quoteDetailPage;
        } catch (DMLException e) {
            Database.rollback(quoteSavePoint);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
    
    private String getParameter(String paraname){
        if(ApexPages.currentPage().getParameters().get(paraname) != null)
            return String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get(paraname));
        return '';
    }
}