/* *************************************************************************************  
 * Trigger: EntitlementFromAccountToCase 
 * This trigger updates the Case Entitlement Field according to the Entitlements on 
 * Account field of the Case.
 * Author – Cleartask
 * Date – 10/15/2012
 ***************************************************************************************/  
trigger EntitlementFromAccountToCase on Case (before insert, before update){
    Set<Id> accId = new Set<Id>();
    for(Case c : trigger.new){
        if (c.Entitlement == null) {
          accId.add(c.AccountId);
        }
        if (c.EntitlementId == null) {
          accId.add(c.AccountId);
        }
    }
    
    if(accId != null && accId.size()>0){
        Map<Id, Account> accMap = new Map<Id, Account>([select id, (select id from Entitlements where Status = 'Active' limit 1) from Account where Id in :accId]);
        if(accMap != null && accMap.size()>0){
             for(Case c : trigger.new){
                 Account acc = accMap.get(c.AccountId);
                 System.debug('acc'+ acc);
                 List<Entitlement> entlmentList = acc.Entitlements;
                 if(acc != null && entlmentList != null && entlmentList.size()>0){
                     System.debug('ent id'+ entlmentList[0].id);
                     c.EntitlementId = entlmentList[0].id;
                 }
               
             }
        }
    }
}