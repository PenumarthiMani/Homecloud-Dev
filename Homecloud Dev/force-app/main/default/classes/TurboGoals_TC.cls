@isTest
public class TurboGoals_TC
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
        
         List<Sales__c> goals = new List<Sales__c>();
        //TurboGoal goals = New  TurboGoal();
        TurboGoal.turboList(u1.Id,'2019');
        TurboGoal.turboListSave(goals);
        TurboGoal.currentyear();
        TurboGoal.fetchUser();
        
    }
}