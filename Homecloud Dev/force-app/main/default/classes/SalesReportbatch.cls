/*
    Description: Update Actual in Sales Object based on Opportunity count for current month.
    Execution Process: 
    string query = 'select id, Name from User where isActive = true and Profile.Name != \'Chatter Free User\'';
    Id batchInstanceId = database.executeBatch(new SalesReportbatch(query), 100);    
       
    //SalesReportbatch batch = new SalesReportbatch();
    //Database.executebatch(batch, 200);
    
*/
global without sharing class SalesReportbatch implements Database.Batchable<sObject> {
     global string query;
     global SalesReportbatch(String q){
         query = q;
     }
     global Database.QueryLocator start(Database.BatchableContext BC){
         return Database.getQueryLocator(query);
     }
     global void execute(Database.BatchableContext BC, List<sObject> scope){
         set<Id> userIds = new set<Id>();
         for(sObject usr : scope){
             User u = (User)usr;
             userIds.add(usr.Id);
         }
         List<Sales__c> currentYearSalesRecords = [select id, OwnerId, External_Id__c, User__c, Date__c, Actuals__c from Sales__c where Date__c = THIS_YEAR and User__c In: userIds];
         Map<string, Sales__c> currentYearSalesRecordMap = new Map<string, Sales__c>();
         for(Sales__c s : currentYearSalesRecords ){
             if(Schema.sObjectType.Sales__c.fields.Actuals__c.isUpdateable() && Schema.sObjectType.Sales__c.fields.External_Id__c.isUpdateable())
             s.Actuals__c = null;
             currentYearSalesRecordMap.put(s.External_Id__c, s);
         }
         List<AggregateResult> aggregateResults = [SELECT count(Id) cnt, CALENDAR_MONTH(Sale_Date__c) calMonth,  OwnerId FROM Connection__c where OwnerId In: userIds and Sale_Date__c <> null and Sale_Date__c = THIS_YEAR  GROUP BY OwnerId, CALENDAR_MONTH(Sale_Date__c)];
         List<Sales__c> salesRecords = new List<Sales__c>();
         for(AggregateResult ar : aggregateResults){
              string externalId = (String)ar.get('OwnerId')+'-'+Datetime.newInstance(system.Today().Year(), (Integer)ar.get('calMonth'), 1, 0, 0, 0).format('MMM-YYYY');
              salesRecords.add(new Sales__c(OwnerId = (String)ar.get('OwnerId'), External_Id__c = externalId, User__c = (String)ar.get('OwnerId'), Actuals__c = (Integer)ar.get('cnt'), Date__c = Date.newInstance(system.Today().Year(), (Integer)ar.get('calMonth'), 1)));
              currentYearSalesRecordMap.remove(externalId); 
         }   
         salesRecords.addAll(currentYearSalesRecordMap.values());  
          if(Schema.sObjectType.Sales__c.isUpdateable() || Schema.sObjectType.Sales__c.isCreateable())
         database.Upsert(salesRecords, Sales__c.External_Id__c, false);
     }
     global void finish(Database.BatchableContext bc){ }
      
     
}