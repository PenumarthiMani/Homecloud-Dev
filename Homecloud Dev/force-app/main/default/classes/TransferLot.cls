/*
Class Name : Transfer Lot
Description: Need to transfer lot on the quotes.
Test Class : TransferLot_TC
*/
public without sharing class TransferLot{
    @AuraEnabled 
    public static string lotTransfer(String QuoteId, string NewLotId){
        string message = '';
        Savepoint sp = Database.setSavepoint();
        Scenario__c sc=new Scenario__c ();
        try{
            
            DescribeSObjectResult scenarioDescribeResult = Scenario__c.getSObjectType().getDescribe();
            List<String> scenarioFieldNames = new List<String>( scenarioDescribeResult.fields.getMap().keySet() );
            String scenarioQuery = ' SELECT ' + String.join( scenarioFieldNames, ',' ) + ' FROM ' + scenarioDescribeResult.getName() +' WHERE Id =\''+ String.escapeSingleQuotes(QuoteId) +'\' LIMIT 1 ';
            Scenario__c scenario = Database.query( scenarioQuery );
            
            DescribeSObjectResult scenarioGroupDescribeResult = Scenario_Group__c.getSObjectType().getDescribe();
            List<String> scenarioGroupFieldNames = new List<String>( scenarioGroupDescribeResult.fields.getMap().keySet() );
            String scenarioGroupQuery = ' SELECT ' + String.join( scenarioGroupFieldNames, ',' ) + ' FROM ' + scenarioGroupDescribeResult.getName() +' WHERE Scenario__c =\''+ String.escapeSingleQuotes(QuoteId) +'\'';
            List<Scenario_Group__c> scenarioGroups = Database.query(scenarioGroupQuery);
            
            DescribeSObjectResult optionsDescribeResult = Option__c.getSObjectType().getDescribe();
            List<String> optionFieldNames = new List<String>( optionsDescribeResult.fields.getMap().keySet() );
            String optionsQuery = ' SELECT ' + String.join( optionFieldNames, ',' ) + ', Group__r.Name, Catalog__r.Global__c FROM ' + optionsDescribeResult.getName() +' WHERE Scenario__c =\''+ String.escapeSingleQuotes(QuoteId)+'\'';
            List<Option__c> options = Database.query( optionsQuery );
            
            DescribeSObjectResult depositDescribeResult = Deposit__c.getSObjectType().getDescribe();
            List<String> depositFieldNames = new List<String>( depositDescribeResult.fields.getMap().keySet() );
            String depositQuery = ' SELECT ' + String.join( depositFieldNames, ',' ) + ' FROM ' + depositDescribeResult.getName() +' WHERE Scenario__c =\''+ String.escapeSingleQuotes(QuoteId) +'\'';
            List<Deposit__c> deposits = Database.query( depositQuery );
            
            DescribeSobjectResult discountDescribeResults = Discount__c.getSobjectType().getDescribe();
            List<String> discountFieldNames = new List<String>(discountDescribeResults.fields.getMap().keyset());
            String discountQuery = 'SELECT '+String.join( discountFieldNames, ',')+' FROM ' + discountDescribeResults.getName()+ ' WHERE Scenario__c = \''+ String.escapeSingleQuotes(QuoteId) +'\'';
            List<Discount__c> discounts = Database.query( discountQuery );
            
            DescribeSObjectResult scenarioIncetiveDescribeResult = Scenario_Incentive__c.getSObjectType().getDescribe();
            List<String> scenarioIncentiveFieldNames = new List<String>( scenarioIncetiveDescribeResult.fields.getMap().keySet() );
            String scenarioIncentiveQuery = ' SELECT ' + String.join( scenarioIncentiveFieldNames, ',' ) + ' FROM ' + scenarioIncetiveDescribeResult.getName() +' WHERE Scenario__c =\''+ String.escapeSingleQuotes(QuoteId) +'\'';
            List<Scenario_Incentive__c> scenarioIncentives = Database.query( scenarioIncentiveQuery );
            
             Catalog__c lotProduct = [select id, Name, Price__c from Catalog__c where Id =: NewLotId limit 1]; 
            
            sc =  scenario.clone(false, false, false, false);
            if(Schema.sObjectType.Scenario__c.fields.Status__c.isUpdateable())
                sc.Status__c = 'Draft';
            if(Schema.sObjectType.Scenario__c.fields.Lot__c.isUpdateable())
                sc.Lot__c = NewLotId;
            if(Schema.sObjectType.Scenario__c.fields.Previous_Scenario__c.isUpdateable())
                sc.Previous_Scenario__c = scenario.Id;
            if(Schema.sObjectType.Scenario__c.fields.Cancelled__c.isUpdateable())
                sc.Cancelled__c = false;
            if(Schema.sObjectType.Scenario__c.isCreateable())
                insert sc;
            
            if(Schema.sObjectType.Scenario__c.fields.Status__c.isUpdateable())
                scenario.Status__c = 'Cancelled';
            if(Schema.sObjectType.Scenario__c.fields.Cancelled__c.isUpdateable())
                scenario.Cancelled__c = True;
            if(Schema.sObjectType.Scenario__c.isCreateable())
                update scenario;
            
            List<Scenario_Group__c> groupsToInsert = new List<Scenario_Group__c>();
            for(Scenario_Group__c sg : scenarioGroups){
                Scenario_Group__c grp = sg.clone(false, false, false, false);
                if(Schema.sObjectType.Scenario_Group__c.fields.Scenario__c.isAccessible())
                    grp.Scenario__c = sc.Id;
                groupsToInsert.add(grp);
            }
            if(Schema.sObjectType.Scenario_Group__c.isCreateable())
                insert groupsToInsert;
            
            Map<String, Scenario_Group__c> scenarioGroupMap = new Map<String, Scenario_Group__c>();
            for(Scenario_Group__c sg : scenarioGroups){
                scenarioGroupMap.put(sg.Name, sg);
            }
            
            List<Option__c> optionsToInsert = new List<Option__c>();
            Option__c modelCatalog = new Option__c();
            for(Option__c option : options){
                Option__c op = option.clone(false, false, false, false);
                if(Schema.sObjectType.Option__c.fields.Scenario__c.isAccessible())
                    system.debug('@@'+sc.Id);
                op.Scenario__c = sc.Id;
                if(Schema.sObjectType.Option__c.fields.Type__c.isUpdateable())
                    if(op.Type__c == 'Homesite' || op.Type__c == 'Lot'){
                        if(Schema.sObjectType.Option__c.fields.Catalog__c.isUpdateable())
                            op.Catalog__c = NewLotId;
                        if(Schema.sObjectType.Option__c.fields.UnitPrice__c.isUpdateable())
                            op.UnitPrice__c = lotProduct.Price__c;
                        if(Schema.sObjectType.Option__c.fields.Subtotal__c.isUpdateable())
                            op.Subtotal__c = lotProduct.Price__c;
                    }
                if(op.Type__c == 'Model'){
                    modelCatalog = op;
                }
                if(op.Group__c <> null && scenarioGroupMap.containsKey(op.Group__r.Name)){
                    op.Group__c = scenarioGroupMap.get(op.Group__r.Name).Id;
                    op.Group_Name__c = scenarioGroupMap.get(op.Group__r.Name).Name;
                }    
                if(op.Type__c != 'Model') optionsToInsert.add(op);
            }
            if(Schema.sObjectType.Option__c.isCreateable())
                insert modelCatalog;
            for(Option__c option : optionsToInsert){
                if(option.Required_By__c <> null) option.Required_By__c = modelCatalog.Id;
            }
            if(Schema.sObjectType.Option__c.isCreateable())
                insert optionsToInsert;
            
            List<Deposit__c> depositRecords = new List<Deposit__c>();
            for(Deposit__c deposit : deposits){
                Deposit__c dp = deposit.clone(false, false, false, false);
                if(Schema.sObjectType.Deposit__c.fields.Scenario__c.isUpdateable())
                    dp.Scenario__c = sc.Id;
                depositRecords.add(dp);
            }
            if(Schema.sObjectType.Deposit__c.isCreateable())
                insert depositRecords;
            
            List<Discount__c> discountRecords = new List<Discount__c>();
            for(Discount__c discount : discounts){
                Discount__c dp = discount.clone(false, false, false, false);
                if(Schema.sObjectType.Discount__c.fields.Scenario__c.isUpdateable())
                    dp.Scenario__c = sc.Id;
                discountRecords.add(dp);
            }
            if(Schema.sObjectType.Discount__c.isCreateable())
                insert discountRecords;
            List<Scenario_Incentive__c> senarioIncetiveToLoad = new List<Scenario_Incentive__c>();
            for(Scenario_Incentive__c incentives : scenarioIncentives){
                Scenario_Incentive__c sincentive = incentives.clone(false, false, false, false);
                if(Schema.sObjectType.Scenario_Incentive__c.fields.Scenario__c.isUpdateable())
                    sincentive.Scenario__c = sc.Id;
                senarioIncetiveToLoad.add(sincentive);
            }
            if(Schema.sObjectType.Scenario_Incentive__c.isCreateable())
                insert senarioIncetiveToLoad;
            
          /*  List<Catalog__c> catalogRecords = new List<Catalog__c>();
              catalogRecords.add(new Catalog__c(Id = scenario.Lot__c, Status__c = 'Open'));
              catalogRecords.add(new Catalog__c(Id = NewLotId, Status__c = 'Reserved'));
              if(Schema.sObjectType.Catalog__c.isUpdateable())
                update catalogRecords;    */
        
           
        }
        catch(Exception e){
            message = e.getMessage();
            Database.rollback(sp);
        }
        if(String.isBlank(message))
            message = 'updated successfully,'+sc.Id;
        return message;
        
    }
    @AuraEnabled
    public static Scenario__c getCommunity(String QuoteId) 
    {
        Scenario__c  qt = [Select id, Lot__c, Community__c, Model__r.CatalogCode__c, Cancelled__c from Scenario__c where id=: QuoteId];
        return qt;
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
                    system.debug('@@@@@converting to spec');
                    if(Schema.sObjectType.Catalog__c.fields.Status__c.isUpdateable())
                        ProductDetails.Status__c = 'Spec';
                    if(Schema.sObjectType.Catalog__c.isUpdateable())
                        Update productDetails;
                    System.debug('@@@@@'+productDetails);
                    
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
    public static List<picklistWrap> getCancelTo(String QuoteId)
    {
        Id RecordTypeId = RecordTypeUtil.scenarioSpecRecordTypeName();
        Scenario__c  pq=new Scenario__c();
        Scenario__c  qt = [Select id, Previous_Scenario__c from Scenario__c where id=: QuoteId];         
        if(qt.Previous_Scenario__c!=NULL)
            pq= [Select id, RecordTypeId from Scenario__c where id=: qt.Previous_Scenario__c];
        List<picklistWrap> PriorityOptions = new List<picklistWrap>();
        Schema.DescribeFieldResult fieldResult = Scenario__c.Cancel_Reason__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        PriorityOptions.add(new picklistWrap('--None--', ''));
        if(pq==NULL || pq.RecordTypeId!=RecordTypeId){
            for( Schema.PicklistEntry f : ple)
            {
                PriorityOptions.add(new picklistWrap(f.getLabel(), f.getValue()));
            }      
        }
        else if(pq!=NULL && pq.RecordTypeId==RecordTypeId){
            for( Schema.PicklistEntry f : ple)
            {
                if(f.getLabel()=='Convert to Spec')
                    PriorityOptions.add(new picklistWrap(f.getLabel(), f.getValue()));
            }      
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