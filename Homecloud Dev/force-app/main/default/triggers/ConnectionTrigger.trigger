trigger ConnectionTrigger on Connection__c (before insert,before update, after insert,after update, before delete) {
    
    Trigger_Handler__mdt TriggerHandler = new Trigger_Handler__mdt();
    TriggerHandler = [select id,MasterLabel,IsActive__c,isAfter__c,isBefore__c,isDelete__c,isInsert__c,isUpdate__c from Trigger_Handler__mdt where MasterLabel = 'ConnectionTrigger'];
    Trigger_Handler__mdt TriggerHandlerCSR = new Trigger_Handler__mdt();
    TriggerHandlerCSR = [select id,MasterLabel,IsActive__c,isAfter__c,isBefore__c,isDelete__c,isInsert__c,isUpdate__c from Trigger_Handler__mdt where MasterLabel = 'CommunitiesRepAccessFromOpp'];
    
    if(Trigger.isBefore){
        if(Trigger.isInsert && TriggerHandler.isInsert__c && TriggerHandler.isBefore__c){
            ConnectionTriggerHandler.beforeInsertUpdateTrigger(Trigger.new, new Map<Id, Connection__c>(), Trigger.isInsert);
        }
        if(Trigger.isUpdate && TriggerHandler.isUpdate__c && TriggerHandler.isBefore__c){
            ConnectionTriggerHandler.beforeInsertUpdateTrigger(Trigger.new, Trigger.oldMap, Trigger.isInsert);
        }
    /*   if(Trigger.isUpdate && TriggerHandler.isUpdate__c && TriggerHandler.isBefore__c){
            ConnectionTriggerHandler.beforeTrigger(Trigger.New, Trigger.OldMap);             
        }*/
        if(Trigger.isDelete && TriggerHandler.isDelete__c && TriggerHandler.isBefore__c){
            ConnectionTriggerHandler.deleteConnection(Trigger.OldMap);             
        }
    } 
    if(Trigger.isAfter){
        if(trigger.isInsert  && TriggerHandler.isinsert__c){
            ConnectionTriggerHandler.OpportunityLeadRanking(Trigger.New, new Map<Id, Connection__c>(), Trigger.isInsert); 
        } 
        if(trigger.isUpdate && TriggerHandler.isUpdate__c)
            ConnectionTriggerHandler.OpportunityLeadRanking(Trigger.New, Trigger.OldMap, Trigger.isInsert);
        if(Trigger.IsAfter && TriggerHandlerCSR <> null && TriggerHandlerCSR.IsActive__c && ((Trigger.IsUpdate && TriggerHandlerCSR.IsUpdate__c) || (Trigger.IsInsert  && TriggerHandlerCSR.IsInsert__c)))
           ConnectionTriggerHandler.OpportunitySharingForReps(Trigger.New, Trigger.OldMap); 
        if(Trigger.isAfter && TriggerHandler.isAfter__c && trigger.isInsert && TriggerHandler.isinsert__c)
             ConnectionTriggerHandler.updateHomebuyer(Trigger.New); 
        if(Trigger.isAfter && TriggerHandler.isAfter__c && trigger.isUpdate && TriggerHandler.isUpdate__c)
             ConnectionTriggerHandler.CobuyerCreation(Trigger.new,Trigger.OldMap);
        if(Trigger.isAfter && TriggerHandler.isAfter__c && trigger.isUpdate && TriggerHandler.isUpdate__c)
             ConnectionTriggerHandler.lotStatusUpdate(Trigger.new,Trigger.OldMap);
    }
}