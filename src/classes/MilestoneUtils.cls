/*
* Class - MilestoneUtils
*/
public class MilestoneUtils {
    
    public static void completeMilestone(List<Id> caseIds, String milestoneName, DateTime complDate) {
          
        List<CaseMilestone> cmsToUpdate = [SELECT Id, completionDate
                           FROM CaseMilestone cm
                           WHERE caseId in :caseIds 
                           AND cm.MilestoneType.Name = :milestoneName 
                           AND completionDate = null limit 1];
                           
        updateMilestone(cmsToUpdate, complDate);
    }
    
    public static void openMilestone(List<Id> caseIds, String milestoneName) {
          
        List<CaseMilestone> cmsToUpdate = [SELECT Id, completionDate
                           FROM CaseMilestone cm
                           WHERE caseId in :caseIds 
                           AND cm.MilestoneType.Name = :milestoneName 
                           AND completionDate != null limit 1];
                           
        updateMilestone(cmsToUpdate, null);
                           
    }
    
    public static void updateMilestone(List<CaseMilestone> cmsToUpdate, DateTime complDate) {
        if (cmsToUpdate.isEmpty() == false){
            for (CaseMilestone cm : cmsToUpdate){
                cm.completionDate = complDate;
            }
            update cmsToUpdate;
        } // end if
    }
    
    /*
    public static void resetMilestone(List<Id> caseIds, DateTime changeDate) {
          
        List<CaseMilestone> cmsToUpdate = [select Id
                           from CaseMilestone cm
                           where caseId in :caseIds and completionDate = null and IsViolated = false];
        if (cmsToUpdate.isEmpty() == false){
          for (CaseMilestone cm : cmsToUpdate){
            cm.startDate = changeDate;
          }
          update cmsToUpdate;
        } // end if
        
        List<Case> casesToUpdate = [select Id
                           from Case ca
                           where Id in :caseIds];
        if (casesToUpdate.isEmpty() == false){
            for (Case ca : casesToUpdate){
                ca.IsPValueChanged__c = false;
            }
            update casesToUpdate;
        } // end if
    }*/
  
    // test methods
    /*static testMethod void testCaseEntitlement(){
    
        Account a = new Account(Name = 'Test Account', BillingState = 'CA', BillingCountry = 'US');
        insert a;
        
        Contact c = new Contact(FirstName = 'Test', LastName = 'Tester', Email = 'test@tester.com', AccountId = a.Id);
        insert c;
        
        Entitlement entl = new Entitlement(Name = 'Test Ent', AccountId = a.Id, 
            StartDate = Date.Today().addDays(-3), EndDate = Date.Today().addDays(3));
        insert entl;
        
        Case caz = new Case(Subject = 'Test Case with Entitlement ', EntitlementId = entl.Id, ContactId = c.Id);
        insert caz;
        
        //verify the entitlement on the case
        System.assertEquals(entl.Id, [SELECT EntitlementId FROM Case WHERE Id = :caz.Id].EntitlementId);

    }*/


    static testMethod void testCompleteMilestoneViaCase(){
        Account a = new Account(Name = 'Test Account', BillingState = 'CA', 
        BillingCountry = 'US');
        insert a;
        
        Contact c = new Contact(FirstName = 'Test', LastName = 'Tester', Email = 'test@tester.com', AccountId = a.Id);
        insert c;
        
        Entitlement entl = new Entitlement(Name = 'Test Ent', AccountId = a.Id, 
            StartDate = Date.Today().addDays(-3), 
            EndDate = Date.Today().addDays(3),
            SlaProcessId = [SELECT Id FROM SlaProcess WHERE isActive = true LIMIT 1].Id);
        insert entl;
        
        Case caz = new Case(Subject = 'Test Case with Entitlement ', EntitlementId = entl.Id, ContactId = c.Id);
        insert caz;

        //now set the First_Response_Complete__c to true
        caz.First_Response_Complete__c = true;
        update caz;
       
        //verify the entitlement on the case
        System.assertEquals(entl.Id, [SELECT EntitlementId FROM Case WHERE Id = :caz.Id].EntitlementId);

        System.assert([SELECT completionDate
                       FROM CaseMilestone cm
                       WHERE caseId = :caz.Id 
                       AND cm.MilestoneType.Name = :MilestoneConstants.FIRST_RESPONSE].completionDate != null);        

        caz.Engineering_Status__c = 'Open';
        update caz;
        
        caz.Engineering_Status__c = MilestoneConstants.IN_QUEUE;
        update caz;
        System.assert([SELECT completionDate
                       FROM CaseMilestone cm
                       WHERE caseId = :caz.Id 
                       AND cm.MilestoneType.Name = :MilestoneConstants.ENG_ACK].completionDate != null);        
       

        
        caz.Engineering_Status__c = MilestoneConstants.IMPLEMENTED;
        update caz;
        System.assert([SELECT completionDate
                       FROM CaseMilestone cm
                       WHERE caseId = :caz.Id 
                       AND cm.MilestoneType.Name = :MilestoneConstants.ENG_FIX].completionDate != null);        
       
        
        caz.Engineering_Status__c = MilestoneConstants.STAGED;
        update caz;
        System.assert([SELECT completionDate
                       FROM CaseMilestone cm
                       WHERE caseId = :caz.Id 
                       AND cm.MilestoneType.Name = :MilestoneConstants.ENG_STAGE].completionDate != null);        
                    
        
        caz.Engineering_Status__c = MilestoneConstants.TESTED;
        update caz;
        System.assert([SELECT completionDate
                       FROM CaseMilestone cm
                       WHERE caseId = :caz.Id 
                       AND cm.MilestoneType.Name = :MilestoneConstants.REL_START].completionDate != null);        

        
        caz.Engineering_Status__c = MilestoneConstants.DEPLOYED;
        update caz;
        System.assert([SELECT completionDate
                       FROM CaseMilestone cm
                       WHERE caseId = :caz.Id 
                       AND cm.MilestoneType.Name = :MilestoneConstants.REL_FINISH].completionDate != null);        
        
        caz.Status = 'Closed';
        caz.Escalation_Reason__c ='Fix Release';
        update caz;
        System.assert([SELECT completionDate
                       FROM CaseMilestone cm
                       WHERE caseId = :caz.Id 
                       AND cm.MilestoneType.Name = :MilestoneConstants.RESOLUTION].completionDate != null);        
                 
    }
    
    static testMethod void testMilestoneConstants() {
        MilestoneConstants mc = new MilestoneConstants();
    }
}