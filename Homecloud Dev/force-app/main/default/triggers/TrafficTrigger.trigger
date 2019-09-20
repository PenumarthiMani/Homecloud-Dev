trigger TrafficTrigger on Traffic__c (before insert,After insert, before update) {
Trigger_Handler__mdt TriggerHandler = new Trigger_Handler__mdt();
    TriggerHandler = [select id,MasterLabel,IsActive__c,isAfter__c,isBefore__c,isDelete__c,isInsert__c,isUpdate__c from Trigger_Handler__mdt where MasterLabel = 'TrafficTrigger'];
    if(trigger.isBefore && triggerhandler <> null && triggerhandler.IsActive__c && TriggerHandler.isBefore__c){
        if(trigger.isInsert && triggerhandler.IsInsert__c){ 
            RegCardHelper.pricecheckvalidation(trigger.new);
        } 
    } 
    if((Trigger.isInsert && Trigger.IsAfter) && triggerhandler <> null && triggerhandler.IsActive__c  && triggerhandler.IsAfter__c && triggerhandler.IsInsert__c)
        RegCardHelper.connectionfieldupdate(Trigger.New); 
}