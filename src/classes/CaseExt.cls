public with sharing class CaseExt 
{
    String caseId {get;set;}
    Case caseObj {get;set;}
    List<CaseHistory> caseHistory {get;set;}

    public CaseExt(ApexPages.StandardController stdController) 
    {
        if(stdController.getRecord() != null)
        {
            // Retrieve current case
            Case current = (Case)stdController.getRecord();

            // Set the internal Id
            if(current != null && current.Id != null)
            {
                caseId = current.Id;

                List<Case> lst = [Select c.AccountId, c.CaseNumber, c.ClosedDate, c.ContactId, c.Contact.Phone, c.CreatedDate, c.Impact__c, c.JIRA_Issue__c, c.OwnerId, c.Reason, c.Status, c.Type from Case c where c.Id =:caseId];
                caseObj = lst[0];
                caseHistory = [SELECT ch.Id, ch.OldValue, ch.NewValue, ch.IsDeleted FROM CaseHistory ch WHERE ch.CaseId = :caseId];
            }

        }
        else
            System.Debug('Unable to access Case Record!');
    }

    public String result 
    {
        get
        {
            if(result == null)
            {
                HttpResponse resp = getResponse();
                result = resp.getBody();
            }
            return(result);
        }
        set;
    }

    public HttpResponse getResponse()
    {
         HttpResponse response = new HttpResponse();

        System.Debug('Response Set to HTTPResponse');

        // Http 
        String url = 'http://issue-server1.us-west-2.ooyala.com:4414/issues/update';

        System.Debug('End Point URL Set');

        HttpRequest  req = new HttpRequest();

        System.Debug('Request object Created');

        // Code for POST data
        req.setHeader('Content-Type', 'application/xml');        
        req.setMethod('POST');
        req.setEndpoint(url);

        System.Debug('Request Headers and Endpont Set');

        String xmlDoc = '';

        xmlDoc += '<Cases>';
        xmlDoc += '  <Case Id=\''+ caseId + '\' Number=\'' + caseObj.CaseNumber + '\'/>';
        xmlDoc += '   <Owner Id=\'' + caseObj.OwnerId + '\'/>';
        xmlDoc += '   <Account Id=\'' + caseObj.AccountId + '\'/>';
        xmlDoc += '   <Contact Id=\'' + caseObj.ContactId + '\'/>';
        xmlDoc += '   <Reason>' + caseObj.Reason + '</Reason>';
        xmlDoc += '   <CaseOrigin>' + caseObj.Contact.Phone + '</CaseOrigin>';
        xmlDoc += '   <Type>' + caseObj.Type + '</Type>';
        xmlDoc += '   <Impact>' + caseObj.Impact__c + '</Impact>';
        xmlDoc += '   <JIRA_Issue>' + caseObj.JIRA_Issue__c + '</JIRA_Issue>';
        xmlDoc += '   <CreatedDate>' + caseObj.CreatedDate + '</CreatedDate>';
        xmlDoc += '   <ClosedDate>' + caseObj.ClosedDate + '</ClosedDate>';
        if(caseHistory != null) {
          xmlDoc += '   <CaseHistories>';
            for(CaseHistory ch : caseHistory) {
                xmlDoc += '    <CaseHistory>';
                xmlDoc += '      <OldValue>' + ch.OldValue + '</OldValue>';
                xmlDoc += '      <NewValue>' + ch.NewValue + '</NewValue>';
                xmlDoc += '      <IsDeleted>' + (ch.IsDeleted ? 'true' : 'false') + '</IsDeleted>';
                xmlDoc += '    </CaseHistory>';
            }
          xmlDoc += '   </CaseHistories>';
        }
        xmlDoc += '  </Case>';
        xmlDoc += '</Cases>';

        System.Debug('XML Doc = ' + xmlDoc);

        req.setBody(xmlDoc);            

        System.Debug('Request Body set to XML');

        Http http = new Http(); 

        System.Debug('Http object created');

        response = http.send(req);
        
        System.Debug('Request Sent');
        
        if (response.getStatusCode() != 200)
        {
            // Error            
            System.Debug('Error Generated!');
            System.Debug('Code = ' + response.getStatusCode());
            System.Debug('Message = ' + response.getStatus());              
        }
        else
        {
            result = response.getBody();
            System.Debug('Result = ' + result);
            
            // Success
            System.Debug('Status Code SUCCESS');                                
        }                           

        return(response); 
    }
}