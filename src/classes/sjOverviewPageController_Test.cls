/* Created by Sven Francornel
*  Test class for the ManageScheduledJobsController and the associated visualforce page 
*/
@isTest
private class sjOverviewPageController_Test
{   
    static testMethod void checkController() 
    {
        Id jobId = Database.executeBatch(new sjAccountBatch());
        Scheduled_Job__c scheduledJob = new Scheduled_Job__c();
        scheduledJob.Frequency__c = 'Monthly';
        scheduledJob.Month_Day_Name_Rank__c = '2';
        scheduledJob.Month_Day_Name__c = '2';
        scheduledJob.Cronid__c = jobId;
        scheduledJob.ApexClass__c = 'sjAccountScheduler';
        scheduledJob.Use_Own_Scheduler__c = true;
        insert scheduledJob;

        PageReference pageRef = Page.sjOverviewPage;
        Test.setCurrentPage(pageRef);   

        sjOverviewPageController customController = new sjOverviewPageController();

        String expectedUrl = '/apex/sjDetailPage';

        System.assertEquals(expectedUrl, String.valueOf(customController.createNewJob().getUrl()));

        customController.editJob();
        customController.jobId = scheduledJob.Id;
        customController.editJob();

        customController.updateScheduledJobs();

		customController.deleteJob();        

    }

    static testMethod void checkController2() 
    {
        Id jobId = Database.executeBatch(new sjAccountBatch());
        Scheduled_Job__c scheduledJob = new Scheduled_Job__c();
        scheduledJob.Frequency__c = 'Monthly';
        scheduledJob.Month_Day_Name_Rank__c = '2';
        scheduledJob.Month_Day_Name__c = '2';
        scheduledJob.Cronid__c = jobId;
        scheduledJob.ApexClass__c = 'sjAccountBatch';        
        insert scheduledJob;

        PageReference pageRef = Page.sjOverviewPage;
        Test.setCurrentPage(pageRef);   

        sjOverviewPageController customController = new sjOverviewPageController();

        String expectedUrl = '/apex/sjDetailPage';

        System.assertEquals(expectedUrl, String.valueOf(customController.createNewJob().getUrl()));

        for(Scheduled_Job__c sj : customController.lsScheduledJobs)
        {
        	sj.Enabled__c = false;
        }
		customController.updateScheduledJobs();

		for(Scheduled_Job__c sj : customController.lsScheduledJobs)
        {
        	sj.Enabled__c = true;
        }
		customController.updateScheduledJobs();

        customController.editJob();
        customController.jobId = scheduledJob.Id;
        customController.editJob();

        customController.updateScheduledJobs();

		customController.deleteJob();        

    }

    static testMethod void checkController3() 
    {
        Id jobId = Database.executeBatch(new sjAccountBatch());
        Scheduled_Job__c scheduledJob = new Scheduled_Job__c();
        scheduledJob.Frequency__c = 'Monthly';
        scheduledJob.Month_Day_Name_Rank__c = '2';
        scheduledJob.Month_Day_Name__c = '2';
        scheduledJob.Cronid__c = jobId;
        scheduledJob.ApexClass__c = 'sjAccountScheduler';
        scheduledJob.Use_Own_Scheduler__c = true;        
        insert scheduledJob;

        PageReference pageRef = Page.sjOverviewPage;
        Test.setCurrentPage(pageRef);   

        sjOverviewPageController customController = new sjOverviewPageController();

        String expectedUrl = '/apex/sjDetailPage';

        System.assertEquals(expectedUrl, String.valueOf(customController.createNewJob().getUrl()));

        for(Scheduled_Job__c sj : customController.lsScheduledJobs)
        {
        	sj.Enabled__c = false;
        }
		customController.updateScheduledJobs();

		for(Scheduled_Job__c sj : customController.lsScheduledJobs)
        {
        	sj.Enabled__c = true;
        	sj.Use_Own_Scheduler__c = true; 
        	scheduledJob.ApexClass__c = 'sjAccountScheduler';
        }
		customController.updateScheduledJobs();

        customController.editJob();
        customController.jobId = scheduledJob.Id;
        customController.editJob();

        customController.updateScheduledJobs();

		customController.deleteJob();        

    }
}