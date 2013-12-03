trigger CompleteMilestones on Case (before update, before insert) {
    
    // Cannot be a portal user
    if (UserInfo.getUserType() != 'Standard') {
        return;
    }
        
    //Set completion time for milestones
    DateTime completionDate = System.now();
    
    //Set up lists for different milestone events
    List<Id> caseIdsFirstResponse = new List<Id>();
    List<Id> caseIdsEngAck = new List<Id>();
    List<Id> caseIdsEngFix = new List<Id>();
    List<Id> caseIdsEngStage = new List<Id>();
    List<Id> caseIdsRelStart = new List<Id>();
    List<Id> caseIdsRelFinish = new List<Id>();
    List<Id> caseIdsClosed = new List<Id>();        
        
    //Handle all events       
    for (Case c : Trigger.new) 
    {
        String status =  (c.Status == null) ? '' : c.Status;
        String engineeringStatus =  (c.Engineering_Status__c == null) ? '' : c.Engineering_Status__c;
        // make sure case has valid entitlement status
        if ((c.EntitlementId != null)&&
            (c.SlaStartDate <= completionDate)&&
            (c.SlaStartDate != null)&&
            (c.SlaExitDate == null)) 
        {
                
            // Process first response cases
            if(c.First_Response_Complete__c) {
                caseIdsFirstResponse.add(c.Id);
            }                
            
            // Process Eng Ack Cases
            if(engineeringStatus.equalsIgnoreCase(MilestoneConstants.IN_QUEUE) || engineeringStatus.equalsIgnoreCase(MilestoneConstants.REJECTED )) {
                caseIdsEngAck.add(c.Id);
            }                
                
            // Process Eng Fix Cases
            if(engineeringStatus.equalsIgnoreCase(MilestoneConstants.ANSWERED) 
                || engineeringStatus.equalsIgnoreCase(MilestoneConstants.IMPLEMENTED)) {
                caseIdsEngFix.add(c.Id);
            }                
                
            // Process Eng Stage Cases
            if(engineeringStatus.equalsIgnoreCase(MilestoneConstants.STAGED)) {
                caseIdsEngStage.add(c.Id);
            }                
                
            // Process Release Started Cases
            if(engineeringStatus.equalsIgnoreCase(MilestoneConstants.TESTED)) {
                caseIdsRelStart.add(c.Id);
            }                
                
            // Process Release Finished Cases
            if(engineeringStatus.equalsIgnoreCase(MilestoneConstants.DEPLOYED)) {
                caseIdsRelFinish.add(c.Id);
            }                
            
            // Process Closed Cases
            if(status.equalsIgnoreCase(MilestoneConstants.CLOSED)) {
                caseIdsClosed.add(c.Id);
            }                
        }
    }
        
    if (caseIdsFirstResponse.isEmpty() == false){
        MilestoneUtils.completeMilestone(caseIdsFirstResponse, MilestoneConstants.FIRST_RESPONSE, completionDate);
    }
    
    if (caseIdsEngAck.isEmpty() == false){
        MilestoneUtils.completeMilestone(caseIdsEngAck, MilestoneConstants.ENG_ACK, completionDate);
    }
    
    if (caseIdsEngFix.isEmpty() == false){
        MilestoneUtils.completeMilestone(caseIdsEngFix, MilestoneConstants.ENG_ACK, completionDate);
        MilestoneUtils.completeMilestone(caseIdsEngFix, MilestoneConstants.ENG_FIX, completionDate);
        //if goes back from Staged -> Implemented
        MilestoneUtils.openMilestone(caseIdsEngFix, MilestoneConstants.ENG_STAGE);
    }
        
    if (caseIdsEngStage.isEmpty() == false){
        MilestoneUtils.completeMilestone(caseIdsEngStage, MilestoneConstants.ENG_ACK, completionDate);
        MilestoneUtils.completeMilestone(caseIdsEngStage, MilestoneConstants.ENG_FIX, completionDate);
        MilestoneUtils.completeMilestone(caseIdsEngStage, MilestoneConstants.ENG_STAGE, completionDate);
    }
        
    if (caseIdsRelStart.isEmpty() == false){
        MilestoneUtils.completeMilestone(caseIdsRelStart, MilestoneConstants.ENG_ACK, completionDate);
        MilestoneUtils.completeMilestone(caseIdsRelStart, MilestoneConstants.ENG_FIX, completionDate);
        MilestoneUtils.completeMilestone(caseIdsRelStart, MilestoneConstants.ENG_STAGE, completionDate);
        MilestoneUtils.completeMilestone(caseIdsRelStart, MilestoneConstants.REL_START, completionDate);
    }
    
    if (caseIdsRelFinish.isEmpty() == false){
        MilestoneUtils.completeMilestone(caseIdsRelFinish, MilestoneConstants.ENG_ACK, completionDate);
        MilestoneUtils.completeMilestone(caseIdsRelFinish, MilestoneConstants.ENG_FIX, completionDate);
        MilestoneUtils.completeMilestone(caseIdsRelFinish, MilestoneConstants.ENG_STAGE, completionDate);
        MilestoneUtils.completeMilestone(caseIdsRelFinish, MilestoneConstants.REL_START, completionDate);
        MilestoneUtils.completeMilestone(caseIdsRelFinish, MilestoneConstants.REL_FINISH, completionDate);
    }
        
    if (caseIdsClosed.isEmpty() == false){
        System.debug('caseIdsFirstResponse = ' + caseIdsFirstResponse);
        
        MilestoneUtils.completeMilestone(caseIdsClosed, MilestoneConstants.FIRST_RESPONSE, completionDate);
        MilestoneUtils.completeMilestone(caseIdsClosed, MilestoneConstants.ENG_ACK, completionDate);
        MilestoneUtils.completeMilestone(caseIdsClosed, MilestoneConstants.ENG_FIX, completionDate);
        MilestoneUtils.completeMilestone(caseIdsClosed, MilestoneConstants.ENG_STAGE, completionDate);
        MilestoneUtils.completeMilestone(caseIdsClosed, MilestoneConstants.REL_START, completionDate);
        MilestoneUtils.completeMilestone(caseIdsClosed, MilestoneConstants.REL_FINISH, completionDate);
        MilestoneUtils.completeMilestone(caseIdsClosed, MilestoneConstants.RESOLUTION, completionDate);
            
    }
}

            /*List<Case> caseListClosed = [Select c.Id, c.ContactId, c.Contact.Email,
                              c.OwnerId, c.Status,
                              c.EntitlementId, c.SlaStartDate,
                              c.SlaExitDate
                           From Case c
                           Where c.Id IN :caseIdsClosed ];            
            if (caseListClosed.isEmpty() == false){
                List<Id> updateCasesClosed = new List<Id>();
                for (Case caseObj:caseListClosed) {
                        updateCasesClosed.add(caseObj.Id);
                }
                if(updateCasesClosed.isEmpty() == false)
                        MilestoneUtils.completeMilestone(caseIdsClosed, 'Resolution', completionDate);
                        MilestoneUtils.completeMilestone(caseIdsClosed, 'Restoration', completionDate);
                        MilestoneUtils.completeMilestone(caseIdsClosed, 'Communication', completionDate);
            } */