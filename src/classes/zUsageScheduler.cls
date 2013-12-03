/************************************************************************
 * This class simply schedules the zUsageBatchable batch job.
 ************************************************************************/
global class zUsageScheduler implements Schedulable {

    global void execute(SchedulableContext scx) {
        zUsageBatchable nlb = new zUsageBatchable();
        Database.executeBatch(nlb, 100);
    }

}