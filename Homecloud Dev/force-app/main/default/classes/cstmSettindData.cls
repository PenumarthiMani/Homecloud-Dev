public class cstmSettindData {
    @AuraEnabled
    public static  List<AgentRecordType__c> getListSettings(){
        List<AgentRecordType__c> dList = new List<AgentRecordType__c>();
        dList = AgentRecordType__c.getall().values();
        system.debug('dList:::::::::::::::::::::::'+dList);     
        
      return dList;
    }
    
    
    
   /* @AuraEnabled
    public static  List<AgentRecordType__c> getListSettings(){
        List<AgentRecordType__c> dList = new List<AgentRecordType__c>();
        dList = AgentRecordType__c.getall().values();
        system.debug('dList:::::::::::::::::::::::'+dList);
        
        Id AgentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        
        String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + AgentRecordTypeId;
        
        system.debug(fullFileURL+':::::::::::fullFileURL::::::::::'+'::::::::::AgentRecordTypeId::::::::::'+AgentRecordTypeId);
        
        //https://home-dev-ed--c.visualforce.com
        
        
        String target = 'ed--c.visualforce';
        String replacement = 'ed.lightning.force';
        String s2 = s1.replace(target, replacement);
        System.assertEquals('axydxya', s2);
        
      return dList;
    }*/
    
}