@istest
public class WetSignatureTest{
    @testsetup public static void testdata(){
        Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Homebuyer').getRecordTypeId();
        List<Contact> contlist = TestDataUtil.CreateContact(2,RecordTypeIdContact);
        insert contlist;
        List<Connection__c> conlist = TestDataUtil.Createconnection(3);
        conlist[0].Homebuyer__c = contlist[0].id;
        conlist[1].Homebuyer__c = contlist[0].id;
        conlist[2].Homebuyer__c = contlist[0].id;
        insert conlist;
        List<Division__c> divlist = TestDataUtil.Createdivision(1);
        insert divlist;
        List<Community__C> comlist = TestDataUtil.Createcommunity(2,divlist[0].Id);
        insert comlist;
        Id RecordTypeIdLot = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Lot').getRecordTypeId();
        Id RecordTypeIdModel = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Model').getRecordTypeId();
        List<Catalog__c> catalog = new List<catalog__c>();
        catalog.add(new catalog__c(Name = 'testcatalog',IsActive__c = True,Community__c = comlist[0].Id,RecordTypeId = RecordTypeIdLot));
        catalog.add(new catalog__c(Name = 'testcatalog1',IsActive__c = True,Community__c = comlist[0].Id,RecordTypeId = RecordTypeIdModel));
        insert catalog;
        Id RecordTypeIdscenario = Schema.SObjectType.Scenario__c.getRecordTypeInfosByName().get('Regular').getRecordTypeId();
        Id RecordTypeIdscenario1 = Schema.SObjectType.Scenario__c.getRecordTypeInfosByName().get('Spec Quote').getRecordTypeId();
        List<Scenario__c> scenario = new List<Scenario__c>();
        scenario.add(new Scenario__c(Connection__c = Conlist[0].Id,Community__c = comlist[0].Id,RecordTypeId = RecordTypeIdscenario,Division__c = divlist[0].Id));
        scenario.add(new Scenario__c(Connection__c = Conlist[1].Id,Community__c = comlist[0].Id,RecordTypeId = RecordTypeIdscenario,Division__c = divlist[0].Id,Status__c = 'Draft',Lot__c = catalog[0].Id,Model__c = catalog[1].Id));
        scenario.add(new Scenario__c(Connection__c = Conlist[2].Id,Community__c = comlist[1].Id,RecordTypeId = RecordTypeIdscenario,Division__c = divlist[0].Id,Status__c = 'Draft'));
        insert scenario;
        
        Signature__c sign = new Signature__c();
        sign.Signature_Label1__c = 'test';
        sign.Signature_Value1__c = 'ttest';
        sign.Signature_Label2__c = 'test';
        sign.Signature_Value2__c = 'ttest';
        insert sign;
    }
    @istest
    public static void UnitTest(){
        List<Scenario__c> scn = new List<Scenario__c>([select Id,Connection__c,community__c,Division__c,Lot__c,Model__c from Scenario__c where Model__c <> Null]);
        String a = WetSignature.WetSignaturevalidations(scn[0].Id);
        System.assertNotEquals(a, 'Success');
        String b = WetSignature.updateQuote(scn[0].Id,'');
        System.assertEquals(b, 'Success');
       List<WetSignature.picklistWrap> pic = WetSignature.SignatureType();
        System.assertNotEquals(pic.size(), 0);
    }
    @istest
    public static void UnitTest1(){
        List<Scenario__c> scn = new List<Scenario__c>([select Id,Connection__c,community__c,Division__c,Lot__c,Model__c from Scenario__c where Lot__c = Null]);
        String a = WetSignature.WetSignaturevalidations(scn[0].Id);
        System.assertNotEquals(a, 'Success');
        String b = WetSignature.updateQuote('','');
        System.assertNotEquals(b, 'Success');
       List<WetSignature.picklistWrap> pic = WetSignature.SignatureType();
        System.assertNotEquals(pic.size(), 0);
    }
    @istest
    public static void UnitTest2(){
        List<Scenario__c> scn = new List<Scenario__c>([select Id,Connection__c,community__c,Division__c,Lot__c,Model__c from Scenario__c where Lot__c = Null]);
        String a = WetSignature.WetSignaturevalidations('');
         System.assertNotEquals(a, 'Success');
       String b = WetSignature.updateQuote('','');
        System.assertNotEquals(b, 'Success');
       List<WetSignature.picklistWrap> pic = WetSignature.SignatureType();
         System.assertNotEquals(pic.size(), 0);
    }
}