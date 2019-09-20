//Getting record type id from Scenario object 
public without sharing class StandardQuoteController {
    
    @AuraEnabled
    public static Id getRecTypeId(String recordTypeLabel){
        Id recid = Schema.SObjectType.Scenario__c.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();        
        return recid;
    }  
@AuraEnabled
    public static list<string> dogetfieldsetfields(){
        list<string> ScenarioFields= new list<string>();
        for(Schema.FieldSetMember c:SObjectType.Scenario__c.FieldSets.NewScenario_Fieldset.getFields()){
            ScenarioFields.add(c.getFieldPath());
        }
        system.debug('ScenarioFields:'+ScenarioFields);
        return ScenarioFields;        
    }    
    @AuraEnabled
    public static ScenarioClass RegRequired(String conId){
        Id recId = RecordTypeUtil.trafficRegisteredRecordTypeName();
        Connection__c connectionRecord = [select id, Name, Division__c, Division__r.Active__c, Community__c, Community__r.Active__c, (select id from Connection__r where status__c = 'Approved' and Cancelled__c = False), (Select Id from Traffic__r where RecordTypeId =: recId) from Connection__c where Id =: conId];
        Scenario_Validation__mdt isRegRequired = new Scenario_Validation__mdt();
        isRegRequired = [select id, MasterLabel, Reg_Card_Required__c from Scenario_Validation__mdt where MasterLabel = 'RegCardRequired'];
        ScenarioClass sc = new ScenarioClass();
        sc.hasError = False;
        sc.message = '';
        // return isRegRequired.Reg_Card_Required__c;
        if(!connectionRecord.Division__r.Active__c || !connectionRecord.Community__r.Active__c){
            sc.hasError = True;
            sc.message = 'Division and Community on Connection should be active to create Scenario.';
        }
        else if(!connectionRecord.Connection__r.isEmpty()){
            sc.hasError = True;
            sc.message = 'One of the Scenario for the Connection is already Approved. Please use new connection or cancel the approved scenario to continue.';
        }
        else if(isRegRequired.Reg_Card_Required__c == True){
            if(connectionRecord.Traffic__r.isEmpty()){
                sc.hasError = True;
                sc.message = 'Scenario cannot be created without RegCard.';
            }
        }
        return sc;
    }
    public class ScenarioClass{
        @AuraEnabled public boolean hasError{get;set;}
        @AuraEnabled public string message{get;set;}
        
    }
}