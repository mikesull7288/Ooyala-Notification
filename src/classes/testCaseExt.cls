@isTest
private class testCaseExt  
{
    static testMethod void testCaseExt() 
    {
        Test.startTest();
        Case caseObj = new Case();
        
        caseobj.Subject = 'Test Case';
        caseObj.Status = 'Open';
        caseObj.Origin = 'Phone';
        
        insert(caseObj);
        caseObj.Status = 'Closed';
        update caseObj;
                
        ApexPages.StandardController std = new ApexPages.StandardController(caseObj);
        CaseExt ext = new CaseExt(std);
        
        if (ext.result != null)
        {
            System.Debug('Response =' + ext.result);
        }
        Test.stopTest();
    }
}