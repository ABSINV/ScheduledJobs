/* 
*  Controller extension for the page to create/edit scheduled jobs   
*/
public with sharing class sjDetailPageController 
{
    //The scheduled job record of the standard controller
    public Scheduled_Job__c scheduledJob {get; set;}     

    //Variable to hold the id of the scheduled job when the id is specified in the querystring of the page   
    public Id existingJobId {get; set;}

    //A string array to hold the selected week days when the frequency has been set to Weekly
    public String[] weekdays {get; set;}
    
    //A boolean to indicate which month option needs to be disabled/enabled
    public Boolean disableMonthOption2 {get; set;}

    //A string that indicates which month option has been chosen
    public String selectedMonthOption {get; set;}             

    //Constructor of the extension
    public sjDetailPageController () 
    {
        //Get the id parameter from the querystring if it is present
        existingJobId = ApexPages.currentPage().getParameters().get('id');

        //Check if the id was specified in the querystring
        if(existingJobId != null)
        {
            //The id was specified, so get the scheduled job via the id
            this.scheduledJob = [SELECT Name, CronId__c, Enabled__c, Frequency__c, ApexClass__c, Use_Own_Scheduler__c, Description__c, Cron_Expression__c, Preferred_Start_Hour__c, Preferred_Start_Minutes__c, Month_Day_Number__c, Month_Day_Name_Rank__c, Month_Day_Name__c, Week_Days__c FROM Scheduled_Job__c WHERE Id =: existingJobId];
            
            //The scheduled job was created with a Weekly frequency
            if(this.scheduledJob.Week_Days__c != null)
            {
                weekdays = this.scheduledJob.Week_Days__c.split(',');
                disableMonthOption2 = true;   
                selectedMonthOption = '1';
            }
            else if(this.scheduledJob.Month_Day_Number__c != null)
            {
                disableMonthOption2 = true;   
                selectedMonthOption = '1';
                weekdays = new String[]{};   
            }
            else if(this.scheduledJob.Month_Day_Name_Rank__c != null && this.scheduledJob.Month_Day_Name__c != null)
            {
                disableMonthOption2 = false;   
                selectedMonthOption = '2';
                weekdays = new String[]{};   
            }
        }
        //No id was specified, we have the purpose to create a new scheduled job
        else 
        {
            //Init the scheduled job record
            this.scheduledJob = new Scheduled_Job__c();  
            
            //Init the array with the weekdays
            weekdays = new String[]{};        

            //By default, the first month option has been selected and the inputs of option 2 are disabled     
            disableMonthOption2 = true;     
            selectedMonthOption = '1';             
        }        
    }

    //Method to update or insert a scheduled job record
    public pageReference scheduleJob()
    {
        //It goes about an update
        if(existingJobId != null)
        {
            //If the frequenxy is set to weekly, clear the values for the month inputs
            if(scheduledJob.Frequency__c == 'Weekly')
            {
                scheduledJob.Month_Day_Number__c = null;
                scheduledJob.Month_Day_Name_Rank__c = null;
                scheduledJob.Month_Day_Name__c = null;

                //Get all the selected days and append them to have a string
                scheduledJob.Week_Days__c = String.join(weekdays, ',');
            }
            //The frequency has been set to monthly
            else if(scheduledJob.Frequency__c == 'Monthly')
            {
                //Clear the week days
                scheduledJob.Week_Days__c = null;
                
                //If the first month option has been selected, clear the inputs of the second month option
                if(selectedMonthOption == '1')
                {
                    scheduledJob.Month_Day_Name_Rank__c = null;
                    scheduledJob.Month_Day_Name__c = null;
                    scheduledJob.Use_Month_Day_Number__c = true;
                }
                //If the second month option has been selected, clear the inputs of the first month option
                else if(selectedMonthOption == '2')
                {
                    scheduledJob.Month_Day_Number__c = null;
                    scheduledJob.Use_Month_Day_Number__c = false;
                }
            }           

            //Get the cron expression via the frequency input values and assign it to the cron expression field of the scheduled job
            scheduledjob.Cron_Expression__c = sjCronExpressionGenerator.getCronExpression(scheduledjob.Preferred_Start_Hour__c, scheduledjob.Preferred_Start_Minutes__c, scheduledjob.Month_Day_Number__c, scheduledjob.Month_Day_Name_Rank__c, scheduledjob.Month_Day_Name__c, scheduledjob.Week_Days__c);
            
            //Try to update the scheduled job, first update necessary to check if there are any validation errors
            try
            {
                update scheduledjob;    
            }
            catch(Exception ex)
            {
                //The update failed, so display the exception on the page
                ApexPages.addMessages(ex);
                return null;
            }

            //The scheduled job was updated successfully, so abort the scheduled job and schedule it again with the updated cron expression
            if(scheduledJob.cronid__c != null)
            {
                System.abortJob(scheduledjob.cronid__c);        
            }            

            //Check if the user wants to use his own scheduler or use the general scheduler
            if(scheduledjob.Use_Own_Scheduler__c)
            {
                //A scheduler has been selected, so schedule the job and get the cron id
                System.Type t = sjClassInfoManager.GetTypeForClassName(scheduledjob.ApexClass__c);    
                Schedulable cls = (Schedulable) JSON.deserialize('{}',t);            
                scheduledjob.cronid__c = System.schedule(scheduledjob.Name, scheduledjob.Cron_Expression__c, cls);             
            }
            //The general scheduler is going to be used
            else
            {
                //Set up the general scheduler and schedule the job
                sjBatchScheduler scheduler = new sjBatchScheduler();   
                System.Type t = sjClassInfoManager.GetTypeForClassName(scheduledjob.ApexClass__c);     
                Database.Batchable<SObject> cls = (Database.Batchable<SObject>) JSON.deserialize('{}',t);
                scheduler.batchClass = cls;
                scheduledjob.cronid__c = System.schedule(scheduledjob.Name, scheduledjob.Cron_Expression__c, scheduler);                   
            }

            //The job has been scheduled and the cron id has been set to the cron id field on the scheduled job record, so it needs another update
            update scheduledjob;                
        }
        //A new scheduled job is being created
        else
        {
            //Get a list of scheduled jobs that have the same apex class selected as the new scheduled job
            List<Scheduled_Job__c> lsExistingJobs = [SELECT Id FROM Scheduled_Job__c WHERE ApexClass__c =: scheduledJob.ApexClass__c];            
            
            //The frequency has been set to weekly
            if(scheduledJob.Frequency__c == 'Weekly')
            {
                //Append the selected week days to 1 string and assign it to the week days field on the scheduled job
                scheduledJob.Week_Days__c = String.join(weekdays, ',');
            }
            //The frequency has been set to monthly
            else if(scheduledJob.Frequency__c == 'Monthly')
            {
                //The first month option has been selected
                if(selectedMonthOption == '1')
                {
                    //Clear the inputs for the second month option
                    scheduledJob.Use_Month_Day_Number__c = true;                        
                    scheduledJob.Month_Day_Name_Rank__c = null;
                    scheduledJob.Month_Day_Name__c = null;
                }
                //The second month option has been selected
                else if(selectedMonthOption == '2')
                {
                    //Clear the inputs for the first month option
                    scheduledJob.Month_Day_Number__c = null;
                    scheduledJob.Use_Month_Day_Number__c = false;                                                
                }
            }

            //Check if the list of scheduled jobs with the same apex class contains items, if it does, display error
            if(lsExistingJobs.size() > 0)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.sjDuplicateApexClass));
                return null;
            }    

            //Try to insert the scheduled job
            try
            {
                insert scheduledJob;
            }
            catch(Exception ex)
            {
                //There was an exception, so display the exception
                ApexPages.addMessages(ex);
                return null;
            }

            this.scheduledJob = [SELECT Name, CronId__c, Enabled__c, Frequency__c, ApexClass__c, Use_Own_Scheduler__c, Description__c, Cron_Expression__c, Preferred_Start_Hour__c, Preferred_Start_Minutes__c, Month_Day_Number__c, Month_Day_Name_Rank__c, Month_Day_Name__c, Week_Days__c FROM Scheduled_Job__c WHERE Id =: scheduledJob.Id];

            //Generate the cron expression based on the frequency inputs and assign it to the cron expression field on scheduled job
            scheduledJob.Cron_Expression__c = sjCronExpressionGenerator.getCronExpression(scheduledJob.Preferred_Start_Hour__c, scheduledJob.Preferred_Start_Minutes__c, scheduledJob.Month_Day_Number__c, scheduledJob.Month_Day_Name_Rank__c, scheduledJob.Month_Day_Name__c, scheduledJob.Week_Days__c);
            
            //The user indicated that he wants to use his own scheduler
            if(this.scheduledJob.Use_Own_Scheduler__c)
            {
                //Schedule the job and assign the cron id to the scheduled job
                System.Type t = sjClassInfoManager.GetTypeForClassName(scheduledJob.ApexClass__c);    
                Schedulable cls = (Schedulable) JSON.deserialize('{}',t);            
                scheduledJob.cronid__c = System.schedule(scheduledJob.Name, scheduledJob.Cron_Expression__c, cls);             
            }
            //The general scheduler will be used
            else
            {
                //Schedule the job and assign the cron id to the scheduled job
                sjBatchScheduler scheduler = new sjBatchScheduler();   
                System.Type t = sjClassInfoManager.GetTypeForClassName(scheduledJob.ApexClass__c);     
                Database.Batchable<SObject> cls = (Database.Batchable<SObject>) JSON.deserialize('{}',t);
                scheduler.batchClass = cls;
                scheduledJob.Cronid__c = System.schedule(scheduledJob.Name, scheduledJob.Cron_Expression__c, scheduler);
            }            

            //By default, the new scheduled job will be enabled
            scheduledJob.Enabled__c = true;
            
            //Update the scheduled job to include the cron id
            update scheduledJob;
        }

        //If no exceptions were thrown, create a page reference to the manage page and redirect to it
        PageReference redirect = new PageReference('/apex/sjOverviewPage');
        redirect.setRedirect(true);
        return redirect;
    }        

    //Method to invert the boolean that indicates if the second month option is disabled or not
    public void disableMonthOption()
    {        
        if(disableMonthOption2)        
        {
            disableMonthOption2 = false;
        }            
        else disableMonthOption2 = true;
    }

    //Method with the purpose to redirect to the manage page for all the scheduled jobs
    public pageReference goToManagerPage()
    {
        //Create a new page reference and return it
        PageReference redirect = new PageReference('/apex/sjOverviewPage');
        redirect.setRedirect(true);
        return redirect;
    }

    //Method to create a list of day options
    public List<SelectOption> getDays() 
    {
        //Create a list of slect options
        List<SelectOption> options = new List<SelectOption>();

        //Add all the days with the correct index needed for the cron expression
        options.add(new SelectOption('2','Monday'));
        options.add(new SelectOption('3','Tuesday'));
        options.add(new SelectOption('4','Wednesday'));
        options.add(new SelectOption('5','Thursday'));
        options.add(new SelectOption('6','Friday'));
        options.add(new SelectOption('7','Saturday'));
        options.add(new SelectOption('1','Sunday'));

        //Return the list of options
        return options;
    }

    //Method to create the 2 options for the month radiobutton options
    public List<SelectOption> getMonthOptions() 
    {
        //Create a new list of select options
        List<SelectOption> options = new List<SelectOption>();

        //Add the 2 options to the list
        options.add(new SelectOption('1','Option 1'));
        options.add(new SelectOption('2','Option 2'));       

        //Return the list
        return options;
    }

    //Method to create a select list with all the day numbers in a month
    public List<SelectOption> getMonthDayNumbers() 
    {
        //Create a list of select options
        List<SelectOption> options = new List<SelectOption>();         
        
        //Get the schema result for the field Month_Day_Number' of Scheduled_Job
        Schema.DescribeFieldResult monthDayNumberDescription = Scheduled_Job__c.Month_Day_Number__c.getDescribe();
        
        //Create a select option for every picklist value
        for (Schema.Picklistentry picklistEntry:monthDayNumberDescription.getPicklistValues())
        {
            options.add(new SelectOption(pickListEntry.getValue(), pickListEntry.getLabel()));
        }  

        //Return the list of select options
        return options;   
    }
    
    //Method to create a select list with the '1st', '2nd', etc options
    public List<SelectOption> getMonthDayNameRanks() 
    {
        //Create a list of select options
        List<SelectOption> options = new List<SelectOption>();         
        
        //Get the schema result for the field 'Month_Day_Name_Rank' of Scheduled_Job_
        Schema.DescribeFieldResult monthDayNameRankDescription = Scheduled_Job__c.Month_Day_Name_Rank__c.getDescribe();
        
        //init the index
        integer index = 1;

        //Loop through the picklist values and create a selectoption for every picklist value
        for (Schema.Picklistentry picklistEntry:monthDayNameRankDescription.getPicklistValues())
        {
            options.add(new SelectOption(String.valueOf(index), pickListEntry.getLabel()));
            index++;
        }  

        //Return the list of select options
        return options;   
    }  

    //Method to return the classes that are batchable
    public List<SelectOption> getBatchClasses()
    {
        //Create a new list to hold the select options        
        List<SelectOption> lsSelectOptions = new List<SelectOption>();
        
        //A list to hold all the batchable classes
        List<ApexClass> lsBatchClasses = new List<ApexClass>();
        
        //Loop over all the batchable apex classes 
        for(ApexClass ac : [SELECT Id, Name FROM ApexClass /*WHERE Name NOT IN: getUsedApexClasses()*/])
        {
            try
            {
                //Get the System type of the apex class via the helper method
                System.Type t = sjClassInfoManager.GetTypeForClassName(ac.Name);     
                
                //JSon desrialize the  system type and try to convert it to Database
                Database.Batchable<SObject> cls = (Database.Batchable<SObject>) JSON.deserialize('{}',t);
                lsBatchClasses.add(ac);
            }
            catch(Exception ex)
            {
                //Need to display a decent error message   
            }
        }

        //Add a default option
        lsSelectOptions.add(new SelectOption('None', 'None'));
        for(ApexClass ac : lsBatchClasses)
        {
            lsSelectOptions.add(new SelectOption(ac.Name, ac.Name));
        }

        //Return the list
        return lsSelectOptions;
    }

    //Method to get all the classes that implement schedulable
    public List<SelectOption> getScheduleClasses()
    {
        //Create a new list to hold the selectoptions
        List<SelectOption> lsSelectOptions = new List<SelectOption>();
        
        //Create a new list of apex classes
        List<ApexClass> lsSchedulableClasses = new List<ApexClass>();

        //Loop over all the apex classes in the org
        for(ApexClass ac : [SELECT Id, Name FROM ApexClass])
        {
            try
            {
                //Try to get the system type of the class via the name of the apex class
                System.Type t = sjClassInfoManager.GetTypeForClassName(ac.Name);     

                //Create an schedulable instance of the system type
                Schedulable cls = (Schedulable) JSON.deserialize('{}',t);

                //If the above hasn't caused an exception, add the apex class to the list of apex classes
                lsSchedulableClasses.add(ac);
            }
            catch(Exception ex)
            {
                //Need to display a decent error message   
            }
        }

        //Add a default select option to the list
        lsSelectOptions.add(new SelectOption('None', 'None'));

        //Create a selectoption for every apex class and add it to the list of selectoptions
        for(ApexClass ac : lsSchedulableClasses)
        {
            lsSelectOptions.add(new SelectOption(ac.Name, ac.Name));
        }

        //Return the list
        return lsSelectOptions;
    }
}