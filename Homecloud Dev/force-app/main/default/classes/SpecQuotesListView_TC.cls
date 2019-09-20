@istest 
public class SpecQuotesListView_TC{
    @testsetup public static void testsetupmethod(){
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
        Id RecordTypeIdScenario = Schema.SObjectType.Scenario__c.getRecordTypeInfosByName().get('Spec Quote').getRecordTypeId();
        List<Scenario__c> scen = TestDataUtil.Createscenario(conlist[0].Id,comlist[0].Id,RecordTypeIdScenario,divlist[0].Id);
        insert scen;
    }
    @istest
    public Static void UnitTest(){
        List<Division__c> div = new List<Division__c>([select id,Name from Division__c]);
        List<Community__c> com = new List<Community__c>([select id,Name from Community__c]);
        List<Scenario__c> sce = new List<Scenario__c>([select id,Name,Division__c,community__c,Connection__c from Scenario__c]);
        List<Scenario__c> spe = SpecQuotesListView.specQuotes('New',com[0].Id,div[0].Id);
        system.assertNotEquals(spe.size(), 0);
        Scenario__c sc = SpecQuotesListView.newSpecQuote(sce[0],com[0].Id,div[0].Id);
        system.assertNotEquals(sc, null);
     /*   List<SpecQuotesListView.picklistWrap> pic = SpecQuotesListView.getStatus();
        system.assertNotEquals(pic.size(), 0); */
        List<SpecQuotesListView.picklistWrap> pic1 = SpecQuotesListView.getDivisions();
        system.assertNotEquals(pic1.size(), 0);
        List<SpecQuotesListView.picklistWrap> pic2 = SpecQuotesListView.getCommunities(div[0].Id);
        system.assertNotEquals(pic2.size(), 0);
    }
}