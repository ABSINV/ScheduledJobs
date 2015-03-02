global class sjAccountScheduler implements Schedulable 
{
	global void execute(SchedulableContext sc) 
	{
		database.executebatch(new sjAccountBatch(), 200);
	}
}