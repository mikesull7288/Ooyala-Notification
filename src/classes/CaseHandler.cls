/****************************************************************************
Author:   Sean Shen
Date:     2013-10-21
Purpose:  To handle the trigger events on the case object
Version:  1.0


*****************************************************************************/
public class CaseHandler{
    private List<case> cList;
    private Map<Id,case> cMap;
    
    public void setCaseList(List<case> cList){
        this.cList = cList;
    }
    
    public void setCaseMap(Map<Id,case> cMap){
        this.cMap = cMap;
    }
    
    public Boolean validateEmail(String email) {
        Boolean res = true;             
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: http://www.regular-expressions.info/email.html
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
    
        if (!MyMatcher.matches()) 
            res = false;
        return res; 
    }
    
    public void updateEmailFields(Boolean updateFlag){
        System.debug('function updateEmailFields: updateFlag='+updateFlag);
        for(case c: cList){
            case tmp = null;
            if(cMap!=null) tmp = cMap.get(c.Id);            
            updateEmailFieldsForOne(c,tmp,updateFlag);
        }
    }
    
    public void updateEmailFieldsForOne(Case nc,Case oc,Boolean updateFlag)
    {
        System.debug('function updateEmailFields: updateFlag='+updateFlag+' Watchers__c='+nc.Watchers__c);
        System.assert(nc!=null);
        //if user did not update the watcher__c field
        if(updateFlag){
            system.assert(oc!=null);
            if(nc.Watchers__c == oc.Watchers__c)
                return;
        }
                
         //clear all the watchers field     
        if(nc.Watchers__c == null || nc.Watchers__c == ''){
            for(Integer i=0;i<10;i++){
                nc.put('Watcher_'+(i+1)+'__c','');
            }
            return;
        }
        

        //set the 10 watchers field;        
        String[] emailArray = nc.Watchers__c.split(',');
        if(emailArray.size()>10){
            nc.Watchers__c.addError('You can not add more than 10 emails');
            return;
        }
        
        for(Integer i=0;i<emailArray.size();i++){
            System.debug('Email for case '+nc.Subject+': '+emailArray[i]);
            emailArray[i] = emailArray[i].trim();
            if(validateEmail(emailArray[i]))
                nc.put('Watcher_'+(i+1)+'__c',emailArray[i]);
            else{
                nc.Watchers__c.addError('Please enter valid email addresses:'+ emailArray[i]);
                break;
            }                
        }
        //clear the rest
        for(Integer i=emailArray.size();i<10;i++)
        {
            nc.put('Watcher_'+(i+1)+'__c','');
        }       
    }
}