@isTest
public class StandardQuoteController_TC {
    @testSetup static void testdata(){
         Id recordtypeidhb = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Homebuyer').getRecordTypeId();
        List<Contact> con=TestDataUtil.createContact(1,recordtypeidhb);
        con[0].Type__c='Lead';
        insert con;
        List<Division__c> divlist = TestDataUtil.Createdivision(1);
        insert divlist;
        List<Community__c> comlist = TestDataUtil.Createcommunity(1,divlist[0].Id);
        insert comlist;
        List<Connection__c> conlist = TestDataUtil.Createconnection(1);
        conlist[0].Homebuyer__c=con[0].id;
        conlist[0].Division__c=divlist[0].Id;
        conlist[0].Community__c=comlist[0].Id;
        conlist[0].Prospect_Rating__c='A';
   insert conlist;  
    }
    @isTest static void validateRecTypeId(){
         Id recordid = StandardQuoteController.getRecTypeId('Regular');
        Id recordtypeidhb = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Homebuyer').getRecordTypeId();
        List<Contact> contact=[Select Id,Name from Contact where Name!='Testcontact0'];
        List<Contact> homb=[Select Id,Name from Contact where Name='Testcontact0'];
        Connection__c con=[Select Id,Name,Homebuyer__c from Connection__c where Homebuyer__c=:homb[0].Id limit 1];
        StandardQuoteController.RegRequired(con.id);
        System.assertNotEquals(recordid, Null);
    }
}