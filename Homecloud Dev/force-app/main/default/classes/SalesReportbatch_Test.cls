@isTest 
public class SalesReportbatch_Test 
{    
    
    @testSetup static void testData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User usr = new User(Alias = 'standt', Email='standarduser@pradeep.com', 
            EmailEncodingKey='UTF-8', LastName='Testing1256', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@pradeep.com');
            
        insert usr;
        
        Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Homebuyer').getRecordTypeId();
        List<Contact> contlist = TestDataUtil.CreateContact(2,RecordTypeIdContact);
        insert contlist;
        
        List<Connection__c> con = TestDataUtil.Createconnection(1);
        con[0].Homebuyer__c = contlist[0].id;
        insert con;
        
        List<Division__c> div = TestDataUtil.Createdivision(1);
        insert div;
        List<Sales__c> sales = TestDataUtil.Createsales(div[0].Id,usr.Id);
        sales[0].Actuals__c = 2000;
        sales[0].External_id__c = '123456789';
        sales[0].Date__c = system.today();
        insert sales;
    
    }
    @istest
    public static void testMethod1() 
    {           
        Test.startTest();
        String query = 'select id, Name from User where isActive = true and Profile.Name != \'Chatter Free User\' Limit 10';
        Id batchInstanceId = database.executeBatch(new SalesReportbatch(query), 10); 
        Test.stopTest();
        User u = [select id,Name from User limit 1];
        System.assertNotEquals(u.Name, 'Chatter Free User');
  }
        
}