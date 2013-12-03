@isTest
public class EnhanceQuoteControllerTest extends Zuora.zApi {

  static testMethod void try_this() {
    Test.startTest();
    Zuora.zApi zApiInstance = new Zuora.zApi();
    zApiInstance.setEndpoint('https://apisandbox.zuora.com/apps/services/a/35.0');
    //Opportunity opp = [SELECT Id, Account.Id from Opportunity where Name = 'Test Yammer'];
	Account a = new Account(Name='Test Account'); 
	insert a; 
	Opportunity opp = new Opportunity(AccountId=a.Id, Name='Test Opportunity', StageName='Prospecting', CloseDate=Date.today(), Est_Monthly_Revenue__c = 0.0, CMRR_Technical_Support__c = 0.0 ); 
	insert opp;    
    Test.setCurrentPageReference(Page.EnhanceQuote);
    ApexPages.currentPage().getParameters().put('id', opp.id);
    ApexPages.StandardController apex = new ApexPages.StandardController(opp);
    EnhanceQuoteController con = new EnhanceQuoteController(apex);
    con.onLoad();
    con.onSelectAccountType();
    con.onSelectAccount();
    con.selectedSubscriptionType = 'existing';
    con.onSelectSubscriptionType();
    System.assertNotEquals(con.selectedAmendmentType, 'amend');
    con.selectedAmendmentType = 'amend';
    con.goNewQuote();
    con.selectedAmendmentType = 'renew';
    con.goNewQuote();
    System.assert(! Apexpages.hasMessages() );
    System.assertEquals( con.initFailed, false );
    //System.assertEquals( con.subscriptionList.size(), 0 );
    System.assertEquals( con.selectedAccountType, null );
    System.assertEquals( con.selectedAccount, null );
    System.assertEquals( con.selectedSubscription, null );
    System.assertEquals( con.selectedAmendmentType, 'renew' );
    System.assertEquals( con.billingAccountList.size(), 0 );
    System.assertEquals(ApexPages.currentPage().getUrl(), '/apex/enhancequote?id=' + opp.id);
    Test.stopTest();
  }

  static testMethod void maybe() {
    Test.startTest();
    Zuora.zApi zApiInstance = new Zuora.zApi();
    zApiInstance.setEndpoint('https://apisandbox.zuora.com/apps/services/a/35.0');
    Opportunity opp = New Opportunity(Name='Test Opportunity', CloseDate=Date.Today(), 
              Est_Monthly_Revenue__c=0, StageName='Legacy', CMRR_Technical_Support__c=0);
    insert opp;
    Test.setCurrentPageReference(Page.EnhanceQuote);
    ApexPages.currentPage().getParameters().put('id', opp.id);
    ApexPages.StandardController apex = new ApexPages.StandardController(opp);
    EnhanceQuoteController con = new EnhanceQuoteController(apex);
    con.onSelectAccount();
    con.onSelectAccountType();
    con.onSelectSubscriptionType();
    con.goNewQuote();
    System.assert(! Apexpages.hasMessages() );
    System.assertEquals( con.initFailed, false );
    System.assertEquals( con.selectedAccountType, null );
    System.assertEquals( con.selectedAccount, null );
    System.assertEquals( con.selectedSubscription, null );
    System.assertEquals( con.selectedAmendmentType, null );
    System.assertEquals( con.billingAccountList, null );
    System.assertEquals(ApexPages.currentPage().getUrl(), '/apex/enhancequote?id=' + opp.id);
    Test.stopTest();
  }

  static testMethod void negative() {
    Test.startTest();
    Opportunity opp = New Opportunity(Name='Test Opportunity', CloseDate=Date.Today(), 
              Est_Monthly_Revenue__c=0, StageName='Legacy', CMRR_Technical_Support__c=0);
    Test.setCurrentPageReference(Page.EnhanceQuote);
    ApexPages.currentPage().getParameters().put('id', '000000000000000'); // invalid opp id.
    ApexPages.StandardController apex = new ApexPages.StandardController(opp);
    EnhanceQuoteController con = new EnhanceQuoteController(apex);
    System.assert( Apexpages.hasMessages() );
    System.assertEquals( Apexpages.getMessages().size(), 1);
    System.assertEquals(ApexPages.getMessages()[0].getSummary(), 'Invalid opportunity specified to create a quote.');
    System.assertEquals( con.initFailed, true );
    Test.stopTest();
  }

  static testMethod void negativeTest() {
    Test.startTest();
    Opportunity opp = New Opportunity(Name='Test Opportunity', CloseDate=Date.Today(), 
              Est_Monthly_Revenue__c=0, StageName='Legacy', CMRR_Technical_Support__c=0);
    Test.setCurrentPageReference(Page.EnhanceQuote);
    ApexPages.StandardController apex = new ApexPages.StandardController(opp);
    EnhanceQuoteController con = new EnhanceQuoteController(apex);
    System.assert( Apexpages.hasMessages() );
    System.assertEquals( Apexpages.getMessages().size(), 1);
    System.assertEquals(ApexPages.getMessages()[0].getSummary(), 'Need to specify the id of opportunity to create a quote.');
    System.assertEquals( con.initFailed, true );
    Test.stopTest();
  }

}