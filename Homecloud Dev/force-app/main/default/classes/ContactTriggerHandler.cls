public class ContactTriggerHandler {
    public static void deletehomebuyer(Map<Id,Contact> oldContacts){
        Id homebuyerRecTypeId=RecordTypeUtil.contactRecordTypeName();
        List<Contact> homebuyers=[Select Id,Name,RecordTypeID,(Select Id,Name from Connections__r) from Contact where Id IN:oldContacts.keySet() AND RecordTypeId=:homebuyerRecTypeId];
        for(Contact hb:homebuyers){
            if(!hb.Connections__r.isEmpty()){
             oldContacts.get(hb.Id).addError('You cannot delete Homebuyer with Connections.');   
            }            
        }
    }
}