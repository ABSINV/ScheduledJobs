/*
* Test class for the controller of sjDetailPage
*/
@isTest
private class sjDetailPageController_Test
{       
    //The init of the page and controller will be tested, as well as all the method with exception of the save method
    static testMethod void testPageBehaviourNewJobNoSave() 
    {
        PageReference pageRef = Page.sjDetailPage;
        Test.setCurrentPage(pageRef);

        sjDetailPageController customController = new sjDetailPageController();

        //Check if the variables of the custom controller have been initialized
        System.assertNotEquals(null, customController.scheduledJob);
        System.assertNotEquals(null, customController.weekdays);
        System.assert(customController.disableMonthOption2);
        System.assertEquals('1', customController.selectedMonthOption);

        //Test if the method, to get the batchable classes, works fine.
        List<SelectOption> lsBatchableClasses = customController.getBatchClasses();
        System.assert(lsBatchableClasses.size() > 0);       

        //Mark the checkbox to indicate you want to use your own scheduler
        customController.scheduledJob.Use_Own_Scheduler__c = true;
        //Test the method to get the schedulable classes
        List<SelectOption> lsSchedulableClasses = customController.getScheduleClasses();
        System.assert(lsSchedulableClasses.size() > 0);     

        //Check if the list of options will be created correctly based on the picklist values
        List<SelectOption> lsMonthDayNameRanks = customController.getMonthDayNameRanks();
        System.assert(lsMonthDayNameRanks.size() > 0);

        //Check if the list with the numbers of the days in a month will be created correctly
        List<SelectOption> lsMonthDayNumbers = customController.getMonthDayNumbers();
        System.assert(lsMonthDayNumbers.size() > 0);        

        //Check if the list with the 2 month options for the radiobutton group will be created correctly
        List<SelectOption> lsMonthOptions = customController.getMonthOptions();
        System.assert(lsMonthOptions.size() > 0);       

        //Check if the method to create a list of the days as select options works correctly
        List<SelectOption> lsDays = customController.getDays();
        System.assert(lsDays.size() > 0);       

        //Test the method to check the redirect to the manage page
        PageReference targetRedirect = customController.goToManagerPage();      
        String expectedTarget = '/apex/sjOverviewPage';
        String actualTarget = targetRedirect.getUrl();
        System.assertEquals(expectedTarget, actualTarget);

        //By calling the following controller method, the value of the boolen will be inverted      
        customController.disableMonthOption();
        System.assert(!customController.disableMonthOption2);
        customController.disableMonthOption();
        System.assert(customController.disableMonthOption2);
    }

    //Method to test the save action when no frequency has been selected
    static testMethod void testNewJobSaveNoFrequency() 
    {
        PageReference pageRef = Page.sjDetailPage;
        Test.setCurrentPage(pageRef);

        sjDetailPageController customController = new sjDetailPageController();
        
        //Simulate a click on the save button
        customController.scheduleJob();

        //Get the page messages, since no information has been entered, the frequency validation rule will prevent the insert and shop up in the page messages
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs)
        {
            if (msg.getDetail().contains('A frequency needs to be selected for the job.') )
            {
                b = true;
            }   
        }
        system.assert(b);

        //Set the frequency to weekly and select the sjAccountBatch.
        customController.scheduledJob.Frequency__c = 'Weekly';
        customController.weekdays.add('1');
        customController.scheduledJob.ApexClass__c = 'sjAccountBatch';
        customController.scheduleJob();

        //The job should have been scheduled without any errors, check if a scheduled job can be found
        List<Scheduled_Job__c> lsScheduledJobs = [SELECT Id, Cron_Expression__c FROM Scheduled_Job__c];
        System.assert(lsScheduledJobs.size() > 0);
        System.assertEquals('0 00 0 ? * 1', lsScheduledJobs[0].Cron_Expression__c);

        //Try to create another scheduled job for the same apex class
        //The insert should be prevented, since a scheduled job for that apex class already exists
        customController.scheduledJob.Frequency__c = 'Weekly';
        customController.weekdays.add('1');
        customController.scheduledJob.ApexClass__c = 'sjAccountBatch';
        customController.scheduledJob.Use_Own_Scheduler__c = true;
        customController.scheduleJob();

