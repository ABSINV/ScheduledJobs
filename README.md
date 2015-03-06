Easily Manage Scheduled jobs in Salesforce
=============

The app makes use of a custom object, 2 visualforce pages and a few apex classes. Once you add the components to your org, there will be a tab called “Scheduled jobs”. When you click on the tab you will see the overview page for the scheduled jobs submitted via the app.

![ScreenShot](http://www.absi.be/uploadedImages/00_Structured_Data/Blog_Posts/scheduled-jobs.png)

First we are going to schedule a job. You have to click on the “Schedule new job” button. You will be redirect to the input page. The input page looks similar to the standard Salesforce page, but several features have been added.

![ScreenShot](http://www.absi.be/uploadedImages/00_Structured_Data/Blog_Posts/schedule-a-job.png)

You are able to give in a description for the job. There are more options to set the start time of the job. On the standard Salesforce page you can only set it to a certain hour. The app allows you to set the minutes as well. The minutes in the drop-down go up with steps of 15 minutes.

The frequency selection works the same as with the standard Salesforce page. It will show you additional options when you select weekly or monthly.

On the top right of the page you will see a checkbox “Use Own scheduler”. By default this isn’t selected. A scheduler class has been added to the app and works as a general scheduler. So it is no longer necessary to create scheduler classes for each batch yourself.

If you leave the checkbox unmarked, you have to specify a batch class in the drop-down below. The drop-down will only display apex classes that implement the Batchable interface.

If you don’t want to use the general scheduler class, mark the checkbox and you will be able to submit your own scheduler class. The dropdown below the checkbox will now only display the apex classes that implement the Schedulable interface.

![ScreenShot](http://www.absi.be/uploadedImages/00_Structured_Data/Blog_Posts/schedule-a-job-3.png)

When everything has been configured as you wish, click the save button. You will be redirected to the overview page again and you will see your newly scheduled job. By default a new job will always be enabled.

![ScreenShot](http://www.absi.be/uploadedImages/00_Structured_Data/Blog_Posts/schedule-a-job-4.png)

When you check the Scheduled Jobs page in the Setup Menu, you will notice the new job has been scheduled.

![ScreenShot](http://www.absi.be/uploadedImages/00_Structured_Data/Blog_Posts/schedule-a-job-5.png)

If you want to disable one or more jobs, change the “Enabled” checkbox and press the “Update scheduled jobs” button. When you marked a job to be disabled, the job will be aborted. In contrary to standard Salesforce, the information for the job hasn’t been deleted. If you want to enable the job again, just mark the checkbox and press the update button.

Sometimes you will have to schedule the job at another time. With standard Salesforce you have to delete the job and recreate it again. You can do it easier with this app. Just navigate to the overview page and click on the Edit link of the job. You will be redirected to the edit page where you can change the hour, the frequency, etc. Make your changes and click the save button.

Read everything at the following link: http://www.absi.be/managing-scheduled-jobs.aspx



Click the below link to deploy it to a production/developer organization <br/><br/>
<a href="https://githubsfdeploy.herokuapp.com?owner=ABSINV&repo=ScheduledJobs">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

thanks to @afawcett for the deploy to Salesforce button
http://andyinthecloud.com/2014/09/27/the-new-github-deploy-to-salesforce-tool-button/
