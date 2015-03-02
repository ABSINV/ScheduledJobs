/* 
*  Class with methods to generate cron expressions based on the given input
*/
public with sharing class sjCronExpressionGenerator 
{
    //Method to create a cron expression based on the given input
    public static String getCronExpression(String hour, String minutes, String dayOfMonth, String dayOfMonthRank, String weekdayOfMonth, String daysOfWeek)
    {
        //Every cron expression has seconds, minutes and hours
        //Set the seconds to 0 by default and use the minutes and hours from the input
        String cronExpression = '0 ' + minutes + ' ' + hour; 

        //If the day of month has been specified/ monthly has been chosen as frequency
        if(dayOfMonth != '' && dayOfMonth != null)
        {
            //Add the day and the expression to run every month to the cron expression
            cronExpression += ' ' + dayOfMonth + ' */1 ?';
        }
        //If the weekday and the day from which week have been specified, add the values to the cron expression 
        else if(dayOfMonthRank != null && weekdayOfMonth != null)
        {
            //If the "last" option wasn't chosen, use the number specified in dayOfMonthRank
            if(dayOfMonthRank != '5')
            {
                cronExpression += ' ? * ' + weekdayOfMonth + '#' + dayOfMonthRank;  
            }
            //"Last" was chosen, so replace the number by "L" in the cron expression
            else cronExpression += ' ? * ' + weekdayOfMonth + 'L';
        }
        //Weekly has been specified as frequency
        else cronExpression += ' ? * ' + daysOfWeek + ' ';
        
        //return the cronexpression
        return cronExpression;
    }
}