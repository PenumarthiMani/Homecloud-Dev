trigger ContactTrigger on Contact (before delete) {
    if(Trigger.isDelete && Trigger.isBefore){
        ContactTriggerHandler.deletehomebuyer(Trigger.oldMap);
    }
}