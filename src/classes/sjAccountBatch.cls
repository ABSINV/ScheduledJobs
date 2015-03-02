global class sjAccountBatch implements Database.Batchable<sObject> {
	
	String query;
	
	global sjAccountBatch() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		query = 'SELECT Id FROM Account';
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
	
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}	
}