public without sharing class CatalogController {
    @Auraenabled
    public static initilizeWrapper doinitialize(string Communityid,string recordtype,string sortopt,string sortfield,integer offsetcount,integer limitcount){
        initilizeWrapper iw= new initilizeWrapper();
        Id catalogRecordTypeId = Schema.SObjectType.catalog__c.getRecordTypeInfosByName().get(recordtype).getRecordTypeId();
        string query='SELECT Id, Name, Category__c,Community__c,Community__r.Name,Price__c, State__c, Status__c, Street__c, CatalogCode__c, Option__c, Model__c, IsActive__c, Catalog_Family__c, Description__c, Postal_Code__c FROM Catalog__c where RecordTypeId=\''+
           String.escapeSingleQuotes(catalogRecordTypeId)+'\' and Community__c=\''+ 
           String.escapeSingleQuotes(Communityid )+'\' order by '+
           String.escapeSingleQuotes(sortfield)+' '+
           String.escapeSingleQuotes(sortopt);
        list<catalog__c> c=database.query(query);
        list<catalog__c> cc=new list<catalog__c>();
        for(catalog__c c1:c){
            if(cc.size()<limitcount){
                cc.add(c1);
            }
        }
        iw.countofrecords=c.size();
        iw.TotalSearchcountofrecords=c.size();
        iw.countofsearchedrecords=cc.size();
        iw.recordtypeid=catalogRecordTypeId;
        iw.recordlist=cc;
        iw.offsetcount=0;
        return iw;
    }
    public class initilizeWrapper{
        @Auraenabled public integer countofsearchedrecords{get;set;}
        @Auraenabled public integer countofrecords{get;set;}
        @Auraenabled public integer offsetcount{get;set;}
        @Auraenabled public integer TotalSearchcountofrecords{get;set;}
        @Auraenabled public integer limitcount{get;set;}
        @Auraenabled public string recordtypeid{get;set;}
        @Auraenabled public string sortopt{get;set;}
        @Auraenabled public string searchstringdata{get;set;}
        @Auraenabled public list<catalog__c> recordlist{get;set;}
    }
    @Auraenabled
    public static initilizeWrapper dodelete(string Communityid,string recordtype,string delrecid){
        initilizeWrapper iw= new initilizeWrapper();
        list<catalog__c> c=[SELECT Id, Name FROM Catalog__c where id=:delrecid];
        delete c;
        Id catalogRecordTypeId = Schema.SObjectType.catalog__c.getRecordTypeInfosByName().get(recordtype).getRecordTypeId();
        list<catalog__c> c2=[SELECT Id, Name, Category__c,Community__c,Community__r.Name,  Price__c, State__c, Status__c, Street__c, CatalogCode__c, Option__c, Model__c, IsActive__c, Catalog_Family__c, Description__c, Postal_Code__c FROM Catalog__c where RecordTypeId=:catalogRecordTypeId and Community__c=:Communityid];
        iw.countofrecords=c2.size();
        iw.recordlist=c2;
        return iw;
    }
    @Auraenabled
    public static initilizeWrapper dosearchval(string Communityid,string recordtype,string sortopt,string sortfield,integer offsetcount,integer limitcount,string searchstring){
                
        offsetcount=0;
        string storesearchstringval=string.valueof(searchstring);
        initilizeWrapper iw= new initilizeWrapper();
        Id catalogRecordTypeId = Schema.SObjectType.catalog__c.getRecordTypeInfosByName().get(recordtype).getRecordTypeId();
        list<catalog__c> c= new list<catalog__c>();
        if(!string.isBlank(searchstring)){
            searchstring=searchstring+'%';
            c=[SELECT Id, Name, Category__c,Community__c,Community__r.Name,Price__c, State__c, Status__c, Street__c, CatalogCode__c, Option__c, Model__c, IsActive__c  FROM Catalog__c where name like :searchstring and RecordTypeId=:catalogRecordTypeId and Community__c=:Communityid Limit :limitcount Offset :offsetcount];
        }
        else{
            c=[SELECT Id, Name, Category__c,Community__c,Community__r.Name,Price__c, State__c, Status__c, Street__c, CatalogCode__c, Option__c, Model__c, IsActive__c FROM Catalog__c where RecordTypeId=:catalogRecordTypeId and Community__c=:Communityid Limit :limitcount Offset :offsetcount];
        }
        
        list<catalog__c> tot=[SELECT Id, Name, Category__c,Community__c,Community__r.Name,Price__c, State__c, Status__c, Street__c, CatalogCode__c, Option__c, Model__c, IsActive__c  FROM Catalog__c where name like :searchstring and RecordTypeId=:catalogRecordTypeId and Community__c=:Communityid];
        list<catalog__c> tot1=new list<catalog__c>();
        if(!string.isBlank(searchstring)){
            searchstring=searchstring+'%';
            tot1=[SELECT Id, Name, Category__c,Community__c,Community__r.Name,Price__c, State__c, Status__c, Street__c, CatalogCode__c, Option__c, Model__c, IsActive__c  FROM Catalog__c where name like :searchstring and RecordTypeId=:catalogRecordTypeId and Community__c=:Communityid ];
        }
        else{
             tot1=[SELECT Id, Name, Category__c,Community__c,Community__r.Name,Price__c, State__c, Status__c, Street__c, CatalogCode__c, Option__c, Model__c, IsActive__c FROM Catalog__c where RecordTypeId=:catalogRecordTypeId and Community__c=:Communityid ];
        }
            
        
        iw.TotalSearchcountofrecords=tot1.size();
        iw.offsetcount=offsetcount;//+limitcount;
        iw.countofsearchedrecords=c.size();
        iw.recordtypeid=catalogRecordTypeId;
        iw.recordlist=c;
        iw.searchstringdata=string.valueof(storesearchstringval);
        return iw;
    }
    @AuraEnabled
    public static initilizeWrapper dosort(string Communityid,string recordtype,string sortopt,string sortfield,integer offsetcount,integer limitcount,string searchstring){
        offsetcount=0;
        initilizeWrapper iw= new initilizeWrapper();
        Id catalogRecordTypeId = Schema.SObjectType.catalog__c.getRecordTypeInfosByName().get(recordtype).getRecordTypeId();
        string query='SELECT Id, Name, Category__c,Community__c,Community__r.Name,Price__c, State__c, Status__c, Street__c, CatalogCode__c, Option__c, Model__c, IsActive__c, Catalog_Family__c, Description__c, Postal_Code__c FROM Catalog__c where RecordTypeId=\''+
            String.escapeSingleQuotes(catalogRecordTypeId)+'\' and Community__c=\''+String.escapeSingleQuotes(Communityid )+'\'';
        if(string.isNotBlank(searchstring)){
            searchstring=searchstring+'%';
            query=query+' and Name like \''+ String.escapeSingleQuotes(searchstring)+'\'' ; 
        }         
        query=query+' order by '+sortfield+' '+sortopt;
        list<Catalog__c> searchlist=database.query(query);
        
        query=query+ ' Limit '+limitcount+' Offset '+offsetcount;
        list<catalog__c> c=database.query(query);


        iw.recordlist=c;
        iw.offsetcount=offsetcount;
        if(sortopt=='asc')iw.sortopt='desc';
        else iw.sortopt='asc';  
        iw.countofsearchedrecords=c.size();
        iw.TotalSearchcountofrecords=searchlist.size();
        return iw;
    }
    @Auraenabled
    public static initilizeWrapper doactions(string Communityid,string recordtype,string sortopt,string sortfield,integer offsetcount,integer limitcount,string searchstring,string whichaction){
        if(offsetcount==null)offsetcount=0;
        initilizeWrapper iw= new initilizeWrapper();
        if(whichaction=='Next'){
            offsetcount=offsetcount+limitcount;
        }
        if(whichaction=='Previous'){
            offsetcount=offsetcount-limitcount;
        }
        Id catalogRecordTypeId = Schema.SObjectType.catalog__c.getRecordTypeInfosByName().get(recordtype).getRecordTypeId();
        string query='SELECT Id, Name, Category__c,Community__c,Community__r.Name,Price__c, State__c, Status__c, Street__c, CatalogCode__c, Option__c, Model__c, IsActive__c FROM Catalog__c where RecordTypeId=\''+
             String.escapeSingleQuotes(catalogRecordTypeId)+'\' and Community__c=\''+String.escapeSingleQuotes(Communityid)+'\'' ;
        if(string.isNotBlank(searchstring)){
            searchstring=searchstring+'%';
            query=query+' and Name like \''+String.escapeSingleQuotes(searchstring)+'\'' ; 
        }
       
            query=query +' order by '+sortfield +' '+sortopt+' Limit '+limitcount+' Offset '+offsetcount;
        list<catalog__c> c=database.query(query);
        iw.countofsearchedrecords=offsetcount+c.size();
        iw.recordlist=c;
        iw.offsetcount=offsetcount;

             
        return iw;
    }
    
    
    //to check for the object level permissions of a profile
     @Auraenabled
    public static permissionWrapper docheckpermissionforprofile(string objectname){
        string userprofile=userinfo.getProfileId();
        string resp;
        permissionWrapper pw = new permissionWrapper();
        map<boolean,boolean> mapst= new map<boolean,boolean>();
        list<ObjectPermissions> c=[SELECT Id, ParentId, Parent.Profile.Name, Parent.Profileid, SobjectType, PermissionsEdit,
                                   PermissionsCreate, PermissionsRead, PermissionsDelete, PermissionsViewAllRecords, 
                                   PermissionsModifyAllRecords FROM ObjectPermissions where SobjectType=:objectname and 
                                   Parent.Profileid=:userprofile];
        pw.isReadable=false;
        pw.isEditable = false;
        pw.isDelete = false;
        pw.iscreate=false;
        if(c.size()>0){
            //mapst.put(c[0].PermissionsEdit,c[0].PermissionsDelete);
            //    resp='"iseditable":'+c[0].PermissionsEdit+',"isdeleteable":'+c[0].PermissionsDelete;
            pw.isEditable = c[0].PermissionsEdit;
            pw.isDelete = c[0].PermissionsDelete;
            pw.isReadable=c[0].PermissionsRead;
            pw.iscreate=c[0].PermissionsCreate;
        }
        return pw;
    }
    
    public class permissionWrapper{
        @Auraenabled public boolean isReadable{get;set;}
        @Auraenabled public boolean isEditable{get;set;}
        @Auraenabled public boolean isDelete{get;set;}
        @Auraenabled public boolean iscreate{get;set;}
    }
   
}