public without sharing class NewConnectionController {
    @AuraEnabled
    public static String createConnection(String homebuyer,String div,String communityid,Date closingdate){
        try
        {
            Date d = System.today();
            if(d <= closingdate){
            Community__c com=[Select Id,Name,Division__c,Division__r.ID from Community__c where Id=:communityid];
            Contact contact=[Select Id,Name,RecordTypeId,AccountId,Agent__c from Contact where Id=:homebuyer];
            Connection__c con=new Connection__c();
            con.Name=com.Name+'-'+Date.today().format()+'-'+contact.Name;
            con.Homebuyer__c=homebuyer;
            con.Division__c=div;
            con.Community__c=communityid;
            con.Agency__c=contact.AccountId;
            con.Agent__c=contact.Agent__c;
            con.Status__c='Lead';
            if(closingdate <> NULL)
               con.Estimated_Close_Date__c=closingdate;
            insert con;
            return con.Id;
            }
            return 'Error';
        }
        catch(exception e)
        {
            return e.getMessage();
        }
    } 
    @AuraEnabled
    public Static String recordname(String contactid){
        Contact con = [select id,Name from Contact where Id =: contactid];
        return con.Name;
    }

}