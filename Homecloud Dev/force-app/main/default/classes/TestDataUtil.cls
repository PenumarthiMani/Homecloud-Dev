@isTest
public class TestDataUtil
{
    public static List<Account> createAccounts(Integer numOfRecords)
    {
        List<Account> accts = new List<Account>();
        for(Integer i=0; i<numOfRecords; i++) {
            accts.add(new Account(Name='TestAccount' + i));
        }
        return accts;
    }
    public static List<Contact> CreateContact(Integer numOfRecords,id recordtypeid)
    {
        List<Contact> con = new List<Contact>();
        for(Integer i=0; i<numOfRecords; i++) {
            con.add(new Contact(lastName='Testcontact' + i,RecordTypeId=recordtypeid));
        }
        return con;
    }
    public static List<Connection__c> Createconnection(Integer numOfRecords)
    {
        List<Connection__c> con = new List<Connection__c>();
        for(Integer i=0; i<numOfRecords; i++) {
            con.add(new Connection__c(Name='Testconnection' + i,Status__c = 'Lead'));
        }
        return con;
    }
    public static List<Division__c> Createdivision(Integer numOfRecords)
    {
        List<Division__c> div= new List<Division__c>();
        for(Integer i=0; i<numOfRecords; i++) {
            div.add(new Division__c(Name='TestDivision' + i,Active__c = True));
        }
        return div;
    }
    public static List<Community__C> Createcommunity(Integer numOfRecords,id divid)
    {
        List<Community__c> com = new List<Community__c>();
        for(Integer i=0; i<numOfRecords; i++) {
            com.add(new Community__c(Name='Testcommunity' + i,Active__c = True,Division__c = divid));
        }
        return com;
    }
    public static List<Traffic__c> Createtraffic(id Connectionid,Id Communityid,id recordtypeid)
    {
        List<Traffic__c> tra = new List<Traffic__c>();
        tra.add(new Traffic__c(Connection__c = Connectionid,Community__c = Communityid,RecordTypeId = recordtypeid));
        return tra;
    }
    public static List<Scenario__c> Createscenario(id Connectionid,Id Communityid,id recordtypeid,Id divisionid)
    {
        List<Scenario__c> scenario = new List<Scenario__c>();
        scenario.add(new Scenario__c(Connection__c = Connectionid,Community__c = Communityid,RecordTypeId = recordtypeid,Division__c = divisionid));
        return scenario;
    }
    public static List<Option__c> Createoption(id catalogid,Id Scenarioid)
    {
        List<Option__c> opt = new List<Option__c>();  
        opt.add(new Option__c(Catalog__c = catalogid,Scenario__c = Scenarioid));
        return opt;
    }
    public static List<Catalog__c> Createcatalog(id Communityid,Id recordTypeId)
    {
        List<Catalog__c> catalog = new List<Catalog__c>();
        catalog.add(new Catalog__c(Name = 'testcatalog',IsActive__c = True,Community__c = Communityid,RecordTypeId = recordTypeId));
        return catalog;
    }
    public static List<Sales__c> Createsales(id Divisionid,Id Userid)
    {
        List<Sales__c> sasles = new List<Sales__c>();
        sasles.add(new Sales__c(Division__c = Divisionid,User__c = Userid));
        return sasles;
    }
    public static List<Scenario_Incentive__c> Createscenarioincentive(id incentiveid,Id scenarioid)
    {
        List<Scenario_Incentive__c> scenarioincentive = new List<Scenario_Incentive__c>();
        scenarioincentive.add(new Scenario_Incentive__c(Scenario__c = scenarioid,Incentive_Master__c = incentiveid));
        return scenarioincentive;
    }
    public static List<Incentive_Master__c> Createincentive(id communityid,Id divisionid)
    {
        Id RecordTypeIdincentivemaster = Schema.SObjectType.Incentive_Master__c.getRecordTypeInfosByName().get('Dollar').getRecordTypeId();
        List<Incentive_Master__c> incentive = new List<Incentive_Master__c>();
        incentive.add(new Incentive_Master__c(Community__c = communityid,Division__c = divisionid,RecordTypeId = RecordTypeIdincentivemaster));
        return incentive;
    }
    public static List<Task> CreateTask(Integer numOfRecords,Id whatid,Id whoId)
    {
        List<Task> newTasks=new List<Task>();
        for(Integer i=0; i<numOfRecords; i++) {
            
            Task newTask=new Task();
            newTask.Subject='TestTask' + i;
            if(whatid!=Null){
                newTask.WhatId=whatid;            
            }
            if(whatid!=Null){
                newTask.WhoId=whoid;            
            }
            newTasks.add(newTask);            
        }
        return newTasks;
    }
}