        //Get the page messages and check if the error message for a duplicate apex class is added to the page.
        msgs = ApexPages.getMessages();           
        b = false;
        for(Apexpages.Message msg:msgs)
        {
            if (msg.getDetail().contains('A scheduled job was already made for the chosen apex class')) 
            {
                b = true;
            }
        }
        system.assert(b);
    }

    //Test the creation of a scheduled job with his own scheduler
    static testMethod void testNewJobWithOwnscheduler() 
    {
        PageReference pageRef = Page.sjDetailPage;
        Test.setCurrentPage(pageRef);

        sjDetailPageController customController = new sjDetailPageController();
        
        //Create a scheduled job whereby a specified scheduler has been specified
        customController.scheduledJob.Frequency__c = 'Weekly';
        customController.weekdays.add('1');
        customController.scheduledJob.ApexClass__c = 'sjAccountScheduler';
        customController.scheduledJob.Use_Own_Scheduler__c = true;
        customController.scheduleJob();

        List<Scheduled_Job__c> lsScheduledJobs = [SELECT Id, Cron_Expression__c FROM Scheduled_Job__c];
        System.assert(lsScheduledJobs.size() > 0);
        System.assertEquals('0 00 0 ? * 1', lsScheduledJobs[0].Cron_Expression__c);      
    }

    //Test the creation of a scheduled job with the first month option selected
    static testMethod void testNewJobSaveMonthlyOption1() 
    {
        PageReference pageRef = Page.sjDetailPage;
        Test.setCurrentPage(pageRef);

        sjDetailPageController customController = new sjDetailPageController();

        //Create a monthly scheduled job
        customController.scheduledJob.Frequency__c = 'Monthly';
        customController.selectedMonthOption = '1';
        customController.scheduledJob.Month_Day_Number__c = '15';
        customController.scheduledJob.ApexClass__c = 'sjAccountBatch';        
        customController.scheduleJob();

        //The scheduled job should have been created withot errors, so check if you can find a scheduled job
        List<Scheduled_Job__c> lsScheduledJobs = [SELECT Id, Cron_Expression__c FROM Scheduled_Job__c];
        System.assert(lsScheduledJobs.size() > 0);
        System.assertEquals('0 00 0 15 */1 ?', lsScheduledJobs[0].Cron_Expression__c);     
    }

    //Test the creation of a scheduled job with the second month option selected
    static testMethod void testNewJobSaveMonthlyOption2() 
    {
        PageReference pageRef = Page.sjDetailPage;
        Test.setCurrentPage(pageRef);

        sjDetailPageController customController = new sjDetailPageController();
        
        //Create a scheduled job with month option 2 selected
        customController.scheduledJob.Frequency__c = 'Monthly';
        customController.selectedMonthOption = '2';
        customController.scheduledJob.Month_Day_Name_Rank__c = '2';
        customController.scheduledJob.Month_Day_Name__c = '2';
        customController.scheduledJob.ApexClass__c = 'sjAccountBatch';        
        customController.scheduleJob();

        //The scheduled job should have been created withot errors, so check if you can find a scheduled job
        List<Scheduled_Job__c> lsScheduledJobs = [SELECT Id, Cron_Expression__c FROM Scheduled_Job__c];
        System.assert(lsScheduledJobs.size() > 0);
        System.assertEquals('0 00 0 ? * 2#2', lsScheduledJobs[0].Cron_Expression__c);         
    }

    //Test the edit of an existing weekly job
    static testMethod void testEditExistingWeeklyJob() 
    {
        //Create a job id to pass to the scehduled job
        Id jobId = Database.executeBatch(new sjAccountBatch());

        //Create a new scheduled job without using the creation screen
        Scheduled_Job__c scheduledJob = new Scheduled_Job__c();
        scheduledJob.Frequency__c = 'Weekly';
        scheduledJob.Week_Days__c = '1';
        scheduledJob.Cronid__c = jobId;
        scheduledJob.ApexClass__c = 'sjAccountBatch'; 
        insert scheduledJob;        

        //Set up the visualforce page
        PageReference pageRef = Page.sjDetailPage;
        Test.setCurrentPage(pageRef);

        //Pass the job id as a parameter to the page
        pageRef.getParameters().put('id', scheduledJob.Id);
        sjDetailPageController customController = new sjDetailPageController();

        //Try to save the scheduled job again
        customController.scheduleJob();

        //The scheduled job should have been updated without a problem
        List<Scheduled_Job__c> lsScheduledJobs = [SELECT Id, Cron_Expression__c FROM Scheduled_Job__c];
        System.assert(lsScheduledJobs.size() > 0);
        System.assertEquals('0 00 0 ? * 1', lsScheduledJobs[0].Cron_Expression__c); 
    }

    //Test the edit of an existing monthly job
    static testMethod void testMonthlyJobOption1() 
    {
        //Create a job id to pass to the scehduled job
        Id jobId = Database.executeBatch(new sjAccountBatch());

        //Create a new scheduled job without using the creation screen
        Scheduled_Job__c scheduledJob = new Scheduled_Job__c();
        scheduledJob.Frequency__c = 'Monthly';
        scheduledJob.Month_Day_Number__c = '15';
        scheduledJob.Cronid__c = jobId;
        scheduledJob.ApexClass__c = 'sjAccountBatch'; 
        insert scheduledJob;        

        //Set up the visualforce page
        PageReference pageRef = Page.sjDetailPage;
        Test.setCurrentPage(pageRef);

        //Pass the job id as a parameter to the page
        pageRef.getParameters().put('id', scheduledJob.Id);
        sjDetailPageController customController = new sjDetailPageController();

        //Try to save the scheduled job again
        customController.scheduleJob();

        //The scheduled job should have been updated without a problem
        List<Scheduled_Job__c> lsScheduledJobs = [SELECT Id, Cron_Expression__c FROM Scheduled_Job__c];
        System.assert(lsScheduledJobs.size() > 0);
        System.assertEquals('0 00 0 15 */1 ?', lsScheduledJobs[0].Cron_Expression__c); 
    }

    //Test the edit of an existing monthly job
    static testMethod void testExistingMonthlyJobOption2() 
    {
        //Create a job id to pass to the scehduled job
        Id jobId = Database.executeBatch(new sjAccountBatch());

        //Create a new scheduled job without using the creation screen
        Scheduled_Job__c scheduledJob = new Scheduled_Job__c();
        scheduledJob.Frequency__c = 'Monthly';
        scheduledJob.Month_Day_Name_Rank__c = '2';
        scheduledJob.Month_Day_Name__c = '2';
        scheduledJob.Cronid__c = jobId;
        scheduledJob.ApexClass__c = 'sjAccountBatch'; 
        insert scheduledJob;
        
        //Set up the visualforce page
        PageReference pageRef = Page.sjDetailPage;
        Test.setCurrentPage(pageRef);

        //Pass the job id as a parameter to the page
        pageRef.getParameters().put('id', scheduledJob.Id);
        sjDetailPageController customController = new sjDetailPageController();

        //Try to save the scheduled job again
        customController.scheduleJob();

        //The scheduled job should have been updated without a problem
        List<Scheduled_Job__c> lsScheduledJobs = [SELECT Id, Cron_Expression__c FROM Scheduled_Job__c];
        System.assert(lsScheduledJobs.size() > 0);
        System.assertEquals('0 00 0 ? * 2#2', lsScheduledJobs[0].Cron_Expression__c);  
    }

    //Test the edit of an existing monthly job with a specified scheduler
    static testMethod void testExistingMonthlyJobOwnScheduler() 
    {
        //Create a job id to pass to the scehduled job
        Id jobId = Database.executeBatch(new sjAccountBatch());

        //Create a new scheduled job without using the creation screen
        Scheduled_Job__c scheduledJob = new Scheduled_Job__c();
        scheduledJob.Frequency__c = 'Monthly';
        scheduledJob.Month_Day_Name_Rank__c = '2';
        scheduledJob.Month_Day_Name__c = '2';
        scheduledJob.Cronid__c = jobId;
        scheduledJob.ApexClass__c = 'sjAccountScheduler';
        scheduledJob.Use_Own_Scheduler__c = true;
        insert scheduledJob;
        
        //Set up the visualforce page
        PageReference pageRef = Page.sjDetailPage;
        Test.setCurrentPage(pageRef);

        //Pass the job id as a parameter to the page
        pageRef.getParameters().put('id', scheduledJob.Id);
        sjDetailPageController customController = new sjDetailPageController();

        //Try to save the scheduled job again
        customController.scheduleJob();

        //The scheduled job should have been updated without a problem
        List<Scheduled_Job__c> lsScheduledJobs = [SELECT Id, Cron_Expression__c FROM Scheduled_Job__c];
        System.assert(lsScheduledJobs.size() > 0);
        System.assertEquals('0 00 0 ? * 2#2', lsScheduledJobs[0].Cron_Expression__c); 

        //Set the frequency to null and click the save button
        customController.scheduledJob.Frequency__c = null;        
        customController.scheduleJob();   

        //Get the page messages, since no information has been entered, the frequency validation rule will prevent the insert and shop up in the page messages
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs)
        {
            if (msg.getDetail().contains('A frequency needs to be selected for the job.') )
            {
                b = true;
            }   
        }
        system.assert(b);     
    }
}