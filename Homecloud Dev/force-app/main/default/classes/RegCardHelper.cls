public without sharing class RegCardHelper{
    @AuraEnabled
    public static list<string> dogetfieldsetfields(){
        list<string> regcardfields= new list<string>();
        for(Schema.FieldSetMember c:SObjectType.Connection__c.FieldSets.Regcard_Fieldset.getFields()){
            regcardfields.add(c.getFieldPath());
        }
        system.debug('regcardfields:'+regcardfields);
        return regcardfields;        
    } 
/*     @AuraEnabled
    public static wrapperfieldset dogetfieldsetfields(){
        wrapperfieldset wrapperdata=new wrapperfieldset();
        list<string> regcardfields= new list<string>();
        list<string> datefields= new list<string>();
        for(Schema.FieldSetMember c:SObjectType.Connection__c.FieldSets.Regcard_Fieldset.getFields()){
            regcardfields.add(c.getFieldPath());
            if(String.valueOf(c.getType())=='Date'){
                datefields.add(c.getFieldPath());
            }
        }
        system.debug('regcardfields:'+regcardfields);
        system.debug('datefields:'+datefields);
        wrapperdata.regCardFieldsetWrapper=regcardfields;
        wrapperdata.regCardDateFieldsWrapper=datefields;
        return wrapperdata;        
    }
    public class wrapperfieldset{
        @AuraEnabled public list<string> regCardFieldsetWrapper {get;set;}
        @AuraEnabled public list<string> regCardDateFieldsWrapper {get;set;}
        
    }  */
    @AuraEnabled
    public static string doRegCard(string opp){
        String RecordTypeId = RecordTypeUtil.TrafficRegisteredRecordTypeName();
        DescribeSObjectResult connectionDescribeResult = Connection__c.getSObjectType().getDescribe();
        List<String> connectionFieldNames = new List<String>( connectionDescribeResult.fields.getMap().keySet() );
        DescribeSObjectResult TrafficDescribeResult = Traffic__c.getSObjectType().getDescribe();
        List<String> trafficFieldNames = new List<String>( TrafficDescribeResult.fields.getMap().keySet() );
        String connectionQuery = 'SELECT '+String.join( connectionFieldNames, ',' )+',(SELECT '+String.join( trafficFieldNames, ',' )+ ' FROM traffic__r WHERE RecordTypeId =\''+String.escapeSingleQuotes(RecordTypeId)+'\')' +' FROM '+ connectionDescribeResult.getName()+' WHERE id =\''+String.escapeSingleQuotes(opp)+'\'';
        //Connection__c op=[select id,I_plan_to_purchase_a_home__c,How_did_you_hear_about_us__c,When_do_you_plan_to_move__c,Current_Residence__c,Price_Range_Min__c,Price_Range_Max__c,How_many_bedrooms_you_want_in_New_Home__c,Community__c,Date__c,(Select id,Connection__c,Community__c,RecordTypeId,I_plan_to_purchase_a_home__c,How_did_you_hear_about_us__c,When_do_you_plan_to_move__c,Current_Residence__c,Price_Range_Min__c,Price_Range_Max__c,How_many_bedrooms_you_want_in_New_Home__c from Traffic__r Where RecordTypeId =:RecordTypeId AND  Connection__c=: opp) from Connection__c where id=:opp];
        Connection__c op = Database.query(connectionQuery);
        Traffic__c trafficrec= new Traffic__c();
        trafficrec.Connection__c=op.id; system.debug('trafficrec:'+trafficrec);
        if(Schema.sObjectType.Traffic__c.fields.RecordTypeId.isUpdateable())
            trafficrec.RecordTypeId=RecordTypeId;
        //List<Traffic__c> rlist=[Select id,Connection__c,Community__c,RecordTypeId,Date__c from Traffic__c Where RecordTypeId =:RecordTypeId AND  Connection__c=: opp];
        //String trafficfields2 = ' SELECT ' + String.join( trafficFieldNames, ',' ) + ' FROM ' + TrafficDescribeResult.getName() +' WHERE Connection__c =\''+ opp+'\' And RecordTypeId = \''+RecordTypeId+'\'';
        //Traffic__c rlist = Database.query(trafficfields2);
        if(op.Traffic__r.size()>0)
        {
            trafficrec.id=op.Traffic__r[0].id;
        }
        if(Schema.sObjectType.Traffic__c.fields.I_plan_to_purchase_a_home__c.isUpdateable())
            trafficrec.I_plan_to_purchase_a_home__c=op.I_plan_to_purchase_a_home__c;
        if(Schema.sObjectType.Traffic__c.fields.How_did_you_hear_about_us__c.isUpdateable())
            trafficrec.How_did_you_hear_about_us__c=op.How_did_you_hear_about_us__c;
        if(Schema.sObjectType.Traffic__c.fields.When_do_you_plan_to_move__c.isUpdateable())
            trafficrec.When_do_you_plan_to_move__c=op.When_do_you_plan_to_move__c;
        if(Schema.sObjectType.Traffic__c.fields.Current_Residence__c.isUpdateable())
            trafficrec.Current_Residence__c=op.Current_Residence__c;
   /*     if(Schema.sObjectType.Traffic__c.fields.Price_Range_Min__c.isUpdateable())
            trafficrec.Price_Range_Min__c=op.Price_Range_Min__c;
        if(Schema.sObjectType.Traffic__c.fields.Price_Range_Max__c.isUpdateable())
            trafficrec.Price_Range_Max__c=op.Price_Range_Max__c;  */
        if(Schema.sObjectType.Traffic__c.fields.How_many_bedrooms_you_want_in_New_Home__c.isUpdateable())
            trafficrec.How_many_bedrooms_you_want_in_New_Home__c=op.How_many_bedrooms_you_want_in_New_Home__c;
        if(Schema.sObjectType.Traffic__c.fields.Community__c.isUpdateable())
            trafficrec.Community__c = op.Community__c;
        if(Schema.sObjectType.Traffic__c.fields.Date__c.isUpdateable())
            trafficrec.Date__c=op.Date__c;
        if(Schema.sObjectType.Traffic__c.fields.Price_Range__c.isUpdateable())
            trafficrec.Price_Range__c=op.Price_Range__c;
        try
        {
            if(Schema.sObjectType.Traffic__c.isUpdateable() || Schema.sObjectType.Traffic__c.isCreateable())
                upsert trafficrec;
            return 'Reg card has been successfully created';
        }
        catch(Exception e){
            return e.getMessage();
        }
    }
    
    public static void connectionfieldupdate(List<Traffic__c> regvalues){
        List<Connection__c> opptyRecords = new List<Connection__c>();
        List<Traffic__c> recardvalues = new List<Traffic__c>([select id,Connection__c,RecordType.Name,Connection__r.Status__c from Traffic__c where id in: regvalues]);
        for(Traffic__c t : recardvalues){
            if((t.Connection__c <> null && t.connection__r.Status__c == 'Lead') && (Schema.sObjectType.Connection__c.fields.Status__c.isUpdateable() && Schema.sObjectType.Connection__c.fields.RegCard_Created__c.isUpdateable())){
                opptyRecords.add(new Connection__c(Id = t.Connection__c,RegCard_Created__c = true));
            }
        }if(!opptyRecords.isEmpty())
            update opptyRecords;
    }
    public static void pricecheckvalidation(list<Traffic__c> pricecheck){
        for(Traffic__c c:pricecheck){
      /*      if( c.Price_Range_Min__c > c.Price_Range_Max__c){                
                c.adderror('Min Price Should not be more than Max Price');
            }  */
        }
    } 
}