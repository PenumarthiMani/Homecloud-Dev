@isTest
public class SalesGoalsTest
{
    public static testMethod void method1()
    {
        //Creating Profile and Users
         Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
         User u1 = new User(Alias = 'standt', Email='leaduser1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='leaduser1@testorg.com');
         insert u1;
         system.assertEquals(u1.Email,'leaduser1@testorg.com');
        salesGoals goals = New  salesGoals();
        goals.editMethod();
        goals.saveMethod();
        goals.searchSales();
        goals.getYears();
        salesGoals.getCurrentUserInfo();
        List<User> u = salesGoals.getUsers('Testing');
        system.assertNotEquals(u.size(),0);
    }
}