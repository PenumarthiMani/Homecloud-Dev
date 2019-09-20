public without sharing class InputLookupReusableClass
{
    @AuraEnabled
    public static List<wrapperClass> getSearchResults(String sObjectName,string sObjectFields,string objectFilter1,string objectFilter2,string objectFilter3, string filter1, string filter1value, string filter2, string filter2value, string filter3, string filter3value, string searchValue)
    {
        String sQuery;
        sQuery = 'select '+sObjectFields+' from '+sObjectName+' where createddate != null';
        boolean b = false;
        
        if(!string.IsBlank(filter1) && !string.IsBlank(filter1value))
        {
            if((sObjectName == 'Division__c' || sObjectName == 'Community__c') && filter1 == 'Active__c') 
                sQuery += ' and '+String.escapeSingleQuotes(filter1)+' = '+String.escapeSingleQuotes(filter1value);
            if(sObjectName == 'Community__c' && !string.IsBlank(filter2) && !string.IsBlank(filter2value))
                sQuery += ' and '+String.escapeSingleQuotes(filter2)+' = \''+String.escapeSingleQuotes(filter2value)+'\'';
        	if(sObjectName == 'Catalog__c'){
                sQuery += ' and '+String.escapeSingleQuotes(filter1)+' = \''+String.escapeSingleQuotes(filter1value)+'\'';
                if(!string.IsBlank(filter2) && !string.IsBlank(filter2value))
                    sQuery += ' and '+String.escapeSingleQuotes(filter2)+' = \''+String.escapeSingleQuotes(filter2value)+'\'';
                if(!string.IsBlank(filter3) && !string.IsBlank(filter3value)) 
                    sQuery += ' and '+String.escapeSingleQuotes(filter3)+' <> \''+String.escapeSingleQuotes(filter3value)+'\'';   
            }
        }
        
        if(!string.IsBlank(searchValue) && !string.IsBlank(objectFilter1))
        {
            sQuery += ' and ('+objectFilter1+' LIKE \'%'+ String.escapeSingleQuotes(searchValue.trim())+ '%\'';
            b = true;
        }
        if(!string.IsBlank(searchValue) && !string.IsBlank(objectFilter2))
        {
            if(b)
                sQuery += ' or '+objectFilter2+' LIKE \'%'+ String.escapeSingleQuotes(searchValue.trim())+ '%\'';
            else
            {
                sQuery += ' and ('+objectFilter2+' LIKE \'%'+ String.escapeSingleQuotes(searchValue.trim())+ '%\'';
                b = true;
            }    
        }
        if(!string.IsBlank(searchValue) && !string.IsBlank(objectFilter3))
        {
            if(b)
                sQuery += ' or '+objectFilter3+' LIKE \'%'+ String.escapeSingleQuotes(searchValue.trim())+ '%\'';
            else
                sQuery += ' and ('+objectFilter3+' LIKE \'%'+ String.escapeSingleQuotes(searchValue.trim())+ '%\'';
        }
        if(!string.IsBlank(searchValue) && (!string.IsBlank(objectFilter3) || !string.IsBlank(objectFilter2) || !string.IsBlank(objectFilter1)))
            sQuery += ')  limit 50';
        else if(string.IsBlank(objectFilter3) && string.IsBlank(objectFilter2) && string.IsBlank(objectFilter1)) 
            sQuery += ' limit 5';   
        else
            sQuery += ' limit 5';
        List<sObject> sObjectList = Database.query(sQuery);
        
        List<wrapperClass> wrapList = new List<wrapperClass>();
        for(sObject s : sObjectList)
        {
            wrapperClass w = new wrapperClass();
            if(!string.IsBlank(objectFilter1))
                w.displayField1 = string.valueOf(s.get(objectFilter1));
            if(!string.IsBlank(objectFilter2))
                w.displayField2 = string.valueOf(s.get(objectFilter2));
            if(!string.IsBlank(objectFilter3))
                w.displayField3 = string.valueOf(s.get(objectFilter3)); 
            
            w.recordId = string.valueOf(s.get('id'));
            wrapList.add(w);
        }
        return wrapList;
    }
    @AuraEnabled        
    public static sObject getAccLeads(String accid,String leadid){      
        sObject sob;        
        if(!String.isBlank(accid)){       
            Contact con=[Select Id,Name from Contact where Id=:accid];      
            sob=new Contact();      
            sob=con;        
        }       
        else if(!String.isBlank(leadid)){        
            Lead lea=[Select Id,Name from Lead where Id=:leadid];       
            sob=new Lead();     
            sob=lea;        
        }       
        return sob;     
    }
    @AuraEnabled        
    public static sObject getCons(String conid){      
        sObject sob;        
        if(!String.isBlank(conid)){       
            Contact con=[Select Id,Name from Contact where Id=:conid];      
            sob=new Contact();      
            sob=con;        
        }  
        return sob;     
    }
    @AuraEnabled
    public static user fetchUser()
    {
      // query current user information  
      User lUser = [select id,Name FROM User Where id =: userInfo.getUserId() limit 1];
        return lUser;
    }
    public class wrapperClass
    {
        @AuraEnabled public string displayField1{Get;set;}
        @AuraEnabled public string displayField2{Get;set;}
        @AuraEnabled public string displayField3{Get;set;}
        @AuraEnabled public string recordId{Get;set;}
    }
}