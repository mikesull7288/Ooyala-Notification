/************************************************************************
 * This class simply schedules the zSubProdChargeUpdateScheduler batch job.
 ************************************************************************/
global class zSubProdChargeUpdateScheduler implements Schedulable {

    global void execute(SchedulableContext scx) {
        zSubProdChargeUpdateBatchable nlb = new zSubProdChargeUpdateBatchable();
        Database.executeBatch(nlb, 100);
    }

}