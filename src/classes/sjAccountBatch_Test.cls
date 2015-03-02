/*
*  Test class for sjAccountBatch. The batch doesn't contain any further logic, so the purpose of this class is to provide test coverage
*/
@isTest
private class sjAccountBatch_Test
{   
    static 
    {
        //Create test accounts

        //Create a list of accounts
        List<Account> lsAccounts = new List<Account>();
        for(integer i=0; i<100; i++)
        {
            lsAccounts.add(new Account(Name = 'Account ' + i));
        }
        insert lsAccounts;
    }

    static testMethod void checkBatch() 
    {
        Test.startTest();

        Database.executeBatch(new sjAccountBatch(), 200);

        Test.stopTest();
    }   
}