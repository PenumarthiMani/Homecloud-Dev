public without sharing class SelectionReportController{ 
public SelectionReportController(){    
          
        quoteId = (Id)ApexPages.currentPage().getParameters().get('qid');
        quoteId = String.escapeSingleQuotes(quoteId);
    
        
        String quoteQuery = ' SELECT Id, Name, Total_Incentive_Amount__c, DiscountAmount__c, Options_Total__c, LotPremium__c, BasePrice__c, Net_Amount__c, Division__c, HomeBuyer__r.Name, Lot__r.Name, Lot__r.Street__c, Lot__r.City__c, Lot__r.State__c, Lot__r.Postal_Code__c, Model__r.Name, Division__r.Name, Community__r.Name, '+
                                       + ' (SELECT Id, Quantity__c, UnitPrice__c, NetAmount__c, Cancelled__c, CatalogCode__c, Catalog__r.Name, Group__r.Name From Option__r where Type__c = \'Model Options\' Order By Cancelled__c, Group__r.Name, Catalog__r.Name ASC) '
                                       + ' FROM Scenario__c WHERE  Id = \''+String.escapeSingleQuotes(quoteId)+'\'';
        quote = database.query(quoteQuery);
        innerList = new List<InnerClass>();
        ammendaRecordMap = new Map<String, List<Option__c>>();
        ammendaRecordMap.put('--', new List<Option__c>());
        List<Option__c> cancelledItems = new List<Option__c>();
        List<Option__c> itemsWithOutAddenda = new List<Option__c>();
        for(Option__c ql : quote.Option__r){
            List<Option__c> quoteline = new List<Option__c>();
            if(ql.Cancelled__c){
                cancelledItems.add(ql); 
            }
            else if(ql.Group__c == null){
                itemsWithOutAddenda.add(ql);
            }            
            else if(ql.Group__c <> null && ammendaRecordMap.containsKey(ql.Group__r.Name)){
                List<Option__c> quotelines = ammendaRecordMap.get(ql.Group__r.Name);
                quotelines.add(ql);
                ammendaRecordMap.put(ql.Group__r.Name, quotelines);
            }
            else{
                quoteline.add(ql);
                ammendaRecordMap.put(ql.Group__r.Name, quoteline);
            }
        }
        if(!cancelledItems.isEmpty()) ammendaRecordMap.put('Cancelled', cancelledItems);   
        if(itemsWithOutAddenda.isEmpty()) 
           ammendaRecordMap.remove('--');
        else   
           ammendaRecordMap.get('--').addAll(itemsWithOutAddenda);   
        innerList = new List<InnerClass>();
        
        for(String s : ammendaRecordMap.KeySet()){             
                 InnerClass ic = new InnerClass();
                 ic.AmmendaSeqNumber = s;
                 ic.quoteLines = ammendaRecordMap.get(s);
                 
                 innerList.add(ic);
        }
        
    }
    public Map<String, List<Option__c>> ammendaRecordMap{get;set;}
    public Map<Id, Option__c> quoteLineAttributeMap{get;set;}
    public List<InnerClass> innerList{get;set;}
    public Scenario__c quote{get;set;}
    public string quoteId{get;set;}
    public class InnerClass{
        public string AmmendaSeqNumber{get;set;}
        public List<Option__c> quoteLines{get;set;}
        public Map<String, List<Option__c>> categoryLines{get;set;}
         
    }  
}