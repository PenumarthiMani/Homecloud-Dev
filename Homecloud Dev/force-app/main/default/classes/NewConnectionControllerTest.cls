@isTest
private class NewConnectionControllerTest{
    static testMethod void NewConnectionControllerMethod(){
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
        //com[0].Division__c = d[0].id;
        insert com;
        
         date day = system.today();    
         string connectionid = NewConnectionController.createConnection(a[0].id,d[0].id,com[0].id,day);
         system.assertNotEquals(connectionid,'');
        
         NewConnectionController.recordname(con.id);
        
    }
}