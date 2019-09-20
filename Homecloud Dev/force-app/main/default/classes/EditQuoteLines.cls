Public without sharing Class EditQuoteLines{
    @AuraEnabled
    Public Static Scenario__c selectedQuote(String RecordId)
    {
        Scenario__c Qtdetails = New Scenario__c();
        Qtdetails = [Select Id, Lot__c, Model__c, Package__c, Community__c, Status__c, RecordType.Name from Scenario__c where Id =: RecordId];
        return Qtdetails;
    } 
    @AuraEnabled 
    Public Static Option__c selectedLot(String RecordId, String LotId)
    {
        Option__c lotProduct = New Option__c();
        if(LotId <> null){
           lotProduct = [Select Id, Scenario__c, Catalog__c, Catalog__r.Name, Catalog__r.CatalogCode__c, Notes__c, UnitPrice__c, NetAmount__c, Quantity__c, Discount__c from Option__c where Scenario__c =: RecordId and Catalog__c =: LotId]; 
        }
        return lotProduct;
    }
    @AuraEnabled
    Public Static Option__c selectedModel(String RecordId, String ModelId)
    {
        Option__c modelProduct = New Option__c();
        if(ModelId <> null)
            modelProduct = [Select Id, Catalog__c, Catalog__r.Name, Catalog__r.CatalogCode__c, Notes__c, UnitPrice__c, Quantity__c, NetAmount__c, Discount__c from Option__c where Scenario__c =: RecordId and Catalog__c =: ModelId];
        return modelProduct;
    }
    @AuraEnabled
    Public Static List<Option__c> selectedOptions(String RecordId, String ModelId)
    {
        Id ModelOptionRecordType=RecordTypeUtil.ModelOptionrecordtypename();
        List<Option__c> selectedOptions  = New List<Option__c>();
        selectedOptions = [Select Id, Catalog__c, Catalog__r.Name,  Notes__c, Cancelled__c, Catalog__r.CatalogCode__c, UnitPrice__c, Subtotal__c, NetAmount__c, Quantity__c, Discount__c from Option__c where Scenario__c =: RecordId and ((Required_By__c =: ModelId and Catalog__r.recordtypeId=:ModelOptionRecordType) OR Catalog__r.Global__c = True)];
        return selectedOptions;
    }
    @AuraEnabled
    Public Static List<WapperClass> availableLots(String RecordId, String CommunityId)
    {
        Scenario__c sc = [Select id, RecordType.DeveloperName from Scenario__c where Id =: RecordId];
        Id LotRecordType=RecordTypeUtil.Lotrecordtypename();
        List<Catalog__c> lotProducts = New List<Catalog__c>(); 
        String lotQuery = 'Select Id, Name, Price__c, Status__c, CatalogCode__c, RecordtypeId, Community__c, Category__c, SubCategory__c from Catalog__c where IsActive__c = True and RecordtypeId = \''+ LotRecordType+'\' and Community__c = \''+ CommunityId+'\' and Status__c <> \'Closed\' and Status__c <> \'Reserved\'';
        if(sc.RecordType.DeveloperName == 'Spec_Quote') lotQuery = lotQuery + ' and Status__c <> \'Spec\'';
        lotProducts = database.query(lotQuery); system.debug('lotProducts:'+lotProducts);
        List<WapperClass> WapperOptions = New List<WapperClass>();
        for(Catalog__c Prod: lotProducts)
        {
            WapperClass Wc= New WapperClass();
            Wc.ProductDetails = Prod;
            Wc.Checkbox = False;
            Wc.UnitPrice = Prod.Price__c;
            Wc.Discount = 0;
            Wc.Quantity = 1;
            WapperOptions.add(Wc);
        }
        return WapperOptions;
    }
    @AuraEnabled
    Public Static List<WapperClass> availableModels(String RecordId, String CommunityId)
    {
        Id ModelRecordType=RecordTypeUtil.Modelrecordtypename();
        List<Catalog__c> modelProducts = New List<Catalog__c>();
        modelProducts = [Select Id, Name, Status__c, Price__c, CatalogCode__c, RecordtypeId, Community__c, Category__c, SubCategory__c from Catalog__c where IsActive__c = True and RecordtypeID =: ModelRecordType and  Community__c =: CommunityId];
        List<WapperClass> WapperOptions = New List<WapperClass>();
        for(Catalog__c Prod: modelProducts)
        {
            WapperClass Wc= New WapperClass();
            Wc.ProductDetails = Prod;
            Wc.UnitPrice = Prod.Price__c;
            Wc.Checkbox = False;
            Wc.Discount = 0;
            Wc.Quantity = 1;
            WapperOptions.add(Wc);
        }
        return WapperOptions;
    }
    
    @AuraEnabled
    Public Static List<WapperClass> availableOptions(String RecordId, String CommunityId, String ModelId, String Category, String ProductName)
    {
        List<Catalog__c> modelOptions = New List<Catalog__c>();
        Id RecordType = RecordTypeUtil.ModelOptionrecordtypename();
        System.debug('**** COMMUNITY ***** '+CommunityId);
        String qry = 'Select Id, Name, Price__c, CatalogCode__c, Recordtype.DeveloperName, Community__c, Category__c, SubCategory__c, Option__c from Catalog__c where IsActive__c = True '; 
        if(ModelId <> null) 
            qry += ' and ((RecordTypeId = \''+String.escapeSingleQuotes(RecordType)+'\' and Model__c = \''+String.escapeSingleQuotes(ModelId)+'\' and Option__r.IsActive__c = True) OR (Community__c = \''+CommunityId+'\' and Global__c = True))'; 
        else
            qry += ' and Community__c = \''+String.escapeSingleQuotes(CommunityId)+'\' and Global__c = True'; 
        
        if(Category <> null) qry += ' and Category__c = \''+String.escapeSingleQuotes(Category)+'\'';
        if(ProductName <> Null && ProductName <> '')
            qry +=  ' and (Name Like \'%'+String.escapeSingleQuotes(ProductName)+'%\' Or CatalogCode__c Like \'%'+String.escapeSingleQuotes(ProductName)+'%\')';
        
        system.debug('***** QUERY *****'+qry);
        modelOptions = Database.Query(qry);
        List<WapperClass> WapperOptions = New List<WapperClass>();
        for(Catalog__c Prod: modelOptions){
            WapperClass Wc= New WapperClass();
            Wc.ProductDetails = Prod;
            Wc.UnitPrice = Prod.Price__c;
            Wc.Discount = 0;
            Wc.Quantity = 1;
            Wc.Checkbox = False;
            WapperOptions.add(Wc);
        }
        return WapperOptions;
    }
    @AuraEnabled
    Public Static List<Wapperclass> selectedOptions(String RecordId, List<WapperClass> Options)
    {
        List<Option__c> LineItems = New List<Option__c>();
        for(WapperClass Wc: Options)
        {
            Option__c Line = New Option__c();
            if(Schema.sObjectType.Option__c.fields.Scenario__c.isAccessible())
                Line.Scenario__c = RecordId;
            if(Schema.sObjectType.Option__c.fields.Catalog__c.isUpdateable())
                Line.Catalog__c = Wc.ProductDetails.Id;
            if(Schema.sObjectType.Option__c.fields.Quantity__c.isUpdateable())
                Line.Quantity__c = Wc.Quantity;
            LineItems.add(Line);
        }
        if(!LineItems.IsEmpty()){
            if(Schema.sObjectType.Option__c.isCreateable())
                Insert LineItems;
        }
        return null;
    }
    @AuraEnabled
    Public Static Option__c updateLine(Option__c Line)
    {
        Option__c QtLine= New Option__c();
        QtLine.Id = Line.id;
        if(Schema.sObjectType.Option__c.fields.UnitPrice__c.isUpdateable())
            QtLine.UnitPrice__c = Line.UnitPrice__c;
        if(Schema.sObjectType.Option__c.fields.Subtotal__c.isUpdateable())
            QtLine.Subtotal__c = (Line.UnitPrice__c * Line.Quantity__c) - Line.Discount__c;
        if(Schema.sObjectType.Option__c.isUpdateable())
            Update QtLine;
        return QtLine;
    }
    @AuraEnabled
    Public Static List<Option__c> updateOptionsLines(List<Option__c> Lines, String LineId)
    {
        List<Option__c> QuoteLines = New List<Option__c>();
        for(Option__c QtLine: Lines)
        {
            if(QtLine.Id == LineId)
            {
                Option__c Line = New Option__c();
                Line.Id = QtLine.Id;
                if(Schema.sObjectType.Option__c.fields.Quantity__c.isUpdateable())
                    Line.Quantity__c = QtLine.Quantity__c;
                if(Schema.sObjectType.Option__c.fields.Notes__c.isUpdateable())
                    Line.Notes__c = QtLine.Notes__c;
                if(QtLine.Cancelled__c){
                    if(Schema.sObjectType.Option__c.fields.Cancelled__c.isUpdateable())
                        Line.Cancelled__c = True;
                }
                QuoteLines.add(Line);    
            }
        }
        if(!QuoteLines.IsEmpty())            
            if(Schema.sObjectType.Option__c.isUpdateable())
            Update QuoteLines;
        return Lines;
    }
    @AuraEnabled
    Public Static String deletelotLine(Option__c Line)
    {
        try
        { 
            if(Schema.sObjectType.Scenario__c.isUpdateable() && Schema.sObjectType.Scenario__c.fields.Lot__c.isUpdateable()){
                Scenario__c sc = new Scenario__c(Id = Line.Scenario__c, Lot__c = null);
                update sc;
            }    
            if(Schema.sObjectType.Option__c.isDeletable())
                Delete Line;
            return 'Success';
        }
        catch(Exception e){
            return e.getMessage();
        }    
    }
    @AuraEnabled
    Public Static String deleteModelLine(String RecordId, Option__c Line)
    {
        try
        {
            List<Option__c> Quotelines = New List<Option__c>();
            QuoteLines = [Select Id, Scenario__c, Required_By__c from Option__c where Required_By__c =: Line.Id];
            QuoteLines.add(Line);
            List<Scenario_Group__c> QtGroups = New List<Scenario_Group__c>();
            QtGroups = [Select Id from Scenario_Group__c where Scenario__c =: RecordId and Scenario__c <> Null];
            
            if(Schema.sObjectType.Scenario__c.isUpdateable() && Schema.sObjectType.Scenario__c.fields.Model__c.isUpdateable()){
                Scenario__c sc = new Scenario__c(Id = RecordId, Model__c = null);
                update sc;
            }
            if(Schema.sObjectType.Option__c.isDeletable())
                Delete QuoteLines;
            if(!QtGroups.isEmpty())
                if(Schema.sObjectType.Scenario_Group__c.isDeletable())
                Delete QtGroups;
            return 'Success';
        }
        catch(Exception e){
            return e.getMessage();
        }    
    }
    @AuraEnabled
    Public Static String deleteOptionLine(List<Option__c> Lines, String LineId)
    {
        List<Option__c> QuoteLine = New List<Option__c>();
        try
        {
            QuoteLine = [Select Id from Option__c where Id =: LineId];
            if(!QuoteLine.IsEmpty()){
                if(Schema.sObjectType.Option__c.isDeletable())
                    Delete QuoteLine;
            }
            return 'Success';
        }
        catch(Exception e){
            return e.getMessage();
        }
    }
    @AuraEnabled
    Public Static String insertLotModelPackage(String LineItem, String RecordId)
    {
        Id OptionRecordType = RecordTypeUtil.Optionrecordtypename();
        Id LotRecordType = RecordTypeUtil.Lotrecordtypename();
        Id ModelRecordType = RecordTypeUtil.Modelrecordtypename();
        Id ModelOption = RecordTypeUtil.ModelOptionrecordtypename();
        Id SpecQuoteId = RecordTypeUtil.scenariospecrecordtypename();
        Scenario__c sc = [select id, Name, RecordType.Name, RecordType.DeveloperName from Scenario__c where Id =: RecordId];
        List<WapperClass> WapperLines = (List<WapperClass>)JSON.deserialize(LineItem, List<WapperClass>.class);
        List<Option__c> InsertQuoteLines = New List<Option__c>();
        Set<Id> ProductIds = new Set<Id>();
        String Type;
        Boolean Spec = False;
        try{
            for(WapperClass Wc: WapperLines){
                if(Wc.Checkbox){
                    if(Wc.ProductDetails.RecordTypeId == ModelRecordType)
                        Type = 'Model';
                    else if(Wc.ProductDetails.RecordTypeId == LotRecordType){  
                        Type = 'Lot';
                        if(Wc.ProductDetails.Status__c == 'Spec') Spec = True;
                    }
                    else if(Wc.ProductDetails.RecordTypeId == OptionRecordType){  
                        Type = 'Option';
                    }
                    else
                        Type = 'Model Options';
                    
                    Option__c opt = new Option__c();
                    if(Schema.sObjectType.Option__c.fields.Scenario__c.isAccessible())
                        opt.Scenario__c = RecordId;
                    if(Schema.sObjectType.Option__c.fields.Catalog__c.isUpdateable())
                        opt.Catalog__c = Wc.ProductDetails.Id;
                    if(Schema.sObjectType.Option__c.fields.UnitPrice__c.isUpdateable())
                        opt.UnitPrice__c = Wc.UnitPrice;
                    if(Schema.sObjectType.Option__c.fields.Discount__c.isUpdateable())
                        opt.Discount__c = Wc.Discount;
                    if(Schema.sObjectType.Option__c.fields.Quantity__c.isUpdateable())
                        opt.Quantity__c = Wc.Quantity;
                    if(Schema.sObjectType.Option__c.fields.Subtotal__c.isUpdateable())
                        opt.Subtotal__c = (Wc.UnitPrice * Wc.Quantity) - Wc.Discount;
                    if(Schema.sObjectType.Option__c.fields.Type__c.isUpdateable())
                        opt.Type__c = Type;
                    InsertQuoteLines.add(opt);
                    ProductIds.add(Wc.ProductDetails.Id);
                }          
            }
            system.debug('*** QUOTE LINES ***'+insertQuoteLines);
            system.debug('*** SPEC ***'+Spec+' *** '+ProductIds);
            if(Spec && !ProductIds.IsEmpty()){
                List<Scenario__c> specQuote = [Select Id, (Select Id, Catalog__c, Notes__c, Quantity__c, Scenario__c, UnitPrice__c, Subtotal__c, NetAmount__c, Type__c, Group__c, Group_Name__c from Option__r where Cancelled__c = False) from Scenario__c where Lot__c IN: ProductIds and RecordTypeId =: specQuoteId and Status__c <> 'Converted'];
                List<Scenario_Group__c> scenarioGroup = [select id, Name from Scenario_Group__c where Scenario__r.Lot__c IN: ProductIds and Scenario__r.RecordTypeId =: specQuoteId and Scenario__r.Status__c <> 'Converted'];
                
                DescribeSObjectResult scenarioIncetiveDescribeResult = Scenario_Incentive__c.getSObjectType().getDescribe();
                List<String> scenarioIncentiveFieldNames = new List<String>( scenarioIncetiveDescribeResult.fields.getMap().keySet() );
                String scenarioIncentiveQuery = ' SELECT ' + String.join( scenarioIncentiveFieldNames, ',' ) + ' FROM ' + scenarioIncetiveDescribeResult.getName() +' WHERE Scenario__r.Lot__c IN: ProductIds and Scenario__r.RecordTypeId =\''+ specQuoteId+'\' and Scenario__r.Status__c <> \'Converted\'';
                system.debug('@@@@'+scenarioIncentiveQuery);
                List<Scenario_Incentive__c> scenarioIncentives = Database.query( scenarioIncentiveQuery );
            
                Option__c ModelLine = New Option__c();
                Option__c LotLine = New Option__c();
                List<Option__c> OptionLines = New List<Option__c>();
                String previousScenarioId = null;
                for(Scenario__c Qt : SpecQuote){ 
                    for(Option__c Line: Qt.Option__r){
                        if(previousScenarioId == null) previousScenarioId = line.Scenario__c;
                        if(Line.Type__c == 'Model Options'){
                            Option__c QLine = New Option__c();
                            QLine = Line.Clone();
                            if(Schema.sObjectType.Option__c.fields.Scenario__c.isAccessible())
                                QLine.Scenario__c = RecordId;
                            OptionLines.add(QLine);
                        }
                        else if(Line.Type__c == 'Model'){
                            ModelLine = Line.Clone();
                            if(Schema.sObjectType.Option__c.fields.Scenario__c.isAccessible())
                                ModelLine.Scenario__c = RecordId;
                        }
                        else if(Line.Type__c == 'Lot'){
                            LotLine = Line.Clone(false,false,false,false);
                            if(Schema.sObjectType.Option__c.fields.Scenario__c.isAccessible())
                                LotLine.Scenario__c = RecordId;
                        }
                    }
                }
                Scenario__c QtDetails = New Scenario__c();    
                QtDetails.Id = RecordId;
                QtDetails.Previous_Scenario__c = previousScenarioId;
                if(LotLine.Type__c <> Null){
                    if(Schema.sObjectType.Option__c.isCreateable())
                        Insert LotLine;
                    if(Schema.sObjectType.Scenario__c.fields.Lot__c.isUpdateable())
                        QtDetails.Lot__c = LotLine.Catalog__c;                    
                }    
                if(ModelLine.Type__c <> Null){
                    if(Schema.sObjectType.Option__c.isCreateable())
                        Insert ModelLine;
                    if(Schema.sObjectType.Scenario__c.fields.Model__c.isUpdateable())
                        QtDetails.Model__c = ModelLine.Catalog__c;
                }
                if(Schema.sObjectType.Scenario__c.isUpdateable())
                    Update QtDetails;
                
                Map<String, Id> scenarioGroupMap = new Map<String, Id>();
                if(!scenarioGroup.isEmpty()){
                    List<Scenario_Group__c> groupRecords = new List<Scenario_Group__c>();
                    for(Scenario_Group__c sg : scenarioGroup){
                        groupRecords.add(new Scenario_Group__c(Name = sg.Name, Scenario__c = recordId));
                    }
                    insert groupRecords;
                    
                    for(Scenario_Group__c sg : groupRecords){
                        scenarioGroupMap.put(sg.Name, sg.Id);
                    }
                }   
                if(ModelLine.Id <> Null && !OptionLines.IsEmpty() && Schema.sObjectType.Option__c.isCreateable()){
                    for(Option__c QLines: OptionLines){
                        if(Schema.sObjectType.Option__c.fields.Required_By__c.isUpdateable())
                            QLines.Required_By__c = ModelLine.Id;
                        if(QLines.Group__c <> null && scenarioGroupMap.containsKey(QLines.Group__c)){
                            QLines.Group__c = scenarioGroupMap.get(QLines.Group__c);
                        }    
                    }
                    insert OptionLines;
                } 
                if(!scenarioIncentives.isEmpty() && Schema.sObjectType.Option__c.isCreateable()){
                    List<Scenario_Incentive__c> scenarioIncentiveRecords = new List<Scenario_Incentive__c>();
                    for(SCenario_Incentive__c inv : scenarioIncentives){
                        Scenario_Incentive__c si = inv.clone(false, false);
                        si.Scenario__c = RecordId;
                        scenarioIncentiveRecords.add(si);
                    }
                    insert scenarioIncentiveRecords;
                }     
            }
            else
            {         
                if(Schema.sObjectType.Option__c.isCreateable())
                    Insert InsertQuoteLines;
                if(Type == 'Model' || Type == 'Lot' || Type == 'Package')
                {
                    Scenario__c updateQuote = new Scenario__c();
                    updateQuote.Id = RecordId;
                    if(Type == 'Model'){
                        if(Schema.sObjectType.Scenario__c.fields.Model__c.isUpdateable())
                            UpdateQuote.Model__c = InsertQuoteLines[0].Catalog__c;
                    }
                    else if(Type == 'Lot'){
                        if(Schema.sObjectType.Scenario__c.fields.Lot__c.isUpdateable())
                            UpdateQuote.Lot__c = insertQuoteLines[0].Catalog__c;
                        if(sc.RecordTypeId == SpecQuoteId){
                            Catalog__c ct = new Catalog__c();                            
                            ct.Id = InsertQuoteLines[0].Catalog__c;
                            if(Schema.sObjectType.Catalog__c.fields.Status__c.isUpdateable())
                                ct.Status__c = 'Spec';
                            if(Schema.sObjectType.Catalog__c.isUpdateable())
                                update ct; 
                        }   
                    }    
                    if(Schema.sObjectType.Scenario__c.isUpdateable())
                        Update UpdateQuote;
                }
            }
            return 'Success';
        }
        catch(Exception e){
            return string.valueof(e.getLineNumber() +' & '+e.getMessage()); 
        }
    }
    @AuraEnabled
    Public Static String insertOptions(String LineItem, String RecordId, String ModelId)
    {
        List<WapperClass> WapperLines = (List<WapperClass>)JSON.deserialize(LineItem, List<WapperClass>.class);
        List<Option__c> InsertQuoteLines = New List<Option__c>();
        Set<Id> ProductIds = New Set<Id>();
        // Map<Id,Id> PriceEntries = New Map<Id,Id>();
        try
        {
            for(WapperClass Wc: WapperLines)
            {
                if(Wc.Checkbox) {   
                    Option__c opt=new Option__c();
                    if(Schema.sObjectType.Option__c.fields.Required_By__c.isUpdateable())
                        opt.Required_By__c = ModelId;
                    if(Schema.sObjectType.Option__c.fields.Scenario__c.isAccessible())
                        opt.Scenario__c = RecordId;
                    if(Schema.sObjectType.Option__c.fields.Catalog__c.isUpdateable())
                        opt.Catalog__c = Wc.ProductDetails.Id;
                    if(Schema.sObjectType.Option__c.fields.UnitPrice__c.isUpdateable())
                        opt.UnitPrice__c = Wc.UnitPrice;
                    if(Schema.sObjectType.Option__c.fields.Discount__c.isUpdateable())
                        opt.Discount__c = Wc.Discount;
                    if(Schema.sObjectType.Option__c.fields.Quantity__c.isUpdateable())
                        opt.Quantity__c = Wc.Quantity; 
                    if(Schema.sObjectType.Option__c.fields.Subtotal__c.isUpdateable())
                        opt.Subtotal__c = (Wc.UnitPrice * Wc.Quantity) - Wc.Discount;
                    if(Schema.sObjectType.Option__c.fields.Type__c.isUpdateable())
                        opt.Type__c = 'Model Options';
                    InsertQuoteLines.add(opt);
                    // InsertQuoteLines.add(New Option__c(Required_By__c = ModelId, Scenario__c = RecordId, Catalog__c = Wc.ProductDetails.Id, UnitPrice__c = Wc.UnitPrice, Discount__c = Wc.Discount, Quantity__c = Wc.Quantity, Subtotal__c = (Wc.UnitPrice * Wc.Quantity) - Wc.Discount, Type__c = 'Model Options'));       
                    ProductIds.add(Wc.ProductDetails.Id);
                }          
            }
            if(!InsertQuoteLines.IsEmpty())
            {          
                if(Schema.sObjectType.Option__c.isCreateable())
                    Insert InsertQuoteLines;
            }
            return 'Success';
        }
        catch(Exception e){
            return e.getMessage();
        }
    }
     @AuraEnabled
    Public Static String ConnectionStatusValidation(String RecordId)
    {  
         Scenario__c sc = [select id, Name, Community__c,Connection__c from Scenario__c where Id =: RecordId];
            Connection__c con=[Select Id,Name,Status__c from Connection__c where Id=:sc.Connection__c];
        if(con.Status__c=='Closed Won'){
            return 'Closed Won';
        }
        else{
            return'Not Closed Won';
        }
    }
    @AuraEnabled
    Public Static List<PicklistWrap> categorypicklist(String RecordId, String ModelId)
    {       
        Scenario__c sc = [select id, Name, Community__c,Connection__c from Scenario__c where Id =: RecordId];
        AggregateResult[] groupedResults = [SELECT Category__c, Count(Id) recordCount from Catalog__c where IsActive__c = True and Community__c =: sc.Community__c and ((Recordtype.Developername = 'Model_Options' and Model__c =: ModelId) OR (Community__c =: sc.Community__c and Global__c = True)) Group By Category__c];
        Set<String> availableCategories = New Set<String>();
        List<PicklistWrap> categoryOptions = new List<PicklistWrap>();
        for(AggregateResult ar : groupedResults)
        {
            if(String.Valueof(ar.get('Category__c')) <> Null && String.Valueof(ar.get('Category__c')) <> '' && Integer.valueOf(ar.get('recordCount')) > 0)
            {
                availableCategories.add(String.ValueOf(ar.get('Category__c'))); 
            }
        }
        categoryOptions.add(new picklistWrap('--None-',''));
        
        for(String Str: availableCategories)
        {
            categoryOptions.add(new picklistWrap(Str, Str));
        }
        return categoryOptions;        
    }
    @AuraEnabled
    Public Static List<InnerClass> selectedlines(String RecordId, String ModelId)
    {
        Id ModelOptionRecordType=RecordTypeUtil.ModelOptionrecordtypename();
        List<Option__c> selectedOptions  = New List<Option__c>();
        List<InnerClass> InnerLines = New List<InnerClass>();
        Map<String, List<Option__c>> MapLines = New Map<String, List<Option__c>>();
        selectedOptions = [Select Id, name,Catalog__c, Group__c, Catalog__r.Name,  Notes__c, Cancelled__c, Catalog__r.CatalogCode__c, UnitPrice__c, Quantity__c, Subtotal__c, NetAmount__c, Discount__c, Group__r.Name from Option__c where Scenario__C =: RecordId and ((Required_By__c =: ModelId and Catalog__r.RecordTypeId=:ModelOptionRecordType) OR Catalog__r.Global__c = True) Order by Group__r.createddate Asc Nulls Last];
        system.debug('selectedOptions:'+selectedOptions);
        for(Option__c Line: selectedOptions)
        { system.debug('Line:'+Line.Group__c+' name:'+Line.Group__r.name);
            String GroupName;
            if(!Line.Cancelled__c)
            {
                if(Line.Group__c == Null)
                    GroupName = '--';  
                else
                    GroupName = Line.Group__r.Name;      
                if(MapLines.ContainsKey(GroupName))
                {
                    List<Option__c> Existing = New List<Option__c>();
                    Existing.addAll(MapLines.get(GroupName));
                    Existing.add(Line);
                    MapLines.Put(GroupName, Existing);
                }
                else
                {
                    List<Option__c> Existing = New List<Option__c>();
                    Existing.add(Line);
                    MapLines.Put(GroupName,Existing);
                }
            }
            else
            {
                
                Line.Group__c = null;
                if(MapLines.ContainsKey('Cancelled'))
                {
                    List<Option__c> Existing = New List<Option__c>();
                    Existing.addAll(MapLines.get('Cancelled'));
                    Existing.add(Line);
                    MapLines.Put('Cancelled', Existing);
                }
                else
                {
                    List<Option__c> Existing = New List<Option__c>();
                    Existing.add(Line);
                    MapLines.Put('Cancelled',Existing);
                }
            }    
        }
        List<InnerClass> emptyGroup = new List<InnerClass>();
        List<InnerClass> cancelledGroup = new List<InnerClass>();
        List<InnerClass> groupedRecords = new List<InnerClass>();
        if(!MapLines.KeySet().isEmpty())
        {
            for(String Str: MapLines.KeySet())
            {
                InnerClass InnerDetails = New InnerClass();
                InnerDetails.GroupName = Str;
                List<Option__c> Existing = New List<Option__c>();
                Existing.addAll(MapLines.get(Str));
                List<WapperClass> Wapper = New List<WapperClass>();
                for(Option__c QLine: Existing)
                {
                    WapperClass Wp = New WapperClass();
                    Wp.LineDetails = QLine;
                    Wapper.add(Wp);
                }
                InnerDetails.InnerWapperList.addAll(Wapper); 
                if(Str == '--') emptyGroup.add(InnerDetails); 
                else if(Str == 'Cancelled') cancelledGroup.add(InnerDetails); 
                else groupedRecords.add(InnerDetails); 
            }
        }
        InnerLines.addAll(emptyGroup);
        InnerLines.addAll(groupedRecords);
        InnerLines.addAll(cancelledGroup);
        return InnerLines;
    }
    @AuraEnabled
    Public Static String UpdateLineOptions(String LineItems, String LineId)
    {
        try
        {
            List<InnerClass> InnerWapperLines = (List<InnerClass>)JSON.deserialize(LineItems, List<InnerClass>.class);
            system.debug('InnerWapperLines:::::'+InnerWapperLines);
            Option__c QtLine = New Option__c();
            for(InnerClass Ic: InnerWapperLines)
            { system.debug('ic:'+ic);
                List<WapperClass> WapperLines = New List<WapperClass>();
                WapperLines.addAll(Ic.InnerWapperList); system.debug('WapperLines:'+WapperLines);
                for(WapperClass Wc: WapperLines)
                {
                    if(Wc.LineDetails.Id == LineId)
                    {
                        QtLine.Id = Wc.LineDetails.Id;
                        if(Schema.sObjectType.Option__c.fields.Quantity__c.isUpdateable())
                            QtLine.Quantity__c = Wc.LineDetails.Quantity__c;
                        if(Schema.sObjectType.Option__c.fields.Notes__c.isUpdateable())
                            QtLine.Notes__c = Wc.LineDetails.Notes__c;
                        if(Schema.sObjectType.Option__c.fields.Cancelled__c.isUpdateable())
                            QtLine.Cancelled__c = Wc.LineDetails.Cancelled__c;
                        if(QtLine.Cancelled__c )
                        {
                            if(Schema.sObjectType.Option__c.fields.Group__c.isUpdateable()){
                                QtLine.Group__c = null;
                            }    
                            if(Schema.sObjectType.Option__c.fields.Cancelled_Date__c.isUpdateable())
                                QtLine.Cancelled_Date__c = System.Today();
                        }
                        break;
                        break;
                    }
                }
            }
            if(Schema.sObjectType.Option__c.isUpdateable())
                Update QtLine;
            return 'Success';
        }
        catch(Exception e){
            return e.getMessage(); 
        }
    }
    @AuraEnabled
    Public Static List<PicklistWrap> groupPicklist(String RecordId)
    {
        List<Scenario_Group__c> GroupLines = New List<Scenario_Group__c>();
        GroupLines = [Select Id, Name from Scenario_Group__c where Scenario__c =: RecordId order by Name Asc];
        List<PicklistWrap> groupPicklist = new List<PicklistWrap>();
        groupPicklist.add(New picklistWrap('','--None--'));
        groupPicklist.add(New picklistWrap('Create Group','Create Group'));
        for(Scenario_Group__c Grp : GroupLines)
        {
            if(!String.IsBlank(Grp.Name))
            {
                groupPicklist.add(new picklistWrap(Grp.Id,Grp.Name));
            }
        }
        return groupPicklist;
    }
    @AuraEnabled
    Public Static List<WapperClass> ungroupedQuoteLines(String RecordId, String ModelId)
    {
        Id ModelOptionRecordType=RecordTypeUtil.ModelOptionrecordtypename();
        List<WapperClass> Wapperlist = New List<WapperClass>();
        List<Option__c> QtLines = New List<Option__c>();
        QtLines = [Select Id, Catalog__c, Catalog__r.Name,  Notes__c, Cancelled__c, Catalog__r.CatalogCode__c, UnitPrice__c, Quantity__c, Discount__c, Subtotal__c, NetAmount__c from Option__c where Cancelled__c = False and Scenario__c =: RecordId and ((Required_By__c =: ModelId and Catalog__r.recordtypeId =: ModelOptionRecordType) OR Catalog__r.Global__c = True) and Group__c = Null ];
        for(Option__c line: QtLines)
        {
            WapperClass Wc = New WapperClass();
            Wc.LineDetails = line;
            Wc.Checkbox = False;
            Wapperlist.add(Wc);
        }
        return Wapperlist;
    }
    @AuraEnabled
    Public Static String tieToGroups(String RecordId, String GroupId, String Name, String Lines)
    {
        try
        {
            List<WapperClass> WapperLines = (List<WapperClass>)JSON.deserialize(Lines, List<WapperClass>.class);
            if(Name <> Null && Name <> '')
            {
                List<Scenario_Group__c> Groupslist = New List<Scenario_Group__c>();
                Groupslist = [Select Id, Name from Scenario_Group__c where Name =: Name and Scenario__c =: RecordId];
                if(Groupslist.IsEmpty())
                {
                    Scenario_Group__c QtGroup = New Scenario_Group__c();
                    QtGroup.Name = Name;
                    if(Schema.sObjectType.Scenario_Group__c.fields.Scenario__c.isUpdateable())
                        QtGroup.Scenario__c = RecordId;
                    if(Schema.sObjectType.Scenario_Group__c.isCreateable())
                        Insert QtGroup;
                    GroupId = QtGroup.Id;
                }
                else
                    GroupId = Groupslist[0].Id;
            }
            List<Option__c> QtLines = New List<Option__c>(); 
            for(WapperClass Wc: WapperLines)
            {
                Option__c QLines = New Option__c();
                If(Wc.Checkbox)
                {    
                    QLines = Wc.LineDetails;
                    if(Schema.sObjectType.Option__c.fields.Group__c.isUpdateable())
                        QLines.Group__c = GroupId;
                    QtLines.add(QLines);  
                }      
            }
            if(!QtLines.IsEmpty()){
                if(Schema.sObjectType.Option__c.isUpdateable())
                    Update QtLines; 
            }
            return 'Success';
        }
        catch(Exception e){
            return e.getMessage();
        }
    }
    @AuraEnabled
    Public Static String removeFromGroup(String LineId)
    {
        List<Option__c> Line = New List<Option__c>();
        try
        {
            String GroupId;
            String QuoteId;
            Line = [Select Id, Scenario__c, Group__c from Option__c where Id =: LineId];
            for(Option__c QtLine: Line)
            {
                GroupId = QtLine.Group__c;
                QuoteId = QtLine.Scenario__c;
                if(Schema.sObjectType.Option__c.fields.Group__c.isUpdateable())
                    QtLine.Group__c = Null;
            }
            if(!Line.IsEmpty()){
                if(Schema.sObjectType.Option__c.isUpdateable())
                    Update Line;
            }
            List<Option__c> QtLines = New List<Option__c>(); 
            QtLines = [Select Id from Option__c where Group__c =: GroupId and Scenario__c =: QuoteId];
            if(QtLines.IsEmpty())
            {
                Scenario_Group__c QtGroup = New Scenario_Group__c();
                QtGroup.Id = GroupId;
                if(Schema.sObjectType.Option__c.isDeletable())
                    Delete QtGroup;    
            }   
            return 'Success';
        }
        catch(Exception e){
            return e.getMessage();
        }
    }
    Public Class WapperClass
    {
        @AuraEnabled Public Boolean Checkbox{get;set;}
        @AuraEnabled Public Catalog__c ProductDetails{get;set;}
        @AuraEnabled Public Decimal UnitPrice{get;set;}
        @AuraEnabled Public Decimal NetAmount{get;set;}
        @AuraEnabled Public Integer Discount{get;set;}
        @AuraEnabled Public Integer Quantity{get;set;}
        @AuraEnabled Public Option__c LineDetails{get;set;}
        Public WapperClass()
        {
            Checkbox = False;
            ProductDetails = New Catalog__c();
            Discount = 0;
        }
    }
    Public Class InnerClass
    {
        @AuraEnabled Public String GroupName{get;set;}
        @AuraEnabled Public List<WapperClass> InnerWapperList{get;set;}
        Public InnerClass()
        {
            InnerWapperList = New List<WapperClass>();
        }
    }
    public class PicklistWrap{
        @AuraEnabled public string labelVal;
        @AuraEnabled public string optionVal;
        public PicklistWrap(string option, string label){
            this.labelVal = label;
            this.optionVal = option;
        }
    }
}