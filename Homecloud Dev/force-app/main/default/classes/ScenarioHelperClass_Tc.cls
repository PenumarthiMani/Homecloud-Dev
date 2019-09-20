@istest
public class ScenarioHelperClass_Tc{
    @testsetup static void testdata(){
        Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Homebuyer').getRecordTypeId();
        List<Contact> contlist = TestDataUtil.CreateContact(2,RecordTypeIdContact);
        insert contlist;
        List<Connection__c> Conlist= TestDataUtil.Createconnection(3);
        Conlist[0].Homebuyer__c = contlist[0].id;  
        Conlist[1].Homebuyer__c = contlist[0].id;  
        Conlist[2].Homebuyer__c = contlist[0].id;  
        insert Conlist; 
       
        
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
        List<Scenario__c> scenario = new List<Scenario__c>();
        scenario.add(new Scenario__c(Connection__c = Conlist[0].Id,Community__c = comlist[0].Id,RecordTypeId = RecordTypeIdscenario,Division__c = divlist[0].Id));
        scenario.add(new Scenario__c(Connection__c = Conlist[1].Id,Community__c = comlist[0].Id,RecordTypeId = RecordTypeIdscenario,Division__c = divlist[0].Id,Status__c = 'Draft',Lot__c = catalog[0].Id,Model__c = catalog[1].Id));
        scenario.add(new Scenario__c(Connection__c = Conlist[2].Id,Community__c = comlist[1].Id,RecordTypeId = RecordTypeIdscenario,Division__c = divlist[0].Id,Status__c = 'Draft',Lot__c = catalog[0].Id,Model__c = catalog[1].Id));
        
        insert scenario;
        scenario[1].Status__c = 'Approved';
        update scenario[1];
        system.assertEquals(scenario[1].Status__c, 'Approved');
        
        scenario[2].Status__c = 'Approved';
        update scenario[2];
        //Delete scenario;
        
        scenario[2].Status__c = 'Cancelled';
        update scenario[2];
        
        Id RecordTypeIdscenarioSpec = Schema.SObjectType.Scenario__c.getRecordTypeInfosByName().get('Spec Quote').getRecordTypeId();
        List<Scenario__c> scenario1 = new List<Scenario__c>();
        scenario1.add(new Scenario__c(Connection__c = Conlist[1].Id,Community__c = comlist[0].Id,RecordTypeId = RecordTypeIdscenarioSpec,Division__c = divlist[0].Id,Status__c = 'New',Lot__c = catalog[0].Id,Model__c = catalog[1].Id));
        scenario1.add(new Scenario__c(Connection__c = Conlist[2].Id,Community__c = comlist[1].Id,RecordTypeId = RecordTypeIdscenarioSpec,Division__c = divlist[0].Id,Status__c = 'New',Lot__c = catalog[0].Id,Model__c = catalog[1].Id));
        
        insert scenario1;
        Map<Id, Scenario__c> scenmap = new Map<Id, Scenario__c>([Select Id,Lot__c from Scenario__c]);
        
        ScenarioHelperClass.scenarioDelete(scenmap);
        
    }
    @istest
    public static void UnitTest(){
    List<Division__c> divlist = TestDataUtil.Createdivision(1);
        insert divlist;
        List<Community__C> comlist = TestDataUtil.Createcommunity(2,divlist[0].Id);
        insert comlist;
    Id RecordTypeIdLot = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Lot').getRecordTypeId();
    List<Catalog__c> catalog = new List<catalog__c>();
    insert catalog;
        catalog.add(new catalog__c(Name = 'testcatalog',IsActive__c = True,Community__c = comlist[0].Id,RecordTypeId = RecordTypeIdLot));
        List<Scenario__c> scn = new List<Scenario__c>([select Id,Status__c,Connection__c,community__c,Division__c from Scenario__c limit 1] );
        //scn[0].Status__c = 'Approved';
        //scn[1].Lot__c= catalog[0].id;
        Delete scn;
       // update scn;
        //system.assertEquals(scn[0].Status__c, 'Approved');
    }
    
}