public without sharing class WetSignature{
    @AuraEnabled
    Public Static String WetSignaturevalidations(String QuoteId)
    {
        string message = '';
        String QuoteLineError = '';
        Boolean QuoteLineValidation = False;
        try{
            if(!String.isBlank(QuoteId))
            {
                Scenario__c  quote = new Scenario__c();
                DescribeSObjectResult quoteDescribeResult = Scenario__c.getSObjectType().getDescribe();
                List<String> QuotefieldNames = new List<String>( quoteDescribeResult.fields.getMap().keySet());
                String quoteQuery = ' SELECT id, Name, Status__c, Connection__c, HomeBuyer__c, Lot__c, Model__c, Cancelled__c, Home_Buyer_Signed_Date__c, Purchase_Agreement_Date__c, Division__c, Community__c from Scenario__c where Id = \''+String.escapeSingleQuotes(QuoteId)+'\'';
                                   
                quote = Database.query(quoteQuery);
                List<Scenario__c> approvedScenarios = [select id, Name from Scenario__c where Id !=: QuoteId and Status__c = 'Approved' and Cancelled__c = False and Connection__c =: quote.Connection__c];
                 if(quote.Lot__c <> null){
                    List<Scenario__c> quoteWithHomesiteRecords = [select id, Name from Scenario__c where RecordType.Name = 'Regular' and Status__c != '' and Lot__c =: quote.Lot__c and Status__c != 'Draft' and Cancelled__c = False and Id !=: quote.Id];
                    if(quoteWithHomesiteRecords.size() > 0){
                        message+='<li>Active Scenarios exist for this Lot. Please cancel any active Scenarios before proceeding.</li>';
                    }
                }
                if(!approvedScenarios.isEmpty()){
                    message = '<li>One of the Scenario for the Connection is already Approved. Please use new connection or cancel the approved scenario to continue.</li>';
                }
                else if(quote.Cancelled__c)
                    message = '<li>You can\'t perfrom wetsignature on Scenario that is cancelled.</li>';
                else{
                    if(quote.Lot__c == Null)
                        message +=  '<li>Please select Lot on Scenario.</li>';
                    if(quote.Model__c == null)
                        message += '<li>Please select Model on Scenario.</li>'; 
                    if(Quote.Homebuyer__c == Null)
                        message += '<li>Please fill the Homebuyer on Scenario.</li>';
                    if(Quote.Connection__c == Null) 
                        message += '<li>Please fill the Connection on Scenario.</li>';
                    if(!String.isBlank(message)) message = 'You can\'t upload the Attachment until you fill the field listed below for the associated Scenario:<br/><ul>'+message+'</ul>';    
                }
                if(String.isBlank(message))
                    return 'Success';
                else
                {  
                    return message;
                }        
            }    
            else
            {
                message = 'Sorry, Something went wrong. Please come back from Scenario Wet Signature';
                return message;
            }
        }
        catch(Exception e){
             return e.getMessage();
        }
    }
    //Updating the quote after uploading the file
    @AuraEnabled
    Public Static String updateQuote(String QuoteId, String SelectedType)
    {
        try{
            Scenario__c  quote = new Scenario__c();
            if(!String.isBlank(QuoteId))
            {
                if(quote.Home_Buyer_Signed_Date__c == null && Schema.sObjectType.Scenario__c.fields.Home_Buyer_Signed_Date__c.isAccessible()) quote.Home_Buyer_Signed_Date__c = System.Now();
                if(quote.Purchase_Agreement_Date__c == null && Schema.sObjectType.Scenario__c.fields.Purchase_Agreement_Date__c.isAccessible()) quote.Purchase_Agreement_Date__c = System.Today();
                if(Schema.sObjectType.Scenario__c.fields.status__c.isAccessible())
                quote.status__c = 'Approved';
                quote.Id = QuoteId;
                if(Schema.sObjectType.Scenario__c.isUpdateable()) update quote;
                 return 'Success';
            }
            else
                return 'Sorry, something went wrong';   
         }
         catch(Exception e){
             return e.getMessage();
         }
    } 
    //To get signature type picklist values
    @AuraEnabled
    public static List<picklistWrap> SignatureType()
    {
       List<picklistWrap> Type = new List<picklistWrap>();
       Type.add(new picklistWrap('--None--', ''));

       Signature__c sign = Signature__c.getInstance();
       if(sign.Signature_Value1__c <> '' && sign.Signature_Value1__c <> null && sign.Signature_Label1__c <> '' && sign.Signature_Label1__c <> null)
           Type.add(new picklistWrap(sign.Signature_Label1__c, sign.Signature_Value1__c));
       if(sign.Signature_Value2__c <> '' && sign.Signature_Value2__c <> null && sign.Signature_Label2__c <> '' && sign.Signature_Label2__c <> null)
           Type.add(new picklistWrap(sign.Signature_Label2__c,sign.Signature_Value2__c));
       return Type;
    }
    public class picklistWrap {
        @AuraEnabled public string labelval;
        @AuraEnabled public string selectedVal;
        public picklistWrap(string labelval, string selectedVal)
        {
            this.labelval = labelval;
            this.selectedVal = selectedVal;
        }
    }   
}