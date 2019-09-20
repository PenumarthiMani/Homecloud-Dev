public without sharing class ConnectionTriggerHandler{   
    
    //purpose : to update Connection stage name
    /*    public static void beforeTrigger(List<Connection__c> newOppRecords,  Map<Id, Connection__c> oldOppRecords){        
for(Connection__c opp : newOppRecords){ 
Connection__c oldOpp = oldOppRecords.get(opp.id);
if(opp.Status__c == 'Sale' && opp.Status__c <> oldOpp.Status__c){
if(Schema.sObjectType.Connection__c.fields.Sale_Date__c.isUpdateable())
opp.Sale_Date__c = System.Today();
}
if(opp.lost_opportunity__c == 'Yes' && oldOpp.lost_opportunity__c != opp.lost_opportunity__c){
if(Schema.sObjectType.Connection__c.fields.Status__c.isUpdateable())
opp.Status__c = 'Lost';
}
else if(opp.Status__c == 'Lead' && opp.RegCard_created__c){
if(Schema.sObjectType.Connection__c.fields.Status__c.isUpdateable())
opp.Status__c = 'Prospect';
}
}  
} */
    
    public static void beforeInsertUpdateTrigger(List<Connection__c> newOppRecords,  Map<Id, Connection__c> oldOppRecords, Boolean isInsert){
        set<Id> communityId = new set<Id>();
        set<Id> agentIds = new set<Id>();
        for(Connection__c opp : newOppRecords){
            if(!isInsert && opp.Community__c <> oldOppRecords.get(opp.Id).Community__c)
                communityId.add(opp.Community__c);
            if(opp.Agent__c <> null) agentIds.add(opp.Agent__c);
        }
        Map<Id, Community__c> communityRecordMap = new Map<Id, Community__c>([select id, Name from Community__c where Id In: communityId]);     
        Map<Id, Contact> agencyMap = new Map<Id, Contact>([select id, Name, Agency__c from Contact where Id IN: agentIds and Agency__c <> null]);
        for(Connection__c opp : newOppRecords){
            if(!isInsert && opp.Community__c <> oldOppRecords.get(opp.Id).Community__c){
                string name = opp.Name.substringAfter('-');
                opp.Name = communityRecordMap.get(opp.Community__c).Name+'-'+name;
            }
            if(opp.Agent__c <> null && (opp.Agency__c == null || (!isInsert && opp.Agency__c <> oldOppRecords.get(opp.Id).Agency__c)) && agencyMap.containsKey(opp.Agent__c)){
                opp.Agency__c = agencyMap.get(opp.Agent__c).Agency__c;
            }
            if(String.isNotBlank(opp.Prospect_Rating__c) && (isInsert || (!isInsert && opp.Prospect_Rating__c != oldOppRecords.get(opp.Id).Prospect_Rating__c))){
                if(Schema.sObjectType.Connection__c.fields.Prospect_Rating_Modified_Date__c.isUpdateable())
                    opp.Prospect_Rating_Modified_Date__c = System.Today();
            }
        }    
    }
    
    public static void OpportunityLeadRanking(List<connection__c> newOpportunityRecords, Map<Id, Connection__c> oldOpportunityRecords, Boolean isInsert){
        Set<Id> oppIds = new Set<Id>();
        List<Task> tasksToInsert = new List<Task>();
        List<Task> tasksToDelete = new List<Task>();
        for(connection__c opp : newOpportunityRecords){
            if((isInsert && String.isNotBlank(opp.Prospect_Rating__c)) || (!isInsert && opp.Prospect_Rating__c != oldOpportunityRecords.get(opp.Id).Prospect_Rating__c )){
                oppIds.add(opp.Id);
            }
        }
        if(!oppIds.isEmpty()){
            Map<Id,Task> oppRecordActivity =  new Map<Id,Task>([Select Id, WhatId ,Subject, ActivityDate, Opportunity_Ranking_Type__c,IsClosed  from Task where ActivityDate >= Today and Opportunity_Ranking_Type__c != null and WhatId In: oppIds and Isclosed = false]);
            Map<Id,Task> oppRankingRecordActivity =  new Map<Id,Task>([Select Id, WhatId ,Subject, ActivityDate, Opportunity_Ranking_Type__c,IsClosed  from Task where Opportunity_Ranking_Type__c != null and WhatId In: oppIds and Isclosed = false]);
            Map<string, Connection_Prospect_Ranking_Condition__mdt> prospectRankingCondtionRecords =new Map<string, Connection_Prospect_Ranking_Condition__mdt>([select id,MasterLabel,Active__c,Number_Of_Days_c__c,Number_Of_Hours__c,Rank__c,Subject__c from Connection_Prospect_Ranking_Condition__mdt where Active__c = true]);
            for(Connection__c op : newOpportunityRecords){            
                if((isInsert && String.isNotBlank(op.Prospect_Rating__c)) || (!isInsert && op.Prospect_Rating__c != oldOpportunityRecords.get(op.Id).Prospect_Rating__c ) && (Schema.sObjectType.Connection__c.fields.Prospect_Rating__c.isUpdateable() && Schema.sObjectType.Task.fields.Opportunity_Ranking_Type__c.isUpdateable())){
                    
                    // On insert
                    if(isInsert){                                                              
                        if(String.isNotBlank(op.Prospect_Rating__c)){
                            tasksToInsert.addAll(createTasks(op.Prospect_Rating__c, op.OwnerId, op.Id, 0, prospectRankingCondtionRecords));
                        }            
                    }   
                    // On update         
                    else{ 
                        
                        Connection__c oldOppty = oldOpportunityRecords.get(op.Id);                   
                        
                        if(String.isNotBlank(op.Prospect_Rating__c) && op.Prospect_Rating__c <> oldOppty.Prospect_Rating__c){
                            
                            List<Task> deleteTasks = new List<Task>();
                            
                            for(Task taskRecords : oppRecordActivity.values()){
                                if(op.Id == taskRecords.WhatId){ //Card 4819 - Code ends
                                    if(taskRecords.Opportunity_Ranking_Type__c == 'Prospect') 
                                        deleteTasks.add(new Task(Id = taskRecords.Id));
                                }
                            }
                            tasksToDelete.addAll(deleteTasks);
                            
                            Integer noOfdays = 0;
                            if(oldOppty.Prospect_Rating_Modified_Date__c <> null)
                                noOfdays = oldOppty.Prospect_Rating_Modified_Date__c.daysBetween(system.Today());                  
                            tasksToInsert.addAll(createTasks(op.Prospect_Rating__c, op.OwnerId, op.Id, noOfdays, prospectRankingCondtionRecords));
                        }  
                        
                        //If Prospect Rating is null, delete all open pending tasks related to Prospect 
                        if(String.isBlank(op.Prospect_Rating__c)) {
                            
                            List<Task> deleteTasks = new List<Task>();
                            for(Task taskRecords : oppRankingRecordActivity.values()){
                                if(op.Id == taskRecords.WhatId ){                
                                    if(taskRecords.Opportunity_Ranking_Type__c == 'Prospect'){                                                     
                                        deleteTasks.add(new Task(Id = taskRecords.Id));                            
                                    }
                                }
                            }
                            tasksToDelete.addAll(deleteTasks);            
                        } 
                        
                    }
                }       
            }
        }        
        if(Schema.sObjectType.Task.isCreateable() && Schema.sObjectType.Task.isDeletable())
            delete tasksToDelete;
        insert tasksToInsert;
    }
    
    //purpose : to create Task  
    public static List<Task> createTasks(String prospectRating, string OwnerId, string opptyId, Integer noOfDays, Map<string, Connection_Prospect_Ranking_Condition__mdt> prospectRankingCondtionRecords){
        List<Task> taskRecords = new List<Task>();
        if(prospectRating <> null || prospectRating <> '' && (Schema.sObjectType.Connection_Prospect_Ranking_Condition__mdt.fields.Number_Of_Days_c__c.isUpdateable() && Schema.sObjectType.Connection_Prospect_Ranking_Condition__mdt.fields.Rank__c.isUpdateable() && Schema.sObjectType.Connection_Prospect_Ranking_Condition__mdt.fields.Subject__c.isUpdateable())){
            for(Connection_Prospect_Ranking_Condition__mdt rank : prospectRankingCondtionRecords.values()){
                Integer duedays = 0;
                if(rank.Number_Of_Days_c__c <> null) duedays = Integer.valueOf(rank.Number_Of_Days_c__c);
                if(prospectRating == rank.Rank__c && duedays >= noOfDays){
                    taskRecords.add(new Task(Subject = rank.Subject__c, ActivityDate = System.Today().addDays(duedays), Opportunity_Ranking_Type__c = 'Prospect', OwnerId = OwnerId, WhatId = opptyId));    
                }
            }
        }    
        return taskRecords;
    }
    public static boolean isRecursive = true;
    //Purpose: To control the access on opportunity from community reps   
    Public static void OpportunitySharingForReps(List<Connection__c> OpportunityList,Map<Id, Connection__c> OldMapOpportunities)
    {       
    } 
    public static void updateHomebuyer(List<Connection__c> ConList){
        Set<Id> HomebuyerIds=new Set<Id>();
        Id HomebuyerRecordType = RecordTypeUtil.contactrecordtypename();
        for(Connection__c con:ConList){
            HomebuyerIds.add(con.Homebuyer__c);  
        }
        List<Contact> homebuyers=[Select Id,Type__c,RecordtypeId from Contact where Id IN:HomebuyerIds AND RecordTypeId=:HomebuyerRecordType];
        for(Contact hb:homebuyers){
            if(hb.Type__c!='Buyer'){
                hb.Type__c='Buyer';
            }
        }
        if(Schema.sObjectType.Connection__c.isUpdateable())
            update homebuyers;
    }
    
    public static void deleteConnection(Map<Id,Connection__c> oldConnections){
        List<Connection__c> delConnections=[Select Id,Name,(Select Id,Name from Connection__r) from Connection__c where Id IN:oldConnections.keySet()];
        for(Connection__c dc:delConnections){
            if(!dc.Connection__r.isEmpty()){
                oldConnections.get(dc.Id).addError('You cannot delete Connection with Scenarios.');   
            }            
        }
    }
    Public static void CobuyerCreation(List<Connection__c> ConnectionList,Map<Id, Connection__c> OldMapConnections)
    { 	
        Set<Id> CobuyerIds=new Set<Id>();
        List<Co_Buyer__c> newCoBuyers=new List<Co_Buyer__c>(); 
        for(Connection__c con:ConnectionList){
            Co_Buyer__c cb=new Co_Buyer__c();
            if(con.Co_Buyer_1__c<> NULL && con.Co_Buyer_1__c<>OldMapConnections.get(con.Id).Co_Buyer_1__c){
                cb.Co_Buyer__c=con.Co_Buyer_1__c;
                cb.Connection__c=con.Id;                
                newCoBuyers.add(cb);
                if(OldMapConnections.get(con.Id).Co_Buyer_1__c<>NULL){
                    CobuyerIds.add(OldMapConnections.get(con.Id).Co_Buyer_1__c);
                }
            }else if(OldMapConnections.get(con.Id).Co_Buyer_1__c<>NULL && con.Co_Buyer_1__c== NULL)
                CobuyerIds.add(OldMapConnections.get(con.Id).Co_Buyer_1__c);
            
            if(con.Co_Buyer_2__c<> NULL && con.Co_Buyer_2__c<>OldMapConnections.get(con.Id).Co_Buyer_2__c){
                cb.Co_Buyer__c=con.Co_Buyer_2__c;
                cb.Connection__c=con.Id;                
                newCoBuyers.add(cb);
                if(OldMapConnections.get(con.Id).Co_Buyer_2__c<>NULL){
                    CobuyerIds.add(OldMapConnections.get(con.Id).Co_Buyer_2__c);
                }
            }else if(OldMapConnections.get(con.Id).Co_Buyer_2__c<>NULL && con.Co_Buyer_2__c== NULL)
                CobuyerIds.add(OldMapConnections.get(con.Id).Co_Buyer_2__c);
            
            if(con.Co_Buyer_3__c<> NULL && con.Co_Buyer_3__c<>OldMapConnections.get(con.Id).Co_Buyer_3__c){
                cb.Co_Buyer__c=con.Co_Buyer_3__c;
                cb.Connection__c=con.Id;                
                newCoBuyers.add(cb);
                if(OldMapConnections.get(con.Id).Co_Buyer_3__c<>NULL){
                    CobuyerIds.add(OldMapConnections.get(con.Id).Co_Buyer_3__c);
                }
            }else if(OldMapConnections.get(con.Id).Co_Buyer_3__c<>NULL && con.Co_Buyer_3__c== NULL)
                CobuyerIds.add(OldMapConnections.get(con.Id).Co_Buyer_3__c);
            if(con.Co_Buyer_4__c<> NULL && con.Co_Buyer_4__c<>OldMapConnections.get(con.Id).Co_Buyer_4__c){
                cb.Co_Buyer__c=con.Co_Buyer_4__c;
                cb.Connection__c=con.Id;                
                newCoBuyers.add(cb);
                if(OldMapConnections.get(con.Id).Co_Buyer_4__c<>NULL){
                    CobuyerIds.add(OldMapConnections.get(con.Id).Co_Buyer_4__c);
                }
            }else if(OldMapConnections.get(con.Id).Co_Buyer_4__c<>NULL && con.Co_Buyer_4__c== NULL)
                CobuyerIds.add(OldMapConnections.get(con.Id).Co_Buyer_4__c);
            if(con.Co_Buyer_5__c<> NULL && con.Co_Buyer_5__c<>OldMapConnections.get(con.Id).Co_Buyer_5__c){
                cb.Co_Buyer__c=con.Co_Buyer_5__c;
                cb.Connection__c=con.Id;                
                newCoBuyers.add(cb);
                if(OldMapConnections.get(con.Id).Co_Buyer_5__c<>NULL){
                    CobuyerIds.add(OldMapConnections.get(con.Id).Co_Buyer_5__c);
                }
            }else if(OldMapConnections.get(con.Id).Co_Buyer_5__c<>NULL && con.Co_Buyer_5__c== NULL)
                CobuyerIds.add(OldMapConnections.get(con.Id).Co_Buyer_5__c);
        }  
        List<Co_Buyer__c> deleteCb=new List<Co_Buyer__c>();
        List<Co_Buyer__c> cblist=[Select Id,Co_Buyer__c,Connection__c from Co_Buyer__c where Co_Buyer__c In:CobuyerIds];
        for(Connection__c con:ConnectionList){
            for(Co_Buyer__c cob:cblist){
                if(OldMapConnections.get(con.Id).Co_Buyer_1__c<>NULL && con.Co_Buyer_1__c<> OldMapConnections.get(con.Id).Co_Buyer_1__c && (cob.Connection__c==con.Id && cob.Co_Buyer__c==OldMapConnections.get(con.Id).Co_Buyer_1__c)){
                    deleteCb.add(cob);   
                }
                else if(OldMapConnections.get(con.Id).Co_Buyer_2__c<>NULL && con.Co_Buyer_2__c<> OldMapConnections.get(con.Id).Co_Buyer_2__c && (cob.Connection__c==con.Id && cob.Co_Buyer__c==OldMapConnections.get(con.Id).Co_Buyer_2__c)){
                    deleteCb.add(cob);   
                }
                else if(OldMapConnections.get(con.Id).Co_Buyer_3__c<>NULL && con.Co_Buyer_3__c<> OldMapConnections.get(con.Id).Co_Buyer_3__c && (cob.Connection__c==con.Id && cob.Co_Buyer__c==OldMapConnections.get(con.Id).Co_Buyer_3__c)){
                    deleteCb.add(cob);   
                }
                else if(OldMapConnections.get(con.Id).Co_Buyer_4__c<>NULL && con.Co_Buyer_4__c<> OldMapConnections.get(con.Id).Co_Buyer_4__c && (cob.Connection__c==con.Id && cob.Co_Buyer__c==OldMapConnections.get(con.Id).Co_Buyer_4__c)){
                    deleteCb.add(cob);   
                }
                else if(OldMapConnections.get(con.Id).Co_Buyer_5__c<>NULL && con.Co_Buyer_5__c<> OldMapConnections.get(con.Id).Co_Buyer_5__c && (cob.Connection__c==con.Id && cob.Co_Buyer__c==OldMapConnections.get(con.Id).Co_Buyer_5__c)){
                    deleteCb.add(cob);   
                }
            }
        }  
        if(!deleteCb.isEmpty())
            delete deleteCb;
        insert newCoBuyers;        
    }   
    public static void lotStatusUpdate(List<Connection__c> ConnectionList,Map<Id, Connection__c> OldMapConnections){
        Set<Id> ScenarioIds=new Set<Id>();
        Set<Id> LotIds=new Set<Id>();
        for(Connection__c con:ConnectionList){
            if(con.Status__c=='Closed Won' && con.Status__c<>OldMapConnections.get(con.Id).Status__c && con.Primary_Scenario__c<>NULL){
                ScenarioIds.add(con.Primary_Scenario__c);   
            }    
        }
        List<Scenario__c> ApprovedScenarios=[Select Id,Name,Status__c,Lot__c from Scenario__c where Status__c='Approved' AND Id In:ScenarioIds];
        for(Scenario__c sc:ApprovedScenarios){
            LotIds.add(sc.Lot__c);  
        }
        List<Catalog__c> lots=[Select Id,Name,Status__c from Catalog__c where Id IN:LotIds];
        for(Catalog__c cat:lots){
            cat.Status__c='Closed';
        }
        update lots;
    }
}