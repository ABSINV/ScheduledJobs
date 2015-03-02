/*
*  Batch class to process contacts
*  The batch doesn't perform any further logic, it is only here to help with the test coverage for the scheduled job functionality
*/
global class sjContactBatch implements Database.Batchable<sObject>
{   
    String query;
    
    global sjContactBatch() 
    {}
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        query = 'SELECT Id FROM Contact';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope) 
    {}
    
    global void finish(Database.BatchableContext BC) 
    {}   
}