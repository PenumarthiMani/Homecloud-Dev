@istest
Public class IncentivesFilteredTest{
    @testsetup
    Public static void Testsetupmethod(){
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
        List<Community__c> comlist = TestDataUtil.Createcommunity(1,divlist[0].Id);
        insert comlist;
        Id recordtypeidlot = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Lot').getRecordTypeId();
        List<catalog__c> catalog = TestDataUtil.Createcatalog(comlist[0].id,recordtypeidlot);
        insert catalog;
        Id RecordTypeIdscenario = Schema.SObjectType.Scenario__c.getRecordTypeInfosByName().get('Regular').getRecordTypeId();
        List<Scenario__c> scenario = new list<Scenario__c>();
        scenario.add(new scenario__c(Connection__c = conlist[0].Id,Community__c = comlist[0].Id,RecordTypeId = RecordTypeIdscenario,Division__c = divlist[0].Id,Lot__c = catalog[0].Id));
        scenario.add(new scenario__c(Connection__c = conlist[1].Id,Community__c = comlist[0].Id,RecordTypeId = RecordTypeIdscenario,Division__c = divlist[0].Id,Lot__c = catalog[0].Id));
        scenario.add(new scenario__c(Connection__c = conlist[2].Id,Community__c = comlist[0].Id,RecordTypeId = RecordTypeIdscenario,Division__c = divlist[0].Id));
        insert scenario;        
        List<Incentive_Master__c> incentive = new List<Incentive_Master__c>();
        incentive.add(new Incentive_Master__c(Community__c = comlist[0].Id,Division__c = divlist[0].Id));
        incentive.add(new Incentive_Master__c(Community__c = comlist[0].Id,Division__c = divlist[0].Id,Lot__c = catalog[0].Id));
        insert incentive;
        List<Scenario_Incentive__c> scenarioincentive = new List<Scenario_Incentive__c>();
        scenarioincentive.add(new Scenario_Incentive__c(Scenario__c = scenario[0].ID,Incentive_Master__c = incentive[0].Id));
        scenarioincentive.add(new Scenario_Incentive__c(Scenario__c = scenario[0].ID,Incentive_Master__c = incentive[1].Id,Amount__c = 25));
        insert scenarioincentive;
    }
    @istest
    public static void Unittest(){
        Scenario__c scen = [select id,community__c,division__c,connection__c,Lot__c,Status__c  from Scenario__c limit 1];
        Incentive_Master__c im = [select id,Community__c,Division__c,Lot__c from Incentive_Master__c where Lot__c <> null];
        List<IncentivesFiltered.innerclass> inn = IncentivesFiltered.Incentivesfiltered(scen.Id);
        System.assertEquals(inn.size(), 0);
        String s='[{"checklist":true,"community":"Belmonte Estates","division":"Dallas","incentiveid":"'+im.id+'","lot":"50","quoteid":"'+scen.id+'"}]';
       String a =  IncentivesFiltered.save(s);
        System.assertNotEquals(a, 'Success');
    }
     @istest
    public static void Unittest1(){
        Scenario__c scen = [select id,Community__c,Division__c,Connection__c,Lot__c,Status__c from Scenario__c where Lot__c = null limit 1];
         List<IncentivesFiltered.innerclass> inn = IncentivesFiltered.Incentivesfiltered(scen.Id);
        System.assertNotEquals(inn.size(), 0);
    }
  
}