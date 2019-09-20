@isTest
private class ContactTriggerHandlerTest{
    static testMethod void ContactTriggerHandlerMethod(){
        Id accRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Homebuyer').getRecordTypeId();
        List<Contact> a = TestDataUtil.CreateContact(1,accRecordType);
        insert a;
        List<Division__c> d = TestDataUtil.Createdivision(1);
        Insert d;
        Contact con = new Contact(LastName = 'Test Contact');
        insert con;
        Lead lead=new Lead(LastName='Doe',FirstName='John',Company='Test',Status='Inquiry');
        insert lead;
        
        List<Community__c> com =  TestDataUtil.Createcommunity(1,d[0].id);
        insert com;
        List<Connection__c> conlist = TestDataUtil.Createconnection(1);
        conlist[0].Homebuyer__c = a[0].id;
        insert conlist;
        Try{
            Delete a[0];
        }
        Catch(Exception e){
            
        }
    }
}