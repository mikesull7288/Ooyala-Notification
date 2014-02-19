global class zInvoiceScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        ZInvoiceBatchable nzb = new zInvoiceBatchable();
        Database.executeBatch(nzb, 100);
    }

}