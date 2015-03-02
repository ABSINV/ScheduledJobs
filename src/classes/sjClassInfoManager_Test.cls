/* 
*  Test class for the sjClassInforManager class
*/
@isTest
private class sjClassInfoManager_Test 
{   
    public testMethod static void testGetType() 
    {
        //Try to get the system type of 'sjTest'. The class doesn't exist, so the method should return null
        System.assertEquals(null, sjClassInfoManager.GetTypeForClassName('sjTest'));

        //Try to get an existing class
        System.assertEquals(Type.forName('sjAccountBatch'), sjClassInfoManager.GetTypeForClassName('sjAccountBatch'));

        //Try to get an existing class with a namespace prefix
        System.assertEquals(Type.forName('sjAccountBatch'), sjClassInfoManager.GetTypeForClassName('sj.sjAccountBatch'));
    }   
}