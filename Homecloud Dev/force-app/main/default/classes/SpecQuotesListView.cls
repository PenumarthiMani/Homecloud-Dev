//Spec Quotes List View and Spec Quote Creation
Public without sharing Class SpecQuotesListView
{
    //Spec List View
    @AuraEnabled
    Public Static List<Scenario__c> specQuotes(String Status, String CommunityId, String DivisionId)
    {
        String queryString = 'Select Id, Name, Status__c, Community__c, Community__r.Name, Division__c, Division__r.Name, Lot__c, Lot__r.Name, Model__c, Model__r.Name, Net_Amount__c from Scenario__c where RecordType.DeveloperName = \'Spec_Quote\' and Status__c = \'New\'';
      /*  if(!String.IsBlank(Status))
            queryString += ' and Status__c = \''+String.escapeSingleQuotes(Status)+'\''; */
        if(!String.IsBlank(DivisionId))
            queryString += ' and Division__c = \''+String.escapeSingleQuotes(DivisionId)+'\'';
        if(!String.IsBlank(CommunityId))
            queryString += ' and Community__c = \''+String.escapeSingleQuotes(CommunityId)+'\'';        
        List<Scenario__c> Quotes = New List<Scenario__c>();
        Quotes = Database.Query(queryString);
        return Quotes;
    }
    //Spec Creation
    @AuraEnabled
    Public Static Scenario__c newSpecQuote(Scenario__c NewSpec, String CommunityId, String DivisionId)
    {            
            Id RecordTypeId = RecordTypeUtil.scenariospecrecordtypename();
            Scenario__c Spec = New Scenario__c(); 
            if(Schema.sObjectType.Scenario__c.fields.Status__c.isUpdateable())
            Spec.Status__c = 'New';
            if(Schema.sObjectType.Scenario__c.fields.RecordTypeId.isUpdateable())
            Spec.RecordTypeId = RecordTypeId;
            if(Schema.sObjectType.Scenario__c.fields.Community__c.isUpdateable())
            Spec.Community__c = CommunityId;
            if(Schema.sObjectType.Scenario__c.fields.Division__c.isUpdateable())
            Spec.Division__c = DivisionId;
            if(Schema.sObjectType.Scenario__c.isCreateable())
            Insert Spec;
            return Spec;
    }
    //To get Quote Status
 /*   @AuraEnabled
    public static List<picklistWrap> getStatus()
    {
      List<picklistWrap> StatusOptions = new List<picklistWrap>();
      Schema.DescribeFieldResult fieldResult = Scenario__c.Status__c.getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
      for( Schema.PicklistEntry f : ple)
      {
          if(f.getValue() <> 'Sent via DocuSign' && f.getValue() <> 'Cancelled' && f.getValue() <> 'Converted')
              StatusOptions.add(new picklistWrap(f.getLabel(), f.getValue()));
      }       
      return StatusOptions;
    } */
//To get divisions list
    @AuraEnabled
    public static List<picklistWrap> getDivisions()
    {
      List<Division__c> divisionList = New List<Division__c>();
      divisionList = [Select Id, Name,Active__c from Division__c where Active__c=True];
      List<picklistWrap> availableDivisions = new List<picklistWrap>();
      for(Division__c div: divisionList)
      {
          availableDivisions.add(new picklistWrap(div.Id, div.Name));
      }       
      return availableDivisions;
    }
    //To get communities list based on selected division
    @AuraEnabled
    public static List<picklistWrap> getCommunities(String DivisionId)
    {
      List<Community__c> communityList = New List<Community__c>();
      communityList = [Select Id, Name from Community__c where Division__c =: DivisionId and Active__c = True];
      List<picklistWrap> availableCommunities = new List<picklistWrap>();
      for(Community__c comm: communityList)
      {
         availableCommunities.add(new picklistWrap(comm.Id, comm.Name));
      }       
      return availableCommunities;
    }
    public class picklistWrap {
        @AuraEnabled public string labelval;
        @AuraEnabled public string selectedVal;
        public picklistWrap(string labelval, string selectedVal){
          this.labelval = labelval;
          this.selectedVal = selectedVal;
        }
    }
}