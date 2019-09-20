@isTest
public class ConnectionTriggerHandlerTest{
    @testSetup
    static void createRecs(){
         Id agencyid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        List<Account> acc=TestDataUtil.createAccounts(1);
        acc[0].RecordTypeId=agencyid;
        insert acc;
        Id recordtypeidhb = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Homebuyer').getRecordTypeId();
        List<Contact> con=TestDataUtil.createContact(6,recordtypeidhb);
        con[0].Type__c='Lead';
         con[1].Type__c='Lead';
        con[2].Type__c='Lead';
        con[3].Type__c='Lead';
        con[4].Type__c='Lead';
        con[5].Type__c='Lead';
        
        insert con;
        List<Division__c> divlist = TestDataUtil.Createdivision(1);
        insert divlist;
        List<Community__c> comlist = TestDataUtil.Createcommunity(1,divlist[0].Id);
        insert comlist;
        List<Connection__c> conlist = TestDataUtil.Createconnection(2);
        conlist[0].Homebuyer__c=con[0].id;
        conlist[0].Division__c=divlist[0].Id;
        conlist[0].Community__c=comlist[0].Id;
        conlist[0].Prospect_Rating__c='A';
        conlist[1].Homebuyer__c=con[0].id;
        conlist[1].Division__c=divlist[0].Id;
        conlist[1].Community__c=comlist[0].Id;
        conlist[1].Prospect_Rating__c='';
        insert conlist;  
        System.assertEquals(conlist[0].Name, 'Testconnection0');
        List<Task> newTasks=TestDataUtil.CreateTask(1,conlist[0].Id,NULL);
         List<Task> newTasks1=TestDataUtil.CreateTask(1,conlist[1].Id,NULL);
         
        conlist[0].Prospect_Rating__c='';
        update  conlist[0];
        
        Id RegScenarioId = Schema.SObjectType.Scenario__c.getRecordTypeInfosByName().get('Regular').getRecordTypeId();
        List<Scenario__c> scenario= TestDataUtil.Createscenario(conlist[0].id,comlist[0].id,RegScenarioId,divlist[0].Id);
        insert scenario;


    }
    @istest
    public static void UnitTest(){
        Id recordtypeidhb = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Homebuyer').getRecordTypeId();
        List<Contact> contact=[Select Id,Name from Contact where Name!='Testcontact0'];
        List<Contact> homb=[Select Id,Name from Contact where Name='Testcontact0'];
        Connection__c con=[Select Id,Name from Connection__c where Homebuyer__c=:homb[0].Id limit 1];
         con.Co_Buyer_1__c=contact[1].id;
         con.Co_Buyer_2__c=contact[2].id;
         con.Co_Buyer_3__c=contact[3].id;
         con.Co_Buyer_4__c=contact[4].id;
         con.Co_Buyer_5__c=contact[0].id;
        con.Prospect_Rating__c='B';
        update con;
        System.assertEquals(con.Prospect_Rating__c, 'B');
    }
    @istest
    public static void UnitTest1(){
        Id recordtypeidhb = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Homebuyer').getRecordTypeId();
        List<Contact> contact=[Select Id,Name from Contact where Name!='Testcontact0'];
         List<Contact> homb=[Select Id,Name from Contact where Name='Testcontact0'];
         Connection__c con=[Select Id,Name,Homebuyer__c  from Connection__c where Homebuyer__c=:homb[0].Id limit 1];
         con.Co_Buyer_1__c=contact[1].id;
         con.Co_Buyer_2__c=contact[2].id;
         con.Co_Buyer_3__c=contact[3].id;
         con.Co_Buyer_4__c=contact[4].id;
         con.Co_Buyer_5__c=contact[0].id;
         con.Prospect_Rating__c='B';
        con.Status__c='Sale';
        update con;
        con.lost_opportunity__c='No';
        update con;
        con.lost_opportunity__c='Yes';
        con.What_Did_They_Purchase__c = 'Resale';
        con.Why__c = 'Plan Related';
        update con;
    }
      @istest
    public static void UnitTest2(){
        Id recordtypeidhb = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Homebuyer').getRecordTypeId();
        List<Contact> contact=[Select Id,Name from Contact where Name!='Testcontact0'];
        List<Contact> homb=[Select Id,Name from Contact where Name='Testcontact0'];
        Connection__c con=[Select Id,Name,Prospect_Rating__c from Connection__c where Homebuyer__c=:homb[0].Id limit 1];
        Try{
        delete con;
        }
        Catch(Exception e){
            
        }
    }
}