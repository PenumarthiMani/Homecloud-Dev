Public without sharing Class CancelScenario
{  
    @AuraEnabled
    Public Static Scenario__c selectedScenario(String recordId){
        DescribeSObjectResult scenarioDescribeResult = Scenario__c.getSObjectType().getDescribe();
            List<String> scenarioFieldNames = new List<String>( scenarioDescribeResult.fields.getMap().keySet() );
            String scenarioQuery = ' SELECT ' + String.join( scenarioFieldNames, ',' ) + ', Connection__r.Status__c, Recordtype.DeveloperName FROM ' + scenarioDescribeResult.getName() +' WHERE Id =\''+ String.escapeSingleQuotes(recordId) +'\' LIMIT 1 ';
            Scenario__c scenario = Database.query( scenarioQuery );
            
        return scenario;
    }
    @AuraEnabled
    Public Static String cancelScenario(Scenario__c scenarioDetails)
    {
        System.Savepoint sp = Database.setSavepoint();
        try
        {
            System.debug(scenarioDetails.Cancel_Reason__c+'****** SCENARIO DETAILS ********'+scenarioDetails);
            Scenario__c newScenario = new Scenario__c();
            if(scenarioDetails.Cancel_Reason__c == 'Convert to Spec' || scenarioDetails.Cancel_Reason__c == 'Revert to Dirt')
            {
                if(scenarioDetails.Cancel_Reason__c == 'Convert to Spec')
                {
                    Id RecordTypeId = RecordTypeUtil.scenariospecrecordtypename();
                    newScenario =  scenarioDetails.clone(false, false, false, false);
                    
                    if(Schema.sObjectType.Scenario__c.fields.Cancel_Reason__c.isUpdateable())
                        newScenario.Cancel_Reason__c = '';
                    if(Schema.sObjectType.Scenario__c.fields.Connection__c.isUpdateable())
                        newScenario.Connection__c = null;
                    if(Schema.sObjectType.Scenario__c.fields.HomeBuyer__c.isUpdateable())
                        newScenario.HomeBuyer__c = null;
                    if(Schema.sObjectType.Scenario__c.fields.RecordTypeId.isUpdateable())
                        newScenario.RecordTypeId = RecordTypeId;
                    if(Schema.sObjectType.Scenario__c.fields.Status__c.isUpdateable())
                        newScenario.Status__c = 'New';
                    if(Schema.sObjectType.Scenario__c.fields.Previous_Scenario__c.isUpdateable())
                        newScenario.Previous_Scenario__c = scenarioDetails.Id;
                    if(Schema.sObjectType.Scenario__c.isCreateable())
                        insert newScenario;
                    
                    
                    DescribeSObjectResult scenarioGroupDescribeResult = Scenario_Group__c.getSObjectType().getDescribe();
                    List<String> scenarioGroupFieldNames = new List<String>( scenarioGroupDescribeResult.fields.getMap().keySet() );
                    String scenarioGroupQuery = ' SELECT ' + String.join( scenarioGroupFieldNames, ',' ) + ' FROM ' + scenarioGroupDescribeResult.getName() +' WHERE Scenario__c =\''+ scenarioDetails.Id +'\'';
                    List<Scenario_Group__c> scenarioGroups = Database.query(scenarioGroupQuery);
                    
                    List<Scenario_Group__c> groupsToInsert = new List<Scenario_Group__c>();
                    for(Scenario_Group__c sg : scenarioGroups){
                        Scenario_Group__c grp = sg.clone(false, false, false, false);
                        if(Schema.sObjectType.Scenario_Group__c.fields.Scenario__c.isAccessible())
                            grp.Scenario__c = newScenario.Id;
                        groupsToInsert.add(grp);
                    }
                    system.debug('****** Scenario Group ******'+groupsToInsert);
                    if(!groupsToInsert.isEmpty() && Schema.sObjectType.Scenario_Group__c.isCreateable())
                        insert groupsToInsert;
                    Map<String, Scenario_Group__c> scenarioGroupMap = new Map<String, Scenario_Group__c>();
                    for(Scenario_Group__c sg : scenarioGroups){
                        scenarioGroupMap.put(sg.Name, sg);
                    }
                    
                    DescribeSObjectResult optionsDescribeResult = Option__c.getSObjectType().getDescribe();
                    List<String> optionFieldNames = new List<String>( optionsDescribeResult.fields.getMap().keySet() );
                    String optionsQuery = ' SELECT ' + String.join( optionFieldNames, ',' ) + ', Group__r.Name, Catalog__r.Global__c FROM ' + optionsDescribeResult.getName() +' WHERE Scenario__c =\''+ scenarioDetails.Id +'\'';
                    List<Option__c> scenarioLines = Database.query( optionsQuery );
                    system.debug('****** Scenario Lines ******'+scenarioLines);
                    List<Option__c> scenarioOptions = new List<Option__c>();
                    System.debug(scenarioDetails.Id+'**** NEW SCENARIO ID ****'+newScenario.Id);
                    for(Option__c options : scenarioLines){
                        Option__c opts =  options.clone(false, false, false, false);
                        opts.Scenario__c = newScenario.Id;
                        if(Schema.sObjectType.Option__c.fields.Required_By__c.isUpdateable())
                        opts.Required_By__c = null;
                        if(Schema.sObjectType.Option__c.fields.Group__c.isUpdateable() && options.Group__c <> null && scenarioGroupMap.containsKey(options.Group__r.Name)){
                            opts.Group__c = scenarioGroupMap.get(options.Group__r.Name).Id;
                            if(Schema.sObjectType.Option__c.fields.Group_Name__c.isUpdateable()) opts.Group_Name__c = scenarioGroupMap.get(options.Group__r.Name).Name;
                        }    
                        scenarioOptions.add(opts);
                    }
                    system.debug('****** Scenario Options ******'+scenarioOptions);
                    if(!scenarioOptions.isEmpty() && Schema.sObjectType.Option__c.isCreateable()){
                        insert scenarioOptions;
                        system.debug('****** Scenario Options SUCCESS ******'+scenarioOptions);
                        string modelOptionId = null;
                        for(Option__c options : scenarioOptions){
                            if(options.Type__c == 'Model'){
                               modelOptionId = options.Id;
                               break;  
                            }
                        }
                        for(Option__c options : scenarioOptions){
                            if(options.Type__c == 'Model Options' && Schema.sObjectType.Option__c.fields.Required_By__c.isUpdateable()) {
                               options.Required_By__c = modelOptionId;
                            }
                        }
                        if(Schema.sObjectType.Option__c.isUpdateable())
                        update scenarioOptions;
                    }
                    Catalog__c productDetails = new Catalog__c();
                    ProductDetails = [Select Id, Status__c from Catalog__c where Id =: scenarioDetails.Lot__c]; 
                    if(Schema.sObjectType.Catalog__c.fields.Status__c.isUpdateable())
                    ProductDetails.Status__c = 'Spec';
                    if(Schema.sObjectType.Catalog__c.isUpdateable())
                    Update productDetails;
                    
                    if(Schema.sObjectType.Scenario__c.fields.Status__c.isUpdateable())
                        scenarioDetails.Status__c = 'Cancelled';
                    if(Schema.sObjectType.Scenario__c.fields.Cancelled__c.isUpdateable())
                        scenarioDetails.Cancelled__c = True;
                    if(Schema.sObjectType.Scenario__c.isUpdateable())
                        Update scenarioDetails;
                    return 'Success-'+newScenario.Id;
                }
                else if(scenarioDetails.Lot__c <> Null){
                    newScenario = scenarioDetails;
                    Catalog__c productDetails = new Catalog__c();
                    ProductDetails = [Select Id, Status__c from Catalog__c where Id =: scenarioDetails.Lot__c]; 
                    if(Schema.sObjectType.Catalog__c.fields.Status__c.isUpdateable())
                    ProductDetails.Status__c = 'Open';
                    if(Schema.sObjectType.Catalog__c.isUpdateable())
                    Update productDetails;
                    if(Schema.sObjectType.Scenario__c.fields.Status__c.isUpdateable())
                    scenarioDetails.Status__c = 'Cancelled';
                    if(Schema.sObjectType.Scenario__c.fields.Cancelled__c.isUpdateable())
                        scenarioDetails.Cancelled__c = True;
                    if(Schema.sObjectType.Scenario__c.isUpdateable())
                        Update scenarioDetails;
                    return 'Success-'+scenarioDetails.Id;
                }
                else{
                    return 'Error';
                }
            }
            else
                return 'Error';
        }
        catch(Exception e){
            system.debug('****** Exception *****'+e);
            Database.rollback(sp); 
            return e.getMessage()+ ' : '+ e.getStackTraceString();
        }
    }
    
    
    @AuraEnabled
    public static List<picklistWrap> getCancelTo()
    {
        List<picklistWrap> PriorityOptions = new List<picklistWrap>();
        Schema.DescribeFieldResult fieldResult = Scenario__c.Cancel_Reason__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        PriorityOptions.add(new picklistWrap('--None--', ''));
        for( Schema.PicklistEntry f : ple)
        {
            PriorityOptions.add(new picklistWrap(f.getLabel(), f.getValue()));
        }       
        return PriorityOptions;
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