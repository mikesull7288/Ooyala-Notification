/****************************************************************************
Author:   Sean Shen
Date:     2013-10-21
Purpose:  To handle the trigger events on the case object
Version:  1.0


*****************************************************************************/
public class CaseClass{
	private static CaseHandler ch = new CaseHandler();
	
	public static void doBeforeInsert(List<Case> cList){
		ch.setCaseList(cList);
		ch.updateEmailFields(false);	
	}
	
	public static void doBeforeUpdate(List<Case> clist, Map<Id,case> oldmap){
		ch.setCaseList(cList);
		ch.setCaseMap(oldmap);
		ch.updateEmailFields(true);
	}
}