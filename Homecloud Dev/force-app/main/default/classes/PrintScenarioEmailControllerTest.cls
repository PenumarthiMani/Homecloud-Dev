@isTest public class PrintScenarioEmailControllerTest{
    @testSetup static void insertData(){
        Id Agencyid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        List<Account> acc=TestDataUtil.createAccounts(1);
        acc[0].RecordTypeId=Agencyid;
        insert acc;
        
        Id Hbrecordtype = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Homebuyer').getRecordTypeId();
        List<Contact> con=TestDataUtil.createContact(1,Hbrecordtype);
        con[0].Type__c='Lead';        
        insert con;
        
        List<Division__c> divlist = TestDataUtil.Createdivision(1);
        insert divlist;
        
        List<Community__c> comlist = TestDataUtil.Createcommunity(1,divlist[0].Id);
        insert comlist;
        
        List<Connection__c> conlist = TestDataUtil.Createconnection(1);
        conlist[0].Homebuyer__c=con[0].id;
        conlist[0].Division__c=divlist[0].Id;
        conlist[0].Community__c=comlist[0].Id;
        conlist[0].Prospect_Rating__c='A';              
        insert conlist; 
        
        Id RegScenarioId = Schema.SObjectType.Scenario__c.getRecordTypeInfosByName().get('Regular').getRecordTypeId();
        List<Scenario__c> scenario= TestDataUtil.Createscenario(conlist[0].id,comlist[0].id,RegScenarioId,divlist[0].Id);
        insert scenario;
        
        Id recordtypeidlot = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Lot').getRecordTypeId();
        List<Catalog__c> lot = TestDataUtil.Createcatalog(comlist[0].id,recordtypeidlot);
        insert lot;
        
        List<Option__c> lotopt = TestDataUtil.Createoption(lot[0].Id,scenario[0].Id);
        lotopt[0].Type__c = 'Lot';
        insert lotopt;
        
        Id recordtypeidmodel = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Model').getRecordTypeId();
        List<Catalog__c> model = TestDataUtil.Createcatalog(comlist[0].id,recordtypeidmodel);
        insert model;      
        
        List<Option__c> modelopt = TestDataUtil.Createoption(model[0].Id,scenario[0].Id);
        modelopt[0].Type__c = 'Model';
        insert modelopt;
        
        Id recordtypeidoption = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Options').getRecordTypeId();
        List<Catalog__c> option = TestDataUtil.Createcatalog(comlist[0].id,recordtypeidoption);
        option[0].Global__c = False;
        insert option;
        
        Id recordmodeloption = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Model Options').getRecordTypeId();
        List<Catalog__c> modeloption = TestDataUtil.Createcatalog(comlist[0].id,recordmodeloption);
        modeloption[0].Model__c=model[0].id;
        modeloption[0].Option__c=option[0].id;
        modeloption[0].Category__c='Structural';
        modeloption[0].Global__c = False;
        insert modeloption;
        
        List<Option__c> optionopt = TestDataUtil.Createoption(modeloption[0].Id,scenario[0].Id);
        optionopt[0].Type__c = 'Model Options';
        //  optionopt[0].Global__c = True;
        insert optionopt;
    }
    @isTest static void testData(){
        List<Scenario__c> scen = new List<Scenario__c>([select id,community__c,connection__c,division__c,RecordTypeId,Cancel_Reason__c from Scenario__c]);
        PageReference pageRef = Page.PrintScenarioEmail; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(scen[0].id));
        Test.setCurrentPage(pageRef);
            String t = Label.printscenarioemail;
       // system.assertNotEquals('/apex/'+t+'?id='+scen[0].id, '');
        PrintScenarioEmailController peqc = new PrintScenarioEmailController();
        peqc.sendEmail();
    }
}