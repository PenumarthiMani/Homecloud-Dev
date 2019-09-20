@IsTest
public class SelectionReportController_TC
{
    @TestSetup
    public static void TestData(){
        List<Division__c> div = TestDataUtil.Createdivision(1);
       // div[0].name = 'test division';
        Insert div;
       
        List<Community__c> com = TestDataUtil.Createcommunity(1,div[0].Id);
        //com[0].name = 'test community';
        //com[0].Division__c = div[0].Id;
        Insert com;
        
        Id Hbrecordtype = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Homebuyer').getRecordTypeId();
        List<Contact> con=TestDataUtil.createContact(1,Hbrecordtype);
        con[0].Type__c='Lead';        
        insert con;
          
        list<Connection__c> opp = TestDataUtil.Createconnection(1);
        //opp[0].Name = 'Spec Connection';
        opp[0].Division__c = div[0].Id; 
        opp[0].Homebuyer__c=con[0].id;
        Insert opp;
        
        Id RecordTypeIdlot = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Model Options').getRecordTypeId();
        List<Catalog__c> catalog = TestDataUtil.Createcatalog(com[0].Id,RecordTypeIdlot);
        insert catalog;
        
        Id RecordTypeIdmodel = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Model Options').getRecordTypeId();
        List<Catalog__c> catalog1 = TestDataUtil.Createcatalog(com[0].Id,RecordTypeIdmodel);
        insert catalog1;
        
        Id RecordTypeIdmodeloption = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Model Options').getRecordTypeId();
        List<Catalog__c> catalog2 = TestDataUtil.Createcatalog(com[0].Id,RecordTypeIdmodeloption);
        insert catalog2;
        
        Id RecordTypeIdscenario = Schema.SObjectType.Scenario__c.getRecordTypeInfosByName().get('Regular').getRecordTypeId();
        List<Scenario__c> scenario = TestDataUtil.Createscenario(opp[0].Id,com[0].Id,RecordTypeIdscenario,div[0].Id);
        //scenario[0].Lot__c = catalog[0].Id;
        //scenario[0].Model__c = catalog1[0].Id;
        insert scenario;
        
        Scenario_Group__c GroupLine = New Scenario_Group__c();
        GroupLine.Name = 'Group1';
        Insert GroupLine; 
        
        List<Option__c> option = TestDataUtil.Createoption(catalog2[0].Id,scenario[0].Id);
        option[0].Group__c = GroupLine.id;
        option[0].Cancelled__c = false;
        option[0].Type__c = 'Model Options';
        insert option;
         
    }
        @istest
        public static void UnitTest(){
            Scenario__c sce = [SELECT Id, Name, Total_Incentive_Amount__c, DiscountAmount__c, Options_Total__c, LotPremium__c, BasePrice__c, Net_Amount__c, Division__c, HomeBuyer__r.Name, Lot__r.Name, Lot__r.Street__c, Lot__r.City__c, Lot__r.State__c, Lot__r.Postal_Code__c, Model__r.Name, Division__r.Name, Community__r.Name,  (SELECT Id, Quantity__c, UnitPrice__c, NetAmount__c, Cancelled__c, CatalogCode__c, Catalog__r.Name, Group__r.Name From Option__r where Type__c = 'Model Options' Order By Cancelled__c, Group__r.Name, Catalog__r.Name ASC)  FROM Scenario__c ];
            System.debug('@@@@'+sce);
            String a = ApexPages.currentPage().getParameters().put('qid',sce.id);
            System.assertEquals(a,null);
            SelectionReportController srcon1 = New SelectionReportController();
            //SelectionReportController srcon = New SelectionReportController(); 
        }
}