@istest
public class CancelScenarioTest{
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
        List<Scenario__c> scenario1= TestDataUtil.Createscenario(conlist[0].id,comlist[0].id,RecordTypeIdscenario,divlist[0].Id);
        insert scenario1;
        Id recordtypeidlot = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Lot').getRecordTypeId();
        List<catalog__c> catalog = TestDataUtil.Createcatalog(comlist[0].id,recordtypeidlot);
        insert catalog;
        List<Option__c> opt = TestDataUtil.Createoption(catalog[0].Id,scenario[0].Id);
        opt[0].Type__c = 'Lot';
        List<Option__c> opt1 = TestDataUtil.Createoption(catalog[0].Id,scenario[0].Id);
        opt1[0].Type__c = 'Model Options';
         List<Option__c> opt2 = TestDataUtil.Createoption(catalog[0].Id,scenario[0].Id);
        opt2[0].Type__c = 'Model';
        insert opt;
        insert opt1;
        insert opt2;
        List<Scenario_Group__c> groupsToInsert = new List<Scenario_Group__c>();
        Scenario_Group__c scenariogroup = new Scenario_Group__c();
        scenariogroup.Name = 'testtest';
        scenariogroup.Scenario__c = scenario[0].Id;
        insert scenariogroup;
    }
    @istest
    public static void UnitTest(){
        List<Scenario__c> scen = new List<Scenario__c>([select id,community__c,connection__c,division__c,RecordTypeId,Cancel_Reason__c from Scenario__c]);
        scen[0].Cancel_Reason__c = 'Convert to Spec';
        update scen[0];
        CancelScenario.selectedScenario(scen[0].Id);
        String a = CancelScenario.cancelScenario(scen[0]);
        CancelScenario.getCancelTo();
        System.assertNotEquals(a, 'Success-'+Scen[0].Id);
    }
    @istest
    public static void UnitTest1(){
        catalog__c cat = [select id,Name,Type__c from catalog__c where Name = 'testcatalog' limit 1];
        Scenario__c scen = [select id,community__c,connection__c,division__c,RecordTypeId,Cancel_Reason__c,(select id,Type__c from Option__r where Type__c = 'Model Options') from Scenario__c limit 1];
        scen.Cancel_Reason__c = 'Revert to Dirt';
        scen.Lot__c = cat.Id;
        update scen;
        CancelScenario.selectedScenario(scen.Id);
        String a = CancelScenario.cancelScenario(scen);
        CancelScenario.getCancelTo();
         System.assertEquals(a, 'Success-'+Scen.Id);
    }
    @istest
    public static void UnitTest2(){
        Scenario__c scen = new Scenario__c();
       String a = CancelScenario.cancelScenario(scen);
        System.assertEquals(a, 'Error');
    }
}