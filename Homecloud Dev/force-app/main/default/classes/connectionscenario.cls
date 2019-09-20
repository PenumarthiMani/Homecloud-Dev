public class connectionscenario {
@AuraEnabled
    public static Connection__c connectionvalues(String Recordid,String objectname){
        connection__c con = new connection__c();
        if(objectname == 'Scenario__c'){
         con = [select id,Name,Homebuyer__c,Community__c,Division__c from connection__c where id =: recordid limit 1];
        }
        return con;
    }
    @AuraEnabled
    public static String communityname(string communityid,string contactid){
        community__c com = new community__c();
        com = [select id,Name from community__c where id =: communityid limit 1];
        contact co = new contact();
        co = [select id,Name from contact where id =: contactid limit 1];
        Date d = Date.today(); 
        String dateFormatString = 'yyyy-MM-dd';
        Date dToday = Date.today();
String dateStr = dToday.year() + '/' + dToday.month() + '/' + dToday.day();
        system.debug('dateStr:'+dateStr);
       // String s1 = d.format(dateFormatString);
     //   string datefor=d.day();
        String s = com.Name +'-' +dateStr+'-'+co.Name;
        system.debug('s:'+s);
        return s;
    }
    
}