@istest
public class CatalogControllerTest{
        @testsetup Static void testsetup(){
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
            Id RecordTypeIdscenario = Schema.SObjectType.Scenario__c.getRecordTypeInfosByName().get('Regular').getRecordTypeId();
            List<Scenario__c> scenario= TestDataUtil.Createscenario(conlist[0].id,comlist[0].id,RecordTypeIdscenario,divlist[0].Id);
            insert scenario;
            Id recordtypeidlot = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Lot').getRecordTypeId();
            Id RecordTypeIdModel = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Model').getRecordTypeId();
            List<catalog__c> catalog = TestDataUtil.Createcatalog(comlist[0].id,recordtypeidlot);
            insert catalog;
        }
        @istest
        public static void UnitTest(){
            List<Community__c> com = new List<Community__c>([select id,Name from community__c]); 
            catalog__c cat = [select id,RecordType.Name from catalog__c where RecordType.Name = 'Lot'];
           CatalogController.initilizeWrapper i = CatalogController.doinitialize(com[0].Id,'Lot','Name','',1,1);
            CatalogController.dodelete(com[0].Id,'Lot',cat.Id);
            System.assertNotEquals(i.countofrecords, 0);
        }
         @istest
        public static void UnitTest1(){
            List<Community__c> com = new List<Community__c>([select id,Name from community__c]); 
            catalog__c cat = [select id,RecordType.Name,Name from catalog__c where RecordType.Name = 'Lot'];
             CatalogController.initilizeWrapper i = CatalogController.doinitialize(com[0].Id,'Lot','Name','',1,1);
            //String c = cat.Name;
            CatalogController.dosearchval(com[0].Id,'Lot',cat.Name,cat.Name,1,1,'');
            CatalogController.dosort(com[0].Id,'Lot','Name','',1,1,'');
            CatalogController.doactions(com[0].Id,'Lot','Name','',1,1,'','Next');
            CatalogController.docheckpermissionforprofile('Community__c');
            System.assertNotEquals(i.countofrecords, 0);
        }    
}