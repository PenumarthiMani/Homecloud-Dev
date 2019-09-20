//Getting record type id from Scenario object 
public without sharing class TestStandardController {
    
    @AuraEnabled
    public static Id getRecTypeId(String recordTypeLabel){
        Id recid = Schema.SObjectType.Scenario__c.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();        
        return recid;
    }  
    @AuraEnabled
    public static List<FieldSetDetails> dogetfieldsetfields(String conId){
        Connection__c connectionRecord = [select id, Name, Division__c, Division__r.Active__c, Community__c,Homebuyer__c, Community__r.Active__c, (select id from Connection__r where status__c = 'Approved' and Cancelled__c = False) from Connection__c where Id =: conId];
        List<FieldSetDetails> ScenarioFields = new List<FieldSetDetails>();
        for(Schema.FieldSetMember c:SObjectType.Scenario__c.FieldSets.NewScenario_Fieldset.getFields()){
            FieldSetDetails fsd = New FieldSetDetails();
            fsd.Label = c.getLabel(); 
            fsd.isRequired = c.getRequired();
            fsd.DbRequired = c.getDbRequired();  
            //fsd.ObjField = c.getSObjectField();
            fsd.Path = c.getFieldPath();
            //fsd.Dtype=c.getType();
            if(c.getFieldPath()=='Division__c')
                fsd.PathValue = connectionRecord.Division__c;
            else if(c.getFieldPath()=='Community__c')
                fsd.PathValue = connectionRecord.Community__c;
            else if(c.getFieldPath()=='Homebuyer__c')
                fsd.PathValue = connectionRecord.Homebuyer__c; 
            else if(c.getFieldPath()=='Connection__c')
                fsd.PathValue = connectionRecord.Id;            
            else  fsd.PathValue = '';
            ScenarioFields.add(fsd); 
        }
        system.debug('@@@ScenarioFields:'+ScenarioFields);
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
    public class FieldSetDetails{
        @AuraEnabled public String Label{get;set;}
        @AuraEnabled public Boolean isRequired{get;set;}
        @AuraEnabled public Boolean DbRequired{get;set;}
        @AuraEnabled public Schema.sObjectField ObjField{get;set;}
        @AuraEnabled public Schema.DisplayType Dtype{get;set;}
        @AuraEnabled public String Path{get;set;}
        @AuraEnabled public String PathValue{get;set;}
        
    }
    
}