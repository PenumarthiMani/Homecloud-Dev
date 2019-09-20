public class RecordTypeUtil{
    public Static Id  contactRecordTypeName(){
     Id lstRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Homebuyer').getRecordTypeId();
      return lstRecordType ;
    }
    public Static Id  contactAgentRecordTypeName(){
     Id lstRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
      return lstRecordType ;
    }
    public Static Id  lotRecordTypeName(){
     Id lstRecordType = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Lot').getRecordTypeId();
      return lstRecordType ;
    }
    public Static Id  modelRecordTypeName(){
     Id lstRecordType = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Model').getRecordTypeId();
      return lstRecordType ;
    }
    public Static Id  optionRecordTypeName(){
     Id lstRecordType = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Options').getRecordTypeId();
      return lstRecordType ;
    }
    public Static Id  modelOptionRecordTypeName(){
     Id lstRecordType = Schema.SObjectType.Catalog__c.getRecordTypeInfosByName().get('Model Options').getRecordTypeId();
      return lstRecordType ;
    }
     public Static Id  incentiveRecordTypeName(){
     Id lstRecordType = Schema.SObjectType.Incentive_Master__c.getRecordTypeInfosByName().get('Dollar').getRecordTypeId();
      return lstRecordType ;
    }
    public Static Id  incentivePercentRecordTypeName(){
     Id lstRecordType = Schema.SObjectType.Incentive_Master__c.getRecordTypeInfosByName().get('Percent').getRecordTypeId();
      return lstRecordType ;
    }
    public Static Id  scenarioRegularRecordTypeName(){
     Id lstRecordType = Schema.SObjectType.Scenario__c.getRecordTypeInfosByName().get('Regular').getRecordTypeId();
      return lstRecordType ;
    }
     public Static Id  scenarioSpecRecordTypeName(){
     Id lstRecordType = Schema.SObjectType.Scenario__c.getRecordTypeInfosByName().get('Spec Quote').getRecordTypeId();
      return lstRecordType ;
    }
     public Static Id  trafficRecordTypeName(){
     Id lstRecordType = Schema.SObjectType.Traffic__c.getRecordTypeInfosByName().get('BeBack').getRecordTypeId();
      return lstRecordType ;
    }
      public Static Id  trafficRegisteredRecordTypeName(){
     Id lstRecordType = Schema.SObjectType.Traffic__c.getRecordTypeInfosByName().get('Registered').getRecordTypeId();
      return lstRecordType ;
    }
    public Static Id  trafficUnregisteredRecordTypeName(){
     Id lstRecordType = Schema.SObjectType.Traffic__c.getRecordTypeInfosByName().get('Unregistered').getRecordTypeId();
      return lstRecordType ; 
    }
}