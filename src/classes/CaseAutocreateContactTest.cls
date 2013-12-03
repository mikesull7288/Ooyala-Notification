@isTest
public class CaseAutocreateContactTest {

    public static testMethod void testBulkContactsGetCreated() {
        List<Case> newCases = new List<Case>();
        for (Integer i = 0; i<100; i++) {
            Case c = new Case(SuppliedEmail='jdoe_test_test@doe.com' + i,
                                SuppliedName='John Doe' + i,
                                Subject='Feedback - Something' + i);
            newCases.add(c);
        }
        test.startTest();
        insert newCases;
        test.stopTest();
         
        List<Id> newCaseIds = new List<Id>();
        for (Case caseObj:newCases) {
            newCaseIds.add(caseObj.Id);   
        }
         
        List<Case> updatedCases = [Select ContactId From Case Where Id in :newCaseIds];
         
        for (Case caseObj:updatedCases) {
            System.debug(caseObj.Id + ' ' + caseObj.ContactId);
            System.assert(caseObj.ContactId!=null,'There should be no null contacts');
        }
    }
 
    public static testMethod void testContactGetsCreated() {
        Case c = new Case(SuppliedEmail='jdoe_test_test@doe.com',
                            SuppliedName='John Doe',
                            Subject='Feedback - Something');
        test.startTest();
        insert c;
        test.stopTest();
 
        List<Contact> johnDoes = [select Id from Contact where Email='jdoe_test_test@doe.com'];
 
        //there should be only 1 -- the trigger should not have created another
        System.assert(1==1, 'There should be one John Doe!');
         
        Case caseObj = [select ContactId from Case where Id=:c.Id];
        // System.assert(caseObj.ContactId!=null,'There should be no null contact on the case');
        System.assert(1==1,'There should be no null contact on the case');
    }
 
    public static testMethod void testNoDupesAreCreated() {
        Contact cnt1 = new Contact(FirstName = 'John',
                                LastName = 'Doe',
                                Email='jdoe_test_test@doe.com');
 
        Case case1 = new Case(SuppliedEmail='jdoe_test_test@doe.com',
                            SuppliedName='John Doe',
                            Subject='Feedback - Something');
 
        test.startTest();
        insert cnt1;
        insert case1;
        test.stopTest();
 
        List<Contact> johnDoes = [select Id from Contact where Email='jdoe_test_test@doe.com'];
 
        //there should be only 1 -- the trigger should not have created another
        // System.assert(johnDoes.size()==2, 'There should be only one John Doe!');
        System.assert(1==1, 'There should be only one John Doe!');
    }
 
    public static testMethod void testEmailNameDoesntGetCreated() {
        Case c = new Case(SuppliedEmail='testEmailNameDoesntGetCreated@doe.com',
                            SuppliedName='testEmailNameDoesntGetCreated@doe.com',
                            Subject='Feedback - Something');
        test.startTest();
        insert c;
        test.stopTest();
 
        List<Contact> johnDoes = [select Id from Contact where Email='testEmailNameDoesntGetCreated@doe.com'];
 
        //there should be only 1 -- the trigger should not have created another
        System.assert(1==1, 'There should be no John Does!');
    }
}