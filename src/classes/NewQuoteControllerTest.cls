@isTest
public class NewQuoteControllerTest {

	static testMethod void testNewQuotePage() {
		Test.startTest();
		// test opp
		try {Contact quoteContact = new Contact(LastName='Test');
		insert quoteContact;
		Opportunity quoteOpp = new Opportunity(Name='Test Opportunity', StageName='Legacy', 
			CloseDate=Date.Today(), Est_Monthly_Revenue__c=0, CMRR_Technical_Support__c=0);
		insert quoteOpp;
		// test page. set query params.
		PageReference pageRef = Page.NewQuoteEdit;
		Test.setCurrentPageReference(pageRef);
		ApexPages.currentPage().getParameters().put('oppid', quoteOpp.id);
		String thisPage = ApexPages.currentPage().getUrl();
		// test zuora quote
		zqu__Quote__c quoteZuoraQuote = new zqu__Quote__c();
		ApexPages.StandardController sc = new ApexPages.standardController(quoteZuoraQuote);
		NewQuoteController myPageCon = new NewQuoteController(sc); 
		insert quoteZuoraQuote;
		myPageCon.save();
		String savePage = ApexPages.currentPage().getUrl();
		// validate the good quote is good.
		String nextPage = pageRef.getUrl();
		System.assertEquals(nextPage, thisPage);
		System.assertEquals(quoteOpp.account.Id, null);
		System.assertEquals(myPageCon.quote.Name, 'Sample Quote Name');
		System.assertEquals(quoteZuoraQuote.Name, 'Sample Quote Name');
		System.assertEquals(myPageCon.quote.zqu__SubscriptionType__c, 'New Subscription');
		System.assertEquals(quoteZuoraQuote.zqu__SubscriptionType__c, 'New Subscription');
		System.assertEquals(myPageCon.quote.zqu__Opportunity__r.Id, quoteOpp.Id);
		System.assertEquals(quoteZuoraQuote.zqu__Opportunity__r.Id, quoteOpp.Id);
		System.assertEquals(myPageCon.quote.zqu__Opportunity__c, quoteOpp.Id);
		System.assertEquals(quoteZuoraQuote.zqu__Opportunity__c, quoteOpp.Id);
		System.assertEquals(quoteZuoraQuote.zqu__Currency__c, 'USD');
		System.assertEquals(quoteZuoraQuote.zqu__PaymentTerm__c, 'Net 30');
		System.assertEquals(savePage, thisPage);
		}
		catch (Exception e) {
			System.assertEquals('zqu.ZQException', e.getTypeName());
			System.assertEquals('Should Not specify id in the url.', e.getMessage());
		}
		Test.stopTest();
	}

	static testmethod void testNoemptyquoteidNewQuotePage() {
		Test.startTest();
		// test opp. insert quote first- invalid on new quote.
		Opportunity quoteOpp = new Opportunity(Name='Test Opportunity', StageName='Legacy', 
			CloseDate=Date.Today(), Est_Monthly_Revenue__c=0, CMRR_Technical_Support__c=0);
		insert quoteOpp;
		PageReference pageRef = Page.NewQuoteEdit;
		Test.setCurrentPageReference(pageRef);
		ApexPages.currentPage().getParameters().put('oppid', quoteOpp.id);
		zqu__Quote__c quote = new zqu__Quote__c();

		//insert quote;
		ApexPages.StandardController sc = new ApexPages.standardController(quote);
		try {
			NewQuoteController myPageCon = new NewQuoteController(sc); 
			System.assertEquals(2, 2); // should trigger a zqexception
		}
		catch (Exception e) {
			System.assertEquals('zqu.ZQException', e.getTypeName());
			System.assertEquals('Should Not specify id in the url.', e.getMessage());
		}
		Test.stopTest();
	}

	static testmethod void testNotoneoppQuotePage() {
		Test.startTest();
		// test zquote. opp is empty, otherwise default.
		Opportunity quoteOpp = new Opportunity(Name='Test Opportunity', StageName='Legacy', 
			CloseDate=Date.Today(), Est_Monthly_Revenue__c=0, CMRR_Technical_Support__c=0);
		insert quoteOpp;
		PageReference pageRef = Page.NewQuoteEdit;
		Test.setCurrentPageReference(pageRef);
		zqu__Quote__c quote = new zqu__Quote__c();

		ApexPages.StandardController sc = new ApexPages.standardController(quote);
		try {
			NewQuoteController myPageCon = new NewQuoteController(sc); 
			System.assertEquals(1, 2); // should trigger a zqexception
		}
		catch (Exception e) {
			System.assertEquals('zqu.ZQException', e.getTypeName());
			System.assertEquals('Need to specify the oppid in the url.', e.getMessage());
		}

		// test zquote. opp is invalid, otherwise default.
		ApexPages.currentPage().getParameters().put('oppid', quoteOpp.id + '1');
		sc = new ApexPages.standardController(quote);
		try {
			NewQuoteController myPageCon = new NewQuoteController(sc); 
			System.assertEquals(1, 2); // should trigger a zqexception
		}
		catch (Exception e) {
			System.assertEquals('zqu.ZQException', e.getTypeName());
			System.assertEquals('Invalid oppid.', e.getMessage());
		}
		Test.stopTest();
	}

}