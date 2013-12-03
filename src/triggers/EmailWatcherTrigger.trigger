/****************************************************************************
Author:   Sean Shen
Date:     2013-10-21
Purpose:  Trigger for splitting the values in watchers field into 10 email fields
Version:  1.0


*****************************************************************************/
trigger EmailWatcherTrigger on Case (before insert, before update) {
   if(Trigger.isInsert){					
		CaseClass.doBeforeInsert(Trigger.new);			
	}		
	if(Trigger.isUpdate){
			CaseClass.doBeforeUpdate(Trigger.new,Trigger.oldMap);					
	}
}