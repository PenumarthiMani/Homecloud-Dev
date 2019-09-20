({
    quoteDetail : function(component, event) {
        var useraction = component.get("c.selectedQuote");        
        useraction.setParams({"RecordId" : component.get("v.recordId")});
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var resultVal = response.getReturnValue();
                component.set("v.QuoteDetails",resultVal);
                this.LotProduct(component,event);
                this.ModelProduct(component,event);
                this.OptionProduct(component,event);
            }
        });
        $A.enqueueAction(useraction);    
    },
    SelectLot : function(component, event) {
        component.set("v.showModalSpinner",true); 
        var useraction = component.get("c.availableLots");        
        useraction.setParams({"RecordId" : component.get("v.recordId"),
                              "CommunityId" : component.get("v.QuoteDetails.Community__c")
                             });
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var result = response.getReturnValue();
                component.set("v.AvailableProduct",result);
                component.set("v.showModalSpinner",false); 
            }
        });
        $A.enqueueAction(useraction);
        
    },
    SelectModel : function(component, event) {
        component.set("v.showModalSpinner",true); 
        var useraction = component.get("c.availableModels");        
        useraction.setParams({"RecordId" : component.get("v.recordId"),
                              "CommunityId" : component.get("v.QuoteDetails.Community__c")
                             });
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var result = response.getReturnValue();
                component.set("v.AvailableProduct",result);
                component.set("v.showModalSpinner",false); 
            }
        });
        $A.enqueueAction(useraction);
        
    },
    SelectOptions : function(component, event) {
        component.set("v.showModalSpinner",true); 
        var useraction = component.get("c.availableOptions");        
        useraction.setParams({"RecordId" : component.get("v.recordId"),
                              "CommunityId" : component.get("v.QuoteDetails.Community__c"),
                              "ModelId" : component.get("v.Model.Catalog__c"),
                              "Category" : component.get("v.SelectedCategory"),
                              "ProductName" : component.get("v.ProductName")                             
                             });
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var result = response.getReturnValue();
                component.set("v.AvailableOPtions",result);
                component.set("v.showModalSpinner",false); 
            }
        });
        $A.enqueueAction(useraction);	
    },
    LotProduct : function(component, event) {
        var useraction = component.get("c.selectedLot");        
        useraction.setParams({"RecordId" : component.get("v.recordId"),
                              "LotId" : component.get("v.QuoteDetails.Lot__c")
                             });
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var result = response.getReturnValue();
                component.set("v.Lot",result);
                
            }
        });
        $A.enqueueAction(useraction);	
    },
    ModelProduct : function(component, event) {
        var useraction = component.get("c.selectedModel");        
        useraction.setParams({"RecordId" : component.get("v.recordId"),
                              "ModelId" : component.get("v.QuoteDetails.Model__c")
                             });
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var result = response.getReturnValue();
                component.set("v.Model",result);
            }
        });
        $A.enqueueAction(useraction);	
    },
    OptionProduct : function(component, event) {
        var useraction = component.get("c.selectedOptions"); 
        useraction.setParams({"RecordId" : component.get("v.recordId"),
                              "ModelId" : component.get("v.Model.Id")
                             });
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var result = response.getReturnValue();
                component.set("v.Options",result);
                this.OptionGroup(component,event);
            }
        });
        $A.enqueueAction(useraction);	
    },
    OptionGroup : function(component, event) {
        var useraction = component.get("c.selectedlines");        
        useraction.setParams({"RecordId" : component.get("v.recordId"),
                              "ModelId" : component.get("v.Model.Id")
                             });
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var result = response.getReturnValue();
                component.set("v.GroupOPtions",result);
            }
        });
        $A.enqueueAction(useraction);	
    },
    UpdateLot : function(component, event) {
        var useraction = component.get("c.updateLine");        
        useraction.setParams({"Line" : component.get("v.Lot")});
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var result = response.getReturnValue();
                this.LotProduct(component,event);
            }
        });
        $A.enqueueAction(useraction);	
    },
    UpdateModel : function(component, event) {
        var useraction = component.get("c.updateLine");        
        useraction.setParams({"Line" : component.get("v.Model")});
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var result = response.getReturnValue();
                this.ModelProduct(component,event);
            }
        });
        $A.enqueueAction(useraction);	
    },
    UpdateOption : function(component, event) {
        var selectedopt = event.getSource().get("v.name");
        var useraction = component.get("c.updateOptionsLines");        
        useraction.setParams({"Lines" : component.get("v.Options"),
                              "LineId" : selectedopt
                             });
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var result = response.getReturnValue();
                this.OptionProduct(component,event);
            }
        });
        $A.enqueueAction(useraction);	
    },
    GroupOption : function(component, event) {
        var baselines = component.get("v.GroupOPtions");
        var x,y,z,q;
        var bool=false;
        for(x of baselines){
            for(y of x.InnerWapperList){
                z=y.LineDetails.Quantity__c;
                var q=z.toString();
                if(q.startsWith("-") || q.includes(".") || q=="0"){
                    bool=true;
                    break;
                }                
            }
            if(bool==true){
                break;
            }
        }
        if(bool==false){
            var selectedopt = event.currentTarget.dataset.datavalue;
            var useraction = component.get("c.UpdateLineOptions");        
            useraction.setParams({"LineItems" : JSON.stringify(baselines),
                                  "LineId" : selectedopt
                                 });
            useraction.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){ 
                    var result = response.getReturnValue();
                    if(result == 'Success')
                    {
                        this.OptionGroup(component,event);
                        component.set("v.OptionsEdit", false); 
                    }                
                }
            });
            $A.enqueueAction(useraction);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Enter a valid Quantity!",
                "type":"Error"
            });
            toastEvent.fire();
        }
    },
    DeletePopup : function(component, event) {
        component.set("v.isDeletePopup", true);
    },
    DeleteProductNo: function(component, event, helper) {
        component.set("v.isDeletePopup", false);
        if(component.get("v.isOpenedLot")==true)
            component.set("v.isOpenedLot", false);
        if(component.get("v.isOpenedModel")==true)
            component.set("v.isOpenedModel", false);
    },
    DeleteProductYes: function(component, event, helper) {
        if(component.get("v.isOpenedLot")==true){
            component.set("v.isDeletePopup", false);
            component.set("v.isOpenedLot", false);
            var useraction = component.get("c.deletelotLine");        
            useraction.setParams({"Line" : component.get("v.Lot")});
            useraction.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){ 
                    var result = response.getReturnValue();
                    if(result == 'Success')
                    {
                        component.set("v.Lot", ""); 
                        this.quoteDetail(component,event);
                    }
                }
                
            });
            $A.enqueueAction(useraction);
        }
        if(component.get("v.isOpenedModel")==true){
            component.set("v.isDeletePopup", false);
            component.set("v.isOpenedModel", false);
            var useraction = component.get("c.deleteModelLine");        
            useraction.setParams({	"RecordId" : component.get("v.recordId"),
                                  "Line" : component.get("v.Model")
                                 });
            useraction.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){ 
                    var result = response.getReturnValue();
                    if(result == 'Success')
                    {
                        component.set("v.Model","");
                        this.quoteDetail(component,event);
                    }
                }
            });
            $A.enqueueAction(useraction);
        }
    },    
    DeleteOption : function(component, event) {
        var selectedopt = event.currentTarget.dataset.datavalue;
        var useraction = component.get("c.deleteOptionLine");        
        useraction.setParams({"LineId" : selectedopt});
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var result = response.getReturnValue();
                this.OptionGroup(component,event);
            }
        });
        $A.enqueueAction(useraction);	
    },
    InsertLotModelPackage : function(component, event) {
        component.set("v.showModalSpinner",true);
        var baselines = component.get("v.AvailableProduct");
        var useraction = component.get("c.insertLotModelPackage");        
        useraction.setParams({"LineItem" : JSON.stringify(baselines),
                              "RecordId" : component.get("v.recordId")
                             });
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var result = response.getReturnValue();
                if(result == 'Success')
                {
                    this.quoteDetail(component,event);
                    component.set("v.AvailablePopUp", true);
                    component.set("v.AddModelPopUp", false); 
                    component.set("v.AvailableProduct",''); 
                    component.set("v.showModalSpinner",false);
                }    
            }
        });
        $A.enqueueAction(useraction);	
    },
    StatusValidation : function(component, event) {
        var useraction = component.get("c.ConnectionStatusValidation");        
        useraction.setParams({"RecordId" : component.get("v.recordId")});
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var resultVal = response.getReturnValue();
                if(resultVal=='Not Closed Won'){
                    component.set("v.AvailablePopUp", false);
                    component.set("v.AddModelPopUp", false);
                    component.set("v.AddOptionsPopUp", true);
                    this.CategoryOptions(component,event); 
                }
                else if(resultVal=='Closed Won'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "You cannot add Options when Connection is Closed.",
                        "type":"Error"
                    });
                    toastEvent.fire();   
                }
            }
        });
        $A.enqueueAction(useraction);    
    },
    
    CategoryOptions : function(component, event) {
        component.set("v.showModalSpinner",true); 
        var useraction = component.get("c.categorypicklist");          
        useraction.setParams({ "RecordId" : component.get("v.recordId"),
                              "ModelId" : component.get("v.Model.Catalog__c")
                             });
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var result = response.getReturnValue();
                console.log('@@@'+result);
                component.set("v.Categories",result);
                component.set("v.showModalSpinner",false); 
            }
        });
        $A.enqueueAction(useraction);	
    },
    InsertOptionProducts : function(component, event) {
        component.set("v.showModalSpinner",true);
        var baselines = component.get("v.AvailableOPtions");
        var useraction = component.get("c.insertOptions");        
        useraction.setParams({"LineItem" : JSON.stringify(baselines),
                              "RecordId" : component.get("v.recordId"),
                              "ModelId" : component.get("v.Model.Id")
                             });
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var result = response.getReturnValue();
                this.quoteDetail(component,event);
                this.SelectOptions(component,event);
                component.set("v.showModalSpinner",false);
            }            
        });
        $A.enqueueAction(useraction);	
    },
    SelectionControl : function(component, event) {
        var selectedpro = event.getSource().get("v.name");
        var selectedval = event.getSource().get("v.value"); 
        if(selectedpro != null && selectedval == true) 
        {    
            var optionList = component.get("v.AvailableProduct"); 
            var newlst =[];
            for(var i in optionList){
                var option = optionList[i];
                if(option.ProductDetails.Id == selectedpro && option.Checkbox == selectedval)  
                    option.Checkbox = true;
                else
                    option.Checkbox = false;
                newlst.push(option);
            } 
            component.set("v.AvailableProduct",newlst);
        }    
    },
    Groupvalues : function(component, event) {
        component.set("v.showModalSpinner",true);
        var useraction = component.get("c.groupPicklist");        
        useraction.setParams({"RecordId" : component.get("v.recordId")});
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var result = response.getReturnValue();
                component.set("v.GroupTypes",result);
                
            }
        });
        $A.enqueueAction(useraction);	
    },
    UnGroupedLines : function(component, event) {
        component.set("v.showModalSpinner",true);
        var useraction = component.get("c.ungroupedQuoteLines");        
        useraction.setParams({"RecordId" : component.get("v.recordId"),
                              "ModelId" : component.get("v.Model.Id")
                             });
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var result = response.getReturnValue();
                component.set("v.AvailableOPtions",result);
                component.set("v.showModalSpinner",false); 
            }
        });
        $A.enqueueAction(useraction);	
    },
    TieWithGroups : function(component, event) {
        var baselines = component.get("v.AvailableOPtions");
        var useraction = component.get("c.tieToGroups");        
        useraction.setParams({"RecordId" : component.get("v.recordId"),
                              "GroupId" : component.get("v.GroupName"),
                              "Name" : component.get("v.Type"),
                              "Lines" : JSON.stringify(baselines)
                             });
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var result = response.getReturnValue();
                if(result == 'Success')
                {
                    component.set("v.GroupName",'');
                    component.set("v.GroupTypes",'');
                    component.set("v.Type",''); 
                    this.Groupvalues(component,event);
                    this.UnGroupedLines(component,event);
                    this.OptionGroup(component,event); 
                    
                }
            }
        });
        $A.enqueueAction(useraction);	
    },
    RemoveFromGroup : function(component, event) {
        var selectedopt = event.currentTarget.dataset.datavalue;
        var useraction = component.get("c.removeFromGroup");        
        useraction.setParams({"LineId" : selectedopt});
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var result = response.getReturnValue();
                if(result == 'Success')
                {
                    this.OptionGroup(component,event);
                }    
            }
        });
        $A.enqueueAction(useraction);	
    },
    CancelSubPopUps : function(component, event) {
        component.set("v.AvailablePopUp", true);
        component.set("v.AddModelPopUp", false); 
        component.set("v.AddOptionsPopUp",false);
        component.set("v.GropingPopUp",false); 
        component.set("v.Type",''); 
        component.set("v.ProductName",'');
        component.set("v.Categories",'');
        component.set("v.SelectedCategory",'');
        component.set("v.GroupName",'');
        component.set("v.GroupTypes",'');
    },
})