public class SalesReportSchedule implements Schedulable{
    public void execute (SchedulableContext SC){
         //SalesReportbatch s1 = new  SalesReportbatch();
         //database.executeBatch(s1);
         
         String query = 'select id, Name from User where isActive = true and Profile.Name != \'Chatter Free User\'';
         if(Test.isRunningTest()){
            query = query + ' Limit 10';
         }
         Id batchInstanceId = database.executeBatch(new SalesReportbatch(query), 10); 
    }
    public void start(){
       if(!Test.isRunningTest()){
       system.schedule ('Sales Batch 1', '0 30 23 * * ?', new SalesReportSchedule());
       system.schedule ('Sales Batch 2', '0 30 11 * * ?', new SalesReportSchedule());
       }
    }
}