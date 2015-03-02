/* 
*  Test class for the sjCronExpressionGenerator class
*/
@isTest
private class sjCronExpressionGenerator_Test 
{   
    private static String hour;
    private static String minutes;
    private static String dayOfMonth;
    private static String dayOfMonthRank;
    private static String weekdayOfMonth;
    private static String daysOfWeek;

    private static String expectedCronExpression;
    private static String actualCronExpression;

    //Check the cron expression when weekly has been chosen as frequency
    static testMethod void checkWeeklyCronExpressionOutput() 
    {
        hour = '1';
        minutes = '30';
        daysOfWeek = '1';       

        expectedCronExpression = '0 30 1 ? * 1 ';
        actualCronExpression = sjCronExpressionGenerator.getCronExpression(hour, minutes, dayOfMonth, dayOfMonthRank, weekdayOfMonth, daysOfWeek);

        System.assertEquals(expectedCronExpression, actualCronExpression);
    }       

    //Check the cron expression when monthly and day of every month has been selected
    static testMethod void checkMonthlyDayCronExpressionOutput() 
    {
        hour = '14';
        minutes = '45';
        daysOfWeek = null;
        dayOfMonth = '5';       

        expectedCronExpression = '0 45 14 5 */1 ?';
        actualCronExpression = sjCronExpressionGenerator.getCronExpression(hour, minutes, dayOfMonth, dayOfMonthRank, weekdayOfMonth, daysOfWeek);

        System.assertEquals(expectedCronExpression, actualCronExpression);
    }   

    //Check the cron expression when monthly and rank day and weekday has been selected
    static testMethod void checkMonthlyRankDayCronExpressionOutput() 
    {
        hour = '9';
        minutes = '15';
        daysOfWeek = null;
        dayOfMonth = null;      
        dayOfMonthRank = '2';
        weekdayOfMonth = '3';

        expectedCronExpression = '0 15 9 ? * 3#2';
        actualCronExpression = sjCronExpressionGenerator.getCronExpression(hour, minutes, dayOfMonth, dayOfMonthRank, weekdayOfMonth, daysOfWeek);

        System.assertEquals(expectedCronExpression, actualCronExpression);
    }   

    //Check the cron expression when monthly and last rank day and weekday has been selected
    static testMethod void checkMonthlyRankLastDayCronExpressionOutput() 
    {
        hour = '9';
        minutes = '15';
        daysOfWeek = null;
        dayOfMonth = null;      
        dayOfMonthRank = '5';
        weekdayOfMonth = '3';

        expectedCronExpression = '0 15 9 ? * 3L';
        actualCronExpression = sjCronExpressionGenerator.getCronExpression(hour, minutes, dayOfMonth, dayOfMonthRank, weekdayOfMonth, daysOfWeek);

        System.assertEquals(expectedCronExpression, actualCronExpression);
    }
}