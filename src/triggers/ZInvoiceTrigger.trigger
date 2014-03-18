trigger zInvoiceTrigger on Zuora__ZInvoice__c (after insert, after update) {
    
    System.debug('===== MS ===== ZInvoiceTrigger: isInsert ['+ Trigger.isInsert +'] isAfter [' + Trigger.isAfter +']');
    System.debug('===== MS ===== invoicesFromTrigger : [' + Trigger.new +']');

    ZInvoiceTriggerHandler handler = new zInvoiceTriggerHandler();

    if(Trigger.isAfter && Trigger.isInsert) {
        handler.SetFileds(Trigger.newMap, Trigger.oldMap, Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isUpdate) {
        handler.SetFileds(Trigger.newMap, Trigger.oldMap, Trigger.new);
    }


}