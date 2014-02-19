trigger zAccountTrigger on Account (after update) {

	if(Trigger.newMap==null) return;
	if(Trigger.oldMap==null) return;

	zAccountTriggerHandler handler = new zAccountTriggerHandler();

	if(Trigger.isUpdate && Trigger.isAfter){
		handler.OnAfterUpdate(Trigger.newMap, Trigger.oldMap, Trigger.new);
	}
}