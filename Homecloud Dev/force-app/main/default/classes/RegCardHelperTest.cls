@istest
public class RegCardHelperTest{
    @testsetup static void testdata(){
        Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Homebuyer').getRecordTypeId();
        List<Contact> contlist = TestDataUtil.CreateContact(2,RecordTypeIdContact);
        insert contlist;
        List<Connection__c> conlist = TestDataUtil.Createconnection(4);
        conlist[0].Homebuyer__c = contlist[0].id;
        conlist[1].Homebuyer__c = contlist[0].id;
        conlist[2].Homebuyer__c = contlist[0].id;
        conlist[3].Homebuyer__c = contlist[0].id;
        insert conlist;
                    
        List<Division__c> divlist = TestDataUtil.Createdivision(1);
        insert divlist;
        List<Community__C> comlist = TestDataUtil.Createcommunity(2,divlist[0].Id);
        insert comlist;
        Id RecordTypeIdregcard = Schema.SObjectType.Traffic__c.getRecordTypeInfosByName().get('Registered').getRecordTypeId();
        Id RecordTypeIdbeback = Schema.SObjectType.Traffic__c.getRecordTypeInfosByName().get('BeBack').getRecordTypeId();
        List<Traffic__c> trafficlist = new List<Traffic__c>();
        trafficlist.add(new Traffic__c(Connection__c = conlist[0].Id,Community__c = comlist[0].Id,RecordTypeId = RecordTypeIdregcard));
        trafficlist.add(new Traffic__c(Connection__c = conlist[1].Id,Community__c = comlist[1].Id,RecordTypeId = RecordTypeIdregcard));
        trafficlist.add(new Traffic__c(Connection__c = conlist[2].Id,Community__c = comlist[0].Id,RecordTypeId = RecordTypeIdbeback));
        trafficlist.add(new Traffic__c(Connection__c = conlist[3].Id,Community__c = comlist[0].Id,RecordTypeId = RecordTypeIdbeback));
        insert trafficlist;
    }
    @istest
    public static void UnitTest(){
        List<Traffic__c> traffic = [select id,Community__c,Connection__c,RecordType.Name from Traffic__c];
        update traffic;
        Connection__c con = [select id,Community__c,Division__c from Connection__c limit 1];
        String a = RegCardHelper.doRegCard(con.Id);
        System.assertNotEquals(a, 'Success');
    }
}