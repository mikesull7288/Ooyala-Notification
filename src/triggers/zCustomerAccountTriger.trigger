trigger zCustomerAccountTriger on Zuora__CustomerAccount__c (after update) {

    if(Trigger.newMap==null) return;
    if(Trigger.oldMap==null) return;

    zCustomerAccountTriggerHandler handler = new zCustomerAccountTriggerHandler();

    if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnBeforeUpdate(Trigger.newMap, Trigger.oldMap, Trigger.new);
    }
}