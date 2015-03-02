/*
*  General scheduler class. It can be used to call any batch class.
*/
global class sjBatchScheduler implements Schedulable 
{
    //Datamember to hold the apex class
    global Database.Batchable<SObject> batchClass{get;set;}
    
    //Datamember to hold the batchsize, the batch size is 200 by default
    global Integer batchSize{get;set;} {batchSize = 200;}
 	
 	//Execute method will start the execution of the specified batch class
    global void execute(SchedulableContext sc) 
    {
        database.executebatch(batchClass, batchSize);
    }
}