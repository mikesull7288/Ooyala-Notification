/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestWatchers {

	static void checkData(Id accountid)
	{
		//starting checking the data
        List<Case> tmpList = [select watcher_1__c,watcher_2__c,watcher_3__c,watcher_4__c,watcher_5__c,
        			watcher_6__c,watcher_7__c,watcher_8__c,watcher_9__c,watcher_10__c from case where accountid=:accountid];        		
        for(Case tmp : tmpList){
	        System.assertEquals('a@163.com',tmp.Watcher_1__c);		
	        System.assertEquals('b@163.com',tmp.Watcher_2__c);	
	        System.assertEquals('c@163.com',tmp.Watcher_3__c);	
	        System.assertEquals('d@163.com',tmp.Watcher_4__c);	
	        System.assertEquals('e@163.com',tmp.Watcher_5__c);	
	        System.assertEquals('f@163.com',tmp.Watcher_6__c);	
	        System.assertEquals('g@163.com',tmp.Watcher_7__c);	
	        System.assertEquals('h@163.com',tmp.Watcher_8__c);	
	        System.assertEquals('i@163.com',tmp.Watcher_9__c);	
	        System.assertEquals('j@163.com',tmp.Watcher_10__c);  
        }
	}
	
    static testMethod void testUpdate() {
        //Prepare the data;
        Account a = new Account(name='testwatcher1',type='Test',billingcountry='China');
        insert a;
        Contact b = new Contact(lastname='test',firstname='watcher',accountid=a.id);
        insert b;
        
        List<case> cList = new List<case>();
        for(Integer i=0;i<200;i++){        
        	Case c = new Case(contactid=b.id,accountid=a.id,subject='test case for watcher task');
        	cList.add(c);        
        }
        insert cList;
        
        //trigger the update
        test.startTest();
        for(case c : cList)
        c.Watchers__c = 'a@163.com,b@163.com,c@163.com,d@163.com,e@163.com,f@163.com,g@163.com'+
        				',h@163.com,i@163.com,j@163.com';
        update cList;        	
        test.stopTest();
        
        //check data
        checkData(a.id);    	    				        				
    }
    
    static testMethod void testInsert() {
    	//Prepare the data;
    	Account a = new Account(name='testwatcher1',type='Test',billingcountry='China');
        insert a;
        Contact b = new Contact(lastname='test',firstname='watcher',accountid=a.id);
        insert b;
        //trigger the insert
        List<case> cList = new List<case>();
        test.startTest();
        for(Integer i=0;i<200;i++){
        	Case c = new Case(contactid=b.id,accountid=a.id,subject='test case for watcher task',
        				Watchers__c = 'a@163.com,b@163.com,c@163.com,d@163.com,e@163.com,f@163.com,g@163.com,h@163.com,i@163.com,j@163.com');
        	cList.add(c);
        }
        insert cList;        
        test.stopTest();
        
        //check data
       	checkData(a.id);
        
    }   
}