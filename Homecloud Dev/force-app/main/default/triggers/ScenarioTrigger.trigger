trigger ScenarioTrigger on Scenario__c (before Insert, before Update, after Update, after delete) {
   Trigger_Handler__mdt TriggerHandler = [select id, MasterLabel, IsActive__c, isAfter__c, isBefore__c, isDelete__c, isInsert__c, isUpdate__c from Trigger_Handler__mdt where MasterLabel = 'QuoteTriggerHandler'];
   if(triggerhandler <> null && triggerhandler.IsActive__c){
       if(Trigger.isBefore && triggerhandler.IsBefore__c){
           if(Trigger.isInsert && triggerhandler.IsInsert__c)ScenarioHelperClass.beforeTrigger(Trigger.New, new Map<Id, Scenario__c>());
           if(Trigger.isUpdate && triggerhandler.IsUpdate__c)ScenarioHelperClass.beforeTrigger(Trigger.New, Trigger.OldMap);
       }
       else if(Trigger.isAfter && triggerhandler.IsAfter__c){
           if(Trigger.isUpdate && triggerhandler.IsUpdate__c){
               ScenarioHelperClass.afterUpdate(Trigger.newMap, Trigger.oldMap);
                ScenarioHelperClass.CancelOldScenarios(Trigger.newMap,Trigger.OldMap);
           } 
           else if(Trigger.isDelete && triggerhandler.IsDelete__c){
               ScenarioHelperClass.scenarioDelete(Trigger.oldMap);
           }   
       }
       
   }
}