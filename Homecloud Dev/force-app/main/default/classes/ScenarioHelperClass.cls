public without sharing Class ScenarioHelperClass
{
    public Static void beforeTrigger(List<Scenario__c> Scenarioids, Map<Id, Scenario__c> oldScenario){
        List<Connection__c> opptyRecords = new List<Connection__c>();
        set<Id> oppIDs = new set<Id>();
        set<Id> lotIDs = new set<Id>();
        for(Scenario__c qt: Scenarioids){ 
            oppIDs.add(qt.Connection__c);
            if(Schema.sObjectType.Scenario__c.fields.Status__c.isUpdateable() && qt.Lot__c <> null && qt.Status__c == 'Approved' && qt.Status__c != oldScenario.get(qt.Id).Status__c){
                lotIDs.add(qt.Lot__c);
            }
        }
        Map<Id, Catalog__c> lotProducts = new Map<Id, Catalog__c>([Select Id, Status__c, (select id from LotQuotes__r where (RecordType.DeveloperName = 'Regular' and Status__c = 'Approved' and Cancelled__c = false)) from Catalog__c where Id IN: lotIDs]);
        Map<Id, Connection__c> connectionMap = new Map<Id, Connection__c>([select id, Name, Status__c, (select id from Connection__r where RecordType.DeveloperName = 'Regular' and status__c = 'Approved' and Cancelled__c = False) from Connection__c where Id In: oppIDs]);
        System.debug('**** CONNECTION MAP ******'+connectionMap);
        for(Scenario__c qt: Scenarioids){ 
            if(connectionMap.containsKey(qt.Connection__c)){
                Connection__c c = connectionMap.get(qt.Connection__c);
                Scenario__c oldSc = new Scenario__c();
                if(!oldScenario.isEmpty()){
                    oldSc = oldScenario.get(qt.Id);
                }
                if(qt.Status__c <> oldSc.Status__c){
                    if(qt.Lot__c <> null && lotProducts.containsKey(qt.Lot__c) && lotProducts.get(qt.Lot__c).LotQuotes__r.size() > 1)
                        qt.addError('Lot has already been processed on another Scenario. Please use new scenario or cancel the approved scenario to continue.');
                    if(c.Connection__r.size() > 1)
                        qt.addError('One of the Scenario for the Connection is already Approved. Please use new connection or cancel the approved scenario to continue.');
                    if(qt.Connection__c <> null && Schema.sObjectType.Connection__c.fields.Status__c.isUpdateable() && Schema.sObjectType.Connection__c.fields.Status__c.isUpdateable() && Schema.sObjectType.Connection__c.fields.Quote_Created__c.isUpdateable()){
                        if((c.Status__c == 'Lead' || c.Status__c == 'Prospect' || c.Status__c == 'Pre-Sale') && qt.Status__c == 'Approved'){
                            opptyRecords.add(new connection__c(Id = qt.connection__c, Quote_Created__c = True));
                        }
                        else if((c.Status__c == 'Lead' || c.Status__c == 'Prospect') && qt.Status__c == 'Draft')
                        {
                            opptyRecords.add(new Connection__c(Id = qt.Connection__c, Quote_Created__c = True));
                        }
                    }
                }
            }    
        }
        if(!opptyRecords.isEmpty())
            Update opptyRecords;
    }
    
    public Static void afterUpdate(Map<Id, Scenario__c> newQuotes, Map<Id, Scenario__c> OldQuotes)
    {
        Id SpecRecordType = RecordTypeUtil.scenariospecrecordtypename();
        List<Catalog__c> lotProducts = new List<Catalog__c>();
        set<Id> lotIds = new set<Id>();
        for(Scenario__c Qt : newQuotes.values()){            
            Scenario__c oldScenario = new Scenario__c();
            if(OldQuotes.ContainsKey(Qt.Id)){
                oldScenario = OldQuotes.get(Qt.Id);
            }            
            if(!Qt.Cancelled__c && Qt.Status__c == 'Approved' && Qt.status__c <> oldScenario.Status__c){
                if(Qt.RecordTypeId <> SpecRecordType && Schema.sObjectType.Catalog__c.fields.Status__c.isUpdateable()){
                    lotProducts.add(new Catalog__c(Id = qt.Lot__c, Status__c = 'Reserved')); 
                    lotIds.add(qt.Lot__c); 
                     } 
                else if(Schema.sObjectType.Catalog__c.fields.Status__c.isUpdateable()){
                    lotProducts.add(new Catalog__c(Id = qt.Lot__c, Status__c = 'Spec'));
                    lotIds.add(qt.Lot__c);
                }   
            } 
        }
        if(!lotProducts.isEmpty() && Schema.sObjectType.Catalog__c.isUpdateable()) {
            update lotProducts;
        }
        List<Scenario__c> approvedQuotes = [Select Id, Lot__c from Scenario__c where Lot__c IN: lotIds and RecordType.DeveloperName = 'Spec_Quote'];
        for(Scenario__c Qt: ApprovedQuotes){
            if(Schema.sObjectType.Scenario__c.fields.Status__c.isUpdateable())
                Qt.Status__c = 'Converted';
        }
        if(!ApprovedQuotes.IsEmpty() && Schema.sObjectType.Scenario__c.isUpdateable()){
            Update ApprovedQuotes;
        }     
    }
    public Static void CancelOldScenarios(Map<Id, Scenario__c> newQuotes,Map<Id, Scenario__c> oldQuotes)
    {
        Set<Id> conIds=new set<Id>();   
        Id SpecRecordType = RecordTypeUtil.scenariospecrecordtypename();
        for(Scenario__c Qt : newQuotes.values()){
            if(Qt.Status__c=='Approved' && Qt.Status__c <> oldQuotes.get(Qt.Id).Status__c)
            conIds.add(Qt.Connection__c);  
        }
        List<Connection__c> updateCon=new List<Connection__c>();
        List<Scenario__c> updateScenario=new List<Scenario__c>();
        List<Connection__c> con=[Select Id,Name,Primary_Scenario__c,(Select Id,Name,Status__c,Cancelled__c,RecordTypeId from Connection__r where RecordTypeId!=:SpecRecordType) from Connection__c where Id IN:conIds];
        for(Connection__c c:con){
            for(Scenario__c sc:c.Connection__r){
             if(sc.Status__c!='Approved'){
                if(Schema.sObjectType.Scenario__c.fields.Status__c.isUpdateable())
                    sc.Status__c='Cancelled';
                if(Schema.sObjectType.Scenario__c.fields.Cancelled__c.isUpdateable())
                    sc.Cancelled__c=true;
                updateScenario.add(sc); 
            }   
                else if(sc.Status__c=='Approved'){
                    c.Primary_Scenario__c=sc.Id;
                    updateCon.add(c);
                }
            }
        }
        update updateScenario;
        update updateCon;
    }
    public static void scenarioDelete(Map<Id, Scenario__c> scenarioRecords){
        set<Id> lotIds = new set<Id>();
        for(Scenario__c sc : scenarioRecords.values()){
            if(sc.Lot__c <> null ){
                lotIds.add(sc.Lot__c);
            }
        }
        //Map<Id, Catalog__c> lotProducts = new Map<Id, Catalog__c>([Select Id, Status__c, (select id, Status__c, RecordType.DeveloperName from LotQuotes__r where (Status__c = 'Approved' and Cancelled__c = false) OR Status__c = 'New') from Catalog__c where Id IN: lotIDs]);
        List<Catalog__c> catalogRecords = new List<Catalog__c>();
        for(Id lotId : lotIds){
            /*for(Scenario__c sc : LotQuotes__r){
if(sc.RecordType.DeveloperName == 'Regular'){

}
}*/
            if(Schema.sObjectType.Catalog__c.fields.Status__c.isUpdateable())
                catalogRecords.add(new Catalog__c(Id = lotId, Status__c = 'Open'));
        }
        if(Schema.sObjectType.Catalog__c.isUpdateable())
            update catalogRecords;
    }    
}