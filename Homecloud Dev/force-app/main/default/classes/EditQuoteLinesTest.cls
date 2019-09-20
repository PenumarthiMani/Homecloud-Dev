@isTest
public class EditQuoteLinesTest {
    @testSetup
    static void testData(){
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
        
        Id RegScenarioId = Schema.SObjectType.Scenario__c.getRecordTypeInfosByName().get('Spec Quote').getRecordTypeId();
        system.debug('RegScenarioId:::::'+RegScenarioId);
        List<Scenario__c> scenario= TestDataUtil.Createscenario(conlist[0].id,comlist[0].id,RegScenarioId,divlist[0].Id);
        scenario[0].Status__c = 'New';
        insert scenario;
        
        Scenario_Group__c se=new Scenario_Group__c();
        se.name='A';
        se.Scenario__c=scenario[0].id;
        insert se;
        Scenario_Group__c se1=new Scenario_Group__c();
        se1.name='A';
        se1.Scenario__c=scenario[0].id;
        insert se1;
        
        
        Id recordtypeidlot = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Lot').getRecordTypeId();
        List<Catalog__c> lot = TestDataUtil.Createcatalog(comlist[0].id, recordtypeidlot);
        lot[0].Status__c = 'Spec';
        lot[0].IsActive__c=true;
        lot[0].Global__c = True;
        
        insert lot;
        
        list<Catalog__c> c=[Select Id, Name, Price__c, Status__c, CatalogCode__c, RecordtypeId, Community__c, Category__c, SubCategory__c from Catalog__c where IsActive__c = True and Community__c !=null  and Status__c <> 'Closed' and Status__c <> 'Reserved'];
        system.debug('cc:'+c);        
        scenario[0].Lot__c=lot[0].id;
        upsert scenario[0];
        
        List<Option__c> lotopt = TestDataUtil.Createoption(lot[0].Id,scenario[0].Id);
        lotopt[0].Type__c = 'Lot';
        lotopt[0].Cancelled__c=false;
        lotopt[0].Group__c=se.Id;
        insert lotopt;
        
        Id recordtypeidmodel = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Model').getRecordTypeId();
        List<Catalog__c> model = TestDataUtil.Createcatalog(comlist[0].id,recordtypeidmodel);
        insert model;      
        
        List<Option__c> modelopt = TestDataUtil.Createoption(model[0].Id,scenario[0].Id);
        modelopt[0].Type__c = 'Model';
        insert modelopt;
        
        Id recordtypeidoption = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Options').getRecordTypeId();
        List<Catalog__c> option = TestDataUtil.Createcatalog(comlist[0].id,recordtypeidoption);
        option[0].Name = 'testcatalog';
        option[0].Global__c = False;
        insert option;
        
        Id recordmodeloption = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Model Options').getRecordTypeId();
        List<Catalog__c> modeloption = TestDataUtil.Createcatalog(comlist[0].id,recordmodeloption);
        modeloption[0].Model__c=model[0].id;
        modeloption[0].Option__c=option[0].id;
        modeloption[0].Category__c='Structural';
        insert modeloption;
        
        List<Option__c> optionopt = TestDataUtil.Createoption(modeloption[0].Id,scenario[0].Id);
        optionopt[0].Type__c = 'Model Options';
        //  optionopt[0].Global__c = True;
        optionopt[0].Group__c=se.Id;
        insert optionopt;
        
        List<Option__c> optionopt1 = TestDataUtil.Createoption(modeloption[0].Id,scenario[0].Id);
        optionopt1[0].Type__c = 'Model Options';
        //  optionopt[0].Global__c = True;
        optionopt1[0].Group__c=se.Id;
        optionopt1[0].Cancelled__c=true;
        insert optionopt1;
    }
    @isTest static void insertData(){
        
        List<Scenario__c> scen = new List<Scenario__c>([select id,community__c,connection__c,division__c,RecordTypeId,Cancel_Reason__c,Status__c from Scenario__c Limit 1]);
        Scenario_Group__c sg=new Scenario_Group__c();
        sg.Name='TestGroup';
        sg.Scenario__c=scen[0].id;
        insert sg;
        
        System.assertEquals(sg.Name, 'TestGroup');
        list<Scenario_Group__c> sr=[select id,name from Scenario_Group__c];
        Scenario__c sce = EditQuoteLines.selectedQuote(scen[0].id);
        System.assertNotEquals(sce.Lot__c,'');
        Id recordtypeidlot = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Lot').getRecordTypeId();
        catalog__c lotcat = [select id,Name,Type__c,Global__c from catalog__c where RecordTypeId =: recordtypeidlot Limit 1]; system.debug('lotcat:'+lotcat);
        Option__c op = EditQuoteLines.selectedLot(scen[0].id, lotcat.id);
        System.assertEquals(op.Catalog__r.Name,'testcatalog');
        Id recordtypeidmodel = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Model').getRecordTypeId();
        catalog__c modelcat = [select id,Name,Type__c,Global__c from catalog__c where Name = 'testcatalog' AND RecordTypeId=:recordtypeidmodel Limit 1];
        Option__c op1 = EditQuoteLines.selectedModel(scen[0].id, modelcat.id);
        System.assertEquals(op1.Catalog__r.Name,'testcatalog');
        Id recordtypeidmodelopt = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Model Options').getRecordTypeId();
        catalog__c modeloptcat = [select id,Name,Type__c,Global__c from catalog__c where Name = 'testcatalog' AND RecordTypeId=:recordtypeidmodelopt Limit 1];
        List<Option__c> op2 = EditQuoteLines.selectedOptions(scen[0].id, modeloptcat.id);
        System.assertEquals(scen[0].id,op.Scenario__c);
        Division__c div=[Select Id,Name,Active__c from Division__c where Name='TestDivision0' AND Active__c=true];
        Community__c comm=[Select id,Name,Division__c from Community__c where Division__c=:div.Id AND Active__c = True];
        List<EditQuoteLines.WapperClass> wp = EditQuoteLines.availableLots(scen[0].id, comm.id);
        System.assertNotEquals(wp.size(), 1);
        List<EditQuoteLines.WapperClass> wp1 = EditQuoteLines.availableModels(scen[0].id, comm.id);
        System.assertNotEquals(wp1.size(), 0);
        List<EditQuoteLines.WapperClass> wp2 = EditQuoteLines.availableOptions(scen[0].id,comm.id,modelcat.id, 'Structural','testcatalog' );
        System.assertNotEquals(wp2.size(), 0);
        EditQuoteLines.selectedOptions(scen[0].id,EditQuoteLines.availableOptions(scen[0].id,comm.id,modelcat.id, 'Structural','testcatalog' ));
        List<Option__c> modline=[Select Id,Name,Type__c,Catalog__c, Catalog__r.Name,Catalog__r.Global__c ,Scenario__c,Notes__c,Cancelled__c from Option__c where Type__c = 'Model' and Scenario__c=:scen[0].id];
        modline[0].Cancelled__c=true;
        modline[0].Group__c=sg.id;
        update modline;
        modline[0].UnitPrice__c=200;
        modline[0].Quantity__c=2;
        modline[0].Discount__c=10;        
        modline[0].Cancelled__c=true;
        EditQuoteLines.updateLine(modline[0]);
        List<Option__c> optline=[Select Id,Name,Type__c,Group__c,Group__r.Name,Scenario__c,Notes__c,Cancelled__c from Option__c where Type__c = 'Model Options' and Scenario__c=:scen[0].id];
        List<EditQuoteLines.InnerClass> inns = EditQuoteLines.selectedlines(string.valueof(scen[0].id), optline[0].Id);
        optline[0].Group__c=sg.id;
        optline[0].Cancelled__c=true;
        optline[0].Quantity__c=2;
        EditQuoteLines.updateOptionsLines(optline,optline[0].id);
        EditQuoteLines.deletelotLine(optline[0]);
        String LineString = JSON.serialize(modelcat);
        //   EditQuoteLines.insertLotModelPackage(LineString,string.valueof(scen[0].id));
        
        String a = EditQuoteLines.deleteModelLine(string.valueof(scen[0].id), modline[0]);
        system.assertEquals(a,'Success');
        List<EditQuoteLines.PicklistWrap> pic = EditQuoteLines.categorypicklist(string.valueof(scen[0].id), modline[0].Id);
        system.assertNotEquals(pic.size(),0);
        
        List<EditQuoteLines.InnerClass> inn = EditQuoteLines.selectedlines(string.valueof(scen[0].id), optline[0].Id);
        System.assertEquals(inn.size(),1);
        //    EditQuoteLines.insertOptions(modline[0].Id);
        
        List<EditQuoteLines.PicklistWrap> pic1 = EditQuoteLines.groupPicklist(string.valueof(scen[0].id));
        system.assertNotEquals(pic1.size(),0);
        
    }
    @isTest static void insertData1(){ 
        system.debug('insertData1');
          List<Scenario__c> scen = new List<Scenario__c>([select id,Name,community__c,connection__c,division__c,RecordTypeId,Cancel_Reason__c,lot__c,recordtype.developername from Scenario__c]);
          List<Option__c> optline=[Select Id,Name,Type__c,Scenario__c,Notes__c,Cancelled__c,Catalog__c from Option__c where Type__c = 'Model Options' and Scenario__c=:scen[0].id];
          List<Catalog__c> optioncat=[Select Id,Name,RecordTypeID,recordtype.developername,Status__c from Catalog__c where Id=:optline[0].Catalog__c];
          List<Option__c> modline=[Select Id,Name,Type__c,Scenario__c,Notes__c,Cancelled__c,Catalog__c from Option__c where Type__c = 'Model' and Scenario__c=:scen[0].id];
          List<Catalog__c> Modelcat=[Select Id,Name,RecordTypeID,recordtype.developername,Status__c from Catalog__c where Id=:modline[0].Catalog__c];
          List<Option__c> lotline=[Select Id,Name,Type__c,Scenario__c,Notes__c,Cancelled__c,Catalog__c from Option__c where Type__c = 'Lot' and Scenario__c=:scen[0].id];
          List<Catalog__c> lotcat=[Select Id,Name,RecordTypeID,recordtype.developername,Status__c from Catalog__c where Id=:lotline[0].Catalog__c];
          List<EditQuoteLines.WapperClass> waplist=new List<EditQuoteLines.WapperClass>();
          EditQuoteLines.WapperClass wap=new EditQuoteLines.WapperClass();
          wap.Checkbox=true;
          wap.ProductDetails=Modelcat[0];
          wap.UnitPrice=10;
          wap.NetAmount=200;
          wap.Discount=10;
          wap.Quantity=2;
          wap.LineDetails=optline[0];
          waplist.add(wap);
          EditQuoteLines.WapperClass waplot=new EditQuoteLines.WapperClass();
          waplot.Checkbox=true;
          waplot.ProductDetails=lotcat[0];
          waplot.UnitPrice=10;
          waplot.NetAmount=200;
          waplot.Discount=10;
          waplot.Quantity=2;
          waplot.LineDetails=lotline[0];
          waplist.add(waplot);
          EditQuoteLines.WapperClass wapmod=new EditQuoteLines.WapperClass();
          wapmod.Checkbox=true;
          wapmod.ProductDetails=Modelcat[0];
          wapmod.UnitPrice=10;
          wapmod.NetAmount=200;
          wapmod.Discount=10;
          wapmod.Quantity=2;
          wapmod.LineDetails=modline[0];
          waplist.add(wapmod);
          String LineString = JSON.serialize(waplist);
          EditQuoteLines.insertLotModelPackage(LineString,scen[0].id);
          EditQuoteLines.insertOptions(LineString,scen[0].id,modline[0].Id);
          EditQuoteLines.ungroupedQuoteLines(scen[0].id,modline[0].Id);
          EditQuoteLines.tieToGroups(scen[0].id,modline[0].Id, scen[0].Name,LineString);
          EditQuoteLines.removeFromGroup(lotline[0].Id);
          EditQuoteLines.InnerClass w=new EditQuoteLines.InnerClass();
          EditQuoteLines.selectedOptions(scen[0].id,waplist);
          String d = EditQuoteLines.deleteOptionLine(optline,optline[0].Id);
          system.assertEquals(d, 'Success');
          w.GroupName='Cancelled';
          waplist[0].LineDetails.Cancelled__c = true;
          w.InnerWapperList = waplist;
          
          List<EditQuoteLines.InnerClass> wList = new List<EditQuoteLines.InnerClass>();
          wList.add(w);
          
          String LineStrings = JSON.serialize(wList);
          system.debug('LineStrings::::::'+LineStrings);
          String a = EditQuoteLines.UpdateLineOptions(LineStrings,string.valueof(optline[0].Id));
          system.debug(LineString+':::::::a::::::'+string.valueof(optline[0].Id));
          system.assertNotEquals(a, 'Success');
         }
    @isTest static void insertData2(){
        List<Scenario__c> scen = new List<Scenario__c>([select id,Name,community__c,connection__c,division__c,RecordTypeId,Cancel_Reason__c from Scenario__c]);
        List<Option__c> optline=[Select Id,Name,Type__c,Scenario__c,Notes__c,Cancelled__c,Catalog__c,Group__c,Group__r.Name from Option__c where Type__c = 'Model Options' and Scenario__c=:scen[0].id];
        List<Option__c> optline22=[Select Id,Name,Type__c,Scenario__c,Notes__c,Cancelled__c,Catalog__c,Group__c,Group__r.Name from Option__c where Type__c = 'Model Options' and Scenario__c=:scen[0].id and Cancelled__c=true];
        List<Catalog__c> optioncat=[Select Id,Name,RecordTypeID from Catalog__c where Id=:optline[0].Catalog__c];
        List<Option__c> modline=[Select Id,Name,Type__c,Scenario__c,Notes__c,Cancelled__c,Catalog__c from Option__c where Type__c = 'Model' and Scenario__c=:scen[0].id];
        List<Catalog__c> Modelcat=[Select Id,Name,RecordTypeID from Catalog__c where Id=:modline[0].Catalog__c];
        List<Option__c> lotline=[Select Id,Name,Type__c,Scenario__c,Notes__c,Cancelled__c,Catalog__c from Option__c where Type__c = 'Lot' and Scenario__c=:scen[0].id];
        List<Catalog__c> lotcat=[Select Id,Name,RecordTypeID from Catalog__c where Id=:lotline[0].Catalog__c];
        List<EditQuoteLines.WapperClass> waplist=new List<EditQuoteLines.WapperClass>();
        EditQuoteLines.WapperClass waplot=new EditQuoteLines.WapperClass();
        waplot.Checkbox=true;
        waplot.ProductDetails=lotcat[0];
        waplot.UnitPrice=10;
        waplot.NetAmount=200;
        waplot.Discount=10;
        waplot.Quantity=2;
        waplot.LineDetails=lotline[0];
        waplist.add(waplot);
        String LineString = JSON.serialize(waplist);
        String a = EditQuoteLines.insertLotModelPackage(LineString,scen[0].id);
        System.assertEquals(a, 'Success'); system.debug('ffoptline'+optline);
        optline[0].Cancelled__c=true;
        update optline;
        List<EditQuoteLines.InnerClass> inns = EditQuoteLines.selectedlines(string.valueof(scen[0].id), optline[0].Id);
        List<EditQuoteLines.InnerClass> inn = EditQuoteLines.selectedlines(string.valueof(scen[0].id), optline22[0].Id);
    }
    
}