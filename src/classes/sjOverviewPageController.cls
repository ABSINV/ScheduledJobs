public with sharing class sjOverviewPageController
{
    public List<Scheduled_Job__c> lsScheduledJobs {get; set;}
    public Id jobId {get; set;}        
    
    public sjOverviewPageController() 
    {
        lsScheduledJobs = [SELECT Name, CronId__c, Enabled__c, ApexClass__c, Description__c, Cron_Expression__c, Preferred_Start_Hour__c, Preferred_Start_Minutes__c, Month_Day_Number__c, Month_Day_Name_Rank__c, Month_Day_Name__c, Week_Days__c FROM Scheduled_Job__c];
    }

    public pageReference updateScheduledJobs()
    {
        List<Scheduled_Job__c> lsScheduledJobsNeedUpdate = new List<Scheduled_Job__c>();
        
        for(Scheduled_Job__c job : lsScheduledJobs)
        {
            if(!job.Enabled__c && job.cronid__c != null)
            {
                System.abortJob(job.cronid__c);

                job.cronid__c = null;

                lsScheduledJobsNeedUpdate.add(job);
            }
            else if(job.Enabled__c && job.cronid__c == null)
            {                 
                job.Cron_Expression__c = sjCronExpressionGenerator.getCronExpression(job.Preferred_Start_Hour__c, job.Preferred_Start_Minutes__c, job.Month_Day_Number__c, job.Month_Day_Name_Rank__c, job.Month_Day_Name__c, job.Week_Days__c);
                
                if(job.Use_Own_Scheduler__c)
                {
                    System.Type t = sjClassInfoManager.GetTypeForClassName(job.ApexClass__c);    
                    Schedulable cls = (Schedulable) JSON.deserialize('{}',t);            
                    job.cronid__c = System.schedule(job.Name, job.Cron_Expression__c, cls);             
                }
                else
                {
                    sjBatchScheduler scheduler = new sjBatchScheduler();   
                    System.Type t = sjClassInfoManager.GetTypeForClassName(job.ApexClass__c);     
                    Database.Batchable<SObject> cls = (Database.Batchable<SObject>) JSON.deserialize('{}',t);
                    scheduler.batchClass = cls;
                    id cronid = System.schedule(job.Name, job.Cron_Expression__c, scheduler); 
                    job.cronid__c = cronid;    
                }
                
                lsScheduledJobsNeedUpdate.add(job);
            }
        }
        update lsScheduledJobsNeedUpdate;                    
        PageReference redirectPage = new PageReference('/apex/sjOverviewPage');
        redirectPage.setRedirect(true);        
        return redirectPage;
    }

    public pageReference createNewJob()
    {
        PageReference redirect = new PageReference('/apex/sjDetailPage');
        redirect.setRedirect(true);
        return redirect;
    }

    public pageReference deleteJob()
    {
        if(jobId != null)
        {
            Scheduled_Job__c jobNeedDelete = [SELECT CronId__c FROM Scheduled_Job__c WHERE Id =: jobId];
            if(jobNeedDelete.cronId__c != null && jobNeedDelete.CronId__c != '')
            {
                System.abortJob(jobNeedDelete.CronId__c);
            }            
            delete jobNeedDelete;    
        }
        PageReference redirectPage = new PageReference('/apex/sjOverviewPage');
        redirectPage.setRedirect(true);        
        return redirectPage;
    }

    public pageReference editJob()
    {
        if(jobId != null)
        {
            PageReference editLink = new PageReference('/' + jobId + '/e');
            editLink.setRedirect(true) ;
            return editLink;
        }        
        return null;
    }    
}