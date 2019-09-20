@istest
public class TransferLot_TC{
    @testsetup static void testdata(){
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
        catalog.add(new catalog__c(Name = 'testcatalog2',IsActive__c = True,Community__c = comlist[1].Id,RecordTypeId = RecordTypeIdLot));
        insert catalog;
        Id RecordTypeIdscenario = Schema.SObjectType.Scenario__c.getRecordTypeInfosByName().get('Regular').getRecordTypeId();
        List<Scenario__c> scenario = new List<Scenario__c>();
        scenario.add(new Scenario__c(Connection__c = Conlist[0].Id,Community__c = comlist[0].Id,RecordTypeId = RecordTypeIdscenario,Division__c = divlist[0].Id));
        scenario.add(new Scenario__c(Connection__c = Conlist[1].Id,Community__c = comlist[0].Id,RecordTypeId = RecordTypeIdscenario,Division__c = divlist[0].Id,Status__c = 'Draft',Lot__c = catalog[0].Id,Model__c = catalog[1].Id));
        scenario.add(new Scenario__c(Connection__c = Conlist[2].Id,Community__c = comlist[1].Id,RecordTypeId = RecordTypeIdscenario,Division__c = divlist[0].Id,Status__c = 'Draft'));
        insert scenario;
        update scenario;
        Scenario_Group__c scenariogroup = new Scenario_Group__c();
        scenariogroup.Name = 'testtest';
        scenariogroup.Scenario__c = scenario[1].Id;
        insert scenariogroup;
        
        Scenario_Incentive__c scenarioincentive = new Scenario_Incentive__c();
        scenarioincentive.Amount__c = 123;
        scenarioincentive.Scenario__c = scenario[1].Id;
        insert scenarioincentive;
        
        Deposit__c deposit = new Deposit__c();
        deposit.Scenario__c = scenario[1].Id;
        insert deposit;
        
        Discount__c discount = new Discount__c();
        discount.Scenario__c = scenario[1].Id;
        insert discount;
        
        ContentVersion cv=new Contentversion();
        cv.title='test';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('test');
        cv.versiondata=EncodingUtil.base64Decode('test');
        insert cv;
        List<ContentVersion> lstExistingContent = [Select Title, PathOnClient, VersionData,ContentDocumentId From ContentVersion where id=: cv.id];
        system.debug('lstExistingContent:::::'+lstExistingContent);
        List<Option__c> option = new List<option__c>();
        option.add(new Option__c(Catalog__c = catalog[0].Id,Scenario__c = scenario[1].Id,Type__c = 'Lot',Group__c = scenariogroup.Id));
        option.add(new Option__c(Catalog__c = catalog[1].Id,Scenario__c = scenario[1].Id,Type__c = 'Model',Group__c = scenariogroup.Id));
        insert option;
        
        //List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument limit 1];
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = scenario[1].id;
        cdl.ContentDocumentId = lstExistingContent[0].ContentDocumentId;
        cdl.shareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = scenario[2].id;
        cdl1.ContentDocumentId = lstExistingContent[0].ContentDocumentId;
        cdl1.shareType = 'V';
        cdl1.Visibility = 'AllUsers';
        insert cdl1;
        
        system.debug('cdl:::::::::::::::'+cdl);
    }
    @istest
    public static void UnitTest(){
        scenario__c sce = [select id,Name,Lot__c,Community__c,Division__c,Connection__c,Model__c from Scenario__c where Lot__c != Null And Model__c != Null limit 1];
        catalog__c cat = [select id,Name,Community__c,IsActive__c from catalog__c where Name = 'testcatalog2'];
        String a = TransferLot.lotTransfer(sce.id,cat.id);
        System.assertNotEquals(a, 'Success');
        Scenario__c sc = TransferLot.getCommunity(sce.Id);
        System.assertNotEquals(sc.Lot__c, Null);
    }
}