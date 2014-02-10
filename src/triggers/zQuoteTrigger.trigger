trigger zQuoteTrigger on zqu__Quote__c (after update) {

    if(Trigger.newMap==null) return;
    if(Trigger.oldMap==null) return;

  zQuoteTriggerHandler handler = new zQuoteTriggerHandler();
  
  if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnBeforeUpdate(Trigger.newMap, Trigger.oldMap, Trigger.new);
    }
}