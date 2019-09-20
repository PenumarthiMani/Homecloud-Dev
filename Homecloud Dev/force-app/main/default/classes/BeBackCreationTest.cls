@istest 
public class BeBackCreationTest{
    @testSetup static void methodName() {
        Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Homebuyer').getRecordTypeId();
        List<Contact> contlist = TestDataUtil.CreateContact(2,RecordTypeIdContact);
        insert contlist;
        List<Connection__c> conlist = TestDataUtil.Createconnection(1);
        conlist[0].Homebuyer__c = contlist[0].id;
        insert conlist;
        List<Division__c> divlist = TestDataUtil.Createdivision(1);
        insert divlist;
        List<Community__c> comlist = TestDataUtil.Createcommunity(1,divlist[0].Id);
        insert comlist;
        Id RecordTypeIdtraffic = Schema.SObjectType.Traffic__c.getRecordTypeInfosByName().get('Registered').getRecordTypeId();
        List<Traffic__c> tralist = TestDataUtil.CreateTraffic(conlist[0].Id,comlist[0].Id,RecordTypeIdtraffic);
        tralist[0].Date__c = system.today()-1;
        insert tralist;
    }
    @istest
    public static void Unittestmethod(){
        List<Connection__c> con = new List<Connection__c>([select id,Name from Connection__c]);
        String a = BeBackCreation.createBeBack(con[0].Id);
        system.assertEquals(a, 'Success');
    }
     @istest
    public static void Unittestmethod1(){
        Connection__c con = new Connection__c();
        String a = BeBackCreation.createBeBack(con.Id);
        system.assertNotEquals(a, 'Success');
    }
}