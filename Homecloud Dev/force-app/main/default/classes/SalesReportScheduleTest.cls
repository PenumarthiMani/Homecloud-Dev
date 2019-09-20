@istest
public with sharing class SalesReportScheduleTest {
    static testmethod void SalesReport_schedule_Test()
    {
        Test.StartTest();
            SalesReportSchedule sh1 = new SalesReportSchedule();
            String sch = '0 0 23 * * ?';
            system.schedule('Test SalesReport schedule', sch, sh1); 
        Test.stopTest();           
     }
    static testmethod void SalesReport_schedule_Test2()
    {
        Test.StartTest();
            SalesReportSchedule sh1 = new SalesReportSchedule();
            sh1.start();
        Test.stopTest();  
              
     }
   
}