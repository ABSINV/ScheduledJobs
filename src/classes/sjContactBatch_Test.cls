/*
*  Test class for sjContactBatch. The batch doesn't contain any further logic, so the purpose of this class is to provide test coverage
*/
@isTest
private class sjContactBatch_Test 
{
    static 
    {
        //Create test contacts

        //Create a list of contacts
        List<Contact> lsContacts = new List<Contact>();
        for(integer i=0; i<100; i++)
        {
            lsContacts.add(new Contact(LastName = 'Contact ' + i));
        }
        insert lsContacts;
    }   

    static testMethod void checkBatch() 
    {
        Test.startTest();

        Database.executeBatch(new sjContactBatch(), 200);

        Test.stopTest();
    }   
}