@IsTest()
Public Class InputLookupReusableClassTest
{
    @testSetup static void prepareSetupData() 
    {
        List<Division__c> Divisions = TestDataUtil.Createdivision(5);
        Insert Divisions;
        
        List<Community__c> Communities = TestDataUtil.Createcommunity(5,divisions[0].id);
        Insert Communities;  
      
        Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Homebuyer').getRecordTypeId();
        List<Contact> Con = TestDataUtil.CreateContact(1,devRecordTypeId);
        Insert Con;
        
        List<Lead> lstLead =   new List<Lead>{
                          new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open'),
                          new Lead(Company = 'Nike', LastName = 'John', Status = 'Open'),
                          new Lead(Company = 'Miles', LastName = 'Davis', Status = 'Open'),
                          new Lead(Company = 'Reebok', LastName = 'Hillen', Status = 'Open'),
                          new Lead(Company = 'Addidas', LastName = 'Shrin', Status = 'Open')
                         };  
        insert lstLead;
        
        InputLookupReusableClass.fetchUser();
                   
    }
    Public Static TestMethod Void unitTest()
    {
        List<Division__c> Divisions = [Select Id, Name from Division__c];
       List<inputLookupReusableClass.wrapperClass> a = inputLookupReusableClass.getSearchResults('Division__c','Id,Name','Name','Name','Name','','','','','','','Test Division');
        System.assertEquals(a.size(),0);
    }
    Public Static TestMethod Void unitTest1()
    {
        List<Community__c> communities = [Select Id, Name from Community__c];
        List<inputLookupReusableClass.wrapperClass> a = inputLookupReusableClass.getSearchResults('Community__c','Id,Name','Name','Name','Name','','','','','','','Test Community');
        System.assertEquals(a.size(),0);
    }
    Public Static TestMethod Void unitTest2()
    {
        List<Division__c> Divisions = [Select Id, Name from Division__c];
        List<inputLookupReusableClass.wrapperClass> a = inputLookupReusableClass.getSearchResults('Community__c','Id,Name','Name','Name','Name','Division__c',Divisions[0].Id,'','','','','Test Community');
        System.assertEquals(a.size(),0);
    }
    Public Static TestMethod Void unitTest3()
    {
        List<Community__c> communities = [Select Id, Name from Community__c];
        List<inputLookupReusableClass.wrapperClass> a = inputLookupReusableClass.getSearchResults('Community__c','Id,Name','','','','','','','','','','');
       System.assertNOtEquals(a.size(),0);
    }
    Public Static TestMethod Void unitTest4()
    {
        List<Community__c> communities = [Select Id, Name from Community__c];
        List<inputLookupReusableClass.wrapperClass> a = inputLookupReusableClass.getSearchResults('Community__c','Id,Name','','Name','','','','','','','','Test Community');
       System.assertEquals(a.size(),0);
    }
    Public Static TestMethod Void unitTest5()
    {
        List<Community__c> communities = [Select Id, Name from Community__c];
        List<inputLookupReusableClass.wrapperClass> a = inputLookupReusableClass.getSearchResults('Community__c','Id,Name','','','Name','','','','','','','Test Community');
        System.assertEquals(a.size(),0);
    }
    Public Static TestMethod Void unitTest6()
    {
        List<Community__c> communities = [Select Id, Name from Community__c];
         List<inputLookupReusableClass.wrapperClass> a = inputLookupReusableClass.getSearchResults('Community__c','Id,Name','','','Name','','','','','','','');
        System.assertnotEquals(a.size(),0);
    }
    
    Public Static TestMethod Void unitTest7()
    {
        system.debug('unitTest7');
        List<catalog__c> communities = [Select Id, Name from catalog__c];
        List<inputLookupReusableClass.wrapperClass> a = inputLookupReusableClass.getSearchResults('Catalog__c','Id,Name','Id,Name','','','Name','Id,Name','','','','','');
       System.assertEquals(a.size(),0);
    }
     Public Static TestMethod Void unitTest8()
    {
        List<Division__c> Divisions = [Select Id, Name from Division__c];
        string s=Divisions[0].Id+','+product2.id;
        inputLookupReusableClass.getSearchResults('Community__c','Id,Name','Name','Name','Name','Name','Test Community','','','','','Test Community');
    }
     /*Public Static TestMethod Void unitTest9()
    {
        List<Neighborhood__c> neighborhood = [Select Id, Name from Neighborhood__c];
        inputLookupReusableClass.getSearchResults('Neighborhood__c','Id,Name','Name','Name','Name','Name','Test Neighborhood','','','','','Test Community');
     }*/
    Public Static TestMethod Void unitTest10()
    {
        List<Lead> leadRecords = [select id, FirstName, LastName, Email from Lead];
         
        List<Contact> Con1= [select id, FirstName, LastName, Email from Contact ];
       
        inputLookupReusableClass.getAccLeads(Con1[0].id,NULL);
        inputLookupReusableClass.getAccLeads(NULL,leadRecords[0].id);
        inputLookupReusableClass.getCons(con1[0].id);
    } 
}