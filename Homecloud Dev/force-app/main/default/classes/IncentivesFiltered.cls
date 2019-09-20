public without sharing class IncentivesFiltered {
    public class innerclass {
        @AuraEnabled public String Type {set;get;}
        @AuraEnabled public String division {set;get;}
        @AuraEnabled public String community {set;get;}
        @AuraEnabled public String lot {set;get;}
        @AuraEnabled public String IncetiveName {set;get;}
        @AuraEnabled public ID quoteid {set;get;}
        @AuraEnabled public ID incentiveid {set;get;}
        @AuraEnabled public Boolean checklist{set;get;}
        @AuraEnabled public Decimal Amount{set;get;}
        @AuraEnabled public Decimal AmountIncentive{set;get;}
        @AuraEnabled public Decimal Percentage{set;get;}
    }
    //purpose : to get the list of incentives based on Division,Community,Lot
    @AuraEnabled 
    public static List<innerclass> Incentivesfiltered (ID quoteid){  
        List<innerclass> innerclas = new List<innerclass>();
        List<Scenario_Incentive__c> QuoteIncentives = New List<Scenario_Incentive__c>(); 
        Set<Id> ExistingQuoteIncentiveIds = New Set<Id>();
        DescribeSObjectResult scenarioDescribeResult = Scenario__c.getSObjectType().getDescribe();
        List<String> scenarioFieldNames = new List<String>( scenarioDescribeResult.fields.getMap().keySet() );
        DescribeSObjectResult scenarioincentiveDescribeResult = Scenario_Incentive__c.getSObjectType().getDescribe();
        List<String> scenarioincentiveFieldNames = new List<String>( scenarioincentiveDescribeResult.fields.getMap().keySet() );
        String scenarioquery = 'SELECT '+String.join( scenarioFieldNames, ',' )+',Division__r.name,Community__r.Name,Lot__r.Name,(SELECT '+String.join( scenarioincentiveFieldNames, ',' )+ ' FROM Scenario__r)' +' FROM '+ scenarioDescribeResult.getName()+' WHERE id =\''+quoteid+'\'';
        Scenario__c qu = Database.query(scenarioquery);
        //Scenario__c qu = new Scenario__c();
        //qu = [select id, Name, division__c, TotalScenarioOptionPrice__c, Community__c, Community__r.Division__c, Lot__c, Division__r.Name, Community__r.Name,Lot__r.Name,(Select Id,Incentive_Master__c,Scenario__c from Scenario__r) from Scenario__c where id =: quoteid];    
        //Test Scenario
        Set<ID>  existsc=new Set<ID>();    
        for(Scenario_Incentive__c incentives:qu.Scenario__r){
            existsc.add(incentives.Incentive_Master__c);
        }
        //
        String incentiveQuery = 'select id, Name, division__c, community__c, lot__c, Division__r.Name,Community__r.Name,Lot__r.Name,Percent__c,Amount__c,Approval_Status__c, (select Incentive_Master__c, Scenario__c from Quote_Incentives__r where Scenario__c = \''+qu.id+'\') from Incentive_Master__c where ID <> NULL  AND Approval_Status__c = \'Approved\'';
        if(Schema.sObjectType.Scenario__c.fields.division__c.isUpdateable() || Schema.sObjectType.Scenario__c.fields.Lot__c.isUpdateable() || Schema.sObjectType.Scenario__c.fields.community__c.isUpdateable()){
            if(qu.Lot__c <> null && qu.division__c <> null && qu.community__c <> null) incentiveQuery = incentiveQuery + ' and (Division__c = \''+String.escapeSingleQuotes(qu.Division__c)+'\' AND ((Community__c = Null AND Lot__c = Null) OR (Community__c = \''+String.escapeSingleQuotes(qu.community__c)+'\' AND Lot__c = Null) OR (community__c = \''+String.escapeSingleQuotes(qu.community__c)+'\' AND lot__c = \''+String.escapeSingleQuotes(qu.lot__c)+'\') ))';
            else if(qu.community__c <> null && qu.division__c <> null) incentiveQuery = incentiveQuery + ' and (Division__c = \''+String.escapeSingleQuotes(qu.Division__c)+'\' AND ((Community__c = Null AND Lot__c = Null) OR (Community__c = \''+String.escapeSingleQuotes(qu.community__c)+'\' AND Lot__c = Null)))';
            else if(qu.division__c <> null) incentiveQuery = incentiveQuery + ' and (division__c = \''+String.escapeSingleQuotes(qu.Division__c)+'\' AND Community__c = Null AND Lot__c = Null)'; 
            if(!existsc.isEmpty()) incentiveQuery = incentiveQuery + ' and ID NOT IN : existsc'; 
            List<Incentive_Master__c> im = database.query(incentiveQuery); system.debug('im:'+im);
            QuoteIncentives  = [select Incentive_Master__c,Scenario__c from Scenario_Incentive__c where Scenario__c =: qu.id];
            for(Scenario_Incentive__c Qt: QuoteIncentives)
            {
                if(!String.IsEmpty(Qt.Incentive_Master__c))
                    ExistingQuoteIncentiveIds.add(Qt.Incentive_Master__c);  
            }
            for(Incentive_Master__c i : im){                             
                if(!ExistingQuoteIncentiveIds.Contains(i.Id)){
                    innerclass inn = new innerclass();
                    inn.division = qu.Division__r.Name;
                    inn.community = qu.Community__r.Name;
                    inn.lot = qu.Lot__r.Name;
                    if(i.Lot__c <> null) inn.Type = 'Lot Incentive';
                    else if(i.Community__c <> null) inn.Type = 'Community Incentive';
                    else if(i.Division__c <> null) inn.Type = 'Division Incentive';
                    inn.checklist = false;
                    inn.IncetiveName = i.Name;  
                    inn.quoteid = qu.id;
                    inn.incentiveid = i.id;
                    inn.AmountIncentive = i.Amount__c;
                    if(i.Percent__c != null){
                        inn.Percentage = i.Percent__c/100;
                    }
                    if(i.Amount__c != null){
                        inn.Amount = i.Amount__c;
                    }
                    if(i.Percent__c != null){
                        inn.Amount = ((qu.TotalScenarioOptionPrice__c)*(i.Percent__c/100));
                       
                    }                          
                    innerclas.add(inn); 
                }
            }  
        } 
        return innerclas;
    }
    //purpose : to insert Quote incentive selected in the component  
    @AuraEnabled  
    public static String save(String positionRecords){
        try
        {
            if(!string.isBlank(positionRecords)){
                List<innerclass> innerclas =  (List<innerclass>) System.JSON.deserialize(positionRecords,List<innerclass>.class);
               System.debug('@@@@'+innerclas);
                List<Scenario_Incentive__c> quoteincentivedata = new List<Scenario_Incentive__c>();
                for(innerclass i : innerclas){  
                    if(i.checklist){
                        if(Schema.sObjectType.Scenario_Incentive__c.fields.Incentive_Master__c.isUpdateable() && Schema.sObjectType.Scenario_Incentive__c.fields.Scenario__c.isAccessible() && Schema.sObjectType.Scenario_Incentive__c.fields.Amount__c.isUpdateable())
                            quoteincentivedata.add(new Scenario_Incentive__c(Incentive_Master__c = i.incentiveid,Scenario__c = i.quoteid,Amount__c = i.Amount)); 
                    }
                    
                }
                if(Schema.sObjectType.Scenario_Incentive__c.iscreateable())
                    insert quoteincentivedata;
                
            }
            return 'success';
        }
        Catch(exception e)
        {
            return e.getmessage();
        }       
    }
}