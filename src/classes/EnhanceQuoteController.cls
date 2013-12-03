public with sharing class EnhanceQuoteController {
	private Zuora.zApi api;
	private final Opportunity opp;
	private final String CRMId;
	private final Map <String,List<SelectOption>> cachedSubOptions = new Map <String,List<SelectOption>>();
	
	public Boolean initFailed			{get; private set;}
	public String  selectedAccountType		{get;set;}
	public String  selectedAccount			{get;set;}
	public String  selectedSubscription		{get;set;}
	public String  selectedSubscriptionType		{get;set;}
	public String  selectedAmendmentType		{get;set;}
	public List<SelectOption> billingAccountList	{get;set;}
	public List<SelectOption> subscriptionList	{get;set;}
		
	public EnhanceQuoteController(ApexPages.StandardController controller) {
		this.initFailed = true;
		final String oppId = controller.getId();
		if (null == oppId || '' == oppId) {
			appendErrorMessage('Need to specify the id of opportunity to create a quote.');
			return;
		}	 
		
		final List<Opportunity> oppList = [SELECT Id, Account.Id FROM Opportunity WHERE Id = :oppId limit 1];
		if (oppList.size() != 1) {
			appendErrorMessage('Invalid opportunity specified to create a quote.');
			return;
		}	 
		this.opp = oppList[0];
		this.CRMId = this.opp.Account.Id;
		
		if (!Test.isRunningTest()) 
		try { 
			api = new Zuora.zApi();
			api.zlogin();
		} catch (Zuora.zAPIException e) {
			appendErrorMessage(e.getMessage());
			return;
		}
		this.initFailed = false;
	}


	public PageReference onload() {
		try {
			this.loadBillingAccountList();
		} catch (Zuora.zAPIException e) {
			appendErrorMessage(e.getMessage());
			return null;
		}
		return null;
	}
	
	public PageReference onSelectAccount() {
		try {
			this.loadSubscriptionList();
		} catch (Zuora.zAPIException e) {
			appendErrorMessage(e.getMessage());
			return null;
		}
		return null;
	}
	
	public PageReference goNewQuote() {
		PageReference  newQuotePage = Page.NewQuoteEdit;
		String quoteType = 'New';
		if ('amend' == selectedAmendmentType ) 
			quoteType = 'Amend';
		else if ('renew' == selectedAmendmentType) 
			quoteType = 'Renew';
		newQuotePage.getParameters().put('quoteType', quoteType);
		newQuotePage.getParameters().put('billingaccountid', this.selectedAccount);
		newQuotePage.getParameters().put('existsubscriptionid', this.selectedSubscription);
		newQuotePage.getParameters().put('oppid', String.valueOf(this.opp.Id).substring(0,15));
		newQuotePage.setRedirect(true);	 
 
		return newQuotePage;
	}
 
	public PageReference onSelectAccountType() {
		if ('new' == this.selectedAccountType) {
			this.selectedSubscriptionType = 'new';
		} else {
			try {
				this.loadBillingAccountList();
			} catch (Zuora.zAPIException e) {
				appendErrorMessage(e.getMessage()); 
				return null;
			}
			this.selectDefaultAccount();
		}	 
		return null;
	}

	private void selectDefaultAccount() {
		if (this.billingAccountList != null && this.billingAccountList.size() > 0) {
			this.selectedAccount = this.billingAccountList[0].getValue();
		}
		this.onSelectAccount();
	}

	public PageReference onSelectSubscriptionType() {
		if ('existing' == this.selectedSubscriptionType) {
			try {
				this.loadSubscriptionList();
			} catch (Zuora.zAPIException e) {
				appendErrorMessage(e.getMessage());
				return null;
			}
			this.selectDefaultSubscription();
		}	 
		return null;		 
	}   
	private void selectDefaultSubscription() {
		if (this.subscriptionList.size() > 0) {
			this.selectedAmendmentType = 'amend';
			this.selectedSubscription = this.subscriptionList[0].getValue();
		}
	}   

	private void loadBillingAccountList() {
		if (this.CRMId == null) return;
		//already queried from Zuora, no need to query again
		if (this.billingAccountList != null)
			return;
		else{
			//query from Zuora and build the billing account picklist
			this.billingAccountList = new List<SelectOption> ();
			String acczoql = 'SELECT AccountNumber, Name FROM Account WHERE Status = \'Active\' AND CrmId LIKE \'' + this.CRMId.substring(0, 15) + '%\'';
			List <Zuora.zObject> acclist;
			if (Test.isRunningTest()) acclist = new List<Zuora.zObject> (); else
			try {
				acclist = api.zquery(acczoql);
			} catch (Zuora.zAPIException e) {
				throw e;
			}
			
			for(Zuora.zObject acc: acclist) {
				String accvalue = (String)acc.getValue('Id');				 
				String acclabel = acc.getValue('Name') +  ', Acct#:' + acc.getValue('AccountNumber');								   
				this.billingAccountList.add(new SelectOption (accvalue, acclabel));
			} 
		}
	}   
	//query the subscription from zuora and build the picklist
	private void loadSubscriptionList() {
		this.subscriptionList = new  List<SelectOption>();	 
		String subzoql = 'SELECT Id, Name, ContractEffectiveDate, TermType, Status FROM Subscription WHERE TermType=  \'TERMED\' AND Status = \'Active\' AND AccountId = \'' + this.selectedAccount + '\'';
		List<Zuora.zObject> subscriptionList;
		if (this.selectedAccount == null) return;
		try { 
			subscriptionList = api.zquery(subzoql);
		} catch (Zuora.zAPIException e) {
			throw e;
		}				   
		
		for(Zuora.zObject sub : subscriptionList) {
			DateTime cedatetime = (DateTime)sub.getValue('ContractEffectiveDate');			 
			String sublabel = (String)sub.getValue('Name') +  ', Status: ' + (String)sub.getValue('Status') +  ', Contract Effective Date: ' +  cedatetime.date().format();
			this.subscriptionList.add(new SelectOption ((String)sub.getValue('Id'),sublabel));
		}
	}

	static private void appendErrorMessage(String message) {
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
	}

}